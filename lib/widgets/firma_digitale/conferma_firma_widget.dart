import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class ConfermaFirmaWidget extends StatefulWidget {
  final VoidCallback onFirmaCompleta;

  const ConfermaFirmaWidget({
    super.key,
    required this.onFirmaCompleta,
  });

  @override
  State<ConfermaFirmaWidget> createState() => _ConfermaFirmaWidgetState();
}

class _ConfermaFirmaWidgetState extends State<ConfermaFirmaWidget> {
  String? _deviceType;
  String? _deviceModel;
  final String _appVersion = '2.1.0'; // Aggiorna dalla pubspec

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceType = 'iOS';
          _deviceModel = iosInfo.model;
        });
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceType = 'Android';
          _deviceModel = androidInfo.model;
        });
      }
    } catch (e) {
      print('Errore nel recupero info dispositivo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final documento = provider.documento;
        final otpGenerata = provider.otpGenerata;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intestazione
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conferma Firma Documento',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Controlla i dettagli prima di firmare',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Dettagli documento
                _buildDetailSection(
                  context,
                  title: '📄 Documento',
                  children: [
                    _buildDetailRow(
                      'Nome',
                      documento?.nome ?? '-',
                    ),
                    _buildDetailRow(
                      'Hash SHA-256',
                      _truncateHash(documento?.hashSha256 ?? ''),
                    ),
                    _buildDetailRow(
                      'Generato',
                      _formatData(
                          documento?.dataGenerazione ?? DateTime.now()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dettagli OTP
                _buildDetailSection(
                  context,
                  title: '🔐 Verifica OTP',
                  children: [
                    _buildDetailRow(
                      'Status',
                      '✅ Verificato',
                    ),
                    _buildDetailRow(
                      'Scadenza OTP',
                      _formatData(otpGenerata?.scadenza ?? DateTime.now()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dettagli dispositivo
                _buildDetailSection(
                  context,
                  title: '📱 Dispositivo',
                  children: [
                    _buildDetailRow(
                      'Tipo',
                      _deviceType ?? 'Rilevamento...',
                    ),
                    _buildDetailRow(
                      'Modello',
                      _deviceModel ?? 'Rilevamento...',
                    ),
                    _buildDetailRow(
                      'App Version',
                      _appVersion,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Dichiarazione
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📋 Dichiari di voler firmare questo documento in modo digitale. La firma sarà legale e tracciabile.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Error message
                if (provider.hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '❌ Errore',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage ?? 'Errore sconosciuto',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.red.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (provider.hasError) const SizedBox(height: 16),

                // Pulsanti azione
                Row(
                  children: [
                    // Annulla
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Annulla'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Firma
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isLoading ||
                                _deviceType == null ||
                                _deviceModel == null
                            ? null
                            : () async {
                                await provider.firmaDocumento(
                                  deviceType: _deviceType!,
                                  deviceModel: _deviceModel!,
                                  appVersion: _appVersion,
                                );
                                if (provider.isFirmato) {
                                  widget.onFirmaCompleta();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Firma',
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
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateHash(String hash) {
    if (hash.isEmpty) return '-';
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 8)}';
  }

  String _formatData(DateTime data) {
    return '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}';
  }
}
