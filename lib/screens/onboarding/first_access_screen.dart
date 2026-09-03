import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/screens/main_screen.dart';
import 'package:wecoop_app/utils/phone_prefixes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

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

  String _flagForPrefix(String prefix) {
    return PhonePrefixes.flagFor(prefix);
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
                            labelText:
                                AppLocalizations.of(context)!.nameRequired,
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
                            labelText:
                                AppLocalizations.of(context)!.surnameRequired,
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

                        DropdownButtonFormField<String>(
                          initialValue: _prefixController.text,
                          isExpanded: true,
                          decoration: _buildFieldDecoration(
                            context,
                            labelText:
                                AppLocalizations.of(context)!.prefixRequired,
                            icon: Icons.phone,
                          ).copyWith(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                _flagForPrefix(_prefixController.text),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          items:
                              PhonePrefixes.prefixes.map((String prefix) {
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefonoController,
                          decoration: _buildFieldDecoration(
                            context,
                            labelText:
                                AppLocalizations.of(context)!.phoneRequired,
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

                        const SizedBox(height: 12),

                        // Utenti creati dalla piattaforma cloud hanno già
                        // username/password: devono poter andare al login.
                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/login');
                                  },
                          child: Text(
                            AppLocalizations.of(context)!.alreadyHaveAccount,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
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
                                  AppLocalizations.of(
                                    context,
                                  )!.afterRegistrationInfo,
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
      errorBorder: border(AppColors.error.withOpacity(0.45)),
      focusedErrorBorder: border(AppColors.error.withOpacity(0.7), width: 1.4),
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
              border: Border.all(color: scheme.onPrimary.withOpacity(0.25)),
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
    AppLogger.d('\n🚀 === INIZIO PRIMO ACCESSO ===');

    if (!_formKey.currentState!.validate()) {
      AppLogger.d('❌ Form non validato');
      return;
    }

    AppLogger.d('✅ Form validato correttamente');

    setState(() => _isLoading = true);

    try {
      // Pulisci il telefono (solo numeri), allineato al backend normalizePhone.
      final cleanPhone = PhonePrefixes.normalizeForLogin(
        prefix: _prefixController.text,
        phone: _telefonoController.text,
      );
      // Prefisso solo cifre per il body; telefono locale senza prefisso.
      final prefix = _prefixController.text.replaceAll('+', '');
      final telefonoLocale = cleanPhone.startsWith(prefix)
          ? cleanPhone.substring(prefix.length)
          : _telefonoController.text.replaceAll(RegExp(r'[^\d]'), '');
      final telefonoCompleto = '+$cleanPhone';

      AppLogger.d('📝 Dati raccolti:');
      AppLogger.d('   - Nome: ${_nomeController.text.trim()}');
      AppLogger.d('   - Cognome: ${_cognomeController.text.trim()}');
      AppLogger.d('   - Prefisso: ${_prefixController.text}');
      AppLogger.d('   - Telefono pulito: $telefonoLocale');
      AppLogger.d('   - Telefono completo: $telefonoCompleto');
      AppLogger.d('\n🔄 Invio richiesta HTTP a backend...');

      // Chiamata al backend Node
      final url = '${ApiConfig.baseUrl}/auth/primo-accesso';
      final requestBody = {
        'nome': _nomeController.text.trim(),
        'cognome': _cognomeController.text.trim(),
        'prefix': _prefixController.text,
        'telefono': telefonoLocale,
      };

      AppLogger.d('🌐 URL: $url');
      AppLogger.d('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
        return;
      }

      AppLogger.d('\n📥 RISPOSTA RICEVUTA:');
      AppLogger.d('   - Status Code: ${response.statusCode}');
      AppLogger.d('   - Headers: ${response.headers}');
      AppLogger.d('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        AppLogger.d('✅ Status 200 OK');
        AppLogger.d('🔍 Parsing JSON...');
        final data = jsonDecode(response.body);
        AppLogger.d('📦 JSON decodificato completo:');
        AppLogger.d(jsonEncode(data)); // Stampa tutto il JSON formattato

        AppLogger.d('\n🔎 VERIFICA STRUTTURA RESPONSE:');
        AppLogger.d('   - success presente? ${data.containsKey('success')}');
        AppLogger.d('   - success valore: ${data['success']}');
        AppLogger.d('   - data presente? ${data.containsKey('data')}');

        if (data['data'] != null) {
          AppLogger.d('\n📋 CONTENUTO data:');
          AppLogger.d('   - id: ${data['data']['id']}');
          AppLogger.d('   - user_id: ${data['data']['user_id']}');
          AppLogger.d('   - username: ${data['data']['username']}');
          AppLogger.d('   - password: ${data['data']['password']}');
          AppLogger.d(
            '   - token: ${data['data']['token'] != null ? 'PRESENTE (${data['data']['token'].toString().length} chars)' : 'MANCANTE'}',
          );
          AppLogger.d('   - numero_pratica: ${data['data']['numero_pratica']}');
          AppLogger.d('   - nome: ${data['data']['nome']}');
          AppLogger.d('   - cognome: ${data['data']['cognome']}');
          AppLogger.d('   - telefono_completo: ${data['data']['telefono_completo']}');
          AppLogger.d('   - is_socio: ${data['data']['is_socio']}');
          AppLogger.d('   - profilo_completo: ${data['data']['profilo_completo']}');
        } else {
          AppLogger.d('⚠️ data è NULL!');
        }

        if (data['success'] == true) {
          AppLogger.d('✅ success = true');

          // Salva dati localmente
          AppLogger.d('💾 Salvataggio in SharedPreferences...');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('primo_accesso_completato', true);
          AppLogger.d('   ✓ primo_accesso_completato = true');

          if (data['data'] != null) {
            final userData = data['data'];
            AppLogger.d('👤 Dati utente ricevuti:');
            AppLogger.d('   - ID Richiesta: ${userData['id']}');
            AppLogger.d('   - User ID WordPress: ${userData['user_id']}');
            AppLogger.d('   - Numero Pratica: ${userData['numero_pratica']}');
            AppLogger.d('   - Username: ${userData['username']}');
            AppLogger.d('   - Password: ${userData['password']}');
            AppLogger.d('   - Nome: ${userData['nome']}');
            AppLogger.d('   - Cognome: ${userData['cognome']}');
            AppLogger.d('   - Telefono: ${userData['telefono_completo']}');
            AppLogger.d('   - Is Socio: ${userData['is_socio']}');
            AppLogger.d('   - Profilo Completo: ${userData['profilo_completo']}');

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
            AppLogger.d('   ✓ Salvato in SharedPreferences');

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
              AppLogger.d('   ✓ Username salvato: ${userData['username']}');
            } else {
              AppLogger.d('   ⚠️ USERNAME MANCANTE O VUOTO!');
            }

            if (userData['password'] != null &&
                userData['password'].toString().isNotEmpty) {
              AppLogger.d('   ✓ Password salvata in secure storage');
            } else {
              AppLogger.d('   ⚠️ PASSWORD MANCANTE O VUOTA!');
            }

            // Salva JWT token se presente
            if (userData['token'] != null) {
              await _storage.write(key: 'jwt_token', value: userData['token']);
              AppLogger.d('   ✓ JWT Token salvato');
            }

            AppLogger.d('   ✓ Salvato in SecureStorage');
          }

          if (mounted) {
            AppLogger.d('\n🎉 Registrazione completata con successo!');

            // Mostra SEMPRE il dialog con le credenziali
            AppLogger.d('📱 Mostra dialog con credenziali...');
            await _showSuccessDialog(data);

            // Dopo che l'utente chiude il dialog, fa login automatico
            AppLogger.d('\n🔍 CHECK CREDENZIALI PER LOGIN AUTOMATICO:');
            AppLogger.d('   - data presente? ${data['data'] != null}');
            AppLogger.d(
              '   - username presente? ${data['data']?['username'] != null}',
            );
            AppLogger.d('   - username valore: ${data['data']?['username']}');
            AppLogger.d(
              '   - password presente? ${data['data']?['password'] != null}',
            );
            AppLogger.d('   - password valore: ${data['data']?['password']}');

            if (data['data'] != null &&
                data['data']['username'] != null &&
                data['data']['password'] != null &&
                data['data']['username'].toString().isNotEmpty &&
                data['data']['password'].toString().isNotEmpty) {
              AppLogger.d('✅ Credenziali valide - Avvio login automatico...');
              await _autoLogin(
                data['data']['username'],
                data['data']['password'],
              );
            } else {
              AppLogger.d('⚠️ CREDENZIALI MANCANTI O INVALIDE:');
              if (data['data'] == null) {
                AppLogger.d('   - data è NULL');
              }
              final username = data['data']?['username'];
              final password = data['data']?['password'];

              if (username == null || username.toString().isEmpty) {
                AppLogger.d('   - username è NULL o vuoto');
              }
              if (password == null || password.toString().isEmpty) {
                AppLogger.d('   - password è NULL o vuota');
              }
              // Fallback: vai a MainScreen senza login
              AppLogger.d('🧭 Navigazione a MainScreen (senza login)...');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
              AppLogger.d('✅ Navigazione completata\n');
            }
          }
        } else {
          AppLogger.d('⚠️ success = false');
          AppLogger.d('   Messaggio: ${data['message']}');
          AppLogger.d('   Codice errore: ${data['code']}');

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
        AppLogger.d('❌ Status code NON 200: ${response.statusCode}');
        await _handleFirstAccessErrorResponse(response, telefonoCompleto);
      }
    } catch (e, stackTrace) {
      AppLogger.d('\n❌ ECCEZIONE CATTURATA:');
      AppLogger.d('   Errore: $e');
      AppLogger.d('   StackTrace: $stackTrace');
      _showErrorDialog('Errore di connessione: $e');
    } finally {
      AppLogger.d('\n🏁 Termino caricamento...');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      AppLogger.d('=== FINE PRIMO ACCESSO ===\n');
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

      _showDuplicatePhoneDialog(message ?? 'Questo numero è già registrato.');
      return;
    }

    if (!mounted) return;

    _showErrorDialog(
      message ??
          'Errore del server (${response.statusCode}). Riprova più tardi.',
    );
  }

  /// Login automatico dopo registrazione
  Future<void> _autoLogin(String username, String password) async {
    AppLogger.d('\n🔑 === INIZIO LOGIN AUTOMATICO ===');
    AppLogger.d('   Username ricevuto: $username');
    AppLogger.d('   Password ricevuta: $password');
    AppLogger.d('   Username vuoto? ${username.isEmpty}');
    AppLogger.d('   Password vuota? ${password.isEmpty}');

    if (username.isEmpty || password.isEmpty) {
      AppLogger.d('❌ ERRORE: Username o password vuoti!');
      _showLoginErrorDialog('Credenziali mancanti (username o password vuoti)');
      return;
    }

    final url = Uri.parse(ApiConfig.loginUrl);

    try {
      AppLogger.d('🌐 Chiamata a: $url');
      AppLogger.d('📤 Body request:');
      AppLogger.d('   {"username": "$username", "password": "$password"}');
      final response = await HttpClientService.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
        return;
      }

      AppLogger.d('\n📥 RISPOSTA LOGIN:');
      AppLogger.d('   Status: ${response.statusCode}');
      AppLogger.d('   Headers: ${response.headers}');
      AppLogger.d('   Body completo: ${response.body}');

      if (response.statusCode == 200) {
        AppLogger.d('✅ Status 200 - Parsing JSON...');
        final data = jsonDecode(response.body);
        AppLogger.d('📦 JSON decodificato:');
        AppLogger.d(jsonEncode(data));

        AppLogger.d('\n🔍 Verifica campi response:');
        AppLogger.d('   - token presente? ${data['token'] != null}');
        AppLogger.d('   - user_email: ${data['user_email']}');
        AppLogger.d('   - user_display_name: ${data['user_display_name']}');
        AppLogger.d('   - user_nicename: ${data['user_nicename']}');
        AppLogger.d('   - user_id: ${data['user_id']}');

        if (data['token'] != null) {
          AppLogger.d(
            '✅ JWT Token ricevuto! (${data['token'].toString().length} chars)',
          );
          AppLogger.d('\n💾 Salvataggio token e dati utente...');

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
            AppLogger.d('   ✓ User ID salvato: ${data['user_id']}');
          }

          AppLogger.d('   ✓ Token JWT salvato');
          AppLogger.d('   ✓ Dati utente salvati');

          // Recupera metadati utente
          if (data['user_nicename'] != null) {
            await _fetchUserMeta(data['token'], data['user_nicename']);
          }

          // Inizializza push notifications
          try {
            await PushNotificationService().initialize();
            AppLogger.d('   ✓ Push notifications inizializzate');
          } catch (e) {
            AppLogger.d('   ⚠️ Errore push notifications: $e');
          }

          if (mounted) {
            AppLogger.d('\n🎉 Login automatico completato!');
            AppLogger.d('🧭 Navigazione a MainScreen...');

            // Naviga alla schermata principale
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );

            // Mostra messaggio di benvenuto
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.welcomeSuccess),
                backgroundColor: AppColors.secondary,
                duration: const Duration(seconds: 3),
              ),
            );

            AppLogger.d('✅ Navigazione completata');
          }
        } else {
          AppLogger.d('\n❌ TOKEN MANCANTE NELLA RISPOSTA!');
          AppLogger.d('   Response completa: ${response.body}');
          _showLoginErrorDialog('Token non ricevuto dal server');
        }
      } else {
        AppLogger.d('\n❌ LOGIN FALLITO!');
        AppLogger.d('   Status: ${response.statusCode}');
        AppLogger.d('   Body: ${response.body}');

        try {
          final data = jsonDecode(response.body);
          AppLogger.d('   Messaggio errore: ${data['message']}');
          AppLogger.d('   Codice errore: ${data['code']}');
          _showLoginErrorDialog(
            data['message'] ??
                'Errore durante il login automatico (${response.statusCode})',
          );
        } catch (e) {
          AppLogger.d('   Impossibile decodificare risposta errore: $e');
          _showLoginErrorDialog(
            'Errore durante il login automatico (${response.statusCode})',
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.d('\n❌ ERRORE LOGIN AUTOMATICO:');
      AppLogger.d('   Errore: $e');
      AppLogger.d('   StackTrace: $stackTrace');
      _showLoginErrorDialog('Errore di connessione durante il login');
    } finally {
      AppLogger.d('=== FINE LOGIN AUTOMATICO ===\n');
    }
  }

  /// Recupera metadati utente dal backend
  Future<void> _fetchUserMeta(String token, String nicename) async {
    try {
      AppLogger.d('🔍 Recupero metadati utente...');

      final url = Uri.parse('${ApiConfig.baseUrl}/soci/me');
      final response = await HttpClientService.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d('✅ Metadati ricevuti');

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
          AppLogger.d('   ✓ Nome completo salvato: $fullName');
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
        AppLogger.d('⚠️ Metadati non disponibili: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.d('⚠️ Errore recupero metadati: $e');
    }
  }

  /// Dialog di errore per login automatico fallito
  Future<void> _showLoginErrorDialog(String message) async {
    if (!mounted) return;

    AppLogger.d('\n🚨 Mostro dialog errore login:');
    AppLogger.d('   Messaggio: $message');

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
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
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
                  backgroundColor: AppColors.info,
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
                  color: AppColors.info,
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
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: AppColors.info,
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
                                    color: AppColors.info,
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
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: AppColors.info,
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
                                    color: AppColors.info,
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
                  backgroundColor: AppColors.info,
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
                const Icon(Icons.error_outline, color: AppColors.error, size: 32),
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
      builder: (context) {
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
              Icon(Icons.info_outline, color: scheme.primary, size: 32),
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
              style: ElevatedButton.styleFrom(backgroundColor: scheme.primary),
              child: Text(AppLocalizations.of(context)!.goToLogin),
            ),
          ],
        );
      },
    );
  }
}
