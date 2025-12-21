import 'package:flutter/material.dart';
import 'richiesta_form_screen.dart';

class SupportoContabileScreen extends StatelessWidget {
  const SupportoContabileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supporto Contabile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestione Partita IVA e Contabilità',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _OptionCard(
                icon: Icons.add_business,
                title: 'Aprire Partita IVA',
                description: 'Apertura nuova partita IVA',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Supporto Contabile',
                            categoria: 'Aprire Partita IVA',
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
                                'label': 'Tipo di attività',
                                'type': 'select',
                                'options': [
                                  'Commercio',
                                  'Servizi',
                                  'Artigianato',
                                  'Libera professione',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Descrizione attività',
                                'type': 'textarea',
                                'required': true,
                              },
                              {
                                'label': 'Regime fiscale previsto',
                                'type': 'select',
                                'options': [
                                  'Forfettario',
                                  'Semplificato',
                                  'Ordinario',
                                  'Non so',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Fatturato annuo previsto (€)',
                                'type': 'number',
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
                icon: Icons.settings,
                title: 'Gestire la Partita IVA',
                description:
                    'Contabilità ordinaria, fatturazione, registrazioni',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Supporto Contabile',
                            categoria: 'Gestire Partita IVA',
                            campi: const [
                              {
                                'label': 'Nome/Ragione sociale',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Partita IVA',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipo di supporto richiesto',
                                'type': 'select',
                                'options': [
                                  'Fatturazione elettronica',
                                  'Registrazione fatture',
                                  'Gestione prima nota',
                                  'Bilancio annuale',
                                  'Consulenza generale',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Regime fiscale attuale',
                                'type': 'select',
                                'options': [
                                  'Forfettario',
                                  'Semplificato',
                                  'Ordinario',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Descrivi la tua esigenza',
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
                icon: Icons.account_balance,
                title: 'Tasse e Contributi',
                description: 'F24, INPS, scadenze fiscali',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Supporto Contabile',
                            categoria: 'Tasse e Contributi',
                            campi: const [
                              {
                                'label': 'Nome/Ragione sociale',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Partita IVA',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Tipo di adempimento',
                                'type': 'select',
                                'options': [
                                  'Pagamento IVA',
                                  'Contributi INPS',
                                  'Acconto imposte',
                                  'Saldo imposte',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Periodo di riferimento',
                                'type': 'select',
                                'options': [
                                  'Trimestrale',
                                  'Mensile',
                                  'Annuale',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Descrizione',
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
                icon: Icons.help_outline,
                title: 'Chiarimenti e Consulenza',
                description: 'Domande e supporto fiscale/contabile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Supporto Contabile',
                            categoria: 'Consulenza',
                            campi: const [
                              {
                                'label': 'Nome completo',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Email',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Telefono',
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
                                'label': 'Argomento della consulenza',
                                'type': 'select',
                                'options': [
                                  'Aspetti fiscali',
                                  'Aspetti contributivi',
                                  'Regime fiscale',
                                  'Detrazioni/Deduzioni',
                                  'Altro',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Descrivi la tua domanda',
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
                icon: Icons.close_fullscreen,
                title: 'Chiudere o Cambiare Attività',
                description: 'Cessazione o modifica attività',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: 'Supporto Contabile',
                            categoria: 'Chiudere/Cambiare Attività',
                            campi: const [
                              {
                                'label': 'Nome/Ragione sociale',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Partita IVA',
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': 'Cosa vuoi fare?',
                                'type': 'select',
                                'options': [
                                  'Chiudere partita IVA',
                                  'Cambiare attività',
                                  'Cambiare regime fiscale',
                                ],
                                'required': true,
                              },
                              {
                                'label': 'Data prevista',
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': 'Motivazione',
                                'type': 'textarea',
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
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OptionCard({
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
