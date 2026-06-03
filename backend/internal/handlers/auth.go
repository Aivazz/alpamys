package handlers

import (
	"alpamys-backend/internal/database"
	"alpamys-backend/internal/models"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type OnboardingInput struct {
	FullName         string  `json:"full_name"`
	Gender           string  `json:"gender" binding:"required"`
	FavoriteActivity string  `json:"favorite_activity" binding:"required"`
	Age              int     `json:"age" binding:"required,min=1"`
	Weight           float64 `json:"weight" binding:"required,gt=0"`
	WeightUnit       string  `json:"weight_unit" binding:"required"`
	Height           float64 `json:"height" binding:"required,gt=0"`
	HeightUnit       string  `json:"height_unit" binding:"required"`
	FitnessLevel     string  `json:"fitness_level" binding:"required"`
	Goal             string  `json:"goal" binding:"required"`
}

// SyncUser проверяет наличие Firebase UID в базе данных. Если записи нет — создает профиль.
func SyncUser(c *gin.Context) {
	firebaseUID, existsUID := c.Get("firebaseUID")
	email, existsEmail := c.Get("email")
	name, _ := c.Get("name")

	if !existsUID || !existsEmail {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing Firebase session claims"})
		return
	}

	uidStr := firebaseUID.(string)
	emailStr := email.(string)
	nameStr := ""
	if name != nil {
		nameStr = name.(string)
	}

	var user models.User
	err := database.DB.Where("id = ?", uidStr).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			user = models.User{
				ID:                  uidStr,
				Email:               emailStr,
				FullName:            nameStr,
				OnboardingCompleted: false,
			}
			if createErr := database.DB.Create(&user).Error; createErr != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create local user profile: " + createErr.Error()})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error: " + err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User synchronized successfully",
		"user":    user,
	})
}

// SaveOnboarding сохраняет метрики онбординга и автоматически генерирует тренировочный план
func SaveOnboarding(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uidStr := firebaseUID.(string)

	var input OnboardingInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := database.DB.First(&user, "id = ?", uidStr).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found. Please sync user first."})
		return
	}

	// Открываем транзакцию БД, чтобы сохранение анкеты и генерация плана прошли атомарно
	tx := database.DB.Begin()

	if input.FullName != "" {
		user.FullName = input.FullName
	}
	user.Gender = input.Gender
	user.FavoriteActivity = input.FavoriteActivity
	user.Age = input.Age
	user.Weight = input.Weight
	user.WeightUnit = input.WeightUnit
	user.Height = input.Height
	user.HeightUnit = input.HeightUnit
	user.FitnessLevel = input.FitnessLevel
	user.Goal = input.Goal
	user.OnboardingCompleted = true

	if err := tx.Save(&user).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save user metadata: " + err.Error()})
		return
	}

	// Удаляем старый план пользователя, если он существовал, во избежание дублирования
	tx.Where("user_id = ?", uidStr).Delete(&models.WorkoutDay{})

	// Инициализируем наш экспертный генератор (Шаг 2)
	generator := NewRuleBasedGenerator()
	generatedDays := generator.GeneratePlan(&user)

	// Сохраняем сгенерированные дни и упражнения в базу данных
	for _, day := range generatedDays {
		if err := tx.Create(&day).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate workout plan steps: " + err.Error()})
			return
		}
	}

	tx.Commit()

	c.JSON(http.StatusOK, gin.H{
		"message": "Onboarding completed and workout plan generated successfully",
		"user":    user,
	})
}

// GetWorkoutPlan возвращает сгенерированную программу тренировок со всеми упражнениями
func GetWorkoutPlan(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uidStr := firebaseUID.(string)

	var workoutDays []models.WorkoutDay
	// Загружаем дни тренировок вместе со вложенным массивом упражнений (Eager Loading через Preload)
	err := database.DB.Preload("Exercises").Where("user_id = ?", uidStr).Order("day_number asc").Find(&workoutDays).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch workout plan: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, workoutDays)
}

// GetProfile возвращает текущий профиль пользователя
func GetProfile(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uidStr := firebaseUID.(string)

	var user models.User
	if err := database.DB.First(&user, "id = ?", uidStr).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found"})
		return
	}

	c.JSON(http.StatusOK, user)
}

// CheckUserExists проверяет существование почты в базе данных
func CheckUserExists(c *gin.Context) {
	email := c.Query("email")
	if email == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email is required"})
		return
	}

	var user models.User
	if err := database.DB.First(&user, "email = ?", email).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{"exists": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"exists": true})
}
