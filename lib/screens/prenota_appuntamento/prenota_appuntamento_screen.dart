import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import '../../config/api_config.dart';

class PrenotaAppuntamentoScreen extends StatefulWidget {
  const PrenotaAppuntamentoScreen({super.key});

  @override
  _PrenotaAppuntamentoScreenState createState() =>
      _PrenotaAppuntamentoScreenState();
}

class _PrenotaAppuntamentoScreenState extends State<PrenotaAppuntamentoScreen> {
  final storage = SecureStorageService();
  final TextEditingController _emailController = TextEditingController();
  List appuntamenti = [];
  int? selectedAppuntamentoId;
  String? selectedOrario;
  String email = '';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    caricaDatiUtente();
    fetchAppuntamenti();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> caricaDatiUtente() async {
    final storedEmail = await storage.read(key: 'user_email');
    if (storedEmail != null && mounted) {
      setState(() {
        email = storedEmail;
        _emailController.text = storedEmail;
      });
    }
  }

  Future<void> fetchAppuntamenti() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final response = await HttpClientService.get(
        Uri.parse('${ApiConfig.baseUrl}/appuntamenti'),
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
            _isLoading = false;
          });
        }
      } else {
        AppLogger.d('Errore nel recupero appuntamenti: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadError = 'Impossibile caricare gli appuntamenti.';
          });
        }
      }
    } catch (e) {
      AppLogger.e('fetchAppuntamenti errore', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Errore di rete. Riprova più tardi.';
        });
      }
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
    if (_isSubmitting) return; // anti doppio submit
    if (selectedAppuntamentoId == null ||
        selectedOrario == null ||
        email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await HttpClientService.post(
        Uri.parse('${ApiConfig.baseUrl}/prenota'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'appuntamento_id': selectedAppuntamentoId,
          'orario': selectedOrario,
        }),
      );
      if (MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      final result = json.decode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200 && result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.bookingConfirmed)));
        Navigator.pop(context, true); // ✅ Torna con conferma
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.error}: ${result['message'] ?? 'Impossibile prenotare'}',
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.e('inviaPrenotazione errore', e);
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: rete non disponibile')),
        );
      }
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
                controller: _emailController,
                onChanged: (val) => email = val,
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_loadError!, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: fetchAppuntamenti,
                                  child: const Text('Riprova'),
                                ),
                              ],
                            ),
                          )
                        : ListView(
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
                                                '$orario ($posti posti)',
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
                                  }),
                                ],
                              );
                            }),
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
              onPressed: _isSubmitting ? null : inviaPrenotazione,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.book),
            ),
          ),
        ),
      ),
    );
  }
}
