class Documento {
  final String id;
  final String tipo; // permesso_soggiorno, passaporto, codice_fiscale, carta_identita
  final String filePath;
  final String fileName;
  final DateTime dataCaricamento;
  final DateTime? dataScadenza;

  Documento({
    required this.id,
    required this.tipo,
    required this.filePath,
    required this.fileName,
    required this.dataCaricamento,
    this.dataScadenza,
  });

  // Converte da JSON
  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      dataCaricamento: DateTime.parse(json['dataCaricamento'] as String),
      dataScadenza: json['dataScadenza'] != null
          ? DateTime.parse(json['dataScadenza'] as String)
          : null,
    );
  }

  // Converte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'filePath': filePath,
      'fileName': fileName,
      'dataCaricamento': dataCaricamento.toIso8601String(),
      'dataScadenza': dataScadenza?.toIso8601String(),
    };
  }

  // Verifica se il documento sta per scadere (entro 30 giorni)
  bool get staPerScadere {
    if (dataScadenza == null) return false;
    final oggi = DateTime.now();
    final differenza = dataScadenza!.difference(oggi).inDays;
    return differenza >= 0 && differenza <= 30;
  }

  // Verifica se il documento è scaduto
  bool get isScaduto {
    if (dataScadenza == null) return false;
    return dataScadenza!.isBefore(DateTime.now());
  }

  // Copia con modifiche
  Documento copyWith({
    String? id,
    String? tipo,
    String? filePath,
    String? fileName,
    DateTime? dataCaricamento,
    DateTime? dataScadenza,
  }) {
    return Documento(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      dataCaricamento: dataCaricamento ?? this.dataCaricamento,
      dataScadenza: dataScadenza ?? this.dataScadenza,
    );
  }
}

// Tipi di documento supportati
class TipoDocumento {
  static const String permessoSoggiorno = 'permesso_soggiorno';
  static const String passaporto = 'passaporto';
  static const String codiceFiscale = 'codice_fiscale';
  static const String cartaIdentita = 'carta_identita';

  static List<String> get all => [
        permessoSoggiorno,
        passaporto,
        codiceFiscale,
        cartaIdentita,
      ];

  static String getDisplayName(String tipo) {
    switch (tipo) {
      case permessoSoggiorno:
        return 'Permesso di soggiorno';
      case passaporto:
        return 'Passaporto';
      case codiceFiscale:
        return 'Codice fiscale';
      case cartaIdentita:
        return 'Carta di identità';
      default:
        return tipo;
    }
  }
}
