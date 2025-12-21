import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class SportelloScreen extends StatefulWidget {
  const SportelloScreen({super.key});

  @override
  State<SportelloScreen> createState() => _SportelloScreenState();
}

class _SportelloScreenState extends State<SportelloScreen> {
  List<String> servizi = [];

  String? _selectedServizio;

  void _prenota(String tipo, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${l10n.bookAppointment}: $tipo')));
  }

  void _openChatbot() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.chatbotUnavailable)),
    );
  }

  void _vaiAllaPrenotazioneDigitale() {
    Navigator.pushNamed(context, '/prenotaAppuntamento');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Inizializza servizi se vuoto
    if (servizi.isEmpty) {
      servizi = [
        'CAF',
        'Supporto Legale',
        'Consulenza Migratoria',
        'Supporto Psicologico',
      ];
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.digitalDesk)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.digitalDesk,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              l10n.selectService,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.services,
              ),
              value: _selectedServizio,
              items:
                  servizi
                      .map(
                        (servizio) => DropdownMenuItem(
                          value: servizio,
                          child: Text(servizio),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedServizio = val;
                });
              },
            ),
            const SizedBox(height: 16),

            Visibility(
              visible: _selectedServizio == 'CAF',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servizi CAF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/compila730');
                    },
                    icon: const Icon(Icons.edit_document),
                    label: const Text('730'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _prenota('Assegno Unico', context),
                    icon: const Icon(Icons.event_available),
                    label: const Text('Assegno Unico'),
                  ),
                ],
              ),
            ),

            Visibility(
              visible: _selectedServizio != null && _selectedServizio != 'CAF',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bookAppointment,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _prenota(_selectedServizio!, context),
                    icon: const Icon(Icons.event_available),
                    label: Text('${l10n.bookAppointment} $_selectedServizio'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _openChatbot,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.chatbotSupport),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _vaiAllaPrenotazioneDigitale,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(l10n.bookDigitalAppointment),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
