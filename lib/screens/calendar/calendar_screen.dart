import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with WidgetsBindingObserver {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String email = '';
  final storage = const FlutterSecureStorage();

  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    fetchPrenotazioniUtente();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPrenotazioniUtente(); // 🔄 Ricarica ogni volta che torna visibile
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchPrenotazioniUtente(); // 🔄 Ricarica prenotazioni
    }
  }

  Future<String?> caricaDatiUtente() async {
    final storedEmail = await storage.read(key: 'user_email');
    print('📥 Email letta da storage: $storedEmail');
    return storedEmail;
  }

  Future<void> fetchPrenotazioniUtente() async {
    final storedEmail = await caricaDatiUtente();
    if (storedEmail == null || storedEmail.isEmpty) {
      print('⚠️ Nessuna email trovata nello storage.');
      return;
    }

    email = storedEmail;
    print('📧 Email utente recuperata: $email');

    final uri = Uri.parse(
      'https://www.wecoop.org/wp-json/wecoop/v1/prenotazioni-utente?email=$email',
    );
    print('🌐 Chiamata API: $uri');

    final response = await http.get(uri);
    print('📡 Status code: ${response.statusCode}');
    print('📦 Body ricevuto: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('✅ Prenotazioni ricevute: ${data.length}');

      final Map<DateTime, List<Event>> loadedEvents = {};

      for (var item in data) {
        final app = item['appuntamento'];
        final dateStr = app['data'];
        final orario = item['orario'];
        final title = app['title'];
        final sede = app['sede'];
        final sportello = app['sportello'];

        print('📅 Appuntamento: $title – $dateStr – $orario');

        if (dateStr == null) {
          print('⚠️ Data mancante, salto.');
          continue;
        }

        final date = DateTime.tryParse(dateStr);
        if (date == null) {
          print('⚠️ Data non parsabile: $dateStr');
          continue;
        }

        final normalized = DateTime.utc(date.year, date.month, date.day);

        final label = '$sede - $sportello\nOrario: $orario';

        loadedEvents.putIfAbsent(normalized, () => []).add(Event(label));
      }

      print('📆 Eventi normalizzati: ${loadedEvents.length}');
      setState(() {
        _events.clear();
        _events.addAll(loadedEvents);
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } else {
      print('❌ Errore nel recupero prenotazioni: ${response.statusCode}');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Le mie prenotazioni')),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsForDay(selectedDay);
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text('Nessuna prenotazione per questa data.'),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_note,
                          color: Colors.amber,
                        ),
                        title: Text(event.title),
                        onTap: () {
                          // TODO: dettaglio evento o annulla prenotazione
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  Event(this.title);

  @override
  String toString() => title;
}
