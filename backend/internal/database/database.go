package database

import (
	"alpamys-backend/internal/models"
	"log"

	sqlite "github.com/glebarez/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func ConnectDatabase() {
	db, err := gorm.Open(sqlite.Open("alpamys.db"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	log.Println("Database connection established.")

	// Авто-миграция всех моделей (добавили новые сущности дней и упражнений, а также продуктов)
	err = db.AutoMigrate(&models.User{}, &models.WorkoutDay{}, &models.PlanExercise{}, &models.Product{})
	if err != nil {
		log.Fatalf("Database migration failed: %v", err)
	}
	log.Println("Database migration completed.")

	seedProducts(db)

	DB = db
}

func seedProducts(db *gorm.DB) {
	var count int64
	db.Model(&models.Product{}).Count(&count)
	if count == 0 {
		products := []models.Product{
			{
				Name:       "Whey Gold Protein",
				Brand:      "Alpamys Nutrition",
				Category:   "Protein",
				Desc:       "Çikolatalı - 2.2 kg",
				Price:      1490.0,
				Rating:     4.9,
				Image:      "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=300&auto=format&fit=crop&q=80",
				IsFavorite: false,
			},
			{
				Name:       "Creatine Micronized",
				Brand:      "Alpamys Nutrition",
				Category:   "Kreatin",
				Desc:       "Aromasız - 300g",
				Price:      790.0,
				Rating:     4.8,
				Image:      "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=300&auto=format&fit=crop&q=80",
				IsFavorite: true,
			},
			{
				Name:       "BCAA Pro 2:1:1",
				Brand:      "Alpamys Nutrition",
				Category:   "Amino Asitler",
				Desc:       "Karpuzlu - 400g",
				Price:      890.0,
				Rating:     4.7,
				Image:      "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=300&auto=format&fit=crop&q=80",
				IsFavorite: false,
			},
			{
				Name:       "Mass Gainer Powder",
				Brand:      "Alpamys Nutrition",
				Category:   "Gainer",
				Desc:       "Muzlu - 3 kg",
				Price:      1290.0,
				Rating:     4.5,
				Image:      "https://images.unsplash.com/photo-1579758682665-53a1a614eea6?w=300&auto=format&fit=crop&q=80",
				IsFavorite: false,
			},
			{
				Name:       "Omega 3 Ultra Fish Oil",
				Brand:      "Alpamys Nutrition",
				Category:   "Vitaminler",
				Desc:       "120 Yumuşak Kapsül",
				Price:      490.0,
				Rating:     4.8,
				Image:      "https://images.unsplash.com/photo-1611079830811-865ff1a44b73?w=300&auto=format&fit=crop&q=80",
				IsFavorite: true,
			},
			{
				Name:       "Pre-Workout Shox",
				Brand:      "Alpamys Nutrition",
				Category:   "Amino Asitler",
				Desc:       "Ekşi Elma - 300g",
				Price:      990.0,
				Rating:     4.9,
				Image:      "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=300&auto=format&fit=crop&q=80",
				IsFavorite: false,
			},
		}
		if err := db.Create(&products).Error; err != nil {
			log.Printf("Failed to seed products: %v", err)
		} else {
			log.Println("Database seeded with products successfully.")
		}
	}
}
