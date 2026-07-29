/// WeCoop Design System — Spaziature
///
/// Scala 4-based estratta dal Figma. Gap dominanti: 12 e 16. Padding schermo: 20.
library;

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double smd = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Padding orizzontale standard dei contenuti di schermata.
  static const double screenPadding = 20;

  /// Padding interno card (Figma: p-16).
  static const double cardPadding = 16;
}
