/// WeCoop Design System — Colori
///
/// Token colore estratti dal Figma (pagina `Screens/Mobile`) e allineati al
/// tema in `app.dart`. Sono l'unica fonte di verità per i colori dell'app:
/// evitare `Color(0x...)` hardcoded nelle schermate, usare questi token.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ------------------------------------------------------------------ brand
  /// Teal brand principale. AppBar, bottoni primari, link, nav attiva, focus.
  static const Color primary = Color(0xFF1282A8);

  /// Teal scuro — testo dei bottoni outline.
  static const Color primaryDark = Color(0xFF0E6786);

  /// Verde brand — successo/accento, switch ON, badge "iscritto".
  static const Color secondary = Color(0xFF59B575);

  /// Magenta — errori, campi obbligatori, banner di allerta.
  static const Color error = Color(0xFFE6266B);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);

  // -------------------------------------------------------------- superfici
  static const Color surface = Color(0xFFFFFFFF);

  /// Sfondo scaffold — tint teal chiarissimo.
  static const Color background = Color(0xFFF8FBFD);

  // ------------------------------------------------------------------ testo
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF52606D);
  static const Color textMuted = Color(0xFF6F7782);

  /// Label dei campi input (tema legacy).
  static const Color inputLabel = Color(0xFF4D4C4C);

  /// Testo su hero gradiente (leggermente azzurrato).
  static const Color onGradientMuted = Color(0xFFEBF6FF);

  // -------------------------------------------------------------- neutri/UI
  static const Color iconInactive = Color(0xFF9CA3AF);
  static const Color disabled = Color(0xFFCBCED4);
  static const Color bgSubtle = Color(0xFFF1F5F9);

  // ----------------------------------------------------------- bordi/ombre
  /// Bordo hairline su card (nero ~8%).
  static const Color border = Color(0x14000000);

  /// Bordo input (nero ~13%).
  static const Color borderInput = Color(0x22000000);

  /// Colore ombra branded (usato con opacità).
  static const Color shadow = Color(0xFF1F2933);

  // ------------------------------------------------------------- semantici
  static const Color success = Color(0xFF59B575);
  static const Color successBg = Color(0xFFE6F6EC);
  static const Color warning = Color(0xFFFF6F00);
  static const Color errorBg = Color(0xFFFDF0F4); // dal Figma (banner allerta)
  static const Color info = Color(0xFF2196F3);
  static const Color infoBg = Color(0xFFE3F2FD);

  /// Sfondo chip (tema legacy).
  static const Color chipBg = Color(0xFFEFF7FA);

  /// Colore base ombra card branded (tema legacy).
  static const Color shadowBranded = Color(0xFF0F2430);

  // --------------------------------------------------------- overlay/vetro
  /// Chip su AppBar teal (bianco 15%).
  static const Color glassLight = Color(0x26FFFFFF); // ~15%
  /// Badge "Area soci" su hero (bianco 20%).
  static const Color glassBadge = Color(0x33FFFFFF); // ~20%

  // ----------------------------------------------------------- gradienti
  /// Gradiente hero saluto (teal → verde), left→right.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );

  /// Overlay scuro sopra le immagini dei service tile (top→bottom).
  static const LinearGradient imageScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x21000000), Color(0xAB000000)],
  );
}
