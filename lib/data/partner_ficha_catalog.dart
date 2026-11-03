/// Contenuto strutturato della "ficha digital" Partner Accademici.
///
/// I partner noti (es. UNIUMA) hanno copy multilingue e asset locali per
/// allineare la UI al design Figma. Gli altri partner usano solo i dati API.
library;

class PartnerFichaStat {
  final String valueKey;
  final String labelKey;
  final String? valueOverride;
  final String? labelOverride;

  const PartnerFichaStat({
    required this.valueKey,
    required this.labelKey,
    this.valueOverride,
    this.labelOverride,
  });
}

class PartnerAdmissionSection {
  final String titleKey;
  final String? bodyKey;
  final List<String> stepsKeys;

  const PartnerAdmissionSection({
    required this.titleKey,
    this.bodyKey,
    this.stepsKeys = const [],
  });
}

class PartnerFichaLocale {
  final String cardTagline;
  final String affiliation;
  final List<String> tags;
  final String detailHeadline;
  final String detailDescription;
  final String admissionIntro;
  final List<PartnerAdmissionSection> admissionSections;
  /// Valori/label già risolti per stats (override delle chiavi globali).
  final List<({String value, String label})> stats;

  const PartnerFichaLocale({
    required this.cardTagline,
    required this.affiliation,
    required this.tags,
    required this.detailHeadline,
    required this.detailDescription,
    required this.admissionIntro,
    required this.admissionSections,
    required this.stats,
  });
}

class PartnerFicha {
  final String slug;
  /// Alias aggiuntivi sul nome partner API (es. «Società Umanitaria»).
  final List<String> aliases;
  final String coverAsset;
  final Map<String, PartnerFichaLocale> byLang;

  const PartnerFicha({
    required this.slug,
    this.aliases = const [],
    required this.coverAsset,
    required this.byLang,
  });

  PartnerFichaLocale localeFor(String lang) =>
      byLang[lang] ?? byLang['en'] ?? byLang['it']!;

  bool matchesName(String nome) {
    final n = nome.trim().toLowerCase();
    if (n.isEmpty) return false;
    if (n.contains(slug)) return true;
    for (final a in aliases) {
      if (n.contains(a.toLowerCase())) return true;
    }
    return false;
  }
}

/// Match per nome partner API (case-insensitive, slug o alias).
PartnerFicha? fichaForPartnerName(String nome) {
  for (final f in _catalog) {
    if (f.matchesName(nome)) return f;
  }
  return null;
}

const _catalog = <PartnerFicha>[_uniuma];

const _uniumaDetailDescriptionEs =
    'UNIUMA, la Escuela Superior de Mediadores Lingüísticos «P. M. Loria» de la histórica Società Umanitaria, ofrece formación universitaria en Milán y Génova.\n\n'
    'Su oferta académica incluye un grado universitario trienal en Mediación Lingüística y Cultural, con diferentes itinerarios de especialización, y un Máster en Criminología y Psico-Sociología de la Desviación.\n\n'
    'A través de WECOOP, puedes conocer sus programas, explorar tus oportunidades de estudio y solicitar orientación personalizada para dar el próximo paso en tu formación.';

const _uniumaDetailDescriptionIt =
    'UNIUMA, la Scuola Superiore di Mediazione Linguistica «P. M. Loria» della storica Società Umanitaria, offre formazione universitaria a Milano e Genova.\n\n'
    'La sua offerta accademica comprende un corso di laurea triennale in Mediazione Linguistica e Culturale, con diversi itinerari di specializzazione, e un Master in Criminologia e Psico-Sociologia della Devianza.\n\n'
    'Attraverso WECOOP, puoi conoscere i suoi programmi, esplorare le opportunità di studio e richiedere orientamento personalizzato per il prossimo passo nella tua formazione.';

const _uniumaDetailDescriptionEn =
    'UNIUMA, the Higher School of Linguistic Mediators «P. M. Loria» of the historic Società Umanitaria, offers university education in Milan and Genoa.\n\n'
    'Its academic offering includes a three-year university degree in Linguistic and Cultural Mediation, with different specialisation pathways, and a Master\'s in Criminology and Psycho-Sociology of Deviance.\n\n'
    'Through WECOOP, you can explore its programmes, discover your study opportunities and request personalised guidance for the next step in your education.';

