/// Modello per le richieste di supporto (ticket) di WeCoop.
///
/// Rispecchia la tabella `richieste_supporto` del backend Node
/// (equivalente al CPT WordPress `richiesta_supporto`).
/// Il numero ticket ha il formato `SUP-YYYY-NNNNN`.
library;

DateTime? _parseServerDate(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  final normalized = s.contains('T') ? s : s.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

int _parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

/// Ticket di supporto creato dall'app e gestito dal back-office.
class SupportoTicket {
  final int id;
  final String numeroTicket;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String serviceName;
  final String serviceCategory;
  final String? currentScreen;
  final String tipoRichiesta;

  /// `alta` | `media` | `bassa`
  final String priorita;

  /// `aperta` | `in_lavorazione` | `risolta` | `chiusa`
  final String status;
  final String? messaggio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportoTicket({
    required this.id,
    required this.numeroTicket,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    required this.serviceName,
    required this.serviceCategory,
    this.currentScreen,
    required this.tipoRichiesta,
    required this.priorita,
    required this.status,
    this.messaggio,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportoTicket.fromJson(Map<String, dynamic> json) {
    return SupportoTicket(
      id: _parseInt(json['id']),
      numeroTicket: json['numero_ticket']?.toString() ?? '',
      userId: json['user_id'] != null ? _parseInt(json['user_id']) : null,
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      userPhone: json['user_phone']?.toString(),
      serviceName: json['service_name']?.toString() ?? 'Servizio Generico',
      serviceCategory: json['service_category']?.toString() ?? 'generico',
      currentScreen: json['current_screen']?.toString(),
      tipoRichiesta: json['tipo_richiesta']?.toString() ?? 'aiuto_automatico',
      priorita: json['priorita']?.toString() ?? 'media',
      status: json['status']?.toString() ?? 'aperta',
      messaggio: json['messaggio']?.toString(),
      createdAt: _parseServerDate(json['created_at']),
      updatedAt: _parseServerDate(json['updated_at']),
    );
  }

  /// Etichetta leggibile dello stato con emoji (come nel back-office WordPress).
  String get statusLabel {
    switch (status) {
      case 'aperta':
        return '🔵 Aperta';
      case 'in_lavorazione':
        return '🟡 In lavorazione';
      case 'risolta':
        return '🟢 Risolta';
      case 'chiusa':
        return '⚪ Chiusa';
      default:
        return status;
    }
  }

  /// Data formattata dd/MM/YYYY HH:mm (senza dipendenze esterne).
  String get dataFormattata {
    final d = createdAt;
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
