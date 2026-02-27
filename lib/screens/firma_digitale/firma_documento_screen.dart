import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';
import 'package:wecoop_app/widgets/firma_digitale/visualizza_documento_widget.dart';
import 'package:wecoop_app/widgets/firma_digitale/richiesta_otp_widget.dart';
import 'package:wecoop_app/widgets/firma_digitale/verifica_otp_widget.dart';
import 'package:wecoop_app/widgets/firma_digitale/conferma_firma_widget.dart';
import 'package:wecoop_app/widgets/firma_digitale/risultato_firma_widget.dart';

class FirmaDocumentoScreen extends StatefulWidget {
  final int richiestaId;
  final int userId;
  final String telefono;

  const FirmaDocumentoScreen({
    super.key,
    required this.richiestaId,
    required this.userId,
    required this.telefono,
  });

  @override
  State<FirmaDocumentoScreen> createState() => _FirmaDocumentoScreenState();
}

class _FirmaDocumentoScreenState extends State<FirmaDocumentoScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _chiudi() {
    final provider =
        Provider.of<FirmaDigitaleProvider>(context, listen: false);
    provider.reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('digitalSignatureScreenTitle')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _chiudi,
          ),
        ],
      ),
      body: Consumer<FirmaDigitaleProvider>(
        builder: (context, provider, _) {
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (_) {
              setState(() {});
            },
            children: [
              // Step 1: Visualizza Documento
              VisualizzaDocumentoWidget(
                richiestaId: widget.richiestaId,
                userId: widget.userId,
                telefono: widget.telefono,
                onFirmaClick: _nextStep,
              ),

              // Step 2: Richiesta OTP
              RichiestaOTPWidget(
                onOTPInviato: _nextStep,
              ),

              // Step 3: Verifica OTP
              VerificaOTPWidget(
                onOTPVerificato: _nextStep,
              ),

              // Step 4: Conferma Firma
              ConfermaFirmaWidget(
                onFirmaCompleta: _nextStep,
              ),

              // Step 5: Risultato Firma
              RisultatoFirmaWidget(
                onChiudi: _chiudi,
                onVisualizzaRicevuta: () {
                  // TODO: Implementare scaricamento ricevuta
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('receiptDownloadedSimple')),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildProgressBar(),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final currentStep = _getCurrentStep(provider.step);
        final totalSteps = 5;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${currentStep + 1} di $totalSteps',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / totalSteps,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(provider.step),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  int _getCurrentStep(FirmaStep step) {
    switch (step) {
      case FirmaStep.initial:
      case FirmaStep.loadingDocumento:
      case FirmaStep.documentoCaricato:
        return 0;
      case FirmaStep.otpInviato:
        return 1;
      case FirmaStep.verificaOTP:
      case FirmaStep.otpVerificato:
        return 2;
      case FirmaStep.firmando:
      case FirmaStep.firmato:
        return 3;
      case FirmaStep.errore:
        return _pageController.page?.toInt() ?? 0;
    }
  }

  Color _getProgressColor(FirmaStep step) {
    if (step == FirmaStep.errore) {
      return Colors.red;
    } else if (step == FirmaStep.firmato) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
