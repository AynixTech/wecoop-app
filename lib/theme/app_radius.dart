/// WeCoop Design System — Border radius
///
/// Valori estratti dal Figma. Bottoni a pillola (999), card 16, input 12.
library;

import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double badge = 8;
  static const double chip = 10;
  static const double input = 12;
  static const double card = 16;
  static const double cardImage = 18;
  static const double heroCard = 22;
  static const double sheet = 24;
  static const double navBar = 28;

  /// Pillola — tutti i bottoni.
  static const double pill = 999;

  static const BorderRadius inputBr = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardBr = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroBr = BorderRadius.all(Radius.circular(heroCard));
  static const BorderRadius pillBr = BorderRadius.all(Radius.circular(pill));
}