const _uniumaDetailDescriptionFr =
    'UNIUMA, l’École Supérieure de Médiateurs Linguistiques «P. M. Loria» de la historique Società Umanitaria, propose une formation universitaire à Milan et à Gênes.\n\n'
    'Son offre académique comprend un diplôme universitaire triennal en Médiation Linguistique et Culturelle, avec différents parcours de spécialisation, et un Master en Criminologie et Psycho-Sociologie de la Déviance.\n\n'
    'Grâce à WECOOP, vous pouvez découvrir ses programmes, explorer vos opportunités d’études et demander une orientation personnalisée pour franchir la prochaine étape de votre formation.';

const _uniumaDetailDescriptionAr =
    'UNIUMA، المدرسة العليا للوسطاء اللغويين «P. M. Loria» التابعة لـ Società Umanitaria التاريخية، تقدّم تكويناً جامعياً في ميلانو وجنوى.\n\n'
    'تشمل عروضها الأكاديمية درجة جامعية ثلاثية السنوات في الوساطة اللغوية والثقافية، بمسارات تخصص مختلفة، وماجستير في علم الجريمة وعلم النفس الاجتماعي للانحراف.\n\n'
    'من خلال WECOOP يمكنك التعرف على برامجها واستكشاف فرص الدراسة وطلب توجيه شخصي للخطوة التالية في مسارك التعليمي.';

const _uniumaDetailDescriptionZh =
    'UNIUMA 是历史悠久的 Società Umanitaria 旗下语言调解高等学院「P. M. Loria」，在米兰与热那亚提供大学教育。\n\n'
    '其学术项目包括语言与文化调解三年制大学学位（含多种专业方向），以及犯罪学与越轨心理社会学硕士。\n\n'
    '通过 WECOOP，你可以了解其课程、探索留学机会，并申请个性化升学指导，迈出学业下一步。';

const _uniumaAdmissionCatalogEs =
    'SEDES DE MILÁN Y GÉNOVA\n\n'
    'ITINERARIOS DE ESPECIALIZACIÓN\n\n'
    'DEPARTAMENTO DE HUMANIDADES\n'
    '• CRIMINOLOGÍA Y PROTECCIÓN SOCIAL\n'
    '• DIPLOMACIA INTERNACIONAL Y DERECHOS HUMANOS\n'
    '• DISEÑO MULTICULTURAL\n\n'
    'DEPARTAMENTO ECONÓMICO\n'
    '• DISEÑO ARTÍSTICO (activo en la sede de Milán)\n'
    '• GESTIÓN EMPRESARIAL (activo en la sede de Milán)\n'
    '• MARKETING ÉTICO Y DESARROLLO DIGITAL (activo en la sede de Milán)\n'
    '• GESTIÓN SOSTENIBLE DE LA MODA (activo en la sede de Génova)\n'
    '• GESTIÓN PARA EL DISEÑO Y LA GESTIÓN MARÍTIMA, TURÍSTICA Y PORTUARIA (activo en la sede de Génova)\n\n'
    'FORMACIÓN SUPERIOR DE POSGRADO – 60 CFU\n'
    'Master en CRIMINOLOGÍA E PSICO-SOCIOLOGÍA DE LA DESVIACIÓN';

