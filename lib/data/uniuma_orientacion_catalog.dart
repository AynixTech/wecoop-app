/// Catalogo programmi UNIUMA / Società Umanitaria per «Solicitar orientación»
/// e Offerta Formativa in ficha.
/// Spec aggiornata novembre 2026: sezioni A/B, ECTS, titoli aggiornati.
library;

import '../models/offerta_formativa_model.dart';
import '../models/partner_model.dart';
import 'partner_ficha_catalog.dart';

const kUniumaBrochureEsUrl =
    'https://anthonydevhub.fra1.digitaloceanspaces.com/wecoop/uniuma/2026_brochure_es.pdf';

/// Brochure ufficiale 2026–2027 in italiano (bundle app + URL CDN quando pubblicato).
const kUniumaBrochureItAsset = 'assets/documents/uniuma_2026_brochure_it.pdf';
const kUniumaBrochureItUrl =
    'https://anthonydevhub.fra1.digitaloceanspaces.com/wecoop/uniuma/2026_brochure_it.pdf';

/// Prefisso URL embedded in [PartnerMedia.url] per PDF in assets Flutter.
const kUniumaAssetUrlPrefix = 'asset://';

PartnerMedia uniumaBrochureItMedia({int ordine = 0}) => PartnerMedia(
      id: -100,
      tipo: 'brochure',
      titolo: 'Brochure UNIUMA 2026–2027 (Italiano)',
      descrizione: 'Brochure ufficiale accademica — IT',
      url: '$kUniumaAssetUrlPrefix$kUniumaBrochureItAsset',
      mime: 'application/pdf',
      ordine: ordine,
    );

bool _isItalianBrochure(PartnerMedia m) {
  final label = '${m.titolo} ${m.descrizione}'.toLowerCase();
  final url = m.url.toLowerCase();
  return label.contains('italiano') ||
      label.contains('italian') ||
      RegExp(r'(^|[\s_(/-])it([\s_)./-]|$)').hasMatch(label) ||
      url.contains('brochure_it') ||
      url.contains('_it.pdf') ||
      url.startsWith(kUniumaAssetUrlPrefix);
}

/// Documenti brochure UNIUMA: IT sempre in testa, poi eventuali PDF da API.
List<PartnerMedia> uniumaBrochureDocumenti(List<PartnerMedia> fromApi) {
  final docs = fromApi.where((m) => m.isPdf).toList();
  if (!docs.any(_isItalianBrochure)) {
    docs.insert(0, uniumaBrochureItMedia(ordine: 0));
  }
  docs.sort((a, b) {
    final aIt = _isItalianBrochure(a);
    final bIt = _isItalianBrochure(b);
    if (aIt && !bIt) return -1;
    if (!aIt && bIt) return 1;
    return a.ordine.compareTo(b.ordine);
  });
  return docs;
}

class UniumaProgramOption {
  final String codice;
  /// Titoli per lingua (es/it/en/fr/ar/zh). Fallback: it → es → en.
  final Map<String, String> titoli;
  /// Dipartimento / sezione breve per lingua (es. «Dipartimento Umanistico»).
  final Map<String, String> categorie;
  /// triennale | master | undecided | header
  final String livello;
  /// Crediti ECTS (0 = non applicabile / header / undecided).
  final int ects;
  final bool selectable;
  /// Mostrare nella lista Offerta Formativa della ficha (no undecided).
  final bool showInFicha;

  const UniumaProgramOption({
    required this.codice,
    required this.titoli,
    required this.categorie,
    required this.livello,
    this.ects = 0,
    this.selectable = true,
    this.showInFicha = true,
  });

  String titoloFor(String lang) => _pick(titoli, lang);
  String categoriaFor(String lang) => _pick(categorie, lang);

  /// Sottotitolo UI: «Dipartimento Umanistico – Triennale – ECTS 180».
  String dettaglioFor(String lang) {
    if (livello == 'header' || livello == 'undecided') return '';
    final code = lang.toLowerCase().split(RegExp(r'[_-]')).first;
    if (livello == 'master') {
      final masterLabel = {
        'es': 'Máster anual',
        'it': 'Master annuale',
        'en': 'One-year Master',
        'fr': 'Master annuel',
        'ar': 'ماجستير سنوي',
        'zh': '一年制硕士',
      };
      final label = masterLabel[code] ?? masterLabel['it']!;
      return ects > 0 ? '$label – ECTS $ects' : label;
    }
    final cat = categoriaFor(lang);
    final livelloLabel = uniumaLivelloLabel(livello, lang);
    // Capitalizza «Triennale» in IT/ES/… per match brief.
    final livelloUi = livelloLabel.isEmpty
        ? ''
        : '${livelloLabel[0].toUpperCase()}${livelloLabel.substring(1)}';
    final parts = <String>[
      if (cat.isNotEmpty) cat,
      if (livelloUi.isNotEmpty) livelloUi,
      if (ects > 0) 'ECTS $ects',
    ];
    return parts.join(' – ');
  }

