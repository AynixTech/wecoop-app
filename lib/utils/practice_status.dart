import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../theme/theme.dart';

/// Stati operativi visibili all'utente (spec V1.0 Lizandro).
/// Separati dallo stato economico (pagamento).
abstract final class PracticeOps {
  static const String ricevuta = 'ricevuta';
  static const String raccoltaDocumenti = 'raccolta_documenti';
  static const String inLavorazione = 'in_lavorazione';
  static const String attesaUtente = 'attesa_utente';

  static const List<String> filterValues = [
    ricevuta,
    raccoltaDocumenti,
    inLavorazione,
    attesaUtente,
  ];
}

abstract final class PracticeStatus {
  PracticeStatus._();

  static String normalize(String stato) {
    return stato.trim().toLowerCase().replaceAll(' ', '_');
  }

  /// Canonical backend `status` (service_requests.status).
  static String canonical(String? stato) {
    final normalized = normalize(stato ?? '');

    if (normalized == 'awaiting_payment' ||
        normalized == 'pending_payment' ||
        normalized == 'in_attesa_di_pagamento' ||
        normalized == 'in_attesa_pagamento' ||
        (normalized.contains('attesa') && normalized.contains('pagament'))) {
      return 'awaiting_payment';
    }

    if (normalized == 'awaiting_signature' ||
        normalized == 'da_firmare' ||
        normalized == 'pending_firma' ||
        normalized == 'in_attesa_di_firma' ||
        normalized == 'in_attesa_firma' ||
        (normalized.contains('firma') &&
            (normalized.contains('attesa') || normalized.contains('pending')))) {
      return 'awaiting_signature';
    }

    if (normalized == 'completed' ||
        normalized == 'completata' ||
        normalized == 'completato') {
      return 'completed';
    }

    if (normalized == 'cancelled' ||
        normalized == 'annullata' ||
        normalized == 'annullato') {
      return 'cancelled';
    }

    if (normalized == 'rejected' ||
        normalized == 'respinta' ||
        normalized == 'respinto' ||
        normalized == 'failed' ||
        normalized == 'fallito') {
      return 'rejected';
    }

    if (normalized == 'integrazione_documentale' ||
        normalized == 'document_integration' ||
        normalized == 'attesa_documenti' ||
        (normalized.contains('integ') && normalized.contains('document'))) {
      return 'integrazione_documentale';
    }

    if (normalized == 'processing' || normalized == 'in_lavorazione') {
      return 'processing';
    }

    if (normalized == 'paid' || normalized == 'pagato' || normalized == 'pagado') {
      return 'paid';
    }

    if (normalized == 'awaiting_appointment' ||
        normalized == 'in_attesa_appuntamento' ||
        (normalized.contains('appunt') && normalized.contains('attesa'))) {
      return 'awaiting_appointment';
    }

    if (normalized == 'appointment_confirmed' ||
        normalized == 'appuntamento_confermato' ||
        (normalized.contains('appunt') && normalized.contains('conferm'))) {
      return 'appointment_confirmed';
    }

    if (normalized == 'pending' ||
        normalized == 'in_attesa' ||
        normalized == 'aperta') {
      return 'pending';
    }

    return normalized;
  }

  /// Pratica chiusa: non in «Le Mie Richieste»; sì in Storico.
  static bool isClosed(String? stato) {
    final c = canonical(stato);
    return c == 'completed' || c == 'cancelled' || c == 'rejected';
  }

  static bool isActive(String? stato) => !isClosed(stato);

  /// Mapping → 4 stati WECOOP (mai partner/ente).
  static String operational(String? stato) {
    switch (canonical(stato)) {
      case 'pending':
        return PracticeOps.ricevuta;
      case 'integrazione_documentale':
        return PracticeOps.raccoltaDocumenti;
      case 'awaiting_payment':
      case 'awaiting_appointment':
      case 'awaiting_signature':
        return PracticeOps.attesaUtente;
      case 'paid':
      case 'processing':
      case 'appointment_confirmed':
      default:
        if (isClosed(stato)) {
          return canonical(stato); // completed / cancelled / rejected
        }
        return PracticeOps.inLavorazione;
    }
  }

  static String operationalLabel(AppLocalizations l10n, String? stato) {
    switch (operational(stato)) {
      case PracticeOps.ricevuta:
        return _tr(l10n, 'opsStatusRicevuta', 'Richiesta ricevuta');
      case PracticeOps.raccoltaDocumenti:
        return _tr(l10n, 'opsStatusRaccoltaDocumenti', 'In raccolta documenti');
      case PracticeOps.inLavorazione:
        return _tr(l10n, 'opsStatusInLavorazione', 'In lavorazione');
      case PracticeOps.attesaUtente:
        return _tr(l10n, 'opsStatusAttesaUtente', 'In attesa utente');
      case 'completed':
        return _tr(l10n, 'opsStatusCompletata', 'Completata');
      case 'cancelled':
        return _tr(l10n, 'opsStatusAnnullata', 'Annullata');
      case 'rejected':
        return _tr(l10n, 'opsStatusRespinta', 'Respinta');
      default:
        return stato ?? '';
    }
  }

  static Color operationalColor(String? stato) {
    switch (operational(stato)) {
      case PracticeOps.ricevuta:
        return Colors.amber.shade800;
      case PracticeOps.raccoltaDocumenti:
        return const Color(0xFFE91E63);
      case PracticeOps.attesaUtente:
        return const Color(0xFF9C27B0);
      case PracticeOps.inLavorazione:
        return AppColors.info;
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  static IconData operationalIcon(String? stato) {
    switch (operational(stato)) {
      case PracticeOps.ricevuta:
        return Icons.inbox_outlined;
      case PracticeOps.raccoltaDocumenti:
        return Icons.folder_open_outlined;
      case PracticeOps.attesaUtente:
        return Icons.person_outline;
      case PracticeOps.inLavorazione:
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  static bool isPaidHint(Map<String, dynamic> richiesta) {
    final pagamento = richiesta['pagamento'];
    if (pagamento is Map && pagamento['ricevuto'] == true) return true;
    return canonical(
          (richiesta['stato'] ?? richiesta['status'] ?? '').toString(),
        ) ==
        'paid';
  }

  static bool needsPayment(Map<String, dynamic> richiesta) {
    if (isPaidHint(richiesta)) return false;
    if (richiesta['puo_pagare'] == true) return true;
    return canonical(
          (richiesta['stato'] ?? richiesta['status'] ?? '').toString(),
        ) ==
        'awaiting_payment';
  }

  static String _tr(AppLocalizations l10n, String key, String fallback) {
    final v = l10n.translate(key);
    return v == key ? fallback : v;
  }
}
