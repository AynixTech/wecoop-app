import 'package:flutter/material.dart';
import 'richiesta_form_screen.dart';

class MediazioneFiscaleScreen extends StatelessWidget {
  const MediazioneFiscaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mediazione Fiscale')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleziona il servizio fiscale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _ServiceCard(
                icon: Icons.description,
                title: '730 - Dichiarazione dei Redditi',
                description:
                    'Compilazione modello 730 per dipendenti e pensionati',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Mediazione Fiscale',
                            categoria: '730',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Codice fiscale',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Indirizzo di residenza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipologia contribuente',
                                'type': 'select',
                                'options': [
                                  'Lavoratore dipendente',
                                  'Pensionato',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Anno fiscale',
                                'type': 'select',
                                'options': ['2024', '2023', '2022'],
                                'required': true,
                              },
                              {
                                'label': 'Hai spese detraibili/deducibili?',
                                'type': 'select',
                                'options': ['Sì', 'No'],
                                'required': true,
                              },
                              {
                                'label': 'Note e informazioni aggiuntive',
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.person,
                title: 'Persona Fisica',
                description: 'Dichiarazione redditi per persone fisiche',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Mediazione Fiscale',
                            categoria: 'Persona Fisica',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Codice fiscale',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Indirizzo di residenza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipologia di reddito',
                                'type': 'select',
                                'options': [
                                  'Lavoro dipendente',
                                  'Lavoro autonomo',
                                  'Pensione',
                                  'Redditi da capitale',
                                  'Redditi diversi',
                                  'Più tipologie',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Anno fiscale',
                                'type': 'select',
                                'options': ['2024', '2023', '2022'],
                                'required': true,
                              },
                              {
                                'label': 'Hai immobili?',
                                'type': 'select',
                                'options': ['Sì', 'No'],
                                'required': true,
                              },
                              {
                                'label': 'Dettagli e note',
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amber.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