  static String _pick(Map<String, String> m, String lang) {
    final code = lang.toLowerCase().split(RegExp(r'[_-]')).first;
    return m[code] ?? m['it'] ?? m['es'] ?? m['en'] ?? m.values.first;
  }
}

const _catHum = {
  'es': 'Departamento de Humanidades',
  'it': 'Dipartimento Umanistico',
  'en': 'Humanities Department',
  'fr': 'Département des Humanités',
  'ar': 'قسم العلوم الإنسانية',
  'zh': '人文学部',
};

const _catEco = {
  'es': 'Departamento Económico',
  'it': 'Dipartimento Economico',
  'en': 'Economics Department',
  'fr': 'Département Économique',
  'ar': 'القسم الاقتصادي',
  'zh': '经济学部',
};

const _catPos = {
  'es': 'Posgrado',
  'it': 'Post-laurea',
  'en': 'Postgraduate',
  'fr': 'Postgrade',
  'ar': 'دراسات عليا',
  'zh': '研究生',
};

const _catOri = {
  'es': 'Orientación',
  'it': 'Orientamento',
  'en': 'Guidance',
  'fr': 'Orientation',
  'ar': 'توجيه',
  'zh': '升学指导',
};

/// Headers A/B + 9 corsi + «Devo ancora decidere» in coda.
const uniumaOrientacionPrograms = <UniumaProgramOption>[
  UniumaProgramOption(
    codice: 'hdr_laurea',
    titoli: {
      'es': 'A. GRADOS UNIVERSITARIOS EN MEDIACIÓN LINGÜÍSTICA Y CULTURAL',
      'it': 'A. CORSI DI LAUREA IN MEDIAZIONE LINGUISTICA E CULTURALE',
      'en': 'A. DEGREE COURSES IN LINGUISTIC AND CULTURAL MEDIATION',
      'fr': 'A. CURSUS DE LICENCE EN MÉDIATION LINGUISTIQUE ET CULTURELLE',
      'ar': 'أ. برامج البكالوريوس في الوساطة اللغوية والثقافية',
      'zh': 'A. 语言与文化调解本科学位课程',
    },
    categorie: _catHum,
    livello: 'header',
    selectable: false,
    showInFicha: true,
  ),
  UniumaProgramOption(
    codice: 'hum_criminologia',
    titoli: {
      'es': 'Criminología y Protección Social',
      'it': 'Criminologia e Tutela Sociale',
      'en': 'Criminology and Social Protection',
      'fr': 'Criminologie et Protection Sociale',
      'ar': 'علم الجريمة والحماية الاجتماعية',
      'zh': '犯罪学与社会保护',
    },
    categorie: _catHum,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'hum_diplomacia',
    titoli: {
      'es': 'Diplomacia Internacional y Derechos Humanos',
      'it': 'Diplomazia Internazionale e Diritti Umani',
      'en': 'International Diplomacy and Human Rights',
      'fr': 'Diplomatie Internationale et Droits Humains',
      'ar': 'الدبلوماسية الدولية وحقوق الإنسان',
      'zh': '国际外交与人权',
    },
    categorie: _catHum,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'hum_diseno_multi',
    titoli: {
      'es': 'Proyectación Multicultural',
      'it': 'Progettazione Multiculturale',
      'en': 'Multicultural Design',
      'fr': 'Conception Multiculturelle',
      'ar': 'التصميم متعدد الثقافات',
      'zh': '多元文化设计',
    },
    categorie: _catHum,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'eco_artistico',
    titoli: {
      'es': 'Proyectación Artística',
      'it': 'Progettazione Artistica',
      'en': 'Artistic Design',
      'fr': 'Conception Artistique',
      'ar': 'التصميم الفني',
      'zh': '艺术设计',
    },
    categorie: _catEco,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'eco_gestion',
    titoli: {
      'es': 'Gestión Empresarial (Business Management)',
      'it': 'Business Management',
      'en': 'Business Management',
      'fr': 'Gestion d\'Entreprise (Business Management)',
      'ar': 'إدارة الأعمال',
      'zh': '商业管理',
    },
    categorie: _catEco,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'eco_marketing',
    titoli: {
      'es': 'Marketing Ético y Desarrollo Digital',
      'it': 'Marketing Etico e Sviluppo Digitale',
      'en': 'Ethical Marketing and Digital Development',
      'fr': 'Marketing Éthique et Développement Numérique',
      'ar': 'التسويق الأخلاقي والتطوير الرقمي',
      'zh': '伦理营销与数字发展',
    },
    categorie: _catEco,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'eco_moda',
    titoli: {
      'es': 'Gestión Sostenible de la Moda (Sustainable Fashion Management)',
      'it': 'Sustainable Fashion Management',
      'en': 'Sustainable Fashion Management',
      'fr': 'Gestion Durable de la Mode (Sustainable Fashion Management)',
      'ar': 'إدارة الأزياء المستدامة',
      'zh': '可持续时尚管理',
    },
    categorie: _catEco,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'eco_maritima',
    titoli: {
      'es':
          'Management para la Proyectación y la Gestión Turística, Marítima y Portuaria',
      'it':
          'Management per la Progettazione e la Gestione Turistica, Marittima e Portuale',
      'en':
          'Management for Tourism, Maritime and Port Planning and Management',
      'fr':
          'Management pour la Conception et la Gestion Touristique, Maritime et Portuaire',
      'ar':
          'إدارة تصميم وإدارة السياحة والبحر والموانئ',
      'zh': '旅游、海事与港口规划与管理',
    },
    categorie: _catEco,
    livello: 'triennale',
    ects: 180,
  ),
  UniumaProgramOption(
    codice: 'hdr_post',
    titoli: {
      'es': 'B. POSGRADO',
      'it': 'B. POST-LAUREA',
      'en': 'B. POSTGRADUATE',
      'fr': 'B. POSTGRADE',
      'ar': 'ب. الدراسات العليا',
      'zh': 'B. 研究生',
    },
    categorie: _catPos,
    livello: 'header',
    selectable: false,
    showInFicha: true,
  ),
  UniumaProgramOption(
    codice: 'master_criminologia',
    titoli: {
      'es': 'Máster en Criminología y Psico-Sociología de la Desviación',
      'it': 'Master in Criminologia e Psico-Sociologia della Devianza',
      'en': "Master's in Criminology and Psycho-Sociology of Deviance",
      'fr': 'Master en Criminologie et Psycho-Sociologie de la Déviance',
      'ar': 'ماجستير في علم الجريمة وعلم النفس الاجتماعي للانحراف',
      'zh': '犯罪学与越轨心理社会学硕士',
    },
    categorie: _catPos,
    livello: 'master',
    ects: 60,
  ),
  UniumaProgramOption(
    codice: 'undecided',
    titoli: {
      'es': 'Aún debo decidir',
      'it': 'Devo ancora decidere',
      'en': 'I still have to decide',
      'fr': 'Je dois encore décider',
      'ar': 'ما زلت بحاجة إلى اتخاذ قرار',
      'zh': '我还没决定',
    },
    categorie: _catOri,
    livello: 'undecided',
    showInFicha: false,
  ),
];

