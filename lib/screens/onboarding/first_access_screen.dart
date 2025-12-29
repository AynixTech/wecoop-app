import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Schermata di primo accesso con registrazione semplificata
/// Solo 4 campi obbligatori: nome, cognome, prefisso, telefono
class FirstAccessScreen extends StatefulWidget {
  const FirstAccessScreen({super.key});

  @override
  State<FirstAccessScreen> createState() => _FirstAccessScreenState();
}

class _FirstAccessScreenState extends State<FirstAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _prefixController = TextEditingController(text: '+39');
  final _telefonoController = TextEditingController();
  final _storage = SecureStorageService();
  
  bool _isLoading = false;
  
  // Lista prefissi comuni
  final List<String> _prefissi = [
    '+39', // Italia
    '+1',  // USA/Canada
    '+44', // UK
    '+33', // Francia
    '+49', // Germania
    '+34', // Spagna
    '+351', // Portogallo
    '+41', // Svizzera
    '+43', // Austria
    '+30', // Grecia
  ];

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty && mounted) {
      // Utente già loggato, vai direttamente ai servizi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _prefixController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Banner verde informativo
            _buildInfoBanner(),
            
            // Form registrazione
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Logo/Icona
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 24),
                      
                      // Titolo
                      const Text(
                        'Benvenuto!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Inserisci i tuoi dati per iniziare',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Campo Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome *',
                          hintText: 'Mario',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Il nome è obbligatorio';
                          }
                          if (value.trim().length < 2) {
                            return 'Il nome deve avere almeno 2 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Cognome
                      TextFormField(
                        controller: _cognomeController,
                        decoration: InputDecoration(
                          labelText: 'Cognome *',
                          hintText: 'Rossi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Il cognome è obbligatorio';
                          }
                          if (value.trim().length < 2) {
                            return 'Il cognome deve avere almeno 2 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Prefisso + Telefono in riga
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prefisso (dropdown)
                          SizedBox(
                            width: 100,
                            child: DropdownButtonFormField<String>(
                              value: _prefixController.text,
                              decoration: InputDecoration(
                                labelText: 'Pref. *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _prefissi.map((String prefix) {
                                return DropdownMenuItem<String>(
                                  value: prefix,
                                  child: Text(prefix),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _prefixController.text = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Telefono
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoController,
                              decoration: InputDecoration(
                                labelText: 'Telefono *',
                                hintText: '3331234567',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Il telefono è obbligatorio';
                                }
                                
                                // Rimuovi spazi e caratteri non numerici
                                final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                                
                                // Per +39 deve essere 10 cifre (333 123 4567)
                                if (_prefixController.text == '+39') {
                                  if (cleanPhone.length != 10) {
                                    return 'Deve essere 10 cifre (es: 3331234567)';
                                  }
                                } else {
                                  // Altri prefissi: almeno 8 cifre
                                  if (cleanPhone.length < 8) {
                                    return 'Numero telefono non valido';
                                  }
                                }
                                
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Pulsante Continua
                      ElevatedButton(
                        onPressed: _isLoading ? null : _completaPrimoAccesso,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2196F3),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Continua',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Note informative
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dopo la registrazione, potrai accedere a tutti i servizi. '
                                'Un operatore ti contatterà per completare l\'adesione come socio.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Completa i tuoi dati per accedere a tutti i servizi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completaPrimoAccesso() async {
    print('\n🚀 === INIZIO PRIMO ACCESSO ===');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form non validato');
      return;
    }
    
    print('✅ Form validato correttamente');

    setState(() => _isLoading = true);

    try {
      // Pulisci il telefono (solo numeri)
      final cleanPhone = _telefonoController.text.replaceAll(RegExp(r'[^\d]'), '');
      final prefix = _prefixController.text.replaceAll('+', '');
      final telefonoCompleto = '+$prefix$cleanPhone';
      
      print('📝 Dati raccolti:');
      print('   - Nome: ${_nomeController.text.trim()}');
      print('   - Cognome: ${_cognomeController.text.trim()}');
      print('   - Prefisso: ${_prefixController.text}');
      print('   - Telefono pulito: $cleanPhone');
      print('   - Telefono completo: $telefonoCompleto');
      print('\n🔄 Invio richiesta HTTP a backend...');

      // Chiamata al backend WordPress
      final url = 'https://www.wecoop.org/wp-json/wecoop/v1/utenti/primo-accesso';
      final requestBody = {
        'nome': _nomeController.text.trim(),
        'cognome': _cognomeController.text.trim(),
        'prefix': _prefixController.text,
        'telefono': cleanPhone,
      };
      
      print('🌐 URL: $url');
      print('📤 Request Body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('\n📥 RISPOSTA RICEVUTA:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Headers: ${response.headers}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Status 200 OK');
        print('🔍 Parsing JSON...');
        final data = jsonDecode(response.body);
        print('📦 JSON decodificato completo:');
        print(jsonEncode(data)); // Stampa tutto il JSON formattato
        
        print('\n🔎 VERIFICA STRUTTURA RESPONSE:');
        print('   - success presente? ${data.containsKey('success')}');
        print('   - success valore: ${data['success']}');
        print('   - data presente? ${data.containsKey('data')}');
        
        if (data['data'] != null) {
          print('\n📋 CONTENUTO data:');
          print('   - id: ${data['data']['id']}');
          print('   - user_id: ${data['data']['user_id']}');
          print('   - username: ${data['data']['username']}');
          print('   - password: ${data['data']['password']}');
          print('   - token: ${data['data']['token'] != null ? 'PRESENTE (${data['data']['token'].toString().length} chars)' : 'MANCANTE'}');
          print('   - numero_pratica: ${data['data']['numero_pratica']}');
          print('   - nome: ${data['data']['nome']}');
          print('   - cognome: ${data['data']['cognome']}');
          print('   - telefono_completo: ${data['data']['telefono_completo']}');
          print('   - is_socio: ${data['data']['is_socio']}');
          print('   - profilo_completo: ${data['data']['profilo_completo']}');
        } else {
          print('⚠️ data è NULL!');
        }
        
        if (data['success'] == true) {
          print('✅ success = true');
          
          // Salva dati localmente
          print('💾 Salvataggio in SharedPreferences...');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('primo_accesso_completato', true);
          print('   ✓ primo_accesso_completato = true');
          
          if (data['data'] != null) {
            final userData = data['data'];
            print('👤 Dati utente ricevuti:');
            print('   - ID Richiesta: ${userData['id']}');
            print('   - User ID WordPress: ${userData['user_id']}');
            print('   - Numero Pratica: ${userData['numero_pratica']}');
            print('   - Username: ${userData['username']}');
            print('   - Password: ${userData['password']}');
            print('   - Nome: ${userData['nome']}');
            print('   - Cognome: ${userData['cognome']}');
            print('   - Telefono: ${userData['telefono_completo']}');
            print('   - Is Socio: ${userData['is_socio']}');
            print('   - Profilo Completo: ${userData['profilo_completo']}');
            
            await prefs.setInt('user_id', userData['user_id'] ?? 0);
            await prefs.setInt('richiesta_id', userData['id'] ?? 0);
            await prefs.setString('numero_pratica', userData['numero_pratica'] ?? '');
            await prefs.setString('username', userData['username'] ?? '');
            await prefs.setString('nome', userData['nome'] ?? '');
            await prefs.setString('cognome', userData['cognome'] ?? '');
            await prefs.setString('telefono_completo', userData['telefono_completo'] ?? telefonoCompleto);
            await prefs.setBool('is_socio', userData['is_socio'] ?? false);
            await prefs.setBool('profilo_completo', userData['profilo_completo'] ?? false);
            print('   ✓ Salvato in SharedPreferences');
            
            // Salva credenziali in secure storage
            await _storage.write(key: 'user_id', value: (userData['user_id'] ?? 0).toString());
            await _storage.write(key: 'username', value: userData['username'] ?? '');
            await _storage.write(key: 'password', value: userData['password'] ?? '');
            await _storage.write(key: 'numero_pratica', value: userData['numero_pratica'] ?? '');
            
            if (userData['username'] != null && userData['username'].toString().isNotEmpty) {
              print('   ✓ Username salvato: ${userData['username']}');
            } else {
              print('   ⚠️ USERNAME MANCANTE O VUOTO!');
            }
            
            if (userData['password'] != null && userData['password'].toString().isNotEmpty) {
              print('   ✓ Password salvata in secure storage');
            } else {
              print('   ⚠️ PASSWORD MANCANTE O VUOTA!');
            }
            
            // Salva JWT token se presente
            if (userData['token'] != null) {
              await _storage.write(key: 'jwt_token', value: userData['token']);
              print('   ✓ JWT Token salvato');
            }
            
            print('   ✓ Salvato in SecureStorage');
          }
          
          if (mounted) {
            print('\n🎉 Registrazione completata con successo!');
            
            // Mostra SEMPRE il dialog con le credenziali
            print('📱 Mostra dialog con credenziali...');
            await _showSuccessDialog(data);
            
            // Dopo che l'utente chiude il dialog, fa login automatico
            print('\n🔍 CHECK CREDENZIALI PER LOGIN AUTOMATICO:');
            print('   - data presente? ${data['data'] != null}');
            print('   - username presente? ${data['data']?['username'] != null}');
            print('   - username valore: ${data['data']?['username']}');
            print('   - password presente? ${data['data']?['password'] != null}');
            print('   - password valore: ${data['data']?['password']}');
            
            if (data['data'] != null && 
                data['data']['username'] != null && 
                data['data']['password'] != null &&
                data['data']['username'].toString().isNotEmpty &&
                data['data']['password'].toString().isNotEmpty) {
              print('✅ Credenziali valide - Avvio login automatico...');
              await _autoLogin(
                data['data']['username'],
                data['data']['password'],
              );
            } else {
              print('⚠️ CREDENZIALI MANCANTI O INVALIDE:');
              if (data['data'] == null) {
                print('   - data è NULL');
              }
              final username = data['data']?['username'];
              final password = data['data']?['password'];
              
              if (username == null || username.toString().isEmpty) {
                print('   - username è NULL o vuoto');
              }
              if (password == null || password.toString().isEmpty) {
                print('   - password è NULL o vuota');
              }
              // Fallback: vai a MainScreen senza login
              print('🧭 Navigazione a MainScreen (senza login)...');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
              print('✅ Navigazione completata\n');
            }
          }
        } else {
          print('⚠️ success = false');
          print('   Messaggio: ${data['message']}');
          print('   Codice errore: ${data['code']}');
          
          // Gestione errori specifici
          if (data['code'] == 'duplicate_phone') {
            _showDuplicatePhoneDialog(data['message'] ?? 'Questo numero è già registrato');
          } else {
            _showErrorDialog(data['message'] ?? 'Errore durante la registrazione');
          }
        }
      } else {
        print('❌ Status code NON 200: ${response.statusCode}');
        _showErrorDialog('Errore del server (${response.statusCode}). Riprova più tardi.');
      }
    } catch (e, stackTrace) {
      print('\n❌ ECCEZIONE CATTURATA:');
      print('   Errore: $e');
      print('   StackTrace: $stackTrace');
      _showErrorDialog('Errore di connessione: $e');
    } finally {
      print('\n🏁 Termino caricamento...');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('=== FINE PRIMO ACCESSO ===\n');
    }
  }

  /// Login automatico dopo registrazione
  Future<void> _autoLogin(String username, String password) async {
    print('\n🔑 === INIZIO LOGIN AUTOMATICO ===');
    print('   Username ricevuto: $username');
    print('   Password ricevuta: $password');
    print('   Username vuoto? ${username.isEmpty}');
    print('   Password vuota? ${password.isEmpty}');
    
    if (username.isEmpty || password.isEmpty) {
      print('❌ ERRORE: Username o password vuoti!');
      _showLoginErrorDialog('Credenziali mancanti (username o password vuoti)');
      return;
    }
    
    final url = Uri.parse('https://www.wecoop.org/wp-json/jwt-auth/v1/token');
    
    try {
      print('🌐 Chiamata a: $url');
      print('📤 Body request:');
      print('   {"username": "$username", "password": "$password"}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('\n📥 RISPOSTA LOGIN:');
      print('   Status: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body completo: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Status 200 - Parsing JSON...');
        final data = jsonDecode(response.body);
        print('📦 JSON decodificato:');
        print(jsonEncode(data));
        
        print('\n🔍 Verifica campi response:');
        print('   - token presente? ${data['token'] != null}');
        print('   - user_email: ${data['user_email']}');
        print('   - user_display_name: ${data['user_display_name']}');
        print('   - user_nicename: ${data['user_nicename']}');
        print('   - user_id: ${data['user_id']}');
        
        if (data['token'] != null) {
          print('✅ JWT Token ricevuto! (${data['token'].toString().length} chars)');
          print('\n💾 Salvataggio token e dati utente...');
          
          // Salva token e dati utente
          await _storage.write(key: 'jwt_token', value: data['token']);
          await _storage.write(key: 'user_email', value: data['user_email'] ?? '');
          await _storage.write(key: 'user_display_name', value: data['user_display_name'] ?? '');
          await _storage.write(key: 'user_nicename', value: data['user_nicename'] ?? '');
          await _storage.write(key: 'last_login_phone', value: username);
          
          if (data['user_id'] != null) {
            await _storage.write(key: 'user_id', value: data['user_id'].toString());
            print('   ✓ User ID salvato: ${data['user_id']}');
          }
          
          print('   ✓ Token JWT salvato');
          print('   ✓ Dati utente salvati');
          
          // Recupera metadati utente
          if (data['user_nicename'] != null) {
            await _fetchUserMeta(data['token'], data['user_nicename']);
          }
          
          // Inizializza push notifications
          try {
            await PushNotificationService().initialize();
            print('   ✓ Push notifications inizializzate');
          } catch (e) {
            print('   ⚠️ Errore push notifications: $e');
          }
          
          if (mounted) {
            print('\n🎉 Login automatico completato!');
            print('🧭 Navigazione a MainScreen...');
            
            // Naviga alla schermata principale
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
            
            // Mostra messaggio di benvenuto
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Benvenuto! Accesso effettuato con successo'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            
            print('✅ Navigazione completata');
          }
        } else {
          print('\n❌ TOKEN MANCANTE NELLA RISPOSTA!');
          print('   Response completa: ${response.body}');
          _showLoginErrorDialog('Token non ricevuto dal server');
        }
      } else {
        print('\n❌ LOGIN FALLITO!');
        print('   Status: ${response.statusCode}');
        print('   Body: ${response.body}');
        
        try {
          final data = jsonDecode(response.body);
          print('   Messaggio errore: ${data['message']}');
          print('   Codice errore: ${data['code']}');
          _showLoginErrorDialog(data['message'] ?? 'Errore durante il login automatico (${response.statusCode})');
        } catch (e) {
          print('   Impossibile decodificare risposta errore: $e');
          _showLoginErrorDialog('Errore durante il login automatico (${response.statusCode})');
        }
      }
    } catch (e, stackTrace) {
      print('\n❌ ERRORE LOGIN AUTOMATICO:');
      print('   Errore: $e');
      print('   StackTrace: $stackTrace');
      _showLoginErrorDialog('Errore di connessione durante il login');
    } finally {
      print('=== FINE LOGIN AUTOMATICO ===\n');
    }
  }

  /// Recupera metadati utente dal backend
  Future<void> _fetchUserMeta(String token, String nicename) async {
    try {
      print('🔍 Recupero metadati utente...');
      
      final url = Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/soci/me');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Metadati ricevuti');
        
        // Salva nome e cognome se presenti
        if (data['nome'] != null) {
          await _storage.write(key: 'first_name', value: data['nome']);
        }
        if (data['cognome'] != null) {
          await _storage.write(key: 'last_name', value: data['cognome']);
        }
        if (data['nome'] != null && data['cognome'] != null) {
          final fullName = '${data['nome']} ${data['cognome']}';
          await _storage.write(key: 'full_name', value: fullName);
          print('   ✓ Nome completo salvato: $fullName');
        }
        
        // Salva altri dati se presenti
        if (data['telefono'] != null) {
          await _storage.write(key: 'telefono', value: data['telefono']);
        }
        if (data['is_socio'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_socio', data['is_socio']);
        }
      } else {
        print('⚠️ Metadati non disponibili: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Errore recupero metadati: $e');
    }
  }

  /// Dialog di errore per login automatico fallito
  Future<void> _showLoginErrorDialog(String message) async {
    if (!mounted) return;
    
    print('\n🚨 Mostro dialog errore login:');
    print('   Messaggio: $message');
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Login Automatico Fallito',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrazione completata, ma il login automatico è fallito.',
                style: TextStyle(fontSize: 13),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Puoi effettuare il login manualmente.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dettaglio: $message',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Vai al Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Continua'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> data) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 28),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Registrazione Completata!',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account creato con successo!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ecco le tue credenziali di accesso:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            
            // Username
            if (data['data'] != null && data['data']['username'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF1976D2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['data']['username'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Password
            if (data['data'] != null && data['data']['password'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Color(0xFF1976D2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['data']['password'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Salva queste credenziali!',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Errore'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDuplicatePhoneDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 32),
            SizedBox(width: 12),
            Text('Numero già registrato'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF2196F3), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hai già un account? Prova ad effettuare il login.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Vai al Login'),
          ),
        ],
      ),
    );
  }
}
