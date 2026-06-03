package main

import (
	"alpamys-backend/internal/database"
	"alpamys-backend/internal/handlers"
	"alpamys-backend/internal/middleware"
	"bufio"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

func loadEnv() {
	file, err := os.Open(".env")
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			key := strings.TrimSpace(parts[0])
			val := strings.TrimSpace(parts[1])
			val = strings.Trim(val, `"'`)
			os.Setenv(key, val)
		}
	}
	log.Println(".env file loaded successfully.")
}

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func main() {
	loadEnv()
	database.ConnectDatabase()

	r := gin.Default()
	r.Use(CORSMiddleware())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	api := r.Group("/api")
	{
		api.GET("/auth/check", handlers.CheckUserExists)
		api.GET("/products", handlers.GetProducts)

		// Защищенная группа роутов пользователя
		user := api.Group("/user")
		user.Use(middleware.FirebaseAuthMiddleware())
		{
			user.POST("/sync", handlers.SyncUser)
			user.POST("/onboarding", handlers.SaveOnboarding)
			user.GET("/profile", handlers.GetProfile)
			user.POST("/address", handlers.UpdateAddress)

			// НОВЫЙ ЭНДПОИНТ: Получение сгенерированного плана тренировок
			user.GET("/workout-plan", handlers.GetWorkoutPlan)
		}
	}

	port := ":8080"
	log.Printf("Server starting on port %s", port)
	if err := r.Run(port); err != nil {
		log.Fatalf("Server failed to run: %v", err)
	}
}
