/// Modello per un documento dello "Storico pratiche" (730, ISEE, ...).
///
/// Corrisponde alla risposta dell'endpoint REST WordPress:
/// GET /wp-json/wecoop/v1/pratiche/me
class PraticaDocumento {
  final int id;
  final String tipo;
  final String tipoLabel;
  final int? anno;
  final String titolo;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final DateTime? dataCaricamento;
  final String downloadUrl;

  PraticaDocumento({
    required this.id,
    required this.tipo,
    required this.tipoLabel,
    this.anno,
    required this.titolo,
    required this.fileName,
    this.fileSize = 0,
    this.mimeType,
    this.dataCaricamento,
    required this.downloadUrl,
  });

  bool get isPdf =>
      (mimeType ?? '').toLowerCase().contains('pdf') ||
      fileName.toLowerCase().endsWith('.pdf');

  factory PraticaDocumento.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['data_caricamento'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    int? parsedAnno;
    final rawAnno = json['anno'];
    if (rawAnno is int) {
      parsedAnno = rawAnno;
    } else if (rawAnno is String && rawAnno.isNotEmpty) {
      parsedAnno = int.tryParse(rawAnno);
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PraticaDocumento(
      id: parseInt(json['id']),
      tipo: (json['tipo'] as String?) ?? '',
      tipoLabel: (json['tipo_label'] as String?) ?? (json['tipo'] as String?) ?? '',
      anno: parsedAnno,
      titolo: (json['titolo'] as String?) ??
          (json['tipo_label'] as String?) ??
          '',
      fileName: (json['file_name'] as String?) ?? '',
      fileSize: parseInt(json['file_size']),
      mimeType: json['mime_type'] as String?,
      dataCaricamento: parsedDate,
      downloadUrl: (json['download_url'] as String?) ?? '',
    );
  }

  /// Dimensione leggibile (KB/MB).
  String get fileSizeLabel {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(0)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
