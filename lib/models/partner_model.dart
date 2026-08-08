class Partner {
  final int id;
  final String nome;
  final String logoUrl;
  final String websiteUrl;
  final String descrizione;
  final String descrizioneEstesa;
  final String tipo;
  final String citta;
  final int ordine;

  Partner({
    required this.id,
    required this.nome,
    required this.logoUrl,
    required this.websiteUrl,
    required this.descrizione,
    this.descrizioneEstesa = '',
    this.tipo = 'generico',
    this.citta = '',
    required this.ordine,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    // Il backend Node espone i campi come name/website/description; manteniamo
    // la retrocompatibilità con eventuali chiavi legacy (nome/website_url/…).
    return Partner(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['name'] ?? json['nome']) as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      websiteUrl: (json['website'] ?? json['website_url']) as String? ?? '',
      descrizione: (json['description'] ?? json['descrizione']) as String? ?? '',
      descrizioneEstesa: json['descrizione_estesa'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'generico',
      citta: json['citta'] as String? ?? '',
      ordine: (json['ordine'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Materiale multimediale associato a un Partner Accademico.
class PartnerMedia {
  final int id;
  final String tipo; // video | brochure | presentazione | galleria | catalogo | documento
  final String titolo;
  final String descrizione;
  final String url;
  final String mime;
  final int ordine;

  const PartnerMedia({
    required this.id,
    required this.tipo,
    required this.titolo,
    required this.descrizione,
    required this.url,
    required this.mime,
    required this.ordine,
  });

  bool get isImmagine => mime.startsWith('image/') || tipo == 'galleria';
  bool get isVideo => mime.startsWith('video/') || tipo == 'video';
  bool get isPdf => mime == 'application/pdf' || tipo == 'brochure' || tipo == 'presentazione' || tipo == 'catalogo';

  factory PartnerMedia.fromJson(Map<String, dynamic> json) {
    return PartnerMedia(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipo: json['tipo'] as String? ?? 'documento',
      titolo: json['titolo'] as String? ?? '',
      descrizione: json['descrizione'] as String? ?? '',
      url: json['url'] as String? ?? '',
      mime: json['mime'] as String? ?? '',
      ordine: (json['ordine'] as num?)?.toInt() ?? 0,
    );
  }
}
