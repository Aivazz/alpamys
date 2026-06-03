package handlers

import (
	"net/http"
	"alpamys-backend/internal/database"
	"alpamys-backend/internal/models"

	"github.com/gin-gonic/gin"
)

func GetProducts(c *gin.Context) {
	var products []models.Product
	if err := database.DB.Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch products: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, products)
}
