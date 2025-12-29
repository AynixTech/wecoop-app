import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Widget che mostra un pulsante di aiuto dopo 10 secondi di inattività
/// Appare in basso a destra e permette di creare una richiesta di supporto
class HelpButtonWidget extends StatefulWidget {
  /// Nome del servizio corrente (es: "Accoglienza e Orientamento")
  final String serviceName;
  
  /// ID categoria servizio (opzionale, per tracciare meglio)
  final String? serviceCategory;
  
  /// Schermata corrente (per debugging e analytics)
  final String? currentScreen;

  const HelpButtonWidget({
    super.key,
    required this.serviceName,
    this.serviceCategory,
    this.currentScreen,
  });

  @override
  State<HelpButtonWidget> createState() => _HelpButtonWidgetState();
}

class _HelpButtonWidgetState extends State<HelpButtonWidget> {
  Timer? _inactivityTimer;
  bool _isSubmitting = false;
  final _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  /// Avvia il timer di inattività (10 secondi)
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        // Mostra direttamente il dialog invece del pulsante
        _showHelpDialog();
      }
    });
  }

  /// Resetta il timer quando l'utente interagisce
  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  /// Mostra il dialog "Hai bisogno di aiuto?"
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
              _resetInactivityTimer();
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
        'tipo_richiesta': 'aiuto_automatico',
        'priorita': 'media',
        'messaggio': 'L\'utente ha richiesto aiuto dopo 10 secondi di inattività nel servizio ${widget.serviceName}',
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
              _resetInactivityTimer();
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
    // Widget invisibile, il dialog si apre automaticamente dopo 10 secondi
    return const SizedBox.shrink();
  }
}
