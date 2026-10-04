/// Stato attivazione utente (Documento Unico + Privacy) da GET /attivazione/status.
class AttivazioneStatus {
  final String documentoUnicoStato;
  final String? documentoUnicoVersion;
  final DateTime? documentoUnicoSignedAt;
  final String? documentoUnicoHash;
  final String? documentoUnicoUrl;
  final String? documentoUnicoModalita;
  final String requiredDocumentoUnicoVersion;
  final bool needsPrivacyAck;
  final bool needsDocumentoUnico;
  final bool utenteAttivato;

  const AttivazioneStatus({
    required this.documentoUnicoStato,
    this.documentoUnicoVersion,
    this.documentoUnicoSignedAt,
    this.documentoUnicoHash,
    this.documentoUnicoUrl,
    this.documentoUnicoModalita,
    required this.requiredDocumentoUnicoVersion,
    required this.needsPrivacyAck,
    required this.needsDocumentoUnico,
    required this.utenteAttivato,
  });

  bool get isSottoscritto =>
      documentoUnicoStato.toUpperCase() == 'SOTTOSCRITTO';

  bool get isDaAggiornare =>
      documentoUnicoStato.toUpperCase() == 'DA_AGGIORNARE';

  factory AttivazioneStatus.fromJson(Map<String, dynamic> json) {
    final nested = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    DateTime? signedAt;
    final rawSigned = nested['documento_unico_signed_at'];
    if (rawSigned is String && rawSigned.isNotEmpty) {
      signedAt = DateTime.tryParse(rawSigned);
    }

    return AttivazioneStatus(
      documentoUnicoStato:
          (nested['documento_unico_stato'] ?? 'NON_SOTTOSCRITTO').toString(),
      documentoUnicoVersion: nested['documento_unico_version']?.toString(),
      documentoUnicoSignedAt: signedAt,
      documentoUnicoHash: nested['documento_unico_hash']?.toString(),
      documentoUnicoUrl: nested['documento_unico_url']?.toString(),
      documentoUnicoModalita: nested['documento_unico_modalita']?.toString(),
      requiredDocumentoUnicoVersion:
          (nested['required_documento_unico_version'] ?? '1.0').toString(),
      needsPrivacyAck: nested['needs_privacy_ack'] == true,
      needsDocumentoUnico: nested['needs_documento_unico'] == true,
      utenteAttivato: nested['utente_attivato'] == true,
    );
  }
}
