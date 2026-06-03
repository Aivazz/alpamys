import 'package:flutter/material.dart';

/// Responsive helper — адаптирует размеры, шрифты и отступы
/// под любой экран: маленький (360dp), средний (390dp), большой (430dp+)
class R {
  R._();

  static late double _w;
  static late double _h;
  static late double _sp; // scale factor for text

  /// Вызвать один раз в начале build() любого корневого виджета
  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _w = size.width;
    _h = size.height;
    // Базовый дизайн под 390dp (iPhone 14)
    _sp = _w / 390.0;
  }

  // ── Ширина/Высота ────────────────────────────────────────────────────
  /// Адаптивная ширина: r.w(x) = x% от ширины экрана
  static double w(double percent) => _w * percent / 100;

  /// Адаптивная высота: r.h(x) = x% от высоты экрана
  static double h(double percent) => _h * percent / 100;

  // ── Шрифты ──────────────────────────────────────────────────────────
  /// Адаптивный размер шрифта (базовый дизайн 390dp)
  static double sp(double size) => (size * _sp).clamp(size * 0.82, size * 1.18);

  // ── Отступы ─────────────────────────────────────────────────────────
  static double get xs  => _sp * 4;
  static double get sm  => _sp * 8;
  static double get md  => _sp * 16;
  static double get lg  => _sp * 24;
  static double get xl  => _sp * 32;
  static double get xxl => _sp * 48;

  // ── Горизонтальный padding экрана ────────────────────────────────────
  static double get screenPaddingH => _w < 380 ? 16 : (_w > 430 ? 28 : 20);

  // ── Border radius ────────────────────────────────────────────────────
  static double get radiusSm  => _sp * 10;
  static double get radiusMd  => _sp * 16;
  static double get radiusLg  => _sp * 24;
  static double get radiusXl  => _sp * 32;

  // ── Иконки ───────────────────────────────────────────────────────────
  static double get iconSm => sp(18);
  static double get iconMd => sp(22);
  static double get iconLg => sp(28);

  // ── Card image heights ───────────────────────────────────────────────
  static double get gymCardImageH  => _h * 0.22;
  static double get productCardW   => _w * 0.38;
  static double get productCardImgH => _w * 0.34;

  // ── Breakpoints ──────────────────────────────────────────────────────
  static bool get isSmallPhone   => _w < 375;   // SE, Galaxy A series old
  static bool get isMediumPhone  => _w >= 375 && _w < 420;
  static bool get isLargePhone   => _w >= 420;  // Plus, Pro Max, Galaxy S Ultra
}
