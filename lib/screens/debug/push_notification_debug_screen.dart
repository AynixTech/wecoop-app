import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Schermata di debug per testare push notifications
class PushNotificationDebugScreen extends StatefulWidget {
  const PushNotificationDebugScreen({super.key});

  @override
  State<PushNotificationDebugScreen> createState() => _PushNotificationDebugScreenState();
}

class _PushNotificationDebugScreenState extends State<PushNotificationDebugScreen> {
  final storage = SecureStorageService();
  
  String? jwtToken;
  String? fcmToken;
  String apiStatus = 'Non testato';
  String lastError = 'Nessuno';
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    setState(() => isLoading = true);
    
    jwtToken = await storage.read(key: 'jwt_token');
    fcmToken = await storage.read(key: 'fcm_token');
    
    setState(() => isLoading = false);
  }

  Future<void> _testApiEndpoint() async {
    if (jwtToken == null || fcmToken == null) {
      setState(() {
        apiStatus = 'Errore: JWT o FCM token mancante';
      });
      return;
    }

    setState(() {
      isLoading = true;
      apiStatus = 'Test in corso...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://www.wecoop.org/wp-json/push/v1/token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': fcmToken,
          'device_info': 'Flutter App - Debug Test',
        }),
      ).timeout(const Duration(seconds: 30));

      setState(() {
        if (response.statusCode == 200) {
          apiStatus = '✅ SUCCESS (${response.statusCode})';
          lastError = 'Nessuno';
        } else if (response.statusCode == 401) {
          apiStatus = '❌ UNAUTHORIZED (${response.statusCode})';
          lastError = 'JWT token non valido o scaduto';
        } else if (response.statusCode == 404) {
          apiStatus = '❌ NOT FOUND (${response.statusCode})';
          lastError = 'Endpoint /push/v1/token non esiste';
        } else {
          apiStatus = '❌ ERROR (${response.statusCode})';
          lastError = response.body;
        }
      });
    } catch (e) {
      setState(() {
        apiStatus = '❌ EXCEPTION';
        lastError = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiato negli appunti')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Push Notifications Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '📱 FCM Token',
                    fcmToken ?? 'Non disponibile',
                    fcmToken != null,
                    onCopy: fcmToken != null ? () => _copyToClipboard(fcmToken!, 'FCM Token') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    '🔐 JWT Token',
                    jwtToken != null ? '${jwtToken!.substring(0, 30)}...' : 'Non disponibile',
                    jwtToken != null,
                    onCopy: jwtToken != null ? () => _copyToClipboard(jwtToken!, 'JWT Token') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    '🌐 API Status',
                    apiStatus,
                    apiStatus.contains('SUCCESS'),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    '⚠️ Last Error',
                    lastError,
                    lastError == 'Nessuno',
                  ),
                  const SizedBox(height: 24),
                  
                  // Pulsanti azione
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testApiEndpoint,
                      icon: const Icon(Icons.send),
                      label: const Text('Test API Endpoint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadTokens,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ricarica Tokens'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Istruzioni
                  const Text(
                    '📋 Checklist Debug',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem(
                    '1. JWT Token presente',
                    jwtToken != null,
                    'Fai login nell\'app',
                  ),
                  _buildChecklistItem(
                    '2. FCM Token presente',
                    fcmToken != null,
                    'Accetta permessi notifiche',
                  ),
                  _buildChecklistItem(
                    '3. API Endpoint funzionante',
                    apiStatus.contains('SUCCESS'),
                    'Clicca "Test API Endpoint"',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Curl command
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔧 Test con curl',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          'curl -X POST https://www.wecoop.org/wp-json/push/v1/token \\\n'
                          '  -H "Authorization: Bearer ${jwtToken?.substring(0, 30) ?? 'YOUR_JWT_TOKEN'}..." \\\n'
                          '  -H "Content-Type: application/json" \\\n'
                          '  -d \'{"token": "${fcmToken?.substring(0, 30) ?? 'YOUR_FCM_TOKEN'}...", "device_info": "Test"}\' \\\n'
                          '  -v',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Backend checklist
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Verifica Backend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Sul server WordPress verifica:'),
                        const SizedBox(height: 8),
                        const Text('• Plugin attivo: WeCoop Push Notifications'),
                        const Text('• File: firebase-credentials.json esiste'),
                        const Text('• Tabella: wp_wecoop_push_tokens creata'),
                        const Text('• Composer: vendor/ directory presente'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, String value, bool isSuccess, {VoidCallback? onCopy}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: onCopy,
                  tooltip: 'Copia',
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontFamily: value.length > 50 ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isComplete, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    decoration: isComplete ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isComplete)
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
