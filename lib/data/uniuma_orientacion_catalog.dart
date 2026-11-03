/// Catalogo programmi UNIUMA / Società Umanitaria per «Solicitar orientación».
/// Spec V1.0 — 28 ottobre 2026. Se l'API restituisce `offerte_formative`,
/// quelle prevalgono su questo catalogo embedded (i titoli vengono comunque
/// localizzati per codice programma).
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
  /// Titoli per lingua (es/it/en/fr/ar/zh). Fallback: es → en → it.
  final Map<String, String> titoli;
  /// Categoria per lingua.
  final Map<String, String> categorie;
  /// triennale | master | undecided | header
  final String livello;
  final bool selectable;
  /// Mostrare nella lista Offerta Formativa della ficha (no undecided/header).
  final bool showInFicha;

  const UniumaProgramOption({
    required this.codice,
    required this.titoli,
    required this.categorie,
    required this.livello,
    this.selectable = true,
    this.showInFicha = true,
  });

  String titoloFor(String lang) => _pick(titoli, lang);
  String categoriaFor(String lang) => _pick(categorie, lang);

  static String _pick(Map<String, String> m, String lang) {
    final code = lang.toLowerCase().split(RegExp(r'[_-]')).first;
    return m[code] ?? m['it'] ?? m['es'] ?? m['en'] ?? m.values.first;
  }
}

const _catHum = {
  'es': 'Humanidades',
  'it': 'Umanistico',
  'en': 'Humanities',
  'fr': 'Humanités',
  'ar': 'العلوم الإنسانية',
  'zh': '人文学部',
};

const _catEco = {
  'es': 'Económico',
  'it': 'Economico',
  'en': 'Economics',
  'fr': 'Économique',
  'ar': 'القسم الاقتصادي',
  'zh': '经济学部',
};

