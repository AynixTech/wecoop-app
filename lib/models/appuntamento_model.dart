/// Modelli per la feature di prenotazione appuntamenti fisici (Calendly-style).
///
/// Le date arrivano dal backend nel timezone del sito (Europe/Rome) come
/// stringhe "yyyy-MM-dd HH:mm:ss"; qui vengono parse in DateTime "naive"
/// senza conversione di fuso, per mostrarle esattamente come definite
/// dall'operatore.
library;

DateTime? _parseServerDate(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  // Sostituisce lo spazio con 'T' per il parser ISO; niente 'Z' => locale/naive.
  final normalized = s.contains('T') ? s : s.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

int _parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value?.toString().toLowerCase();
  return s == 'true' || s == '1';
}

/// Slot proposto dall'operatore per una richiesta di servizio.
class AppuntamentoSlot {
  final int id;
  final int richiestaId;
  final DateTime? dataOra;
  final int durataMin;
  final String? sede;
  final String? indirizzo;
  final String? note;
  final String stato;

  const AppuntamentoSlot({
    required this.id,
    required this.richiestaId,
    required this.dataOra,
    required this.durataMin,
    this.sede,
    this.indirizzo,
    this.note,
    required this.stato,
  });

  factory AppuntamentoSlot.fromJson(Map<String, dynamic> json) {
    return AppuntamentoSlot(
      id: _parseInt(json['id']),
      richiestaId: _parseInt(json['richiesta_id']),
      dataOra: _parseServerDate(json['data_ora']),
      durataMin: _parseInt(json['durata_min'], 30),
      sede: json['sede']?.toString(),
      indirizzo: json['indirizzo']?.toString(),
      note: json['note']?.toString(),
      stato: json['stato']?.toString() ?? 'proposed',
    );
  }
}

/// Appuntamento confermato dall'utente.
class Appuntamento {
  final int id;
  final int richiestaId;
  final int slotId;
  final DateTime? dataOra;
  final int durataMin;
  final String? sede;
  final String? indirizzo;
  final String? note;
  final String stato;

  /// Indica se l'utente puo' ancora annullare/riprogrammare (oltre la finestra limite).
  final bool canModify;
  final int rescheduleLimitHours;

  const Appuntamento({
    required this.id,
    required this.richiestaId,
    required this.slotId,
    required this.dataOra,
    required this.durataMin,
    this.sede,
    this.indirizzo,
    this.note,
    required this.stato,
    required this.canModify,
    required this.rescheduleLimitHours,
  });

  bool get isConfirmed => stato == 'confirmed';

  factory Appuntamento.fromJson(Map<String, dynamic> json) {
    return Appuntamento(
      id: _parseInt(json['id']),
      richiestaId: _parseInt(json['richiesta_id']),
      slotId: _parseInt(json['slot_id']),
      dataOra: _parseServerDate(json['data_ora']),
      durataMin: _parseInt(json['durata_min'], 30),
      sede: json['sede']?.toString(),
      indirizzo: json['indirizzo']?.toString(),
      note: json['note']?.toString(),
      stato: json['stato']?.toString() ?? 'confirmed',
      canModify: _parseBool(json['can_modify']),
      rescheduleLimitHours: _parseInt(json['reschedule_limit_hours'], 24),
    );
  }
}

/// Risultato del caricamento slot: slot disponibili + eventuale appuntamento gia' confermato.
class SlotDisponibilita {
  final List<AppuntamentoSlot> slots;
  final Appuntamento? appuntamento;

  const SlotDisponibilita({required this.slots, this.appuntamento});
}
