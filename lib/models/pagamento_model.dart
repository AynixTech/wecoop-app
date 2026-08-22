import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

class Pagamento {
  final int id;
  final int richiestaId;
  final int userId;
  final double importo;
  final String stato; // 'pending', 'awaiting_payment', 'completed', 'paid', 'failed', 'cancelled'
  final String? metodoPagamento; // 'stripe', 'paypal', etc.
  final String? transactionId;
  final String? note;
  final String? servizio;
  final String? numeroPratica;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;

  Pagamento({
    required this.id,
    required this.richiestaId,
    required this.userId,
    required this.importo,
    required this.stato,
    this.metodoPagamento,
    this.transactionId,
    this.note,
    this.servizio,
    this.numeroPratica,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
  });

  factory Pagamento.fromJson(Map<String, dynamic> json) {
    // Parse importo gestendo sia String che num
    double parseImporto(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Il backend Node/Postgres può restituire gli id come stringa (BIGINT).
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return Pagamento(
      id: parseInt(json['id']),
      richiestaId: parseInt(json['richiesta_id']),
      userId: parseInt(json['user_id']),
      importo: parseImporto(json['importo']),
      stato: (json['stato'] ?? 'pending').toString(),
      metodoPagamento: json['metodo_pagamento']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      note: json['note']?.toString(),
      servizio: json['servizio']?.toString(),
      numeroPratica: json['numero_pratica']?.toString(),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']),
      paidAt: parseDate(json['paid_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'richiesta_id': richiestaId,
      'user_id': userId,
      'importo': importo,
      'stato': stato,
      'metodo_pagamento': metodoPagamento,
      'transaction_id': transactionId,
      'note': note,
      'servizio': servizio,
      'numero_pratica': numeroPratica,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  bool get isPending {
    final s = stato.toLowerCase();
    return s == 'pending' ||
        s == 'awaiting_payment' ||
        s == 'in_attesa' ||
        s == 'in attesa';
  }

  bool get isPaid {
    final s = stato.toLowerCase();
    return s == 'paid' ||
        s == 'completed' ||
        s == 'completato' ||
        s == 'pagato' ||
        s == 'ricevuto' ||
        s == 'succeeded';
  }
  bool get isFailed => stato == 'failed';
  bool get isCancelled => stato == 'cancelled';

  /// Restituisce la label tradotta dello stato
  /// Richiede il BuildContext per accedere alle localizzazioni
  String statoReadable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return stato;
    
    switch (stato) {
      case 'pending':
        return l10n.paymentStatusPending;
      case 'awaiting_payment':
        return l10n.paymentStatusAwaitingPayment;
      case 'completed':
      case 'completato':
        return l10n.paymentStatusCompleted;
      case 'paid':
      case 'pagato':
        return l10n.paymentStatusPaid;
      case 'failed':
        return l10n.paymentStatusFailed;
      case 'cancelled':
        return l10n.paymentStatusCancelled;
      default:
        return stato;
    }
  }
}
