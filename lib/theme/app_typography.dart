/// WeCoop Design System — Tipografia
///
/// Scala type Inter estratta dal Figma. Pesi usati: 400/500/600/700/800.
/// Colore di default: [AppColors.textPrimary]; override per varianti muted.
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  /// Titolo brand / display (es. "WeCoop" nel login: 28 extrabold).
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: extraBold,
    color: AppColors.textPrimary,
  );

  /// Heading M — titoli AppBar grandi / "WeCoop" home (20 bold).
  static const TextStyle headingM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  /// Heading S — section header, titolo card grande (18 bold).
  static const TextStyle headingS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  /// Titolo AppBar standard (16 semibold).
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.onPrimary,
  );

  /// Label bottoni (16 semibold).
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
  );

  /// Corpo L (15 regular).
  static const TextStyle bodyL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: regular,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Corpo M (14).
  static const TextStyle bodyM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  /// Label form / secondario (13 semibold, colore muted).
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: semiBold,
    color: AppColors.textSecondary,
  );

  /// Caption (12).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textSecondary,
  );

  /// Overline / badge (11 bold, uppercase consigliato).
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: bold,
    letterSpacing: 0.5,
  );
}