String uniumaLivelloLabel(String livello, String lang) {
  const labels = {
    'triennale': {
      'es': 'trienal',
      'it': 'triennale',
      'en': 'three-year',
      'fr': 'triennal',
      'ar': 'ثلاث سنوات',
      'zh': '三年制',
    },
    'master': {
      'es': 'máster',
      'it': 'master',
      'en': "master's",
      'fr': 'master',
      'ar': 'ماجستير',
      'zh': '硕士',
    },
    'undecided': {
      'es': 'por decidir',
      'it': 'da decidere',
      'en': 'undecided',
      'fr': 'à décider',
      'ar': 'غير محدد',
      'zh': '未定',
    },
  };
  final m = labels[livello];
  if (m == null) return livello;
  final code = lang.toLowerCase().split(RegExp(r'[_-]')).first;
  return m[code] ?? m['it'] ?? m['es'] ?? livello;
}

bool isUniumaPartnerName(String? nome) {
  if (nome == null || nome.trim().isEmpty) return false;
  return fichaForPartnerName(nome)?.slug == 'uniuma';
}

/// Tutte le voci (intestazioni + opzioni) per il menu a tendina UNIUMA.
List<OffertaFormativa> uniumaOfferteAsFormative({
  required int partnerId,
  required String partnerNome,
  String lang = 'it',
}) {
  var i = 0;
  return uniumaOrientacionPrograms.map((p) {
    i += 1;
    final dettaglio = p.dettaglioFor(lang);
    return OffertaFormativa(
      id: p.selectable ? (-1000 - i) : (-2000 - i),
      titolo: p.titoloFor(lang),
      descrizione: '',
      partnerId: partnerId,
      partnerNome: partnerNome,
      partnerLogoUrl: '',
      partnerSitoWeb: '',
      // Categoria = sottotitolo completo per UI (Dipartimento … – ECTS).
      categoria: dettaglio.isNotEmpty ? dettaglio : p.categoriaFor(lang),
      durata: p.livello == 'header'
          ? 'header'
          : p.livello == 'undecided'
              ? 'undecided'
              : uniumaLivelloLabel(p.livello, lang),
      linkInfo: p.codice,
      imageUrl: '',
      ordine: i,
    );
  }).toList();
}

