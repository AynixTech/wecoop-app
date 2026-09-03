import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import '../../theme/theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../models/pagamento_model.dart';
import '../../services/pagamento_service.dart';
import '../../services/app_localizations.dart';
import '../../services/push_notification_service.dart';
import '../../config/stripe_config.dart';
import '../../utils/service_request_labels.dart';

class PagamentoScreen extends StatefulWidget {
  final int paymentId;
  final int? richiestaId; // Opzionale: se passi la richiesta invece del payment

  const PagamentoScreen({
    super.key,
    this.paymentId = 0,
    this.richiestaId,
  });

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  Pagamento? _pagamento;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isStripeLoadingDialogVisible = false;

  @override
  void initState() {
    super.initState();
    AppLogger.d('🚀 [PagamentoScreen] initState - paymentId: ${widget.paymentId}, richiestaId: ${widget.richiestaId}');
    _loadPagamento();
  }

  Future<void> _loadPagamento() async {
    AppLogger.d('📱 [PagamentoScreen] Caricamento pagamento...');
    AppLogger.d('📱 [PagamentoScreen] paymentId: ${widget.paymentId}, richiestaId: ${widget.richiestaId}');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Pagamento? pagamento;

      if (widget.richiestaId != null) {
        AppLogger.d('📱 [PagamentoScreen] Carico tramite richiestaId: ${widget.richiestaId}');
        // Carica pagamento tramite richiesta_id
        pagamento = await PagamentoService.getPagamentoPerRichiesta(
          widget.richiestaId!,
        );
      } else if (widget.paymentId > 0) {
        AppLogger.d('📱 [PagamentoScreen] Carico tramite paymentId: ${widget.paymentId}');
        // Carica pagamento tramite payment_id
        pagamento = await PagamentoService.getPagamento(widget.paymentId);
      } else {
        AppLogger.d('⚠️ [PagamentoScreen] Né paymentId né richiestaId forniti!');
      }

      if (pagamento == null) {
        AppLogger.d('❌ [PagamentoScreen] Pagamento non trovato o non esiste');
        
        String errorMsg;
        final l10n = AppLocalizations.of(context);
        if (widget.richiestaId != null) {
          errorMsg = (l10n?.translate('paymentNotRequired') ??
                  'Nessun pagamento richiesto per questa richiesta.\n\nRichiesta ID: {id}')
              .replaceAll('{id}', '${widget.richiestaId}');
        } else {
          errorMsg = l10n?.translate('paymentNotFoundDetail') ??
              (l10n?.paymentNotFound ?? 'Pagamento non trovato');
        }
        
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        return;
      }

      AppLogger.d('✅ [PagamentoScreen] Pagamento caricato: ID ${pagamento.id}, €${pagamento.importo}, Stato: ${pagamento.stato}');
      
      setState(() {
        _pagamento = pagamento;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.d('❌ [PagamentoScreen] Errore caricamento: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)?.translate('paymentLoadError') ??
            'Errore durante il caricamento del pagamento';
        _isLoading = false;
      });
    }
  }

  Future<void> _ensureStripeReady() async {
    // Se gia' configurato (via dart-define o fetch precedente), non fare nulla.
    if (StripeConfig.isConfigured) return;

    final key = await PagamentoService.getStripePublishableKey();
    if (key == null || key.isEmpty) {
      AppLogger.d('⚠️ [PagamentoScreen] Publishable key non disponibile dal backend');
      return;
    }

    StripeConfig.runtimePublishableKey = key;
    try {
      Stripe.publishableKey = key;
      Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
      Stripe.urlScheme = StripeConfig.urlScheme;
      await Stripe.instance.applySettings();
      AppLogger.d('✅ [PagamentoScreen] Stripe inizializzato da backend (${StripeConfig.isTestMode ? "TEST" : "LIVE"})');
    } catch (e) {
      AppLogger.d('❌ [PagamentoScreen] Errore applySettings Stripe: $e');
    }
  }

