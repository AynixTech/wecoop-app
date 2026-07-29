import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/supporto_service.dart';

/// Bubble button fisso in basso a destra che apre la modale di supporto al click
class HelpButtonWidget extends StatefulWidget {
  /// Nome del servizio corrente (es: "Vivere in Italia")
  final String serviceName;
  
  /// ID categoria servizio (opzionale, per tracciare meglio)
  final String? serviceCategory;
  
  /// Schermata corrente (per debugging e analytics)
  final String? currentScreen;

  /// Distanza dal basso per posizionare il bubble sopra il pulsante di invio
  final double bottomOffset;

  const HelpButtonWidget({
    super.key,
    required this.serviceName,
    this.serviceCategory,
    this.currentScreen,
    this.bottomOffset = 104,
  });

  @override
  State<HelpButtonWidget> createState() => _HelpButtonWidgetState();
}

class _HelpButtonWidgetState extends State<HelpButtonWidget> {
  bool _isSubmitting = false;

  /// Mostra il dialog "Hai bisogno di aiuto?" quando l'utente clicca il bubble
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Color(0xFF2196F3), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.needHelp,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${localizations.usingService} "${widget.serviceName}".',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.canWeAssist,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(localizations.noThanks),
          ),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () {
              Navigator.of(context).pop();
              _creaRichiestaSupporto();
            },
            icon: _isSubmitting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? localizations.sending : localizations.yesHelpMe),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Crea una richiesta di supporto chiamando il backend Node via SupportoService.
  Future<void> _creaRichiestaSupporto() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await SupportoService.creaRichiesta(
        serviceName: widget.serviceName,
        serviceCategory: widget.serviceCategory ?? 'non_specificato',
        currentScreen: widget.currentScreen ?? 'non_specificato',
        tipoRichiesta: 'aiuto_manuale',
        priorita: 'media',
        messaggio:
            'L\'utente ha richiesto aiuto cliccando il bubble WhatsApp nel servizio ${widget.serviceName}',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog(result['numero_ticket']?.toString());
      } else {
        _showErrorSnackbar(
          (result['message'] as String?) ?? localizations.errorSendingRequest,
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar(localizations.connectionError);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Mostra dialog di successo
  void _showSuccessDialog([String? numeroTicket]) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(localizations.requestSentSuccess, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.supportRequestCreated,
              style: const TextStyle(fontSize: 14),
            ),
            if (numeroTicket != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.ticketNumber,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            numeroTicket,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              localizations.operatorWillContact,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  /// Mostra snackbar di errore
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: widget.bottomOffset,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showHelpDialog,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.chat,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
