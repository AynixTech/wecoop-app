import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wecoop_app/screens/firma_digitale/firma_documento_screen.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/attivazione_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/socio_service.dart';
import 'package:wecoop_app/theme/app_colors.dart';
import 'package:wecoop_app/utils/app_logger.dart';

/// Helper per sottoscrizione / consultazione Documento Unico a livello utente.
class DocumentoUnicoFlow {
  static final _storage = SecureStorageService();

  /// Apre il flusso OTP user-level (senza pratica).
  /// Ritorna true se la schermata firma è stata aperta.
  static Future<bool> apriSottoscrizione(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Privacy ack se ancora mancante (non blocca se fallisce).
    try {
      final status = await AttivazioneService.getStatus();
      if (status != null && !status.needsDocumentoUnico) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.translate('documentoUnicoAlreadySigned') ??
                    'Documento Unico già sottoscritto',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
      if (status?.needsPrivacyAck == true) {
        await AttivazioneService.markPrivacyViewed();
      }
    } catch (e) {
      AppLogger.d('⚠️ [DU Flow] pre-check attivazione: $e');
    }

    final resolved = await _resolveUserAndPhone();
    if (!context.mounted) return false;

    if (resolved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.translate('missingDigitalSignatureUserData') ??
                'Dati utente mancanti per la firma',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirmaDocumentoScreen(
          userId: resolved.userId,
          telefono: resolved.telefono,
          // User-level: nessuna pratica associata.
          richiestaId: null,
        ),
      ),
    );
    return true;
  }

  /// Scarica e apre il PDF del Documento Unico dell'utente.
  static Future<void> visualizzaDocumento(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AttivazioneService.downloadDocumentoUnicoPdf();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (result['success'] != true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (result['message'] ??
                        l10n?.translate('documentoUnicoNotAvailable') ??
                        'Documento non disponibile')
                    .toString(),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final bytes = result['pdf_bytes'] as List<int>;
      final filename =
          (result['filename'] as String?) ?? 'Documento_Unico_WECOOP.pdf';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      AppLogger.d('❌ [DU Flow] visualizzaDocumento: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.translate('documentoUnicoNotAvailable') ??
                  'Documento non disponibile',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static Future<({int userId, String telefono})?> _resolveUserAndPhone() async {
    final userIdRaw = await _storage.read(key: 'user_id');
    final socioIdRaw = await _storage.read(key: 'socio_id');
    final telefonoRaw =
        await _storage.read(key: 'telefono') ??
        await _storage.read(key: 'user_phone');

    int? userId = userIdRaw != null
        ? int.tryParse(userIdRaw)
        : (socioIdRaw != null ? int.tryParse(socioIdRaw) : null);
    String? telefono = telefonoRaw?.trim();

    if (userId == null || telefono == null || telefono.isEmpty) {
      try {
        final meData = await SocioService.getMe();
        if (meData != null) {
          final meUserIdRaw = (meData['user_id'] ?? meData['id'])?.toString();
          final meUserId =
              meUserIdRaw != null ? int.tryParse(meUserIdRaw) : null;
          final meTelefono = (meData['telefono'] ?? '').toString().trim();
          if (meUserId != null) {
            userId = meUserId;
            await _storage.write(key: 'user_id', value: meUserId.toString());
          }
          if (meTelefono.isNotEmpty) {
            telefono = meTelefono;
            await _storage.write(key: 'telefono', value: meTelefono);
          }
        }
      } catch (e) {
        AppLogger.d('❌ [DU Flow] getMe fallback: $e');
      }
    }

    if (userId == null || telefono == null || telefono.isEmpty) return null;
    return (userId: userId, telefono: telefono);
  }
}
