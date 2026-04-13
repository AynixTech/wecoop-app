class OffertaLavoro {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String companyName;
  final String city;
  final String province;
  final String region;
  final String contractType;
  final String workMode;
  final String salaryRange;
  final String languageRequirement;
  final String phoneWhatsapp;
  final String emailContact;
  final String sourceUrl;
  final String requirements;
  final String schedule;
  final String targetCommunity;
  final String expiresAt;
  final bool isFeatured;
  final bool isActive;
  final String categoryScope;
  final String categoryDirection;
  final String categoryMacro;
  final String categorySub;
  final String publishedAt;
  final List<OffertaCategoria> categories;

  const OffertaLavoro({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.companyName,
    required this.city,
    required this.province,
    required this.region,
    required this.contractType,
    required this.workMode,
    required this.salaryRange,
    required this.languageRequirement,
    required this.phoneWhatsapp,
    required this.emailContact,
    required this.sourceUrl,
    required this.requirements,
    required this.schedule,
    required this.targetCommunity,
    required this.expiresAt,
    required this.isFeatured,
    required this.isActive,
    required this.categoryScope,
    required this.categoryDirection,
    required this.categoryMacro,
    required this.categorySub,
    required this.publishedAt,
    required this.categories,
  });

  factory OffertaLavoro.fromJson(Map<String, dynamic> json) {
    final categoriesRaw = json['categories'];
    final categories = <OffertaCategoria>[];

    if (categoriesRaw is List) {
      for (final item in categoriesRaw) {
        if (item is Map<String, dynamic>) {
          categories.add(OffertaCategoria.fromJson(item));
        }
      }
    }

    return OffertaLavoro(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      region: (json['region'] ?? '').toString(),
      contractType: (json['contract_type'] ?? '').toString(),
      workMode: (json['work_mode'] ?? '').toString(),
      salaryRange: (json['salary_range'] ?? '').toString(),
      languageRequirement: (json['language_requirement'] ?? '').toString(),
      phoneWhatsapp: (json['phone_whatsapp'] ?? '').toString(),
      emailContact: (json['email_contact'] ?? '').toString(),
      sourceUrl: (json['source_url'] ?? '').toString(),
      requirements: (json['requirements'] ?? '').toString(),
      schedule: (json['schedule'] ?? '').toString(),
      targetCommunity: (json['target_community'] ?? '').toString(),
      expiresAt: (json['expires_at'] ?? '').toString(),
      isFeatured: json['is_featured'] == true,
      isActive: json['is_active'] != false,
      categoryScope: (json['category_scope'] ?? 'job').toString(),
      categoryDirection: (json['category_direction'] ?? 'offer').toString(),
      categoryMacro: (json['category_macro'] ?? '').toString(),
      categorySub: (json['category_sub'] ?? '').toString(),
      publishedAt: (json['published_at'] ?? '').toString(),
      categories: categories,
    );
  }
}

class OffertaCategoria {
  final int id;
  final String name;
  final String slug;
  final int count;

  const OffertaCategoria({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  factory OffertaCategoria.fromJson(Map<String, dynamic> json) {
    return OffertaCategoria(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
