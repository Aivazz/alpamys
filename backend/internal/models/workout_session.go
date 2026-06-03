package models

import (
	"time"

	"gorm.io/gorm"
)

// WorkoutHistory хранит общую информацию о завершенной тренировке Антона Иванова
type WorkoutHistory struct {
	ID           uint               `gorm:"primaryKey" json:"id"`
	UserID       string             `gorm:"index" json:"user_id"`
	WorkoutTitle string             `json:"workout_title"`    // Название дня, например "İtiş"
	Duration     int                `json:"duration_seconds"` // Время в секундах
	CompletedAt  time.Time          `json:"completed_at"`
	DeletedAt    gorm.DeletedAt     `gorm:"index" json:"-"`
	Exercises    []ExecutedExercise `gorm:"foreignKey:WorkoutHistoryID" json:"exercises"`
}

// ExecutedExercise хранит данные по конкретному упражнению внутри сессии
type ExecutedExercise struct {
	ID               uint          `gorm:"primaryKey" json:"id"`
	WorkoutHistoryID uint          `gorm:"index" json:"workout_history_id"`
	ExerciseName     string        `json:"exercise_name"`
	Sets             []ExecutedSet `gorm:"foreignKey:ExecutedExerciseID" json:"sets"`
}

// ExecutedSet хранит фактически выполненные вес и повторения для каждого подхода
type ExecutedSet struct {
	ID                 uint    `gorm:"primaryKey" json:"id"`
	ExecutedExerciseID uint    `gorm:"index" json:"executed_exercise_id"`
	SetNumber          int     `json:"set_number"`
	Weight             float64 `json:"weight"` // Вес, который ввёл пользователь
	Reps               int     `json:"reps"`   // Количество повторений
}
