/// Validatori per dati anagrafici italiani (CF, date, indirizzo).
class ItalianValidators {
  ItalianValidators._();

  static String normalizeCodiceFiscale(String value) =>
      value.trim().toUpperCase().replaceAll(' ', '');

  /// Verifica formato e carattere di controllo del codice fiscale italiano.
  static bool isValidCodiceFiscale(String value) {
    final cf = normalizeCodiceFiscale(value);
    if (cf.length != 16) return false;
    if (!RegExp(r'^[A-Z0-9]{16}$').hasMatch(cf)) return false;

    const checkChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const evenChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const oddValues = <String, int>{
      '0': 1,
      '1': 0,
      '2': 5,
      '3': 7,
      '4': 9,
      '5': 13,
      '6': 15,
      '7': 17,
      '8': 19,
      '9': 21,
      'A': 1,
      'B': 0,
      'C': 5,
      'D': 7,
      'E': 9,
      'F': 13,
      'G': 15,
      'H': 17,
      'I': 19,
      'J': 21,
      'K': 2,
      'L': 4,
      'M': 18,
      'N': 20,
      'O': 11,
      'P': 3,
      'Q': 6,
      'R': 8,
      'S': 12,
      'T': 14,
      'U': 16,
      'V': 10,
      'W': 22,
      'X': 25,
      'Y': 24,
      'Z': 23,
    };

    var sum = 0;
    for (var i = 0; i < 15; i++) {
      final c = cf[i];
      if (i.isEven) {
        final odd = oddValues[c];
        if (odd == null) return false;
        sum += odd;
      } else {
        final idx = evenChars.indexOf(c);
        if (idx < 0) return false;
        sum += idx;
      }
    }
    return cf[15] == checkChars[sum % 26];
  }

  static bool isValidEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
  }

  /// Interpreta una data in formato DD/MM/YYYY.
  static DateTime? tryParseItalianDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > DateTime.now().year) return null;
    try {
      final parsed = DateTime(year, month, day);
      if (parsed.year != year || parsed.month != month || parsed.day != day) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Converte DD/MM/YYYY in YYYY-MM-DD per le API.
  static String? birthDateToIso(String value) {
    final parsed = tryParseItalianDate(value);
    if (parsed == null) return null;
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Normalizza date API a YYYY-MM-DD.
  /// Accetta `YYYY-MM-DD`, ISO con ora (`...T00:00:00.000Z`) o già `DD/MM/YYYY`.
  static String? normalizeIsoDate(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final italian = tryParseItalianDate(trimmed);
    if (italian != null) {
      final y = italian.year.toString().padLeft(4, '0');
      final m = italian.month.toString().padLeft(2, '0');
      final d = italian.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    // YYYY-MM-DD o prefisso di un ISO datetime.
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(trimmed);
    if (match != null) {
      return '${match.group(1)}-${match.group(2)}-${match.group(3)}';
    }
    return null;
  }

  /// Converte una data API (YYYY-MM-DD o ISO) in DD/MM/YYYY per i form.
  static String formatBirthDateForDisplay(String? value) {
    final iso = normalizeIsoDate(value);
    if (iso == null) return (value ?? '').trim();
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  /// Restituisce una chiave i18n se non valida, altrimenti null.
  static String? validateBirthDate(String value, {bool required = false}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return required ? 'invalidBirthDate' : null;
    final parsed = tryParseItalianDate(trimmed);
    if (parsed == null) return 'invalidBirthDate';
    if (parsed.isAfter(DateTime.now())) return 'birthDateFuture';
    final minDate = DateTime(DateTime.now().year - 120, 1, 1);
    if (parsed.isBefore(minDate)) return 'invalidBirthDate';
    return null;
  }

  static bool isValidCap(String value) {
    final cap = value.trim();
    if (cap.isEmpty) return true;
    return RegExp(r'^\d{5}$').hasMatch(cap);
  }

  static bool isValidProvince(String value) {
    final p = value.trim().toUpperCase();
    if (p.isEmpty) return true;
    return RegExp(r'^[A-Z]{2}$').hasMatch(p);
  }

  static String? validateAddress(String value, {bool required = false}) {
    final v = value.trim();
    if (v.isEmpty) return required ? 'addressRequired' : null;
    if (v.length < 5) return 'addressTooShort';
    if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(v)) return 'addressTooShort';
    return null;
  }

  static String? validateCity(String value, {bool required = false}) {
    final v = value.trim();
    if (v.isEmpty) return required ? 'cityRequired' : null;
    if (v.length < 2) return 'cityTooShort';
    if (!RegExp(r"^[A-Za-zÀ-ÿ\s'-]{2,}$").hasMatch(v)) return 'cityTooShort';
    return null;
  }
}
