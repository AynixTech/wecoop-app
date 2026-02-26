import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';

class VerificaOTPWidget extends StatefulWidget {
  final VoidCallback onOTPVerificato;

  const VerificaOTPWidget({
    super.key,
    required this.onOTPVerificato,
  });

  @override
  State<VerificaOTPWidget> createState() => _VerificaOTPWidgetState();
}

class _VerificaOTPWidgetState extends State<VerificaOTPWidget> {
  late TextEditingController _otpController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _focusNode = FocusNode();
    // Focus automatico sul campo OTP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final tentativiRimasti = provider.tentativiRimasti ?? 3;
        final otpGenerata = provider.otpGenerata;
        final minutiRimasti = otpGenerata != null
            ? otpGenerata.scadenza.difference(DateTime.now()).inMinutes
            : 0;

        return SingleChildScrollView(
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
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mail,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Titolo
                Text(
                  'Inserisci Codice OTP',
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Descrizione
                Text(
                  'Abbiamo inviato lo stesso codice di 6 cifre via SMS ed email',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Tempo rimanente
                if (minutiRimasti > 0)
                  Text(
                    '⏱️ Scade tra $minutiRimasti min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                const SizedBox(height: 32),

                // Campo di input OTP
                TextFormField(
                  controller: _otpController,
                  focusNode: _focusNode,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),

                // Conteggio tentativi
                if (tentativiRimasti < 3)
                  Text(
                    '⚠️ Tentativi rimasti: $tentativiRimasti',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tentativiRimasti == 1
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 32),

                // Bottone di verifica
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ||
                            _otpController.text.length != 6
                        ? null
                        : () async {
                            print('✅ [OtpUI] Tap verifica OTP code=${_otpController.text} stepBefore=${provider.step} otpId=${provider.otpGenerata?.id}');
                            await provider
                                .verificaOTP(_otpController.text);
                            print('✅ [OtpUI] verificaOTP completata stepAfter=${provider.step} errorCode=${provider.errorCode} error=${provider.errorMessage}');
                            if (provider.step ==
                                FirmaStep.otpVerificato) {
                              print('✅ [OtpUI] Navigo allo step firma');
                              widget.onOTPVerificato();
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
                            'Verifica OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
