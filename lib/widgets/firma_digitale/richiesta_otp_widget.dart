import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';

class RichiestaOTPWidget extends StatefulWidget {
  final VoidCallback onOTPInviato;

  const RichiestaOTPWidget({
    super.key,
    required this.onOTPInviato,
  });

  @override
  State<RichiestaOTPWidget> createState() => _RichiestaOTPWidgetState();
}

class _RichiestaOTPWidgetState extends State<RichiestaOTPWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titolo
                  Text(
                    'Verifica Identità',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Descrizione
                  Text(
                    'Riceverai lo stesso codice OTP via SMS al numero ${provider.telefono} e via email',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage ?? 'Errore sconosciuto',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.red.shade700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Bottone principale
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              print('📱 [OtpUI] Tap invia OTP stepBefore=${provider.step} richiestaId=${provider.richiestaId} telefono=${provider.telefono}');
                              await provider.richiestaOTP();
                              print('📱 [OtpUI] richiestaOTP completata stepAfter=${provider.step} errorCode=${provider.errorCode} error=${provider.errorMessage}');
                              if (provider.step ==
                                  FirmaStep.otpInviato) {
                                print('📱 [OtpUI] Navigo allo step verifica OTP');
                                widget.onOTPInviato();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                              'Invia OTP via SMS + Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info
                  Text(
                    'Il codice sarà valido per 5 minuti (stesso OTP su SMS ed email)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