const _uniumaAdmissionCatalogIt =
    'SEDI DI MILANO E GENOVA\n\n'
    'ITINERARI DI SPECIALIZZAZIONE\n\n'
    'DIPARTIMENTO UMANISTICO\n'
    '• CRIMINOLOGIA E TUTELA SOCIALE\n'
    '• DIPLOMAZIA INTERNAZIONALE E DIRITTI UMANI\n'
    '• DESIGN MULTICULTURALE\n\n'
    'DIPARTIMENTO ECONOMICO\n'
    '• DESIGN ARTISTICO (attivo nella sede di Milano)\n'
    '• GESTIONE D\'IMPRESA (attivo nella sede di Milano)\n'
    '• MARKETING ETICO E SVILUPPO DIGITALE (attivo nella sede di Milano)\n'
    '• GESTIONE SOSTENIBILE DELLA MODA (attivo nella sede di Genova)\n'
    '• GESTIONE PER IL DESIGN E LA GESTIONE MARITTIMA, TURISTICA E PORTUALE (attivo nella sede di Genova)\n\n'
    'FORMAZIONE SUPERIORE DI POST LAUREA – 60 CFU\n'
    'Master in CRIMINOLOGIA E PSICO-SOCIOLOGIA DELLA DEVIANZA';

const _uniumaAdmissionCatalogEn =
    'CAMPUSES IN MILAN AND GENOA\n\n'
    'SPECIALISATION PATHWAYS\n\n'
    'HUMANITIES DEPARTMENT\n'
    '• CRIMINOLOGY AND SOCIAL PROTECTION\n'
    '• INTERNATIONAL DIPLOMACY AND HUMAN RIGHTS\n'
    '• MULTICULTURAL DESIGN\n\n'
    'ECONOMICS DEPARTMENT\n'
    '• ARTISTIC DESIGN (active at the Milan campus)\n'
    '• BUSINESS MANAGEMENT (active at the Milan campus)\n'
    '• ETHICAL MARKETING AND DIGITAL DEVELOPMENT (active at the Milan campus)\n'
    '• SUSTAINABLE FASHION MANAGEMENT (active at the Genoa campus)\n'
    '• MANAGEMENT FOR MARITIME, TOURISM AND PORT DESIGN AND MANAGEMENT (active at the Genoa campus)\n\n'
    'POSTGRADUATE HIGHER EDUCATION – 60 CFU\n'
    'Master\'s in CRIMINOLOGY AND PSYCHO-SOCIOLOGY OF DEVIANCE';

const _uniumaAdmissionCatalogFr =
    'SITES DE MILAN ET GÊNES\n\n'
    'PARCOURS DE SPÉCIALISATION\n\n'
    'DÉPARTEMENT DES HUMANITÉS\n'
    '• CRIMINOLOGIE ET PROTECTION SOCIALE\n'
    '• DIPLOMATIE INTERNATIONALE ET DROITS HUMAINS\n'
    '• DESIGN MULTICULTUREL\n\n'
    'DÉPARTEMENT ÉCONOMIQUE\n'
    '• DESIGN ARTISTIQUE (actif sur le site de Milan)\n'
    '• GESTION D\'ENTREPRISE (actif sur le site de Milan)\n'
    '• MARKETING ÉTHIQUE ET DÉVELOPPEMENT NUMÉRIQUE (actif sur le site de Milan)\n'
    '• GESTION DURABLE DE LA MODE (actif sur le site de Gênes)\n'
    '• GESTION POUR LE DESIGN ET LA GESTION MARITIME, TOURISTIQUE ET PORTUAIRE (actif sur le site de Gênes)\n\n'
    'FORMATION SUPÉRIEURE DE POSTGRADE – 60 CFU\n'
    'Master en CRIMINOLOGIE ET PSYCHO-SOCIOLOGIE DE LA DÉVIANCE';

const _uniumaAdmissionCatalogAr =
    'مقار ميلانو وجنوى\n\n'
    'مسارات التخصص\n\n'
    'قسم العلوم الإنسانية\n'
    '• علم الجريمة والحماية الاجتماعية\n'
    '• الدبلوماسية الدولية وحقوق الإنسان\n'
    '• التصميم متعدد الثقافات\n\n'
    'القسم الاقتصادي\n'
    '• التصميم الفني (نشط في مقر ميلانو)\n'
    '• إدارة الأعمال (نشط في مقر ميلانو)\n'
    '• التسويق الأخلاقي والتطوير الرقمي (نشط في مقر ميلانو)\n'
    '• الإدارة المستدامة للأزياء (نشط في مقر جنوى)\n'
    '• الإدارة للتصميم والإدارة البحرية والسياحية والمينائية (نشط في مقر جنوى)\n\n'
    'تكوين عالٍ لمرحلة ما بعد التخرج – 60 CFU\n'
    'ماجستير في علم الجريمة وعلم النفس الاجتماعي للانحراف';

