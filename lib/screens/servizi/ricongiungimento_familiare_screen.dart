import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class RicongiungimentoFamiliareScreen extends StatelessWidget {
  const RicongiungimentoFamiliareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Naviga direttamente al form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RichiestaFormScreen(
            servizio: l10n.translate('familyReunification'),
            categoria: l10n.translate('familyReunification'),
            campi: [
              {
                'label': l10n.fullName,
                'type': 'text',
                'required': true,
              },
              {
                'label': l10n.email,
                'type': 'text',
                'required': true,
              },
              {
                'label': l10n.phone,
                'type': 'text',
                'required': true,
              },
              {
                'label': l10n.translate('whoToReunite'),
                'type': 'select',
                'options': [
                  l10n.translate('spouse'),
                  l10n.translate('sonDaughter'),
                  l10n.translate('parent'),
                  l10n.translate('otherRelative'),
                ],
                'required': true,
              },
              {
                'label': l10n.translate('familyMemberCountry'),
                'type': 'select',
                'options': [
                  'Italia',
                  'Ecuador',
                  'España',
                  'Colombia',
                  'Perú',
                  'Venezuela',
                  'Argentina',
                  'Brasil',
                  'Chile',
                  'México',
                  'United States',
                  'United Kingdom',
                  'France',
                  'Germany',
                  'Romania',
                  'Polonia',
                  'Ucraina',
                  'Marocco',
                  'Egitto',
                  'Nigeria',
                  'Ghana',
                  'Senegal',
                  'China',
                  'India',
                  'Filippine',
                  'Bangladesh',
                  'Pakistan',
                ],
                'required': true,
              },
              {
                'label': l10n.translate('yourWorkSituation'),
                'type': 'select',
                'options': [
                  l10n.translate('employedWorker'),
                  l10n.translate('domesticWorker'),
                  l10n.translate('businessOwner'),
                  l10n.translate('coCoCoWorker'),
                  l10n.translate('workerPartner'),
                  l10n.translate('freelanceProfessional'),
                ],
                'required': true,
              },
              {
                'label': l10n.translate('haveRentalOrSuitableHouse'),
                'type': 'select',
                'options': [
                  l10n.yes,
                  l10n.no,
                  l10n.translate('dontKnow'),
                ],
                'required': true,
              },
              {
                'label': l10n.translate('additionalNotes'),
                'type': 'textarea',
                'required': false,
              },
            ],
          ),
        ),
      );
    });
    
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