const _catPos = {
  'es': 'Posgrado',
  'it': 'Post laurea',
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

/// Headers non selezionabili + 10 opzioni selezionabili (spec §2.1).
const uniumaOrientacionPrograms = <UniumaProgramOption>[
  UniumaProgramOption(
    codice: 'undecided',
    titoli: {
      'es': 'Aún no lo sé',
      'it': 'Non lo so ancora',
      'en': "I don't know yet",
      'fr': 'Je ne sais pas encore',
      'ar': 'لا أعرف بعد',
      'zh': '还不确定',
    },
    categorie: _catOri,
    livello: 'undecided',
    showInFicha: false,
  ),
  UniumaProgramOption(
    codice: 'hdr_hum',
    titoli: {
      'es':
          'Grado universitario trienal en Mediación Lingüística y Cultural — Departamento de Humanidades',
      'it':
          'Corso di laurea triennale in Mediazione Linguistica e Culturale — Dipartimento Umanistico',
      'en':
          'Three-year university degree in Linguistic and Cultural Mediation — Humanities Department',
      'fr':
          'Diplôme universitaire triennal en Médiation Linguistique et Culturelle — Département des Humanités',
      'ar':
          'درجة جامعية ثلاثية السنوات في الوساطة اللغوية والثقافية — قسم العلوم الإنسانية',
      'zh': '语言与文化调解三年制大学学位 — 人文学部',
    },
    categorie: _catHum,
    livello: 'header',
    selectable: false,
    showInFicha: false,
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
  ),
  UniumaProgramOption(
    codice: 'hum_diseno_multi',
    titoli: {
      'es': 'Diseño Multicultural',
      'it': 'Design Multiculturale',
      'en': 'Multicultural Design',
      'fr': 'Design Multiculturel',
      'ar': 'التصميم متعدد الثقافات',
      'zh': '多元文化设计',
    },
    categorie: _catHum,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hdr_eco',
    titoli: {
      'es':
          'Grado universitario trienal en Mediación Lingüística y Cultural — Departamento Económico',
      'it':
          'Corso di laurea triennale in Mediazione Linguistica e Culturale — Dipartimento Economico',
      'en':
          'Three-year university degree in Linguistic and Cultural Mediation — Economics Department',
      'fr':
          'Diplôme universitaire triennal en Médiation Linguistique et Culturelle — Département Économique',
      'ar':
          'درجة جامعية ثلاثية السنوات في الوساطة اللغوية والثقافية — القسم الاقتصادي',
      'zh': '语言与文化调解三年制大学学位 — 经济学部',
    },
    categorie: _catEco,
    livello: 'header',
    selectable: false,
    showInFicha: false,
  ),
  UniumaProgramOption(
    codice: 'eco_artistico',
    titoli: {
      'es': 'Diseño Artístico (Milán)',
      'it': 'Design Artistico (Milano)',
      'en': 'Artistic Design (Milan)',
      'fr': 'Design Artistique (Milan)',
      'ar': 'التصميم الفني (ميلانو)',
      'zh': '艺术设计（米兰）',
    },
    categorie: _catEco,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_gestion',
    titoli: {
      'es': 'Gestión Empresarial (Milán)',
      'it': 'Gestione d\'Impresa (Milano)',
      'en': 'Business Management (Milan)',
      'fr': 'Gestion d\'Entreprise (Milan)',
      'ar': 'إدارة الأعمال (ميلانو)',
      'zh': '企业管理（米兰）',
    },
    categorie: _catEco,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_marketing',
    titoli: {
      'es': 'Marketing Ético y Desarrollo Digital (Milán)',
      'it': 'Marketing Etico e Sviluppo Digitale (Milano)',
      'en': 'Ethical Marketing and Digital Development (Milan)',
      'fr': 'Marketing Éthique et Développement Numérique (Milan)',
      'ar': 'التسويق الأخلاقي والتطوير الرقمي (ميلانو)',
      'zh': '伦理营销与数字发展（米兰）',
    },
    categorie: _catEco,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_moda',
    titoli: {
      'es': 'Gestión Sostenible de la Moda (Génova)',
      'it': 'Gestione Sostenibile della Moda (Genova)',
      'en': 'Sustainable Fashion Management (Genoa)',
      'fr': 'Gestion Durable de la Mode (Gênes)',
      'ar': 'الإدارة المستدامة للأزياء (جنوى)',
      'zh': '可持续时尚管理（热那亚）',
    },
    categorie: _catEco,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_maritima',
    titoli: {
      'es':
          'Gestión para el Diseño y la Gestión Marítima, Turística y Portuaria (Génova)',
      'it':
          'Gestione per il Design e la Gestione Marittima, Turistica e Portuale (Genova)',
      'en':
          'Management for Maritime, Tourism and Port Design and Management (Genoa)',
      'fr':
          'Gestion pour le Design et la Gestion Maritime, Touristique et Portuaire (Gênes)',
      'ar':
          'الإدارة للتصميم والإدارة البحرية والسياحية والمينائية (جنوى)',
      'zh': '海事、旅游与港口设计与管理（热那亚）',
    },
    categorie: _catEco,
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hdr_master',
    titoli: {
      'es': 'Formación superior de posgrado',
      'it': 'Formazione superiore di post laurea',
      'en': 'Postgraduate higher education',
      'fr': 'Formation supérieure de postgrade',
      'ar': 'تكوين عالٍ لمرحلة ما بعد التخرج',
      'zh': '研究生高等教育',
    },
    categorie: _catPos,
    livello: 'header',
    selectable: false,
    showInFicha: false,
  ),
  UniumaProgramOption(
    codice: 'master_criminologia',
    titoli: {
      'es': 'Máster en Criminología e Psico-Sociología de la Desviación',
      'it': 'Master in Criminologia e Psico-Sociologia della Devianza',
      'en': "Master's in Criminology and Psycho-Sociology of Deviance",
      'fr': 'Master en Criminologie et Psycho-Sociologie de la Déviance',
      'ar': 'ماجستير في علم الجريمة وعلم النفس الاجتماعي للانحراف',
      'zh': '犯罪学与越轨心理社会学硕士',
    },
    categorie: _catPos,
    livello: 'master',
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
    return OffertaFormativa(
      id: p.selectable ? (-1000 - i) : (-2000 - i),
      titolo: p.titoloFor(lang),
      descrizione: '',
      partnerId: partnerId,
      partnerNome: partnerNome,
      partnerLogoUrl: '',
      partnerSitoWeb: '',
      categoria: p.categoriaFor(lang),
      durata: p.livello == 'header'
          ? 'header'
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

/// Voci per la lista «Offerta Formativa» in ficha: no header, no «Aún no lo sé».
bool isUniumaFichaOfferta(OffertaFormativa o) {
  if (isUniumaProgramHeader(o) || isUniumaUndecided(o)) return false;
  final opt = uniumaOptionForOfferta(o);
  if (opt != null) return opt.showInFicha;
  return true;
}

/// Localizza titolo/categoria/durata di un'offerta UNIUMA in base al codice.
OffertaFormativa localizeUniumaOfferta(OffertaFormativa o, String lang) {
  final opt = uniumaOptionForOfferta(o);
  if (opt == null) return o;
  return OffertaFormativa(
    id: o.id,
    titolo: opt.titoloFor(lang),
    descrizione: '',
    partnerId: o.partnerId,
    partnerNome: o.partnerNome,
    partnerLogoUrl: o.partnerLogoUrl,
    partnerSitoWeb: o.partnerSitoWeb,
    categoria: opt.categoriaFor(lang),
    durata: opt.livello == 'header'
        ? 'header'
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

/// True solo per URL http(s). I [linkInfo] UNIUMA sono codici (`hdr_hum`,
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
  // Match su qualsiasi titolo noto (API spesso in ES).
  for (final p in uniumaOrientacionPrograms) {
    for (final t in p.titoli.values) {
      if (t == o.titolo) return p;
    }
  }
  return null;
}
