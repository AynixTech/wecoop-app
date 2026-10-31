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

const _uniuma = PartnerFicha(
  slug: 'uniuma',
  aliases: ['società umanitaria', 'societa umanitaria', 'umanitaria', 'ssml'],
  coverAsset: 'assets/images/partners/uniuma_cover.jpg',
  byLang: {
    'es': PartnerFichaLocale(
      cardTagline:
          'Lenguas, culturas y oportunidades para conectar con el mundo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediación lingüística', '3 años'],
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
      stats: [
        (value: '3 años', label: 'Programa principal'),
        (value: '180 CFU', label: 'Créditos académicos'),
      ],
    ),
    'it': PartnerFichaLocale(
      cardTagline:
          'Lingue, culture e opportunità per connettersi con il mondo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediazione linguistica', '3 anni'],
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
      stats: [
        (value: '3 anni', label: 'Percorso principale'),
        (value: '180 CFU', label: 'Crediti formativi'),
      ],
    ),
    'en': PartnerFichaLocale(
      cardTagline:
          'Languages, cultures and opportunities to connect with the world.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Linguistic mediation', '3 years'],
      detailHeadline: 'Connect languages, cultures and your future.',
      detailDescription:
          'Higher education in linguistic and cultural mediation, in the heart of Milan.',
      admissionIntro:
          'Access and documentation depend on the chosen programme and your previous studies.',
      admissionSections: [
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
      ],
      stats: [
        (value: '3 years', label: 'Main programme'),
        (value: '180 CFU', label: 'Academic credits'),
      ],
    ),
    'fr': PartnerFichaLocale(
      cardTagline:
          'Langues, cultures et opportunités pour se connecter au monde.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Médiation linguistique', '3 ans'],
      detailHeadline: 'Reliez langues, cultures et votre avenir.',
      detailDescription:
          'Formation supérieure en médiation linguistique et culturelle, au cœur de Milan.',
      admissionIntro:
          'L’accès et la documentation dépendent du programme choisi et de vos études antérieures.',
      admissionSections: [
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
      ],
      stats: [
        (value: '3 ans', label: 'Programme principal'),
        (value: '180 CFU', label: 'Crédits académiques'),
      ],
    ),
    'ar': PartnerFichaLocale(
      cardTagline: 'لغات وثقافات وفرص للتواصل مع العالم.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['الوساطة اللغوية', '3 سنوات'],
      detailHeadline: 'اربط اللغات والثقافات ومستقبلك.',
      detailDescription:
          'تعليم عالٍ في الوساطة اللغوية والثقافية، في قلب ميلانو.',
      admissionIntro:
          'يعتمد القبول والوثائق على البرنامج المختار ودراستك السابقة.',
      admissionSections: [
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
      ],
      stats: [
        (value: '3 سنوات', label: 'البرنامج الرئيسي'),
        (value: '180 CFU', label: 'وحدات دراسية'),
      ],
    ),
    'zh': PartnerFichaLocale(
      cardTagline: '语言、文化与连接世界的机遇。',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['语言调解', '3 年'],
      detailHeadline: '连接语言、文化与你的未来。',
      detailDescription: '米兰市中心的语言与文化调解高等教育。',
      admissionIntro: '入学与所需材料取决于所选课程及你的既往学历。',
      admissionSections: [
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
          bodyKey:
              '首先请准备身份证件及既往学历信息。最终清单取决于课程，需与 UNIUMA 确认。',
        ),
        PartnerAdmissionSection(
          titleKey: '你持有外国学历吗？',
          bodyKey:
              '若学历在意大利境外获得，请向 UNIUMA 确认所需文件、翻译或认证，以及招生截止日期。',
        ),
      ],
      stats: [
        (value: '3 年', label: '主修课程'),
        (value: '180 CFU', label: '学分'),
      ],
    ),
  },
);
