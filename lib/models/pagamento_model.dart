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
      if (value is String) return double.parse(value);
      return 0.0;
    }
    
    return Pagamento(
      id: json['id'] as int,
      richiestaId: json['richiesta_id'] as int,
      userId: json['user_id'] as int,
      importo: parseImporto(json['importo']),
      stato: json['stato'] as String,
      metodoPagamento: json['metodo_pagamento'] as String?,
      transactionId: json['transaction_id'] as String?,
      note: json['note'] as String?,
      servizio: json['servizio'] as String?,
      numeroPratica: json['numero_pratica'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at'] as String) 
          : null,
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

  bool get isPending => stato == 'pending' || stato == 'awaiting_payment';
  bool get isPaid => stato == 'paid' || stato == 'completed';
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
        return l10n.paymentStatusCompleted;
      case 'paid':
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
