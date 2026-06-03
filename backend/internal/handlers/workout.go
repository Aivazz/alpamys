package handlers

import (
	"alpamys-backend/internal/database"
	"alpamys-backend/internal/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type SetInput struct {
	SetNumber int     `json:"set_number" binding:"required"`
	Weight    float64 `json:"weight" binding:"required"`
	Reps      int     `json:"reps" binding:"required"`
}

type ExerciseInput struct {
	ExerciseName string     `json:"exercise_name" binding:"required"`
	Sets         []SetInput `json:"sets" binding:"required"`
}

type FinishWorkoutInput struct {
	WorkoutTitle    string          `json:"workout_title" binding:"required"`
	DurationSeconds int             `json:"duration_seconds" binding:"required"`
	Exercises       []ExerciseInput `json:"exercises" binding:"required"`
}

// FinishWorkout сохраняет фактически выполненную тренировку в историю
func FinishWorkout(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uidStr := firebaseUID.(string)

	var input FinishWorkoutInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	tx := database.DB.Begin()

	history := models.WorkoutHistory{
		UserID:       uidStr,
		WorkoutTitle: input.WorkoutTitle,
		Duration:     input.DurationSeconds,
		CompletedAt:  time.Now(),
	}

	if err := tx.Create(&history).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create workout history: " + err.Error()})
		return
	}

	for _, exInput := range input.Exercises {
		executedEx := models.ExecutedExercise{
			WorkoutHistoryID: history.ID,
			ExerciseName:     exInput.ExerciseName,
		}
		if err := tx.Create(&executedEx).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save executed exercise: " + err.Error()})
			return
		}

		for _, setInput := range exInput.Sets {
			executedSet := models.ExecutedSet{
				ExecutedExerciseID: executedEx.ID,
				SetNumber:          setInput.SetNumber,
				Weight:             setInput.Weight,
				Reps:               setInput.Reps,
			}
			if err := tx.Create(&executedSet).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save executed set: " + err.Error()})
				return
			}
		}
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "Antrenman başarıyla kaydedildi!", "history_id": history.ID})
}
