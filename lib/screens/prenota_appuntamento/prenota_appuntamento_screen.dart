import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class PrenotaAppuntamentoScreen extends StatefulWidget {
  @override
  _PrenotaAppuntamentoScreenState createState() =>
      _PrenotaAppuntamentoScreenState();
}

class _PrenotaAppuntamentoScreenState extends State<PrenotaAppuntamentoScreen> {
  final storage = FlutterSecureStorage();
  List appuntamenti = [];
  int? selectedAppuntamentoId;
  String? selectedOrario;
  String email = '';

  @override
  void initState() {
    super.initState();
    caricaDatiUtente();
    fetchAppuntamenti();
  }

  Future<void> caricaDatiUtente() async {
    final storedEmail = await storage.read(key: 'user_email');
    if (storedEmail != null && mounted) {
      setState(() {
        email = storedEmail;
      });
    }
  }

  Future<void> fetchAppuntamenti() async {
    final response = await http.get(
      Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/appuntamenti'),
    );
    if (response.statusCode == 200) {
      final dati = json.decode(response.body);
      dati.sort((a, b) {
        final daStr = a['data'];
        final dbStr = b['data'];
        if (daStr == null || dbStr == null) return 0;
        final da = DateTime.tryParse(daStr);
        final db = DateTime.tryParse(dbStr);
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });
      if (mounted) {
        setState(() {
          appuntamenti = dati;
        });
      }
    } else {
      print('Errore nel recupero appuntamenti: ${response.body}');
    }
  }

  Map<String, Map<String, List>> raggruppaPerSedeEServizio(List appuntamenti) {
    final Map<String, Map<String, List>> mappa = {};
    for (var app in appuntamenti) {
      final sede = app['sede'] ?? 'Sede sconosciuta';
      final servizio = app['sportello'] ?? 'Servizio sconosciuto';

      mappa.putIfAbsent(sede, () => {});
      mappa[sede]!.putIfAbsent(servizio, () => []);
      mappa[sede]![servizio]!.add(app);
    }
    return mappa;
  }

  Future<void> inviaPrenotazione() async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedAppuntamentoId == null ||
        selectedOrario == null ||
        email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
      return;
    }

    final response = await http.post(
      Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/prenota'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'appuntamento_id': selectedAppuntamentoId,
        'orario': selectedOrario,
      }),
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200 && result['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bookingConfirmed)));
      Navigator.pop(context, true); // ✅ Torna con conferma
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.error}: ${result['message'] ?? 'Impossibile prenotare'}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appuntamentiPerSedeEServizio = raggruppaPerSedeEServizio(
      appuntamenti,
    );
    const giorniSettimana = {
      DateTime.monday: 'LUN',
      DateTime.tuesday: 'MAR',
      DateTime.wednesday: 'MER',
      DateTime.thursday: 'GIO',
      DateTime.friday: 'VEN',
      DateTime.saturday: 'SAB',
      DateTime.sunday: 'DOM',
    };

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bookAppointment)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                controller: TextEditingController(text: email),
                onChanged: (val) => email = val,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children:
                      appuntamentiPerSedeEServizio.entries.map((sedeEntry) {
                        final sede = sedeEntry.key;
                        final servizi = sedeEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sede,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...servizi.entries.map((servizioEntry) {
                              final servizio = servizioEntry.key;
                              final listaApp = servizioEntry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Text(
                                      servizio,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  ...listaApp.map<Widget>((app) {
                                    final rawData = app['data'] ?? '';
                                    final data = DateTime.tryParse(rawData);
                                    String dataFormattata = rawData;
                                    if (data != null) {
                                      final giorno =
                                          giorniSettimana[data.weekday] ?? '';
                                      final formato = DateFormat('dd/MM/yyyy');
                                      dataFormattata =
                                          '${formato.format(data)} - $giorno';
                                    }

                                    return Card(
                                      child: ExpansionTile(
                                        title: Text(dataFormattata),
                                        children: [
                                          ...app['orari'].map<Widget>((o) {
                                            final posti =
                                                o['posti_disponibili'];
                                            final orario = o['orario'];
                                            final isDisabled = posti == 0;
                                            return ListTile(
                                              title: Text(
                                                '$orario (${posti} posti)',
                                              ),
                                              trailing: Radio<String>(
                                                value: orario,
                                                groupValue:
                                                    selectedAppuntamentoId ==
                                                            app['id']
                                                        ? selectedOrario
                                                        : null,
                                                onChanged:
                                                    isDisabled
                                                        ? null
                                                        : (val) {
                                                          setState(() {
                                                            selectedAppuntamentoId =
                                                                app['id'];
                                                            selectedOrario =
                                                                val;
                                                          });
                                                        },
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: inviaPrenotazione,
              child: Text(AppLocalizations.of(context)!.book),
            ),
          ),
        ),
      ),
    );
  }
}
