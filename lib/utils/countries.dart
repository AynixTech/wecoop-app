/// Paesi ISO 3166-1 alpha-2 (lista mondiale, nomi in italiano).
/// Fonte allineata a wecoop-backend phone-prefixes.
class Country {
  final String code;
  final String name;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
  });

  String get label => '$flag $name';
}

class Countries {
  Countries._();

  /// Tutti i paesi, ordinati alfabeticamente (IT).
  static const List<Country> all = [
    Country(code: 'AF', name: 'Afghanistan', flag: '🇦🇫'),
    Country(code: 'AL', name: 'Albania', flag: '🇦🇱'),
    Country(code: 'DZ', name: 'Algeria', flag: '🇩🇿'),
    Country(code: 'AD', name: 'Andorra', flag: '🇦🇩'),
    Country(code: 'AO', name: 'Angola', flag: '🇦🇴'),
    Country(code: 'AG', name: 'Antigua e Barbuda', flag: '🇦🇬'),
    Country(code: 'SA', name: 'Arabia Saudita', flag: '🇸🇦'),
    Country(code: 'AR', name: 'Argentina', flag: '🇦🇷'),
    Country(code: 'AM', name: 'Armenia', flag: '🇦🇲'),
    Country(code: 'AU', name: 'Australia', flag: '🇦🇺'),
    Country(code: 'AT', name: 'Austria', flag: '🇦🇹'),
    Country(code: 'AZ', name: 'Azerbaigian', flag: '🇦🇿'),
    Country(code: 'BS', name: 'Bahamas', flag: '🇧🇸'),
    Country(code: 'BH', name: 'Bahrein', flag: '🇧🇭'),
    Country(code: 'BD', name: 'Bangladesh', flag: '🇧🇩'),
    Country(code: 'BB', name: 'Barbados', flag: '🇧🇧'),
    Country(code: 'BE', name: 'Belgio', flag: '🇧🇪'),
    Country(code: 'BZ', name: 'Belize', flag: '🇧🇿'),
    Country(code: 'BJ', name: 'Benin', flag: '🇧🇯'),
    Country(code: 'BT', name: 'Bhutan', flag: '🇧🇹'),
    Country(code: 'BY', name: 'Bielorussia', flag: '🇧🇾'),
    Country(code: 'BO', name: 'Bolivia', flag: '🇧🇴'),
    Country(code: 'BA', name: 'Bosnia ed Erzegovina', flag: '🇧🇦'),
    Country(code: 'BW', name: 'Botswana', flag: '🇧🇼'),
    Country(code: 'BR', name: 'Brasile', flag: '🇧🇷'),
    Country(code: 'BN', name: 'Brunei', flag: '🇧🇳'),
    Country(code: 'BG', name: 'Bulgaria', flag: '🇧🇬'),
    Country(code: 'BF', name: 'Burkina Faso', flag: '🇧🇫'),
    Country(code: 'BI', name: 'Burundi', flag: '🇧🇮'),
    Country(code: 'KH', name: 'Cambogia', flag: '🇰🇭'),
    Country(code: 'CM', name: 'Camerun', flag: '🇨🇲'),
    Country(code: 'CA', name: 'Canada', flag: '🇨🇦'),
    Country(code: 'CV', name: 'Capo Verde', flag: '🇨🇻'),
    Country(code: 'TD', name: 'Ciad', flag: '🇹🇩'),
    Country(code: 'CL', name: 'Cile', flag: '🇨🇱'),
    Country(code: 'CN', name: 'Cina', flag: '🇨🇳'),
    Country(code: 'CY', name: 'Cipro', flag: '🇨🇾'),
    Country(code: 'VA', name: 'Città del Vaticano', flag: '🇻🇦'),
    Country(code: 'CO', name: 'Colombia', flag: '🇨🇴'),
    Country(code: 'KM', name: 'Comore', flag: '🇰🇲'),
    Country(code: 'CG', name: 'Congo (Brazzaville)', flag: '🇨🇬'),
    Country(code: 'CD', name: 'Congo (Kinshasa)', flag: '🇨🇩'),
    Country(code: 'KP', name: 'Corea del Nord', flag: '🇰🇵'),
    Country(code: 'KR', name: 'Corea del Sud', flag: '🇰🇷'),
    Country(code: 'CI', name: "Costa d'Avorio", flag: '🇨🇮'),
    Country(code: 'CR', name: 'Costa Rica', flag: '🇨🇷'),
    Country(code: 'HR', name: 'Croazia', flag: '🇭🇷'),
    Country(code: 'CU', name: 'Cuba', flag: '🇨🇺'),
    Country(code: 'DK', name: 'Danimarca', flag: '🇩🇰'),
    Country(code: 'DM', name: 'Dominica', flag: '🇩🇲'),
    Country(code: 'EC', name: 'Ecuador', flag: '🇪🇨'),
    Country(code: 'EG', name: 'Egitto', flag: '🇪🇬'),
    Country(code: 'SV', name: 'El Salvador', flag: '🇸🇻'),
    Country(code: 'AE', name: 'Emirati Arabi Uniti', flag: '🇦🇪'),
    Country(code: 'ER', name: 'Eritrea', flag: '🇪🇷'),
    Country(code: 'EE', name: 'Estonia', flag: '🇪🇪'),
    Country(code: 'SZ', name: 'Eswatini', flag: '🇸🇿'),
    Country(code: 'ET', name: 'Etiopia', flag: '🇪🇹'),
    Country(code: 'FJ', name: 'Figi', flag: '🇫🇯'),
    Country(code: 'PH', name: 'Filippine', flag: '🇵🇭'),
    Country(code: 'FI', name: 'Finlandia', flag: '🇫🇮'),
    Country(code: 'FR', name: 'Francia', flag: '🇫🇷'),
    Country(code: 'GA', name: 'Gabon', flag: '🇬🇦'),
    Country(code: 'GM', name: 'Gambia', flag: '🇬🇲'),
    Country(code: 'GE', name: 'Georgia', flag: '🇬🇪'),
    Country(code: 'DE', name: 'Germania', flag: '🇩🇪'),
    Country(code: 'GH', name: 'Ghana', flag: '🇬🇭'),
    Country(code: 'JM', name: 'Giamaica', flag: '🇯🇲'),
    Country(code: 'JP', name: 'Giappone', flag: '🇯🇵'),
    Country(code: 'DJ', name: 'Gibuti', flag: '🇩🇯'),
    Country(code: 'JO', name: 'Giordania', flag: '🇯🇴'),
    Country(code: 'GR', name: 'Grecia', flag: '🇬🇷'),
    Country(code: 'GD', name: 'Grenada', flag: '🇬🇩'),
    Country(code: 'GT', name: 'Guatemala', flag: '🇬🇹'),
    Country(code: 'GN', name: 'Guinea', flag: '🇬🇳'),
    Country(code: 'GQ', name: 'Guinea Equatoriale', flag: '🇬🇶'),
    Country(code: 'GW', name: 'Guinea-Bissau', flag: '🇬🇼'),
    Country(code: 'GY', name: 'Guyana', flag: '🇬🇾'),
    Country(code: 'HT', name: 'Haiti', flag: '🇭🇹'),
    Country(code: 'HN', name: 'Honduras', flag: '🇭🇳'),
    Country(code: 'HK', name: 'Hong Kong', flag: '🇭🇰'),
    Country(code: 'IN', name: 'India', flag: '🇮🇳'),
    Country(code: 'ID', name: 'Indonesia', flag: '🇮🇩'),
    Country(code: 'IR', name: 'Iran', flag: '🇮🇷'),
    Country(code: 'IQ', name: 'Iraq', flag: '🇮🇶'),
    Country(code: 'IE', name: 'Irlanda', flag: '🇮🇪'),
    Country(code: 'IS', name: 'Islanda', flag: '🇮🇸'),
    Country(code: 'MH', name: 'Isole Marshall', flag: '🇲🇭'),
    Country(code: 'SB', name: 'Isole Salomone', flag: '🇸🇧'),
    Country(code: 'IL', name: 'Israele', flag: '🇮🇱'),
    Country(code: 'IT', name: 'Italia', flag: '🇮🇹'),
    Country(code: 'KZ', name: 'Kazakistan', flag: '🇰🇿'),
    Country(code: 'KE', name: 'Kenya', flag: '🇰🇪'),
    Country(code: 'KG', name: 'Kirghizistan', flag: '🇰🇬'),
    Country(code: 'KI', name: 'Kiribati', flag: '🇰🇮'),
    Country(code: 'XK', name: 'Kosovo', flag: '🇽🇰'),
    Country(code: 'KW', name: 'Kuwait', flag: '🇰🇼'),
    Country(code: 'LA', name: 'Laos', flag: '🇱🇦'),
    Country(code: 'LS', name: 'Lesotho', flag: '🇱🇸'),
    Country(code: 'LV', name: 'Lettonia', flag: '🇱🇻'),
    Country(code: 'LB', name: 'Libano', flag: '🇱🇧'),
    Country(code: 'LR', name: 'Liberia', flag: '🇱🇷'),
    Country(code: 'LY', name: 'Libia', flag: '🇱🇾'),
    Country(code: 'LI', name: 'Liechtenstein', flag: '🇱🇮'),
    Country(code: 'LT', name: 'Lituania', flag: '🇱🇹'),
    Country(code: 'LU', name: 'Lussemburgo', flag: '🇱🇺'),
    Country(code: 'MO', name: 'Macao', flag: '🇲🇴'),
    Country(code: 'MK', name: 'Macedonia del Nord', flag: '🇲🇰'),
    Country(code: 'MG', name: 'Madagascar', flag: '🇲🇬'),
    Country(code: 'MW', name: 'Malawi', flag: '🇲🇼'),
    Country(code: 'MV', name: 'Maldive', flag: '🇲🇻'),
    Country(code: 'MY', name: 'Malesia', flag: '🇲🇾'),
    Country(code: 'ML', name: 'Mali', flag: '🇲🇱'),
    Country(code: 'MT', name: 'Malta', flag: '🇲🇹'),
    Country(code: 'MA', name: 'Marocco', flag: '🇲🇦'),
    Country(code: 'MR', name: 'Mauritania', flag: '🇲🇷'),
    Country(code: 'MU', name: 'Mauritius', flag: '🇲🇺'),
    Country(code: 'MX', name: 'Messico', flag: '🇲🇽'),
    Country(code: 'FM', name: 'Micronesia', flag: '🇫🇲'),
    Country(code: 'MD', name: 'Moldavia', flag: '🇲🇩'),
    Country(code: 'MC', name: 'Monaco', flag: '🇲🇨'),
    Country(code: 'MN', name: 'Mongolia', flag: '🇲🇳'),
    Country(code: 'ME', name: 'Montenegro', flag: '🇲🇪'),
    Country(code: 'MZ', name: 'Mozambico', flag: '🇲🇿'),
    Country(code: 'MM', name: 'Myanmar', flag: '🇲🇲'),
    Country(code: 'NA', name: 'Namibia', flag: '🇳🇦'),
    Country(code: 'NR', name: 'Nauru', flag: '🇳🇷'),
    Country(code: 'NP', name: 'Nepal', flag: '🇳🇵'),
    Country(code: 'NI', name: 'Nicaragua', flag: '🇳🇮'),
    Country(code: 'NE', name: 'Niger', flag: '🇳🇪'),
    Country(code: 'NG', name: 'Nigeria', flag: '🇳🇬'),
    Country(code: 'NO', name: 'Norvegia', flag: '🇳🇴'),
    Country(code: 'NZ', name: 'Nuova Zelanda', flag: '🇳🇿'),
    Country(code: 'OM', name: 'Oman', flag: '🇴🇲'),
    Country(code: 'NL', name: 'Paesi Bassi', flag: '🇳🇱'),
    Country(code: 'PK', name: 'Pakistan', flag: '🇵🇰'),
    Country(code: 'PW', name: 'Palau', flag: '🇵🇼'),
    Country(code: 'PS', name: 'Palestina', flag: '🇵🇸'),
    Country(code: 'PA', name: 'Panama', flag: '🇵🇦'),
    Country(code: 'PG', name: 'Papua Nuova Guinea', flag: '🇵🇬'),
    Country(code: 'PY', name: 'Paraguay', flag: '🇵🇾'),
    Country(code: 'PE', name: 'Perù', flag: '🇵🇪'),
    Country(code: 'PL', name: 'Polonia', flag: '🇵🇱'),
    Country(code: 'PT', name: 'Portogallo', flag: '🇵🇹'),
    Country(code: 'QA', name: 'Qatar', flag: '🇶🇦'),
    Country(code: 'GB', name: 'Regno Unito', flag: '🇬🇧'),
    Country(code: 'CZ', name: 'Repubblica Ceca', flag: '🇨🇿'),
    Country(code: 'CF', name: 'Repubblica Centrafricana', flag: '🇨🇫'),
    Country(code: 'DO', name: 'Repubblica Dominicana', flag: '🇩🇴'),
    Country(code: 'RO', name: 'Romania', flag: '🇷🇴'),
    Country(code: 'RW', name: 'Ruanda', flag: '🇷🇼'),
    Country(code: 'RU', name: 'Russia', flag: '🇷🇺'),
    Country(code: 'KN', name: 'Saint Kitts e Nevis', flag: '🇰🇳'),
    Country(code: 'LC', name: 'Saint Lucia', flag: '🇱🇨'),
    Country(code: 'VC', name: 'Saint Vincent e Grenadine', flag: '🇻🇨'),
    Country(code: 'WS', name: 'Samoa', flag: '🇼🇸'),
    Country(code: 'SM', name: 'San Marino', flag: '🇸🇲'),
    Country(code: 'ST', name: 'São Tomé e Príncipe', flag: '🇸🇹'),
    Country(code: 'SN', name: 'Senegal', flag: '🇸🇳'),
    Country(code: 'RS', name: 'Serbia', flag: '🇷🇸'),
    Country(code: 'SC', name: 'Seychelles', flag: '🇸🇨'),
    Country(code: 'SL', name: 'Sierra Leone', flag: '🇸🇱'),
    Country(code: 'SG', name: 'Singapore', flag: '🇸🇬'),
    Country(code: 'SY', name: 'Siria', flag: '🇸🇾'),
    Country(code: 'SK', name: 'Slovacchia', flag: '🇸🇰'),
    Country(code: 'SI', name: 'Slovenia', flag: '🇸🇮'),
    Country(code: 'SO', name: 'Somalia', flag: '🇸🇴'),
    Country(code: 'ES', name: 'Spagna', flag: '🇪🇸'),
    Country(code: 'LK', name: 'Sri Lanka', flag: '🇱🇰'),
    Country(code: 'US', name: 'Stati Uniti', flag: '🇺🇸'),
    Country(code: 'SS', name: 'Sud Sudan', flag: '🇸🇸'),
    Country(code: 'ZA', name: 'Sudafrica', flag: '🇿🇦'),
    Country(code: 'SD', name: 'Sudan', flag: '🇸🇩'),
    Country(code: 'SR', name: 'Suriname', flag: '🇸🇷'),
    Country(code: 'SE', name: 'Svezia', flag: '🇸🇪'),
    Country(code: 'CH', name: 'Svizzera', flag: '🇨🇭'),
    Country(code: 'TJ', name: 'Tagikistan', flag: '🇹🇯'),
    Country(code: 'TW', name: 'Taiwan', flag: '🇹🇼'),
    Country(code: 'TZ', name: 'Tanzania', flag: '🇹🇿'),
    Country(code: 'TH', name: 'Thailandia', flag: '🇹🇭'),
    Country(code: 'TL', name: 'Timor Est', flag: '🇹🇱'),
    Country(code: 'TG', name: 'Togo', flag: '🇹🇬'),
    Country(code: 'TO', name: 'Tonga', flag: '🇹🇴'),
    Country(code: 'TT', name: 'Trinidad e Tobago', flag: '🇹🇹'),
    Country(code: 'TN', name: 'Tunisia', flag: '🇹🇳'),
    Country(code: 'TR', name: 'Turchia', flag: '🇹🇷'),
    Country(code: 'TM', name: 'Turkmenistan', flag: '🇹🇲'),
    Country(code: 'TV', name: 'Tuvalu', flag: '🇹🇻'),
    Country(code: 'UA', name: 'Ucraina', flag: '🇺🇦'),
    Country(code: 'UG', name: 'Uganda', flag: '🇺🇬'),
    Country(code: 'HU', name: 'Ungheria', flag: '🇭🇺'),
    Country(code: 'UY', name: 'Uruguay', flag: '🇺🇾'),
    Country(code: 'UZ', name: 'Uzbekistan', flag: '🇺🇿'),
    Country(code: 'VU', name: 'Vanuatu', flag: '🇻🇺'),
    Country(code: 'VE', name: 'Venezuela', flag: '🇻🇪'),
    Country(code: 'VN', name: 'Vietnam', flag: '🇻🇳'),
    Country(code: 'YE', name: 'Yemen', flag: '🇾🇪'),
    Country(code: 'ZM', name: 'Zambia', flag: '🇿🇲'),
    Country(code: 'ZW', name: 'Zimbabwe', flag: '🇿🇼'),
  ];

  /// Opzioni nazionalità per dropdown / picker (compat Map).
  static List<Map<String, String>> get nationalities =>
      all.map((c) => {'code': c.code, 'name': c.label}).toList(growable: false);

  /// Mappa ISO → nome paese.
  static final Map<String, String> names = {
    for (final c in all) c.code: c.name,
  };

  static Country? byCode(String? isoCode) {
    if (isoCode == null || isoCode.isEmpty) return null;
    final code = isoCode.toUpperCase();
    for (final c in all) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Converte codice ISO in nome paese (fallback: codice stesso).
  static String nameFor(String? isoCode) {
    if (isoCode == null || isoCode.isEmpty) return '';
    return names[isoCode.toUpperCase()] ?? isoCode;
  }

  /// Filtra per nome o codice (case-insensitive, accent-tolerant semplice).
  static List<Country> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }
}
