// Modello per il documento unico scaricato
class DocumentoUnico {
  final String url;
  final String contenutoTesto;
  final String hashSha256;
  final String nome;
  final DateTime dataGenerazione;

  DocumentoUnico({
    required this.url,
    required this.contenutoTesto,
    required this.hashSha256,
    required this.nome,
    required this.dataGenerazione,
  });

  factory DocumentoUnico.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['data_generazione'] ?? json['timestamp'];

    DateTime dataGenerazione;
    if (rawTimestamp is int) {
      dataGenerazione = DateTime.fromMillisecondsSinceEpoch(rawTimestamp * 1000);
    } else if (rawTimestamp is String) {
      final tsInt = int.tryParse(rawTimestamp);
      if (tsInt != null) {
        dataGenerazione = DateTime.fromMillisecondsSinceEpoch(tsInt * 1000);
      } else {
        dataGenerazione = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
      }
    } else {
      dataGenerazione = DateTime.now();
    }

    return DocumentoUnico(
      url: (json['url'] ?? json['filepath'] ?? '').toString(),
      contenutoTesto: (json['contenuto_testo'] ?? '').toString(),
      hashSha256: (json['hash_sha256'] ?? '').toString(),
      nome: (json['nome'] ?? 'documento_unico.pdf').toString(),
      dataGenerazione: dataGenerazione,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'contenuto_testo': contenutoTesto,
      'hash_sha256': hashSha256,
      'nome': nome,
      'data_generazione': dataGenerazione.toIso8601String(),
    };
  }
}

// Modello per la response di generazione OTP
class OTPGenerateResponse {
  final String id;
  final DateTime scadenza;
  final int tentativiRimasti;
  final String metodoInvio;

  OTPGenerateResponse({
    required this.id,
    required this.scadenza,
    required this.tentativiRimasti,
    required this.metodoInvio,
  });

  factory OTPGenerateResponse.fromJson(Map<String, dynamic> json) {
    return OTPGenerateResponse(
      id: json['id'] as String,
      scadenza: DateTime.parse(json['scadenza'] as String),
      tentativiRimasti: json['tentativi_rimasti'] as int,
      metodoInvio: json['metodo_invio'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scadenza': scadenza.toIso8601String(),
      'tentativi_rimasti': tentativiRimasti,
      'metodo_invio': metodoInvio,
    };
  }
}

// Modello per la verifica OTP
class OTPVerifyResponse {
  final String id;
  final bool verified;
  final DateTime verifiedAt;

  OTPVerifyResponse({
    required this.id,
    required this.verified,
    required this.verifiedAt,
  });

  factory OTPVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OTPVerifyResponse(
      id: json['id'] as String,
      verified: json['verified'] as bool,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verified': verified,
      'verified_at': verifiedAt.toIso8601String(),
    };
  }
}

// Modello per la firma digitale
class FirmaDigitale {
  final String id;
  final int richiestaId;
  final DateTime firmaTimestamp;
  final String metodoFirma; // FES - Firma Elettronica Semplice
  final String status; // valida, non_valida, scaduta
  final bool hashVerificato;

  FirmaDigitale({
    required this.id,
    required this.richiestaId,
    required this.firmaTimestamp,
    required this.metodoFirma,
    required this.status,
    required this.hashVerificato,
  });

  factory FirmaDigitale.fromJson(Map<String, dynamic> json) {
    return FirmaDigitale(
      id: json['id'] as String,
      richiestaId: json['richiesta_id'] as int,
      firmaTimestamp: DateTime.parse(json['firma_timestamp'] as String),
      metodoFirma: json['metodo_firma'] as String,
      status: json['status'] as String,
      hashVerificato: json['hash_verificato'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'richiesta_id': richiestaId,
      'firma_timestamp': firmaTimestamp.toIso8601String(),
      'metodo_firma': metodoFirma,
      'status': status,
      'hash_verificato': hashVerificato,
    };
  }
}

// Modello per lo stato della firma
class FirmaStatus {
  final bool firmato;
  final String? id;
  final int richiestaId;
  final String? status; // valida, non_valida, scaduta
  final DateTime? dataFirma;
  final String? metodo;
  final String? deviceFirma;
  final String? documentoUrl;
  final String? documentoDownloadUrl;
  final String? firmaHash;
  final String? documentoHashSha256;
  final Map<String, dynamic>? metadata;

  FirmaStatus({
    required this.firmato,
    this.id,
    required this.richiestaId,
    this.status,
    this.dataFirma,
    this.metodo,
    this.deviceFirma,
    this.documentoUrl,
    this.documentoDownloadUrl,
    this.firmaHash,
    this.documentoHashSha256,
    this.metadata,
  });

  factory FirmaStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDataFirma;
    final rawDataFirma = json['data_firma'] ?? json['firma_timestamp'];
    if (rawDataFirma is String) {
      parsedDataFirma = DateTime.tryParse(rawDataFirma);
    }

    return FirmaStatus(
      firmato: json['firmato'] == true,
      id: (json['id'] ?? json['firma_id'])?.toString(),
      richiestaId: (json['richiesta_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString(),
      dataFirma: parsedDataFirma,
      metodo: (json['metodo'] ?? json['firma_tipo'])?.toString(),
      deviceFirma: json['device_firma']?.toString(),
      documentoUrl: json['documento_url']?.toString(),
      documentoDownloadUrl: json['documento_download_url']?.toString(),
      firmaHash: json['firma_hash']?.toString(),
      documentoHashSha256: json['documento_hash_sha256']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firmato': firmato,
      'id': id,
      'richiesta_id': richiestaId,
      'status': status,
      'data_firma': dataFirma?.toIso8601String(),
      'metodo': metodo,
      'device_firma': deviceFirma,
      'documento_url': documentoUrl,
      'documento_download_url': documentoDownloadUrl,
      'firma_hash': firmaHash,
      'documento_hash_sha256': documentoHashSha256,
      'metadata': metadata,
    };
  }
}

// Modello per la verifica dell'integrità firma
class VerificaIntegrita {
  final String firmaId;
  final String integrita; // verificata, non_verificata
  final bool hashCorrisponde;
  final bool otpValidato;
  final bool timestampValido;
  final String metodoFirma;
  final DateTime dataVerifica;

  VerificaIntegrita({
    required this.firmaId,
    required this.integrita,
    required this.hashCorrisponde,
    required this.otpValidato,
    required this.timestampValido,
    required this.metodoFirma,
    required this.dataVerifica,
  });

  factory VerificaIntegrita.fromJson(Map<String, dynamic> json) {
    return VerificaIntegrita(
      firmaId: json['firma_id'] as String,
      integrita: json['integrita'] as String,
      hashCorrisponde: json['hash_corrisponde'] as bool,
      otpValidato: json['otp_validato'] as bool,
      timestampValido: json['timestamp_valido'] as bool,
      metodoFirma: json['metodo_firma'] as String,
      dataVerifica: DateTime.parse(json['data_verifica'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firma_id': firmaId,
      'integrita': integrita,
      'hash_corrisponde': hashCorrisponde,
      'otp_validato': otpValidato,
      'timestamp_valido': timestampValido,
      'metodo_firma': metodoFirma,
      'data_verifica': dataVerifica.toIso8601String(),
    };
  }
}

// Exception personalizzate per la firma digitale
class FirmaDigitaleException implements Exception {
  final String message;
  final String? code;
  final int? tentativiRimasti;
  final int? status;
  final Map<String, dynamic>? details;

  FirmaDigitaleException({
    required this.message,
    this.code,
    this.tentativiRimasti,
    this.status,
    this.details,
  });

  @override
  String toString() => message;
}
