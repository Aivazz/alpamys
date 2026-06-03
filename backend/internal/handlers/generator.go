package handlers

import (
	"alpamys-backend/internal/models"
)

// WorkoutGenerator определяет контракт для генерации планов.
// Это позволит позже бесшовно заменить код на реальный AI.
type WorkoutGenerator interface {
	GeneratePlan(user *models.User) []models.WorkoutDay
}

type RuleBasedGenerator struct{}

func NewRuleBasedGenerator() WorkoutGenerator {
	return &RuleBasedGenerator{}
}

// GeneratePlan анализирует анкету пользователя и возвращает персональный сплит
func (g *RuleBasedGenerator) GeneratePlan(user *models.User) []models.WorkoutDay {
	var days []models.WorkoutDay

	// КЕЙС 1: Пользователь — Новичок (Beginner). Назначаем адаптивный Full Body (Tüm Vücut)
	if user.FitnessLevel == "Beginner" {
		var reps string
		var desc string

		if user.Goal == "Weight loss" {
			reps = "3 Set x 15 Tekrar"
			desc = "Yağ yakımını hızlandırmak ve kalori tüketimini artırmak için yüksek tekrarlı dairesel Tüm Vücut antrenmanı."
		} else {
			reps = "4 Set x 10 Tekrar"
			desc = "Kas kütlesini artırmak ve temel hareket formlarını öğrenmek için tasarlanmış Tüm Vücut güç programı."
		}

		fullBodyDay := models.WorkoutDay{
			UserID:        user.ID,
			DayNumber:     1,
			Title:         "Tüm Vücut (Full Body) Güç",
			Level:         "Başlangıç / Orta",
			Duration:      "60 dk",
			DaysFrequency: "Haftada 3 Gün",
			Desc:          desc,
			WhoFits:       "Yeni başlayanlar ve spora uzun süre ara verenler için kas adaptasyonu sağlar.",
			Image:         "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80",
			Exercises: []models.PlanExercise{
				{Name: "Barbell Squat", SetsReps: reps, Desc: "Temel bacak ve kalça kuvveti için derin çömelme.", Duration: "6 dk"},
				{Name: "Bench Press", SetsReps: reps, Desc: "Göğüs, omuz ve arka kol kasları için temel itiş.", Duration: "6 dk"},
				{Name: "Barbell Row", SetsReps: reps, Desc: "Sırt kalınlığı ve postür düzeltme için çekiş hareketi.", Duration: "5 dk"},
				{Name: "Overhead Press", SetsReps: reps, Desc: "Omuz başları ve merkez bölgesi dengesi için ayakta itiş.", Duration: "5 dk"},
				{Name: "Plank Hold", SetsReps: "3 Set x 60 Saniye", Desc: "Karın ve merkez bölgesi izometrik dayanıklılığı.", Duration: "3 dk"},
			},
		}
		days = append(days, fullBodyDay)
		return days
	}

	// КЕЙС 2: Пользователь — Продвинутый (Intermediate/Advanced). Назначаем Push-Pull-Legs (PPL) Сплит
	// День 1: Итиш (Push)
	pushDay := models.WorkoutDay{
		UserID:        user.ID,
		DayNumber:     1,
		Title:         "1. Gün: İtiş (Push)",
		Level:         user.FitnessLevel,
		Duration:      "55 dk",
		DaysFrequency: "Haftada 3-4 Gün",
		Desc:          "Göğüs, omuz ve arka kol (triceps) kaslarını hedefleyen, itme mekanizmasına dayalı hipertrofi günü.",
		WhoFits:       "Kas hacmini artırmak ve itiş gücünü izole etmek isteyen ileri seviye sporcular.",
		Image:         "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=500&auto=format&fit=crop&q=80",
		Exercises: []models.PlanExercise{
			{Name: "Incline Dumbbell Press", SetsReps: "4 Set x 10 Tekrar", Desc: "Üst göğüs lifleri odaklı kontrollü dumbbell itişi.", Duration: "6 dk"},
			{Name: "Overhead Barbell Press", SetsReps: "4 Set x 8 Tekrar", Desc: "Omuz gücü ve stabilite için ayakta barbell pres.", Duration: "6 dk"},
			{Name: "Dips", SetsReps: "3 Set x 12 Tekrar", Desc: "Alt göğüs ve triceps kaslarını tetikleyen gövde itişi.", Duration: "5 dk"},
			{Name: "Cable Lateral Raise", SetsReps: "4 Set x 15 Tekrar", Desc: "Yan omuz kaslarını izole etmek için kablo açış.", Duration: "4 dk"},
			{Name: "Tricep Pushdown", SetsReps: "3 Set x 12 Tekrar", Desc: "Arka kol kaslarını izole edip pompalama hareketi.", Duration: "4 dk"},
		},
	}

	// День 2: Чекиш (Pull)
	pullDay := models.WorkoutDay{
		UserID:        user.ID,
		DayNumber:     2,
		Title:         "2. Gün: Çekiş (Pull)",
		Level:         user.FitnessLevel,
		Duration:      "60 dk",
		DaysFrequency: "Haftada 3-4 Gün",
		Desc:          "Sırt, biceps и arka omuz kaslarını hedefleyen, çekme mekanizmasına dayalı hacim günü.",
		WhoFits:       "Kanat genişliği, sırt kalınlığı и biceps hacmi hedefleyenler için.",
		Image:         "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80",
		Exercises: []models.PlanExercise{
			{Name: "Deadlift", SetsReps: "3 Set x 5 Tekrar", Desc: "Tüm arka zincir, bel ve sırt kuvveti için yerden çekiş.", Duration: "8 dk"},
			{Name: "Pull-ups (Barfiks)", SetsReps: "4 Set x Maksimum", Desc: "Kanat kaslarını genişletmek için geniş tutuş vücut çekişi.", Duration: "5 dk"},
			{Name: "Seated Cable Row", SetsReps: "3 Set x 10 Tekrar", Desc: "Orta sırt ve kürek kemiği odaklı dar tutuş çekiş.", Duration: "5 dk"},
			{Name: "Face Pull", SetsReps: "4 Set x 15 Tekrar", Desc: "Arka omuz izolasyonu ve duruş/postür sağlığı.", Duration: "4 dk"},
			{Name: "Barbell Bicep Curl", SetsReps: "3 Set x 12 Tekrar", Desc: "Ön kol (biceps) kaslarını büyütmek için düz bar curl.", Duration: "4 dk"},
		},
	}

	// День 3: Баджак (Legs)
	legsDay := models.WorkoutDay{
		UserID:        user.ID,
		DayNumber:     3,
		Title:         "3. Gün: Bacak & Karın (Legs)",
		Level:         user.FitnessLevel,
		Duration:      "60 dk",
		DaysFrequency: "Haftada 3-4 Gün",
		Desc:          "Ön bacak, arka bacak, kalf и merkez bölgesi (core) kaslarını çalıştıran alt vücut günü.",
		WhoFits:       "Alt vücut simetrisi, bacak gücü ve güçlü karın kasları inşa etmek isteyenler.",
		Image:         "https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=500&auto=format&fit=crop&q=80",
		Exercises: []models.PlanExercise{
			{Name: "Barbell Back Squat", SetsReps: "4 Set x 8 Tekrar", Desc: "Kuadriseps ve kalça odaklı temel ağır çömelme.", Duration: "7 dk"},
			{Name: "Romanian Deadlift", SetsReps: "4 Set x 10 Tekrar", Desc: "Arka bacak (hamstrings) ve kalça kaslarını esneterek yükleme.", Duration: "6 dk"},
			{Name: "Leg Press", SetsReps: "3 Set x 12 Tekrar", Desc: "Makinede kontrollü ve güvenli bacak hacmi yüklemesi.", Duration: "5 dk"},
			{Name: "Standing Calf Raise", SetsReps: "4 Set x 15 Tekrar", Desc: "Alt bacak (kalf) kaslarının derinlemesine uyarılması.", Duration: "4 dk"},
			{Name: "Hanging Leg Raise", SetsReps: "3 Set x 15 Tekrar", Desc: "Barfiks demirine asılarak alt karın ve core bölgesini sıkıştırma.", Duration: "4 dk"},
		},
	}

	days = append(days, pushDay, pullDay, legsDay)
	return days
}
