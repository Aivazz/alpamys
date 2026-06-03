package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        string         `gorm:"primaryKey" json:"id"` // Firebase UID
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	FullName string `json:"full_name"`
	Email    string `gorm:"uniqueIndex;not null" json:"email"`

	// Onboarding Info
	Gender           string  `json:"gender"`
	FavoriteActivity string  `json:"favorite_activity"`
	Age              int     `json:"age"`
	Weight           float64 `json:"weight"`
	WeightUnit       string  `json:"weight_unit"` // "kg" / "lbs"
	Height           float64 `json:"height"`
	HeightUnit       string  `json:"height_unit"` // "cm" / "feet"
	FitnessLevel     string  `json:"fitness_level"`
	Goal             string  `json:"goal"`

	// Флаг для проверки, сгенерирован ли тренировочный план
	OnboardingCompleted bool `gorm:"default:false" json:"onboarding_completed"`
}

// WorkoutDay представляет один тренировочный день в программе (например, "1. Gün: İtiş")
type WorkoutDay struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	UserID        string         `gorm:"index" json:"user_id"`
	DayNumber     int            `json:"day_number"` // 1, 2, 3
	Title         string         `json:"title"`      // "İtiş", "Çekiş", "Tüm Vücut"
	Level         string         `json:"level"`      // "Orta Seviye"
	Duration      string         `json:"duration"`   // "60 dk"
	DaysFrequency string         `json:"days"`       // "Haftada 3 Gün"
	Desc          string         `json:"desc"`       // Описание дня
	WhoFits       string         `json:"who_fits"`   // Кому подходит
	Image         string         `json:"image"`      // Ссылка на Unsplash
	Exercises     []PlanExercise `gorm:"foreignKey:WorkoutDayID;constraint:OnDelete:CASCADE;" json:"exercises,omitempty"`
}

// PlanExercise представляет конкретное упражнение внутри тренировочного дня
type PlanExercise struct {
	ID           uint   `gorm:"primaryKey" json:"id"`
	WorkoutDayID uint   `gorm:"index" json:"workout_day_id"`
	Name         string `json:"name"`     // "Bench Press"
	SetsReps     string `json:"sets"`     // "4 Set x 8 Tekrar"
	Desc         string `json:"desc"`     // Описание техники
	Duration     string `json:"duration"` // "6 dk"
}
