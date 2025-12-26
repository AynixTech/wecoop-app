import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../models/pagamento_model.dart';
import '../../services/pagamento_service.dart';
import '../../services/app_localizations.dart';
import '../../config/stripe_config.dart';

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

  @override
  void initState() {
    super.initState();
    print('🚀 [PagamentoScreen] initState - paymentId: ${widget.paymentId}, richiestaId: ${widget.richiestaId}');
    _loadPagamento();
  }

  Future<void> _loadPagamento() async {
    print('📱 [PagamentoScreen] Caricamento pagamento...');
    print('📱 [PagamentoScreen] paymentId: ${widget.paymentId}, richiestaId: ${widget.richiestaId}');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Pagamento? pagamento;

      if (widget.richiestaId != null) {
        print('📱 [PagamentoScreen] Carico tramite richiestaId: ${widget.richiestaId}');
        // Carica pagamento tramite richiesta_id
        pagamento = await PagamentoService.getPagamentoPerRichiesta(
          widget.richiestaId!,
        );
      } else if (widget.paymentId > 0) {
        print('📱 [PagamentoScreen] Carico tramite paymentId: ${widget.paymentId}');
        // Carica pagamento tramite payment_id
        pagamento = await PagamentoService.getPagamento(widget.paymentId);
      } else {
        print('⚠️ [PagamentoScreen] Né paymentId né richiestaId forniti!');
      }

      if (pagamento == null) {
        print('❌ [PagamentoScreen] Pagamento non trovato o non esiste');
        
        String errorMsg;
        if (widget.richiestaId != null) {
          errorMsg = 'Nessun pagamento richiesto per questa richiesta.\n\n'
              'Questa richiesta potrebbe non richiedere un pagamento o il pagamento '
              'non è ancora stato creato dal sistema.\n\n'
              'Richiesta ID: ${widget.richiestaId}';
        } else {
          errorMsg = 'Pagamento non trovato.\n\n'
              'Il pagamento richiesto non esiste o non hai i permessi per visualizzarlo.';
        }
        
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        return;
      }

      print('✅ [PagamentoScreen] Pagamento caricato: ID ${pagamento.id}, €${pagamento.importo}, Stato: ${pagamento.stato}');
      
      setState(() {
        _pagamento = pagamento;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [PagamentoScreen] Errore caricamento: $e');
      setState(() {
        _errorMessage = 'Errore durante il caricamento del pagamento';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStripePayment() async {
    print('💳 [PagamentoScreen] Inizio processo pagamento Stripe');
    
    if (_pagamento == null) {
      print('❌ [PagamentoScreen] Pagamento null, impossibile procedere');
      return;
    }

    print('💳 [PagamentoScreen] Pagamento: ID ${_pagamento!.id}, Importo €${_pagamento!.importo}, Stato: ${_pagamento!.stato}');

    // Verifica se Stripe è configurato
    if (!StripeConfig.isConfigured) {
      print('❌ [PagamentoScreen] Stripe non configurato');
      _showErrorDialog(
        'Stripe non disponibile!\n\n'
        'I pagamenti con carta non sono al momento disponibili. '
        'Riprova più tardi o usa un metodo di pagamento alternativo.'
      );
      return;
    }

    print('✅ [PagamentoScreen] Stripe configurato correttamente');

    try {
      // Mostra loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      print('🔄 Creo Payment Intent per €${_pagamento!.importo}...');

      // 1. Crea Payment Intent sul backend
      final clientSecret = await PagamentoService.creaStripePaymentIntent(
        importo: _pagamento!.importo,
        paymentId: _pagamento!.id,
      );

      print('✅ Client Secret ricevuto: ${clientSecret != null ? "OK" : "NULL"}');

      if (!mounted) return;
      Navigator.pop(context); // Chiudi loading

      if (clientSecret == null) {
        _showErrorDialog(
          'Impossibile creare il pagamento.\n\n'
          'Il server non è riuscito a processare la richiesta. '
          'Verifica la tua connessione e riprova.'
        );
        return;
      }

      print('🔄 Inizializzo Payment Sheet...');

      // 2. Inizializza Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'WeCoop',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF00A86B),
            ),
          ),
        ),
      );

      print('✅ Payment Sheet inizializzato, mostro UI...');

      // 3. Mostra Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print('✅ Pagamento completato con successo!');

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
        // Ricarica i dati del pagamento
        await _loadPagamento();

        _showSuccessDialog(
          'Pagamento Completato!',
          'Il tuo pagamento di €${_pagamento!.importo.toStringAsFixed(2)} è stato processato con successo.',
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Errore durante la conferma del pagamento');
      }
    } on StripeException catch (e) {
      print('❌ StripeException: ${e.error.code} - ${e.error.message}');
      if (!mounted) return;
      
      // Chiudi loading solo se non è già chiuso
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Gestisci errori Stripe specifici
      if (e.error.code == FailureCode.Canceled) {
        print('ℹ️ Utente ha annullato il pagamento');
        // Utente ha annullato
        return;
      }

      _showErrorDialog('Errore Stripe: ${e.error.localizedMessage ?? e.error.message}');
    } catch (e) {
      print('❌ Errore generico: $e');
      if (!mounted) return;
      Navigator.pop(context); // Chiudi loading se aperto
      _showErrorDialog('Errore imprevisto: $e');
    }
  }

  Future<void> _handlePayPalPayment() async {
    if (_pagamento == null) return;

    // TODO: Integra PayPal
    _showInfoDialog(
      'Integrazione PayPal',
      'PayPal non ancora integrato.\n\nImporto: €${_pagamento!.importo.toStringAsFixed(2)}\n\nIntegra react-native-paypal o simile.',
    );
  }

  Future<void> _handleBankTransferPayment() async {
    if (_pagamento == null) return;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bonifico Bancario'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Importo: €${_pagamento!.importo.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Coordinate bancarie:'),
              const SizedBox(height: 8),
              _buildBankDetail('IBAN', 'IT60 X054 2811 1010 0000 0123 456'),
              _buildBankDetail('Intestatario', 'WeCoop Cooperativa'),
              _buildBankDetail('BIC/SWIFT', 'BPMOIT22XXX'),
              const SizedBox(height: 16),
              Text(
                'Causale: ${_pagamento!.numeroPratica ?? 'Pagamento #${_pagamento!.id}'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dopo aver effettuato il bonifico, invia la ricevuta a pagamenti@wecoop.org',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(
                'Istruzioni inviate',
                'Ti abbiamo inviato una email con le istruzioni per il bonifico.',
              );
            },
            child: const Text('Invia Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
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

  void _showInfoDialog(String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title),
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
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
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
                          color: Colors.red,
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
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : _pagamento == null
                  ? const Center(child: Text('Pagamento non trovato'))
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
                                      _pagamento!.servizio ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.paymentFileNumber,
                                      _pagamento!.numeroPratica ?? 'N/A',
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.paymentCreatedDate,
                                      _formatDate(_pagamento!.createdAt),
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
                                    subtitle: AppLocalizations.of(context)!.payWithCardDesc,
                                    color: const Color(0xFF635BFF),
                                    onTap: _handleStripePayment,
                                  ),
                                  const SizedBox(height: 12),

                                  // PayPal
                                  _buildPaymentButton(
                                    icon: Icons.account_balance_wallet,
                                    label: AppLocalizations.of(context)!.payPal,
                                    subtitle: AppLocalizations.of(context)!.payPalDesc,
                                    color: const Color(0xFF0070BA),
                                    onTap: _handlePayPalPayment,
                                  ),
                                  const SizedBox(height: 12),

                                  // Bonifico
                                  _buildPaymentButton(
                                    icon: Icons.account_balance,
                                    label: AppLocalizations.of(context)!.bankTransfer,
                                    subtitle: AppLocalizations.of(context)!.bankTransferDesc,
                                    color: Colors.green,
                                    onTap: _handleBankTransferPayment,
                                  ),
                                ],
                              ),
                            ),

                          // Messaggio se già pagato
                          if (_pagamento!.isPaid)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                color: Colors.green.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
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
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'awaiting_payment':
        return Colors.amber;
      case 'failed':
        return Colors.red;
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
