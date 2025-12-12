import 'package:flutter/material.dart';

class SportelloScreen extends StatefulWidget {
  const SportelloScreen({super.key});

  @override
  State<SportelloScreen> createState() => _SportelloScreenState();
}

class _SportelloScreenState extends State<SportelloScreen> {
  final List<String> servizi = [
    'CAF',
    'Supporto Legale',
    'Consulenza Migratoria',
    'Supporto Psicologico',
  ];

  String? _selectedServizio;

  void _prenota(String tipo) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Appuntamento richiesto per $tipo')));
  }

  void _openChatbot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chatbot non disponibile al momento')),
    );
  }

  void _vaiAllaPrenotazioneDigitale() {
    Navigator.pushNamed(context, '/prenotaAppuntamento');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sportello Digitale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sportello Digitale',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Seleziona il servizio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Servizio',
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
                    onPressed: () => _prenota('Assegno Unico'),
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
                  const Text(
                    'Prenota Appuntamento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _prenota(_selectedServizio!),
                    icon: const Icon(Icons.event_available),
                    label: Text('Prenota Appuntamento $_selectedServizio'),
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
                    label: const Text('Chatbot / Supporto'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _vaiAllaPrenotazioneDigitale,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Prenota Appuntamento Digitale'),
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
