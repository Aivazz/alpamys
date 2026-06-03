import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета темы (для обратной совместимости с другими экранами)
  static const Color primary = Color(0xFFA3CB24); // Салатовый/лаймовый
  static const Color background = Colors.white; // Белый фон
  static const Color surface = Color(0xFFF8F9FA); // Светло-серый фон карточек
  static const Color surfaceLight = Color(0xFFE9ECEF); // Светло-серый для рамок и разделителей
  static const Color textPrimary = Color(0xFF1A1D20); // Темный/черный текст
  static const Color textSecondary = Color(0xFF7B8085); // Серый текст
  static const Color error = Color(0xFFDC3545);
  static const Color googleRed = Color(0xFFEA4335);

  // Новые константы для светлой главной страницы по макету
  static const Color homeBackground = Colors.white; // Белый фон главной страницы
  static const Color textDark = Color(0xFF1A1D20); // Глубокий темно-серый/черный для текста
  static const Color textLight = Color(0xFF7B8085); // Серый для неактивного текста/подсказок
  static const Color inputBackground = Color(0xFFF4F6F9); // Светло-серый для полей ввода
  static const Color bannerOrange = Color(0xFFF2994A); // Оранжевый для баннера
  static const Color orangeBanner = Color(0xFFF2994A); // Совместимость со старым banner_card.dart
  static const Color buttonYellow = Color(0xFFFFC000); // Желтый для кнопки "Egzersize Başla"
  static const Color activeChip = Colors.black; // Черный для активных чипсов
  static const Color passiveChip = Color(0xFFF1F3F5); // Светло-серый для пассивных чипсов
}
