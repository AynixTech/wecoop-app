import 'package:flutter/material.dart';
import 'richiesta_form_screen.dart';

class VisaTurismoScreen extends StatelessWidget {
  const VisaTurismoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visa per Turismo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Richiesta Visto Turistico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: 'Visa per Turismo',
                        categoria: 'Visto turistico',
                        campi: const [
                          {'label': 'Nome completo', 'type': 'text', 'required': true},
                          {'label': 'Data di nascita', 'type': 'date', 'required': true},
                          {'label': 'Nazionalità', 'type': 'text', 'required': true},
                          {'label': 'Numero passaporto', 'type': 'text', 'required': true},
                          {
                            'label': 'Data arrivo prevista',
                            'type': 'date',
                            'required': true
                          },
                          {
                            'label': 'Data partenza prevista',
                            'type': 'date',
                            'required': true
                          },
                          {
                            'label': 'Motivo del viaggio',
                            'type': 'select',
                            'options': ['Turismo', 'Visita famiglia', 'Affari', 'Altro'],
                            'required': true
                          },
                          {'label': 'Indirizzo di soggiorno in Italia', 'type': 'text', 'required': true},
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
                  'Compila richiesta',
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
