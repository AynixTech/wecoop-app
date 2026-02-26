import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';

class RisultatoFirmaWidget extends StatelessWidget {
  final VoidCallback onChiudi;
  final VoidCallback? onVisualizzaRicevuta;

  const RisultatoFirmaWidget({
    super.key,
    required this.onChiudi,
    this.onVisualizzaRicevuta,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final firma = provider.firmaCreata;

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon success
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titolo
                  Text(
                    '✅ Firma Completata',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Sottotitolo
                  Text(
                    'Il tuo documento è stato firmato digitalmente con successo',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Dettagli firma
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          '🆔 ID Firma',
                          firma?.id ?? '-',
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          '⏰ Data Firma',
                          _formatData(
                              firma?.firmaTimestamp ?? DateTime.now()),
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          '📋 Metodo',
                          'Firma Elettronica Semplice (FES)',
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          '✔️ Status',
                          firma?.status ?? '-',
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          '🔐 Hash Verificato',
                          firma?.hashVerificato ?? false ? '✅ Si' : '❌ No',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Cosa succede next?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• La firma è stata salvata nel sistema\n'
                          '• Riceverai un\'email di conferma\n'
                          '• Puoi scaricare la ricevuta sottostante\n'
                          '• Il documento è legalmente vincolante',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Azioni
                  Column(
                    children: [
                      // Visualizza ricevuta
                      if (onVisualizzaRicevuta != null)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: onVisualizzaRicevuta,
                            child: const Text('Scarica Ricevuta'),
                          ),
                        ),
                      if (onVisualizzaRicevuta != null)
                        const SizedBox(height: 12),
                      // Chiudi / Torna
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onChiudi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Torna alla Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatData(DateTime data) {
    return '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}';
  }
}
