import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

/// Consulenza Decreto Flussi: crea una richiesta di servizio.
/// L'operatore contatterà l'utente e potrà inviare una richiesta di appuntamento.
class DecretoFlussiScreen extends StatelessWidget {
  const DecretoFlussiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('decretoFlussi'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.primary),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translate('decretoFlussiIntro'),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('decretoFlussiRequestTitle'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('decretoFlussiRequestSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('decretoFlussi'),
                        categoria: l10n.translate('decretoFlussiCategory'),
                        campi: [
                          {
                            'label': l10n.fullName,
                            'type': 'text',
                            'required': true,
                          },
                          {
                            'label': l10n.translate('decretoFlussiTipologia'),
                            'type': 'select',
                            'options': [
                              l10n.translate('decretoFlussiDomestic'),
                              l10n.translate('decretoFlussiNonSeasonal'),
                            ],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('decretoFlussiRuolo'),
                            'type': 'select',
                            'options': [
                              l10n.translate('decretoFlussiEmployer'),
                              l10n.translate('decretoFlussiWorker'),
                            ],
                            'required': true,
                          },
                          {
                            'label': l10n.phone,
                            'type': 'text',
                            'required': true,
                          },
                          {
                            'label': l10n.translate('decretoFlussiNotes'),
                            'type': 'textarea',
                            'required': false,
                          },
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(
                  l10n.fillRequest,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
