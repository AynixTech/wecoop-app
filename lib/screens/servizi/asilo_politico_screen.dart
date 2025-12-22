import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class AsiloPoliticoScreen extends StatelessWidget {
  const AsiloPoliticoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.politicalAsylum),
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
                    Expanded(
                      child: Text(
                        l10n.internationalProtectionRequest,
                        style: const TextStyle(fontSize: 14),
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
                        servizio: l10n.politicalAsylum,
                        categoria: l10n.internationalProtection,
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfBirth, 'type': 'date', 'required': true},
                          {'label': l10n.countryOfOrigin, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfArrivalInItaly, 'type': 'date', 'required': true},
                          {
                            'label': l10n.reasonForRequest,
                            'type': 'select',
                            'options': [
                              l10n.politicalPersecution,
                              l10n.religiousPersecution,
                              l10n.persecutionSexualOrientation,
                              l10n.war,
                              l10n.other
                            ],
                            'required': true
                          },
                          {
                            'label': l10n.situationDescription,
                            'type': 'textarea',
                            'required': true
                          },
                          {
                            'label': l10n.hasFamilyInItaly,
                            'type': 'select',
                            'options': [l10n.yes, l10n.no],
                            'required': true
                          },
                          {'label': l10n.additionalNotes, 'type': 'textarea', 'required': false},
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
                child: Text(
                  l10n.startRequest,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
