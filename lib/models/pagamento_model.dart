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
    return Pagamento(
      id: json['id'] as int,
      richiestaId: json['richiesta_id'] as int,
      userId: json['user_id'] as int,
      importo: (json['importo'] as num).toDouble(),
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

  String get statoReadable {
    switch (stato) {
      case 'pending':
        return 'In attesa';
      case 'awaiting_payment':
        return 'In attesa di pagamento';
      case 'completed':
        return 'Completato';
      case 'paid':
        return 'Pagato';
      case 'failed':
        return 'Fallito';
      case 'cancelled':
        return 'Annullato';
      default:
        return stato;
    }
  }
}
