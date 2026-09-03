import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/models/supporto_ticket_model.dart';

void main() {
  test('SupportoTicket parses operator replies from mie-richieste payload', () {
    final ticket = SupportoTicket.fromJson({
      'id': 12,
      'numero_ticket': 'SUP-2026-00012',
      'service_name': 'Sportello',
      'service_category': 'generico',
      'tipo_richiesta': 'aiuto_manuale',
      'priorita': 'media',
      'status': 'in_lavorazione',
      'messaggio': 'Ho bisogno di aiuto',
      'created_at': '2026-09-03 10:00:00',
      'risposte': [
        {
          'id': 1,
          'ticket_id': 12,
          'author_name': 'Maria',
          'body': 'Ciao, ti rispondiamo a breve.',
          'tipo': 'operatore',
          'created_at': '2026-09-03 11:00:00',
        },
      ],
    });

    expect(ticket.id, 12);
    expect(ticket.hasRisposte, isTrue);
    expect(ticket.ultimaRisposta?.body, contains('rispondiamo'));
    expect(ticket.risposte.first.authorName, 'Maria');
  });

  test('SupportoTicket handles missing risposte without crashing', () {
    final ticket = SupportoTicket.fromJson({
      'id': 3,
      'numero_ticket': 'SUP-2026-00003',
      'service_name': 'Home',
      'status': 'aperta',
    });

    expect(ticket.risposte, isEmpty);
    expect(ticket.hasRisposte, isFalse);
    expect(ticket.ultimaRisposta, isNull);
  });
}
