class OffertaFormativa {
  final int id;
  final String titolo;
  final String descrizione;
  final int partnerId;
  final String partnerNome;
  final String partnerLogoUrl;
  final String partnerSitoWeb;
  final String categoria;
  final String durata;
  final String linkInfo;
  final String imageUrl;
  final int ordine;

  const OffertaFormativa({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.partnerId,
    required this.partnerNome,
    required this.partnerLogoUrl,
    required this.partnerSitoWeb,
    required this.categoria,
    required this.durata,
    required this.linkInfo,
    required this.imageUrl,
    required this.ordine,
  });

  factory OffertaFormativa.fromJson(Map<String, dynamic> json) {
    return OffertaFormativa(
      id:               (json['id'] as num?)?.toInt() ?? 0,
      titolo:           json['titolo'] as String? ?? '',
      descrizione:      json['descrizione'] as String? ?? '',
      partnerId:        (json['partner_id'] as num?)?.toInt() ?? 0,
      partnerNome:      json['partner_nome'] as String? ?? '',
      partnerLogoUrl:   json['partner_logo_url'] as String? ?? '',
      partnerSitoWeb:   json['partner_sito_web'] as String? ?? '',
      categoria:        json['categoria'] as String? ?? '',
      durata:           json['durata'] as String? ?? '',
      linkInfo:         json['link_info'] as String? ?? '',
      imageUrl:         json['image_url'] as String? ?? '',
      ordine:           (json['ordine'] as num?)?.toInt() ?? 0,
    );
  }
}
