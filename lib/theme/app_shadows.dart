/// WeCoop Design System — Ombre
///
/// BoxShadow custom estratte dal Figma (il tema usa elevation Material = 0 e
/// applica ombre soft custom).
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppShadows {
  /// Ombra card standard — Figma: 0px 4px 16px rgba(31,41,51,0.05).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D1F2933), // #1F2933 @ 5%
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// Ombra piccola — Figma bottone: 0px 4px 4px rgba(18,130,168,0.15).
  static final List<BoxShadow> buttonPrimary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      offset: const Offset(0, 4),
      blurRadius: 4,
    ),
  ];

  /// Ombra bottone Home centrale — 0px 4px 8px rgba(18,130,168,0.15).
  static final List<BoxShadow> centerButton = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];
}
