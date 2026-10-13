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
  final String coverAsset;
  final Map<String, PartnerFichaLocale> byLang;

  const PartnerFicha({
    required this.slug,
    required this.coverAsset,
    required this.byLang,
  });

  PartnerFichaLocale localeFor(String lang) =>
      byLang[lang] ?? byLang['en'] ?? byLang['it']!;
}

/// Match per nome partner API (case-insensitive, contiene lo slug).
PartnerFicha? fichaForPartnerName(String nome) {
  final n = nome.trim().toLowerCase();
  if (n.isEmpty) return null;
  for (final f in _catalog) {
    if (n.contains(f.slug)) return f;
  }
  return null;
}

const _catalog = <PartnerFicha>[_uniuma];

const _uniuma = PartnerFicha(
  slug: 'uniuma',
  coverAsset: 'assets/images/partners/uniuma_cover.jpg',
  byLang: {
    'es': PartnerFichaLocale(
      cardTagline:
          'Lenguas, culturas y oportunidades para conectar con el mundo.',
      affiliation: 'SSML «P. M. Loria» · Società Umanitaria',
      tags: ['Mediación lingüística', '3 años'],
      detailHeadline: 'Conecta lenguas, culturas y tu futuro.',
      detailDescription:
          'Formación superior en mediación lingüística y cultural, en el corazón de Milán.',
      admissionIntro:
          'El acceso y la documentación dependen del programa elegido y de tus estudios previos.',
      admissionSections: [
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
      detailDescription:
          'Formazione superiore in mediazione linguistica e culturale, nel cuore di Milano.',
      admissionIntro:
          'L’accesso e la documentazione dipendono dal percorso scelto e dai tuoi studi precedenti.',
      admissionSections: [
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
