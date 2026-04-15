class OffertaFormativa {
  final int id;
  final String titolo;
  final String descrizione;
  final String partnerNome;
  final String categoria;
  final String durata;
  final String linkInfo;
  final String imageUrl;
  final int ordine;

  const OffertaFormativa({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.partnerNome,
    required this.categoria,
    required this.durata,
    required this.linkInfo,
    required this.imageUrl,
    required this.ordine,
  });

  factory OffertaFormativa.fromJson(Map<String, dynamic> json) {
    return OffertaFormativa(
      id:          (json['id'] as num?)?.toInt() ?? 0,
      titolo:      json['titolo'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      partnerNome: json['partner_nome'] as String? ?? '',
      categoria:   json['categoria'] as String? ?? '',
      durata:      json['durata'] as String? ?? '',
      linkInfo:    json['link_info'] as String? ?? '',
      imageUrl:    json['image_url'] as String? ?? '',
      ordine:      (json['ordine'] as num?)?.toInt() ?? 0,
    );
  }
}
