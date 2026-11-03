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

const _uniumaEmptyStats = <({String value, String label})>[];

/// Sezioni ammissione originali (pre-catalogo itinerari). Il brief QA non
/// chiedeva di sostituirle con l’elenco dei percorsi.
const _uniumaAdmissionEs = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: 'Cómo empezar',
    stepsKeys: [
      'Consulta el programa y su convocatoria vigente.',
      'Solicita el encuentro con la dirección académica.',
      'Confirma los requisitos y presenta la documentación solicitada.',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: 'Documentación a preparar',
    bodyKey:
        'Como punto de partida, ten a mano tu documento de identidad y la información sobre tus estudios previos. La lista definitiva depende del programa y debe confirmarla UNIUMA.',
  ),
  PartnerAdmissionSection(
    titleKey: '¿Tienes un título extranjero?',
    bodyKey:
        'Si tu título se obtuvo fuera de Italia, consulta con UNIUMA la documentación, las traducciones o el reconocimiento que puedan corresponder, además de los plazos de la convocatoria.',
  ),
];

const _uniumaAdmissionIt = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: 'Come iniziare',
    stepsKeys: [
      'Consulta il percorso e il bando vigente.',
      'Richiedi l’incontro con la direzione accademica.',
      'Conferma i requisiti e presenta la documentazione richiesta.',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: 'Documentazione da preparare',
    bodyKey:
        'Come punto di partenza, tieni a portata di mano il documento d’identità e le informazioni sui tuoi studi precedenti. L’elenco definitivo dipende dal percorso e va confermato con UNIUMA.',
  ),
  PartnerAdmissionSection(
    titleKey: 'Hai un titolo estero?',
    bodyKey:
        'Se il tuo titolo è stato conseguito fuori dall’Italia, verifica con UNIUMA la documentazione, le traduzioni o il riconoscimento eventualmente richiesti, oltre alle scadenze del bando.',
  ),
];

const _uniumaAdmissionEn = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: 'How to start',
    stepsKeys: [
      'Review the programme and its current call for applications.',
      'Request a meeting with the academic board.',
      'Confirm the requirements and submit the requested documents.',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: 'Documents to prepare',
    bodyKey:
        'As a starting point, keep your identity document and information about your previous studies ready. The final list depends on the programme and must be confirmed with UNIUMA.',
  ),
  PartnerAdmissionSection(
    titleKey: 'Do you have a foreign degree?',
    bodyKey:
        'If your degree was obtained outside Italy, check with UNIUMA which documents, translations or recognition may be required, as well as the call deadlines.',
  ),
];

const _uniumaAdmissionFr = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: 'Comment commencer',
    stepsKeys: [
      'Consultez le programme et son appel à candidatures en vigueur.',
      'Demandez un entretien avec la direction académique.',
      'Confirmez les exigences et présentez la documentation demandée.',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: 'Documents à préparer',
    bodyKey:
        'Pour commencer, préparez votre pièce d’identité et les informations sur vos études antérieures. La liste définitive dépend du programme et doit être confirmée avec UNIUMA.',
  ),
  PartnerAdmissionSection(
    titleKey: 'Avez-vous un diplôme étranger ?',
    bodyKey:
        'Si votre diplôme a été obtenu hors d’Italie, vérifiez auprès d’UNIUMA la documentation, les traductions ou la reconnaissance éventuellement requises, ainsi que les délais de l’appel.',
  ),
];

const _uniumaAdmissionAr = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: 'كيف تبدأ',
    stepsKeys: [
      'اطّلع على البرنامج ودعوته الحالية.',
      'اطلب لقاءً مع الإدارة الأكاديمية.',
      'أكّد المتطلبات وقدّم الوثائق المطلوبة.',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: 'وثائق للتحضير',
    bodyKey:
        'كنقطة انطلاق، جهّز وثيقة هويتك ومعلومات دراستك السابقة. تعتمد القائمة النهائية على البرنامج ويجب تأكيدها مع UNIUMA.',
  ),
  PartnerAdmissionSection(
    titleKey: 'هل لديك شهادة أجنبية؟',
    bodyKey:
        'إذا حصلت على شهادتك خارج إيطاليا، راجع مع UNIUMA الوثائق أو الترجمات أو الاعتراف المطلوب، بالإضافة إلى مواعيد الدعوة.',
  ),
];

