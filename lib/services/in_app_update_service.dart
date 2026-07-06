import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Gestisce l'aggiornamento nativo tramite Google Play (In-App Updates).
///
/// Funziona SOLO su Android e SOLO quando l'app è installata dal Play Store
/// (non funziona con build di debug/sideload: in quel caso l'API risponde
/// che non ci sono aggiornamenti, ed è normale).
///
/// Non richiede backend: Google Play rileva automaticamente se esiste una
/// versione più recente pubblicata rispetto a quella installata.
class InAppUpdateService {
  /// Controlla se c'è un aggiornamento e, se disponibile, avvia
  /// l'aggiornamento IMMEDIATE (schermata bloccante a schermo intero di
  /// Google che obbliga l'utente ad aggiornare).
  static Future<void> checkAndForceUpdate() async {
    // In-App Updates è disponibile solo su Android.
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // immediateUpdateAllowed indica che Google consente il flusso bloccante.
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Fallback: se l'immediate non è permesso, usa il flexible
          // (download in background, poi completa l'installazione).
          await _performFlexibleUpdate();
        }
      }
    } catch (e) {
      // Errori tipici: app non installata dal Play Store (debug/sideload),
      // nessuna connessione, Play Services assenti. Non blocchiamo l'utente.
      debugPrint('InAppUpdateService: aggiornamento non disponibile: $e');
    }
  }

  static Future<void> _performFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('InAppUpdateService: flexible update fallito: $e');
    }
  }
}