  Future<void> _handleStripePayment() async {
    AppLogger.d('💳 [PagamentoScreen] Inizio processo pagamento Stripe');
    
    if (_pagamento == null) {
      AppLogger.d('❌ [PagamentoScreen] Pagamento null, impossibile procedere');
      return;
    }

    AppLogger.d('💳 [PagamentoScreen] Pagamento: ID ${_pagamento!.id}, Importo €${_pagamento!.importo}, Stato: ${_pagamento!.stato}');

    // Assicura che Stripe sia inizializzato usando la chiave del backend (wp-config-stripe.php)
    await _ensureStripeReady();

    // Verifica se Stripe è configurato
    if (!StripeConfig.isConfigured) {
      AppLogger.d('❌ [PagamentoScreen] Stripe non configurato');
      _showErrorDialog(
        AppLocalizations.of(context)!.translate('stripeUnavailable'),
      );
      return;
    }

    AppLogger.d('✅ [PagamentoScreen] Stripe configurato correttamente');

    try {
      // Mostra loading
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      _isStripeLoadingDialogVisible = true;

      AppLogger.d('🔄 Creo Payment Intent per €${_pagamento!.importo}...');

      // 1. Crea Payment Intent sul backend
      final clientSecret = await PagamentoService.creaStripePaymentIntent(
        importo: _pagamento!.importo,
        paymentId: _pagamento!.id,
      );

      AppLogger.d('✅ Client Secret ricevuto: ${clientSecret != null ? "OK" : "NULL"}');

      if (!mounted) return;
      if (_isStripeLoadingDialogVisible &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
        _isStripeLoadingDialogVisible = false;
        // Attendi la fine dell'animazione di chiusura del dialog prima di mostrare Stripe.
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }

      if (clientSecret == null) {
        _showErrorDialog(
          AppLocalizations.of(context)!.translate('paymentCreateFailed'),
        );
        return;
      }

      AppLogger.d('🔄 Inizializzo Payment Sheet...');

      // 2. Inizializza Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'KINTI SRL',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF00A86B),
            ),
          ),
        ),
      );

      AppLogger.d('✅ Payment Sheet inizializzato, mostro UI...');

      // 3. Mostra Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      AppLogger.d('✅ Pagamento completato con successo!');

      // 4. Se arriviamo qui, il pagamento è riuscito
      // Conferma sul backend WordPress
      final result = await PagamentoService.confermaPagamento(
        paymentId: _pagamento!.id,
        metodoPagamento: 'stripe',
        transactionId: clientSecret,
        note: 'Pagato tramite Stripe in-app',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Registra push token per email future con deep link app (non "Vai alla piattaforma").
        await PushNotificationService().syncTokenWithBackend();

        // Ricarica i dati del pagamento
        await _loadPagamento();

        _showSuccessDialog(
          AppLocalizations.of(context)!.translate('paymentCompletedTitle'),
          AppLocalizations.of(context)!
              .translate('paymentCompletedBody')
              .replaceAll('{amount}', _pagamento!.importo.toStringAsFixed(2)),
        );
      } else {
        _showErrorDialog(
          result['message'] ??
              AppLocalizations.of(context)!.translate('paymentConfirmError'),
        );
      }
    } on StripeException catch (e) {
      AppLogger.d('❌ StripeException: ${e.error.code} - ${e.error.message}');
      if (!mounted) return;
      
      if (_isStripeLoadingDialogVisible &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
        _isStripeLoadingDialogVisible = false;
      }

      // Gestisci errori Stripe specifici
      if (e.error.code == FailureCode.Canceled) {
        AppLogger.d('ℹ️ Utente ha annullato il pagamento');
        // Utente ha annullato
        return;
      }

      _showErrorDialog(
        AppLocalizations.of(context)!
            .translate('stripeErrorPrefix')
            .replaceAll('{detail}', '${e.error.localizedMessage ?? e.error.message}'),
      );
    } catch (e) {
      AppLogger.d('❌ Errore generico: $e');
      if (!mounted) return;
      if (_isStripeLoadingDialogVisible &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
        _isStripeLoadingDialogVisible = false;
      }
      _showErrorDialog(
        AppLocalizations.of(context)!
            .translate('unexpectedErrorPrefix')
            .replaceAll('{detail}', '$e'),
      );
    }
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Text(l10n.error),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Chiudi dialog
              Navigator.pop(context); // Torna alla schermata precedente
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  String _legal(String key) {
    return AppLocalizations.of(context)!.translate(key);
  }

  String _getServizioLabelTradotto(String servizio) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return servizio;
    return ServiceRequestLabels.servizio(l10n, servizio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.payment),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPagamento,
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : _pagamento == null
                  ? Center(child: Text(AppLocalizations.of(context)!.paymentNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header colorato
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.payment,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '€${_pagamento!.importo.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _legal('finalPriceVatIncluded'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatoBadgeColor(_pagamento!.stato),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatoIcon(_pagamento!.stato),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _pagamento!.statoReadable(context),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dettagli pagamento
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.paymentDetails,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.paymentService,
                                      _getServizioLabelTradotto(_pagamento!.servizio ?? 'N/A'),
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.paymentFileNumber,
                                      _pagamento!.numeroPratica ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.paymentCreatedDate,
                                      _formatDate(_pagamento!.createdAt),
                                    ),
                                    _buildDetailRow(
                                      _legal('paymentInvoiceEntity'),
                                      'KINTI SRL',
                                    ),
                                    if (_pagamento!.paidAt != null)
                                      _buildDetailRow(
                                        AppLocalizations.of(context)!.paymentPaidDate,
                                        _formatDate(_pagamento!.paidAt!),
                                      ),
                                    if (_pagamento!.metodoPagamento != null)
                                      _buildDetailRow(
                                        AppLocalizations.of(context)!.paymentMethod,
                                        _pagamento!.metodoPagamento!.toUpperCase(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Pulsanti pagamento (solo se pending)
                          if (_pagamento!.isPending)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                color: const Color(0xFFF7F4EA),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _legal('paymentLegalNoticeTitle'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _legal('paymentLegalNoticeBody'),
                                        style: const TextStyle(height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (_pagamento!.isPending)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  _legal('paymentVatConfirm'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                            // Pulsanti pagamento (solo se pending)
                            if (_pagamento!.isPending)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.choosePaymentMethod,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Stripe
                                  _buildPaymentButton(
                                    icon: Icons.credit_card,
                                    label: AppLocalizations.of(context)!.payWithCard,
                                    subtitle: _legal('stripeConnectedToKinti'),
                                    color: const Color(0xFF635BFF),
                                    onTap: _handleStripePayment,
                                  ),
                                ],
                              ),
                            ),

                          // Messaggio se già pagato
                          if (_pagamento!.isPaid)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                color: AppColors.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.secondary,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.paymentCompletedSuccess,
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
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatoBadgeColor(String stato) {
    switch (stato) {
      case 'paid':
      case 'completed':
        return AppColors.secondary;
      case 'pending':
        return Colors.orange;
      case 'awaiting_payment':
        return Colors.amber;
      case 'failed':
        return AppColors.error;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatoIcon(String stato) {
    switch (stato) {
      case 'paid':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'awaiting_payment':
        return Icons.pending_actions;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
