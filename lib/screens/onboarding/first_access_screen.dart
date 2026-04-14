import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
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
    '+1', // USA/Canada
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [scheme.surfaceContainerLowest, scheme.surface],
            ),
          ),
          child: Column(
            children: [
              _buildInfoBanner(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scheme.primary,
                                  Color.alphaBlend(
                                    scheme.secondary.withOpacity(0.28),
                                    scheme.primary,
                                  ),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.24),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 46,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          AppLocalizations.of(context)!.welcomeExclamation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          AppLocalizations.of(context)!.enterYourDataToStart,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: scheme.onSurface.withOpacity(0.72),
                          ),
                        ),
                        const SizedBox(height: 32),

                        TextFormField(
                          controller: _nomeController,
                          decoration: _buildFieldDecoration(
                            context,
                            labelText: AppLocalizations.of(context)!.nameRequired,
                            hintText: 'Mario',
                            icon: Icons.person,
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            final l10n = AppLocalizations.of(context)!;
                            if (value == null || value.trim().isEmpty) {
                              return l10n.nameIsMandatory;
                            }
                            if (value.trim().length < 2) {
                              return l10n.nameMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _cognomeController,
                          decoration: _buildFieldDecoration(
                            context,
                            labelText: AppLocalizations.of(context)!.surnameRequired,
                            hintText: 'Rossi',
                            icon: Icons.person_outline,
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            final l10n = AppLocalizations.of(context)!;
                            if (value == null || value.trim().isEmpty) {
                              return l10n.surnameIsMandatory;
                            }
                            if (value.trim().length < 2) {
                              return l10n.surnameMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final useVerticalLayout = constraints.maxWidth < 360;
                            final prefixField = SizedBox(
                              width: useVerticalLayout ? double.infinity : 108,
                              child: DropdownButtonFormField<String>(
                                value: _prefixController.text,
                                isExpanded: true,
                                decoration: _buildFieldDecoration(
                                  context,
                                  labelText: AppLocalizations.of(context)!.prefixRequired,
                                  icon: Icons.public,
                                ),
                                items:
                                    _prefissi.map((String prefix) {
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
                            );

                            final phoneField = TextFormField(
                              controller: _telefonoController,
                              decoration: _buildFieldDecoration(
                                context,
                                labelText: AppLocalizations.of(context)!.phoneRequired,
                                hintText: '3331234567',
                                icon: Icons.phone,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                final l10n = AppLocalizations.of(context)!;
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.phoneIsMandatory;
                                }

                                final cleanPhone = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );

                                if (_prefixController.text == '+39') {
                                  if (cleanPhone.length != 10) {
                                    return l10n.phoneMust10Digits;
                                  }
                                } else {
                                  if (cleanPhone.length < 8) {
                                    return l10n.phoneInvalid;
                                  }
                                }

                                return null;
                              },
                            );

                            if (useVerticalLayout) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  prefixField,
                                  const SizedBox(height: 12),
                                  phoneField,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                prefixField,
                                const SizedBox(width: 12),
                                Expanded(child: phoneField),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _completaPrimoAccesso,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            elevation: 0,
                            shadowColor: scheme.primary.withOpacity(0.24),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    AppLocalizations.of(context)!.continue_,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              scheme.primary.withOpacity(0.08),
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: scheme.primary.withOpacity(0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: scheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.afterRegistrationInfo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: scheme.onSurface.withOpacity(0.8),
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
      ),
    );
  }

  InputDecoration _buildFieldDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      prefixIcon: Icon(icon, color: scheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(Colors.black.withOpacity(0.08)),
      enabledBorder: border(Colors.black.withOpacity(0.08)),
      focusedBorder: border(scheme.primary.withOpacity(0.75), width: 1.4),
      errorBorder: border(Colors.red.withOpacity(0.45)),
      focusedErrorBorder: border(Colors.red.withOpacity(0.7), width: 1.4),
      labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.72)),
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.38)),
    );
  }

  Widget _buildInfoBanner() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.alphaBlend(
              scheme.secondary.withOpacity(0.28),
              scheme.primary,
            ),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.onPrimary.withOpacity(0.25),
              ),
            ),
            child: Icon(Icons.info_outline, color: scheme.onPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.completeDataToAccessServices,
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
      final cleanPhone = _telefonoController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
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
      final url =
          'https://www.wecoop.org/wp-json/wecoop/v1/utenti/primo-accesso';
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
      await MaintenanceHandler.handleHttpStatusCode(response.statusCode);

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
          print(
            '   - token: ${data['data']['token'] != null ? 'PRESENTE (${data['data']['token'].toString().length} chars)' : 'MANCANTE'}',
          );
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
            await prefs.setString(
              'numero_pratica',
              userData['numero_pratica'] ?? '',
            );
            await prefs.setString('username', userData['username'] ?? '');
            await prefs.setString('nome', userData['nome'] ?? '');
            await prefs.setString('cognome', userData['cognome'] ?? '');
            await prefs.setString(
              'telefono_completo',
              userData['telefono_completo'] ?? telefonoCompleto,
            );
            await prefs.setBool('is_socio', userData['is_socio'] ?? false);
            await prefs.setBool(
              'profilo_completo',
              userData['profilo_completo'] ?? false,
            );
            print('   ✓ Salvato in SharedPreferences');

            // Salva credenziali in secure storage
            await _storage.write(
              key: 'user_id',
              value: (userData['user_id'] ?? 0).toString(),
            );
            await _storage.write(
              key: 'username',
              value: userData['username'] ?? '',
            );
            await _storage.write(
              key: 'password',
              value: userData['password'] ?? '',
            );
            await _storage.write(
              key: 'auth_username',
              value: userData['username'] ?? '',
            );
            await _storage.write(
              key: 'auth_password',
              value: userData['password'] ?? '',
            );
            await _storage.write(
              key: 'numero_pratica',
              value: userData['numero_pratica'] ?? '',
            );

            if (userData['username'] != null &&
                userData['username'].toString().isNotEmpty) {
              print('   ✓ Username salvato: ${userData['username']}');
            } else {
              print('   ⚠️ USERNAME MANCANTE O VUOTO!');
            }

            if (userData['password'] != null &&
                userData['password'].toString().isNotEmpty) {
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
            print(
              '   - username presente? ${data['data']?['username'] != null}',
            );
            print('   - username valore: ${data['data']?['username']}');
            print(
              '   - password presente? ${data['data']?['password'] != null}',
            );
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
            _showDuplicatePhoneDialog(
              data['message'] ?? 'Questo numero è già registrato',
            );
          } else {
            _showErrorDialog(
              data['message'] ?? 'Errore durante la registrazione',
            );
          }
        }
      } else {
        print('❌ Status code NON 200: ${response.statusCode}');
        await _handleFirstAccessErrorResponse(response, telefonoCompleto);
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

  Future<void> _handleFirstAccessErrorResponse(
    http.Response response,
    String telefonoCompleto,
  ) async {
    Map<String, dynamic>? data;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      data = null;
    }

    final message = data?['message']?.toString();
    final code = data?['code']?.toString().toLowerCase();
    final normalizedMessage = (message ?? '').toLowerCase();
    final normalizedBody = response.body.toLowerCase();
    final isAlreadyRegistered =
        code == 'duplicate_phone' ||
        code == 'username_exists' ||
        normalizedMessage.contains('gia registrato') ||
        normalizedMessage.contains('già registrato') ||
        normalizedMessage.contains('gia presente') ||
        normalizedMessage.contains('già presente') ||
        normalizedBody.contains('duplicate_phone') ||
        normalizedBody.contains('gia registrato') ||
        normalizedBody.contains('già registrato');

    if (isAlreadyRegistered) {
      final loginPhone = telefonoCompleto.replaceAll(RegExp(r'[^\d]'), '');
      await _storage.write(key: 'last_login_phone', value: loginPhone);

      if (!mounted) return;

      _showDuplicatePhoneDialog(
        message ?? 'Questo numero è già registrato.',
      );
      return;
    }

    if (!mounted) return;

    _showErrorDialog(
      message ?? 'Errore del server (${response.statusCode}). Riprova più tardi.',
    );
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
        body: jsonEncode({'username': username, 'password': password}),
      );
      await MaintenanceHandler.handleHttpStatusCode(response.statusCode);

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
          print(
            '✅ JWT Token ricevuto! (${data['token'].toString().length} chars)',
          );
          print('\n💾 Salvataggio token e dati utente...');

          // Salva token e dati utente
          await _storage.write(key: 'jwt_token', value: data['token']);
          await _storage.write(key: 'auth_username', value: username);
          await _storage.write(key: 'auth_password', value: password);
          await _storage.write(
            key: 'user_email',
            value: data['user_email'] ?? '',
          );
          await _storage.write(
            key: 'user_display_name',
            value: data['user_display_name'] ?? '',
          );
          await _storage.write(
            key: 'user_nicename',
            value: data['user_nicename'] ?? '',
          );
          await _storage.write(key: 'last_login_phone', value: username);

          if (data['user_id'] != null) {
            await _storage.write(
              key: 'user_id',
              value: data['user_id'].toString(),
            );
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
                content: Text(AppLocalizations.of(context)!.welcomeSuccess),
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
          _showLoginErrorDialog(
            data['message'] ??
                'Errore durante il login automatico (${response.statusCode})',
          );
        } catch (e) {
          print('   Impossibile decodificare risposta errore: $e');
          _showLoginErrorDialog(
            'Errore durante il login automatico (${response.statusCode})',
          );
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
      await MaintenanceHandler.handleHttpStatusCode(response.statusCode);

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
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.autoLoginFailed,
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
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.registrationCompletedLoginFailed,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2196F3),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.canLoginManually,
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
                child: Text(AppLocalizations.of(context)!.goToLogin),
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
                child: Text(AppLocalizations.of(context)!.continue_),
              ),
            ],
          ),
    );
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> data) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.registrationCompleted,
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
                  Text(
                    AppLocalizations.of(context)!.accountCreatedSuccess,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.yourLoginCredentials,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  if (data['data'] != null &&
                      data['data']['username'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.username,
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
                  if (data['data'] != null &&
                      data['data']['password'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.password,
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
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.saveTheseCredentials,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.error),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
    );
  }

  void _showDuplicatePhoneDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) {
            final scheme = Theme.of(context).colorScheme;

            return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            scrollable: true,
            actionsOverflowDirection: VerticalDirection.down,
            actionsOverflowButtonSpacing: 8,
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: scheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.phoneAlreadyRegistered,
                  ),
                ),
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
                    color: Color.alphaBlend(
                      scheme.primary.withOpacity(0.08),
                      Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.alreadyHaveAccount,
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
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                ),
                child: Text(AppLocalizations.of(context)!.goToLogin),
              ),
            ],
          );
          },
    );
  }
}