const _uniumaAdmissionCatalogZh =
    '米兰与热那亚校区\n\n'
    '专业方向\n\n'
    '人文学部\n'
    '• 犯罪学与社会保护\n'
    '• 国际外交与人权\n'
    '• 多元文化设计\n\n'
    '经济学部\n'
    '• 艺术设计（米兰校区开设）\n'
    '• 企业管理（米兰校区开设）\n'
    '• 伦理营销与数字发展（米兰校区开设）\n'
    '• 可持续时尚管理（热那亚校区开设）\n'
    '• 海事、旅游与港口设计与管理（热那亚校区开设）\n\n'
    '研究生高等教育 – 60 CFU\n'
    '犯罪学与越轨心理社会学硕士';

const _uniumaEmptyStats = <({String value, String label})>[];

const _uniuma = PartnerFicha(
  slug: 'uniuma',
  aliases: ['società umanitaria', 'societa umanitaria', 'umanitaria', 'ssml'],
  coverAsset: 'assets/images/partners/uniuma_cover.jpg',
  byLang: {
    'es': PartnerFichaLocale(
      cardTagline:
          'Lenguas, culturas y oportunidades para conectar con el mundo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediación lingüística'],
      detailHeadline: 'Conecta lenguas, culturas y tu futuro.',
      detailDescription: _uniumaDetailDescriptionEs,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey:
              'A. GRADO UNIVERSITARIO TRIENAL EN MEDIACIÓN LINGÜÍSTICA Y CULTURAL – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogEs,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
    'it': PartnerFichaLocale(
      cardTagline:
          'Lingue, culture e opportunità per connettersi con il mondo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediazione linguistica'],
      detailHeadline: 'Collega lingue, culture e il tuo futuro.',
      detailDescription: _uniumaDetailDescriptionIt,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey:
              'A. CORSO DI LAUREA TRIENNALE IN MEDIAZIONE LINGUISTICA E CULTURALE – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogIt,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
    'en': PartnerFichaLocale(
      cardTagline:
          'Languages, cultures and opportunities to connect with the world.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Linguistic mediation'],
      detailHeadline: 'Connect languages, cultures and your future.',
      detailDescription: _uniumaDetailDescriptionEn,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey:
              'A. THREE-YEAR UNIVERSITY DEGREE IN LINGUISTIC AND CULTURAL MEDIATION – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogEn,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
    'fr': PartnerFichaLocale(
      cardTagline:
          'Langues, cultures et opportunités pour se connecter au monde.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Médiation linguistique'],
      detailHeadline: 'Reliez langues, cultures et votre avenir.',
      detailDescription: _uniumaDetailDescriptionFr,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey:
              'A. DIPLÔME UNIVERSITAIRE TRIENNAL EN MÉDIATION LINGUISTIQUE ET CULTURELLE – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogFr,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
    'ar': PartnerFichaLocale(
      cardTagline: 'لغات وثقافات وفرص للتواصل مع العالم.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['الوساطة اللغوية'],
      detailHeadline: 'اربط اللغات والثقافات ومستقبلك.',
      detailDescription: _uniumaDetailDescriptionAr,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey:
              'أ. درجة جامعية ثلاثية السنوات في الوساطة اللغوية والثقافية – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogAr,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
    'zh': PartnerFichaLocale(
      cardTagline: '语言、文化与连接世界的机遇。',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['语言调解'],
      detailHeadline: '连接语言、文化与你的未来。',
      detailDescription: _uniumaDetailDescriptionZh,
      admissionIntro: '',
      admissionSections: [
        PartnerAdmissionSection(
          titleKey: 'A. 语言与文化调解三年制大学学位 – 180 CFU',
          bodyKey: _uniumaAdmissionCatalogZh,
        ),
      ],
      stats: _uniumaEmptyStats,
    ),
  },
);