const _uniumaAdmissionZh = <PartnerAdmissionSection>[
  PartnerAdmissionSection(
    titleKey: '如何开始',
    stepsKeys: [
      '查阅课程及现行招生简章。',
      '申请与学术管理部门会面。',
      '确认要求并提交所需材料。',
    ],
  ),
  PartnerAdmissionSection(
    titleKey: '需准备的材料',
    bodyKey: '首先请准备身份证件及既往学历信息。最终清单取决于课程，需与 UNIUMA 确认。',
  ),
  PartnerAdmissionSection(
    titleKey: '你持有外国学历吗？',
    bodyKey: '若学历在意大利境外获得，请向 UNIUMA 确认所需文件、翻译或认证，以及招生截止日期。',
  ),
];

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
      admissionIntro:
          'El acceso y la documentación dependen del programa elegido y de tus estudios previos.',
      admissionSections: _uniumaAdmissionEs,
      stats: _uniumaEmptyStats,
    ),
    'it': PartnerFichaLocale(
      cardTagline:
          'Lingue, culture e opportunità per connettersi con il mondo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediazione linguistica'],
      detailHeadline: 'Collega lingue, culture e il tuo futuro.',
      detailDescription: _uniumaDetailDescriptionIt,
      admissionIntro:
          'L’accesso e la documentazione dipendono dal percorso scelto e dai tuoi studi precedenti.',
      admissionSections: _uniumaAdmissionIt,
      stats: _uniumaEmptyStats,
    ),
    'en': PartnerFichaLocale(
      cardTagline:
          'Languages, cultures and opportunities to connect with the world.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Linguistic mediation'],
      detailHeadline: 'Connect languages, cultures and your future.',
      detailDescription: _uniumaDetailDescriptionEn,
      admissionIntro:
          'Access and documentation depend on the chosen programme and your previous studies.',
      admissionSections: _uniumaAdmissionEn,
      stats: _uniumaEmptyStats,
    ),
    'fr': PartnerFichaLocale(
      cardTagline:
          'Langues, cultures et opportunités pour se connecter au monde.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Médiation linguistique'],
      detailHeadline: 'Reliez langues, cultures et votre avenir.',
      detailDescription: _uniumaDetailDescriptionFr,
      admissionIntro:
          'L’accès et la documentation dépendent du programme choisi et de vos études antérieures.',
      admissionSections: _uniumaAdmissionFr,
      stats: _uniumaEmptyStats,
    ),
    'ar': PartnerFichaLocale(
      cardTagline: 'لغات وثقافات وفرص للتواصل مع العالم.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['الوساطة اللغوية'],
      detailHeadline: 'اربط اللغات والثقافات ومستقبلك.',
      detailDescription: _uniumaDetailDescriptionAr,
      admissionIntro:
          'يعتمد القبول والوثائق على البرنامج المختار ودراستك السابقة.',
      admissionSections: _uniumaAdmissionAr,
      stats: _uniumaEmptyStats,
    ),
    'zh': PartnerFichaLocale(
      cardTagline: '语言、文化与连接世界的机遇。',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['语言调解'],
      detailHeadline: '连接语言、文化与你的未来。',
      detailDescription: _uniumaDetailDescriptionZh,
      admissionIntro: '入学与所需材料取决于所选课程及你的既往学历。',
      admissionSections: _uniumaAdmissionZh,
      stats: _uniumaEmptyStats,
    ),
  },
);
