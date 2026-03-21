import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final _storage = SecureStorageService();

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

  /// Crea una richiesta di supporto chiamando l'API backend
  Future<void> _creaRichiestaSupporto() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Recupera dati utente
      final token = await _storage.read(key: 'jwt_token');
      final userId = await _storage.read(key: 'user_id');
      final userEmail = await _storage.read(key: 'user_email');
      final userName = await _storage.read(key: 'user_display_name');
      final userPhone = await _storage.read(key: 'last_login_phone');

      if (token == null || userId == null) {
        _showErrorSnackbar(localizations.errorNotAuthenticated);
        return;
      }

      final url = Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/supporto/richiesta');
      
      final body = {
        'user_id': userId,
        'service_name': widget.serviceName,
        'service_category': widget.serviceCategory ?? 'non_specificato',
        'current_screen': widget.currentScreen ?? 'non_specificato',
        'user_email': userEmail ?? '',
        'user_name': userName ?? '',
        'user_phone': userPhone ?? '',
        'tipo_richiesta': 'aiuto_manuale',
        'priorita': 'media',
        'messaggio': 'L\'utente ha richiesto aiuto cliccando il bubble WhatsApp nel servizio ${widget.serviceName}',
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('\n📤 RICHIESTA SUPPORTO:');
      print('   URL: $url');
      print('   Headers: Content-Type: application/json');
      print('   Authorization: Bearer ${token.substring(0, 20)}...');
      print('   Body:');
      print(jsonEncode(body));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('\n📥 RISPOSTA SUPPORTO:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Richiesta supporto creata!');
        print('   ID: ${data['data']?['id'] ?? 'N/A'}');
        print('   Numero Ticket: ${data['data']?['numero_ticket'] ?? 'N/A'}');
        print('   Status: ${data['data']?['status'] ?? 'N/A'}');
        
        _showSuccessDialog(data['data']?['numero_ticket']);
      } else {
        print('❌ Errore nella risposta: ${response.statusCode}');
        _showErrorSnackbar(localizations.errorSendingRequest);
      }
    } catch (e) {
      print('❌ Errore richiesta supporto: $e');
      _showErrorSnackbar(localizations.connectionError);
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
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
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
