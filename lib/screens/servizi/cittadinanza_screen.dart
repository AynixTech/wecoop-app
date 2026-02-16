import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class CittadinanzaScreen extends StatefulWidget {
  const CittadinanzaScreen({super.key});

  @override
  State<CittadinanzaScreen> createState() => _CittadinanzaScreenState();
}

class _CittadinanzaScreenState extends State<CittadinanzaScreen> {
  bool _showSecondQuestion = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.citizenshipService)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.checkRequirements,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.citizenshipDescription,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (!_showSecondQuestion)
                _QuestionCard(
                  question: 'Hai almeno 10 anni di residenza legale in Italia?',
                  onYes: () {
                    _showNextStep(context, hasResidenza: true);
                  },
                  onNo: () {
                    setState(() {
                      _showSecondQuestion = true;
                    });
                  },
                )
              else
                _QuestionCard(
                  question: 'Sei sposato/a con un cittadino italiano?',
                  onYes: () {
                    _showNextStep(context, hasResidenza: false);
                  },
                  onNo: () {
                    _showNotEligibleMessage(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNextStep(BuildContext context, {required bool hasResidenza}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RichiestaFormScreen(
              servizio: 'Cittadinanza Italiana',
              categoria: hasResidenza ? 'Per residenza' : 'Per matrimonio',
              campi: const [
                {'label': 'Nome completo', 'type': 'text', 'required': true},
                {'label': 'Data di nascita', 'type': 'date', 'required': true},
                {'label': 'Paese di nascita', 'type': 'text', 'required': true},
                {
                  'label': 'Data di arrivo in Italia',
                  'type': 'date',
                  'required': true,
                },
                {
                  'label': 'Indirizzo di residenza attuale',
                  'type': 'text',
                  'required': true,
                },
                {
                  'label': 'Hai precedenti penali?',
                  'type': 'select',
                  'options': ['No', 'Sì'],
                  'required': true,
                },
                {
                  'label': 'Certificazione lingua italiana',
                  'type': 'select',
                  'options': ['A2', 'B1', 'B2', 'C1', 'Non ho certificazione'],
                  'required': true,
                },
                {
                  'label': 'Situazione lavorativa',
                  'type': 'select',
                  'options': [
                    'Dipendente',
                    'Autonomo',
                    'Disoccupato',
                    'Studente',
                    'Pensionato',
                  ],
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
  }

  void _showNotEligibleMessage(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Requisiti non soddisfatti'),
            content: const Text(
              'Al momento non risultano i requisiti necessari per avviare questa pratica. Ti contatteremo se emergono soluzioni alternative. Grazie per la preferenza!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Ho capito'),
              ),
            ],
          ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _QuestionCard({
    required this.question,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onYes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(AppLocalizations.of(context)!.yes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(AppLocalizations.of(context)!.no),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
