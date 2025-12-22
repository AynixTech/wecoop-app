import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class VisaTurismoScreen extends StatelessWidget {
  const VisaTurismoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.touristVisa),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.touristVisaRequest,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.touristVisa,
                        categoria: l10n.touristVisaCategory,
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfBirth, 'type': 'date', 'required': true},
                          {'label': l10n.nationality, 'type': 'text', 'required': true},
                          {'label': l10n.passportNumber, 'type': 'text', 'required': true},
                          {
                            'label': l10n.expectedArrivalDate,
                            'type': 'date',
                            'required': true
                          },
                          {
                            'label': l10n.expectedDepartureDate,
                            'type': 'date',
                            'required': true
                          },
                          {
                            'label': l10n.travelReason,
                            'type': 'select',
                            'options': [
                              l10n.tourism,
                              l10n.familyVisit,
                              l10n.business,
                              l10n.other
                            ],
                            'required': true
                          },
                          {'label': l10n.accommodationAddressItaly, 'type': 'text', 'required': true},
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
                  l10n.fillRequest,
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
