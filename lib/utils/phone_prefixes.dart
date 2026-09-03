class PhonePrefixes {
  static const List<String> prefixes = [
    '+39', // Italia
    '+40', // Romania
    '+355', // Albania
    '+212', // Marocco
    '+380', // Ucraina
    '+86', // Cina
    '+90', // Turchia
    '+98', // Iran
    '+7', // Russia / area CIS
    '+63', // Filippine
    '+91', // India
    '+880', // Bangladesh
    '+92', // Pakistan
    '+221', // Senegal
    '+234', // Nigeria
    '+216', // Tunisia
    '+20', // Egitto
    '+51', // Perù
    '+373', // Moldavia
    '+94', // Sri Lanka
    '+48', // Polonia
    '+55', // Brasile
    '+593', // Ecuador
    '+213', // Algeria
    '+233', // Ghana
    '+225', // Costa d'Avorio
    '+36', // Ungheria
    '+60', // Malesia
    '+62', // Indonesia
    '+65', // Singapore
    '+66', // Thailandia
    '+230', // Mauritius
  ];

  static const Map<String, String> flags = {
    '+39': '🇮🇹',
    '+40': '🇷🇴',
    '+355': '🇦🇱',
    '+212': '🇲🇦',
    '+380': '🇺🇦',
    '+86': '🇨🇳',
    '+90': '🇹🇷',
    '+98': '🇮🇷',
    '+7': '🇷🇺',
    '+63': '🇵🇭',
    '+91': '🇮🇳',
    '+880': '🇧🇩',
    '+92': '🇵🇰',
    '+221': '🇸🇳',
    '+234': '🇳🇬',
    '+216': '🇹🇳',
    '+20': '🇪🇬',
    '+51': '🇵🇪',
    '+373': '🇲🇩',
    '+94': '🇱🇰',
    '+48': '🇵🇱',
    '+55': '🇧🇷',
    '+593': '🇪🇨',
    '+213': '🇩🇿',
    '+233': '🇬🇭',
    '+225': '🇨🇮',
    '+36': '🇭🇺',
    '+60': '🇲🇾',
    '+62': '🇮🇩',
    '+65': '🇸🇬',
    '+66': '🇹🇭',
    '+230': '🇲🇺',
  };

  static String flagFor(String prefix) {
    return flags[prefix] ?? '🌐';
  }

  /// Username di login = prefisso + numero in sole cifre, allineato al backend
  /// (`normalizePhone`): rimuove lo "0" troncale nazionale prima del prefisso.
  ///
  /// Esempi: `+39` + `03331234567` → `393331234567`;
  /// `+39` + `393331234567` → `393331234567`.
  static String normalizeForLogin({
    required String prefix,
    required String phone,
  }) {
    final prefixDigits = prefix.replaceAll(RegExp(r'[^\d]'), '');
    var phoneDigits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (prefixDigits.isNotEmpty) {
      phoneDigits = phoneDigits.replaceFirst(RegExp(r'^0+'), '');
      if (!phoneDigits.startsWith(prefixDigits)) {
        phoneDigits = '$prefixDigits$phoneDigits';
      }
    }

    return phoneDigits;
  }
}