bool isUniumaProgramHeader(OffertaFormativa o) =>
    o.durata == 'header' || o.linkInfo.startsWith('hdr_');

bool isUniumaUndecided(OffertaFormativa o) =>
    o.linkInfo == 'undecided' ||
    o.durata == 'undecided' ||
    o.descrizione == 'undecided';

/// Voci per la lista «Offerta Formativa» in ficha: no «Devo ancora decidere».
/// Gli header A/B restano visibili.
bool isUniumaFichaOfferta(OffertaFormativa o) {
  if (isUniumaUndecided(o)) return false;
  final opt = uniumaOptionForOfferta(o);
  if (opt != null) return opt.showInFicha;
  return !isUniumaUndecided(o);
}

/// Localizza titolo/categoria/durata di un'offerta UNIUMA in base al codice.
OffertaFormativa localizeUniumaOfferta(OffertaFormativa o, String lang) {
  final opt = uniumaOptionForOfferta(o);
  if (opt == null) return o;
  final dettaglio = opt.dettaglioFor(lang);
  return OffertaFormativa(
    id: o.id,
    titolo: opt.titoloFor(lang),
    descrizione: '',
    partnerId: o.partnerId,
    partnerNome: o.partnerNome,
    partnerLogoUrl: o.partnerLogoUrl,
    partnerSitoWeb: o.partnerSitoWeb,
    categoria: dettaglio.isNotEmpty ? dettaglio : opt.categoriaFor(lang),
    durata: opt.livello == 'header'
        ? 'header'
        : opt.livello == 'undecided'
            ? 'undecided'
            : uniumaLivelloLabel(opt.livello, lang),
    linkInfo: opt.codice,
    imageUrl: o.imageUrl,
    ordine: o.ordine,
  );
}

List<OffertaFormativa> localizeUniumaOfferte(
  List<OffertaFormativa> offerte,
  String lang,
) =>
    offerte.map((o) => localizeUniumaOfferta(o, lang)).toList();

/// True solo per URL http(s). I [linkInfo] UNIUMA sono codici (`hdr_laurea`,
/// `undecided`, …) e non vanno aperti con url_launcher.
bool isLaunchableHttpUrl(String? value) {
  if (value == null) return false;
  final s = value.trim();
  if (s.isEmpty) return false;
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme) return false;
  return uri.isScheme('http') || uri.isScheme('https');
}

UniumaProgramOption? uniumaOptionForOfferta(OffertaFormativa? o) {
  if (o == null) return null;
  final code = o.linkInfo.isNotEmpty ? o.linkInfo : o.descrizione;
  for (final p in uniumaOrientacionPrograms) {
    if (p.codice == code) return p;
  }
  // Alias legacy header codes (catalogo precedente).
  if (code == 'hdr_hum' || code == 'hdr_eco') {
    for (final p in uniumaOrientacionPrograms) {
      if (p.codice == 'hdr_laurea') return p;
    }
  }
  if (code == 'hdr_master') {
    for (final p in uniumaOrientacionPrograms) {
      if (p.codice == 'hdr_post') return p;
    }
  }
  // Match su qualsiasi titolo noto (API spesso in ES / titoli vecchi).
  for (final p in uniumaOrientacionPrograms) {
    for (final t in p.titoli.values) {
      if (t == o.titolo) return p;
    }
  }
  // Match titoli legacy ancora eventualmente in API.
  const legacy = <String, String>{
    'Design Multiculturale': 'hum_diseno_multi',
    'Diseño Multicultural': 'hum_diseno_multi',
    'Design Artistico (Milano)': 'eco_artistico',
    'Diseño Artístico (Milán)': 'eco_artistico',
    "Gestione d'Impresa (Milano)": 'eco_gestion',
    'Gestión Empresarial (Milán)': 'eco_gestion',
    'Marketing Etico e Sviluppo Digitale (Milano)': 'eco_marketing',
    'Marketing Ético y Desarrollo Digital (Milán)': 'eco_marketing',
    'Gestione Sostenibile della Moda (Genova)': 'eco_moda',
    'Gestión Sostenible de la Moda (Génova)': 'eco_moda',
    'Gestione per il Design e la Gestione Marittima, Turistica e Portuale (Genova)':
        'eco_maritima',
    'Non lo so ancora': 'undecided',
    'Aún no lo sé': 'undecided',
  };
  final mapped = legacy[o.titolo];
  if (mapped != null) {
    for (final p in uniumaOrientacionPrograms) {
      if (p.codice == mapped) return p;
    }
  }
  return null;
}
