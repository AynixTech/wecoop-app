import 'package:flutter/material.dart';
import 'richiesta_form_screen.dart';

class AsiloPoliticoScreen extends StatelessWidget {
  const AsiloPoliticoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asilo Politico'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'La richiesta di protezione internazionale è un processo delicato. Ti aiuteremo a preparare la documentazione.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: 'Asilo Politico',
                        categoria: 'Protezione Internazionale',
                        campi: const [
                          {'label': 'Nome completo', 'type': 'text', 'required': true},
                          {'label': 'Data di nascita', 'type': 'date', 'required': true},
                          {'label': 'Paese di origine', 'type': 'text', 'required': true},
                          {'label': 'Data di arrivo in Italia', 'type': 'date', 'required': true},
                          {
                            'label': 'Motivo della richiesta',
                            'type': 'select',
                            'options': [
                              'Persecuzione politica',
                              'Persecuzione religiosa',
                              'Persecuzione per orientamento sessuale',
                              'Guerra/conflitto armato',
                              'Altro'
                            ],
                            'required': true
                          },
                          {
                            'label': 'Descrizione situazione',
                            'type': 'textarea',
                            'required': true
                          },
                          {
                            'label': 'Hai familiari in Italia?',
                            'type': 'select',
                            'options': ['Sì', 'No'],
                            'required': true
                          },
                          {'label': 'Note aggiuntive', 'type': 'textarea', 'required': false},
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text(
                  'Inizia la richiesta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
