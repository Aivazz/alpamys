package models

type Product struct {
	ID          uint    `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string  `gorm:"not null" json:"name"`
	Brand       string  `json:"brand"`
	Category    string  `gorm:"index" json:"category"`
	Desc        string  `json:"desc"`
	Price       float64 `json:"price"`
	Rating      float64 `json:"rating"`
	Image       string  `json:"image"`
	IsFavorite  bool    `json:"isFavorite"`
}
