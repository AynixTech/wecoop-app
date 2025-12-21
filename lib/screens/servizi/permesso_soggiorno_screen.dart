import 'package:flutter/material.dart';
import 'richiesta_form_screen.dart';

class PermessoSoggiornoScreen extends StatelessWidget {
  const PermessoSoggiornoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permesso di Soggiorno')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleziona la tipologia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _OptionCard(
                title: 'Per Lavoro Subordinato',
                description: 'Contratto di lavoro dipendente',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Permesso di Soggiorno',
                            categoria: 'Lavoro Subordinato',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Paese di provenienza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipo di contratto',
                                'type': 'select',
                                'options': ['Determinato', 'Indeterminato'],
                                'required': true,
                              },
                              {
                                'label': 'Nome azienda',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Durata contratto (mesi)',
                                'type': 'number',
                                'required': true,
                              },
                              {
                                'label': 'Note aggiuntive',
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
              _OptionCard(
                title: 'Per Lavoro Autonomo',
                description: 'Attività in proprio o libera professione',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Permesso di Soggiorno',
                            categoria: 'Lavoro Autonomo',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Paese di provenienza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipo di attività',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Hai già partita IVA?',
                                'type': 'select',
                                'options': ['Sì', 'No'],
                                'required': true,
                              },
                              {
                                'label': 'Descrizione attività',
                                'type': 'textarea',
                                'required': true,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: 'Per Motivi Familiari',
                description: 'Ricongiungimento familiare',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Permesso di Soggiorno',
                            categoria: 'Motivi Familiari',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Paese di provenienza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Relazione con familiare',
                                'type': 'select',
                                'options': [
                                  'Coniuge',
                                  'Figlio/a',
                                  'Genitore',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Nome familiare in Italia',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Documento identità familiare',
                                'type': 'text',
                                'required': true,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: 'Per Studiare in Italia',
                description: 'Iscrizione a corsi universitari o di formazione',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Permesso di Soggiorno',
                            categoria: 'Studio',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Data di nascita',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Paese di provenienza',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Nome istituto/università',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipo di corso',
                                'type': 'select',
                                'options': [
                                  'Laurea triennale',
                                  'Laurea magistrale',
                                  'Master',
                                  'Dottorato',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Anno di iscrizione',
                                'type': 'text',
                                'required': true,
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

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OptionCard({
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
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.amber.shade700,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
