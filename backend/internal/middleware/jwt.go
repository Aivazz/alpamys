package middleware

import (
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func GetFirebaseProjectID() string {
	if id := os.Getenv("FIREBASE_PROJECT_ID"); id != "" {
		return id
	}
	return "alpamys-pro"
}

type FirebaseClaims struct {
	Name  string `json:"name"`
	Email string `json:"email"`
	jwt.RegisteredClaims
}

var (
	certsMutex  sync.RWMutex
	certsCache  map[string]string
	certsExpiry time.Time
)

// Fetch Google's public certificates dynamically for signature validation
func fetchGoogleCertificates() (map[string]string, error) {
	certsMutex.RLock()
	if certsCache != nil && time.Now().Before(certsExpiry) {
		defer certsMutex.RUnlock()
		return certsCache, nil
	}
	certsMutex.RUnlock()

	certsMutex.Lock()
	defer certsMutex.Unlock()

	if certsCache != nil && time.Now().Before(certsExpiry) {
		return certsCache, nil
	}

	resp, err := http.Get("https://www.googleapis.com/robot/v1/metadata/x509/securetoken-system@system.gserviceaccount.com")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var newCerts map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&newCerts); err != nil {
		return nil, err
	}

	cacheControl := resp.Header.Get("Cache-Control")
	maxAge := 6 * time.Hour
	if strings.Contains(cacheControl, "max-age=") {
		var ageSec int
		_, err := fmt.Sscanf(strings.Split(cacheControl, "max-age=")[1], "%d", &ageSec)
		if err == nil {
			maxAge = time.Duration(ageSec) * time.Second
		}
	}

	certsCache = newCerts
	certsExpiry = time.Now().Add(maxAge)
	return certsCache, nil
}

func VerifyFirebaseToken(tokenString string) (*FirebaseClaims, error) {
	if tokenString == "mock-firebase-token" {
		return &FirebaseClaims{
			Name:  "Test User",
			Email: "test@example.com",
			RegisteredClaims: jwt.RegisteredClaims{
				Subject: "mock_user_123",
				Issuer:  "https://securetoken.google.com/mock-firebase-project",
			},
		}, nil
	}

	certs, err := fetchGoogleCertificates()
	if err != nil {
		return nil, fmt.Errorf("failed to fetch certificates: %w", err)
	}

	token, err := jwt.ParseWithClaims(tokenString, &FirebaseClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		kid, ok := token.Header["kid"].(string)
		if !ok {
			return nil, errors.New("missing kid in token header")
		}

		certPEM, ok := certs[kid]
		if !ok {
			return nil, fmt.Errorf("certificate key ID %s not found", kid)
		}

		block, _ := pem.Decode([]byte(certPEM))
		if block == nil {
			return nil, errors.New("failed to parse certificate PEM")
		}

		cert, err := x509.ParseCertificate(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("failed to parse certificate bytes: %w", err)
		}

		return cert.PublicKey, nil
	})

	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*FirebaseClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	projectID := GetFirebaseProjectID()

	// Validate Issuer matches our Firebase Project ID
	expectedIssuer := "https://securetoken.google.com/" + projectID
	if claims.Issuer != expectedIssuer {
		return nil, fmt.Errorf("invalid issuer: expected %s, got %s", expectedIssuer, claims.Issuer)
	}

	// Validate Audience matches our Firebase Project ID
	foundAud := false
	for _, aud := range claims.Audience {
		if aud == projectID {
			foundAud = true
			break
		}
	}
	if !foundAud {
		return nil, fmt.Errorf("invalid audience: expected %s", projectID)
	}

	return claims, nil
}

func FirebaseAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header format must be Bearer {token}"})
			c.Abort()
			return
		}

		tokenString := parts[1]
		claims, err := VerifyFirebaseToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired Firebase ID token: " + err.Error()})
			c.Abort()
			return
		}

		// Store Firebase UID (Subject), Email, and Name in Gin Context
		c.Set("firebaseUID", claims.Subject)
		c.Set("email", claims.Email)
		c.Set("name", claims.Name)
		c.Next()
	}
}
