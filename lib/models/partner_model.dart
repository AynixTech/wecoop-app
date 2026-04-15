class Partner {
  final int id;
  final String nome;
  final String logoUrl;
  final String websiteUrl;
  final String descrizione;
  final int ordine;

  Partner({
    required this.id,
    required this.nome,
    required this.logoUrl,
    required this.websiteUrl,
    required this.descrizione,
    required this.ordine,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      websiteUrl: json['website_url'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      ordine: json['ordine'] as int? ?? 0,
    );
  }
}
