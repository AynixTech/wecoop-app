import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/screens/onboarding/first_access_screen.dart';
import 'package:wecoop_app/screens/profilo/change_password_screen.dart';
import 'package:wecoop_app/utils/phone_prefixes.dart';
import '../../widgets/language_selector.dart';
import '../../utils/html_utils.dart';
import '../../utils/italian_validators.dart';
import '../../widgets/design_system/design_system.dart';
import '../../config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController prefixController = TextEditingController(
    text: '+39',
  );
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = SecureStorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool rememberPassword = false;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _canUseBiometrics = false;
  bool _hasStoredBiometricCredentials = false;
  bool _biometricLoginEnabled = true;
  bool _forceShowPasswordLogin = false;

  @override
  void initState() {
    super.initState();
    _initializeLoginHelpers();
  }

  Future<void> _initializeLoginHelpers() async {
    await _loadLastPhone();
    await _loadBiometricState();
  }

  /// Carga el último teléfono usado para el login
  Future<void> _loadLastPhone() async {
    final lastPhone = await storage.read(key: 'last_login_phone');
    if (lastPhone != null && lastPhone.isNotEmpty) {
      phoneController.text = lastPhone;
    }
  }

  Future<void> _loadBiometricState() async {
    final supportsBiometrics =
        await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
    final savedUser =
        await storage.read(key: 'biometric_username') ??
        await storage.read(key: 'auth_username');
    final savedPass =
        await storage.read(key: 'biometric_password') ??
        await storage.read(key: 'auth_password');
    final biometricSetting = await storage.read(key: 'biometric_login_enabled');
    final biometricEnabled =
        biometricSetting == null || biometricSetting == 'true';

    if (!mounted) return;
    setState(() {
      _canUseBiometrics = supportsBiometrics;
      _biometricLoginEnabled = biometricEnabled;
      _hasStoredBiometricCredentials =
          (savedUser != null && savedUser.isNotEmpty) &&
          (savedPass != null && savedPass.isNotEmpty);
    });
  }

  Future<void> _login() async {
    // Username = prefisso + numero (solo cifre), allineato al backend.
    // Esempio: +39 + 333 1234567 → 393331234567
    final phone = PhonePrefixes.normalizeForLogin(
      prefix: prefixController.text,
      phone: phoneController.text,
    );
    final password = passwordController.text;

    await _loginWithCredentials(phone: phone, password: password);
  }

  Future<void> _loginWithBiometrics() async {
    final l10n = AppLocalizations.of(context)!;
    AppLogger.d('');
    AppLogger.d('👆 ==================== LOGIN BIOMETRICO ====================');
    AppLogger.d('👆 _biometricLoginEnabled=$_biometricLoginEnabled _canUseBiometrics=$_canUseBiometrics');

    if (!_biometricLoginEnabled) {
      AppLogger.d('👆 Biometria disabilitata nelle impostazioni');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('biometricDisabledInSettings'))),
      );
      return;
    }

    if (!_canUseBiometrics) {
      AppLogger.d('👆 Biometria non disponibile sul dispositivo');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('biometricNotAvailable'))),
      );
      return;
    }

    final savedPhone =
        await storage.read(key: 'biometric_username') ??
        await storage.read(key: 'auth_username');
    final savedPassword =
        await storage.read(key: 'biometric_password') ??
        await storage.read(key: 'auth_password');

    AppLogger.d('👆 savedPhone="$savedPhone" (null=${savedPhone == null})');
    AppLogger.d('👆 savedPassword length=${savedPassword?.length ?? 0} (null=${savedPassword == null})');

    if (savedPhone == null ||
        savedPhone.isEmpty ||
        savedPassword == null ||
        savedPassword.isEmpty) {
      AppLogger.d('👆 Credenziali biometriche mancanti/vuote');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('biometricCredentialsMissing'))),
      );
      return;
    }

    try {
      AppLogger.d('👆 Avvio autenticazione biometrica...');
      final authenticated = await _localAuth.authenticate(
        localizedReason: l10n.translate('biometricAuthReason'),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      AppLogger.d('👆 Biometria autenticata: $authenticated');

      if (!authenticated) return;

      await _loginWithCredentials(phone: savedPhone, password: savedPassword, fromBiometrics: true);
    } catch (e) {
      AppLogger.d('👆 Eccezione biometria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('biometricAuthFailed'))),
      );
    }
  }

  Future<void> _loginWithCredentials({
    required String phone,
    required String password,
    bool fromBiometrics = false,
  }) async {
    AppLogger.d('');
    AppLogger.d('🔐 ==================== LOGIN ====================');
    AppLogger.d('🔐 Tipo: ${fromBiometrics ? "BIOMETRICO" : "MANUALE"}');
    AppLogger.d('🔐 phone (username): "$phone"');
    AppLogger.d('🔐 password length: ${password.length} (vuota=${password.isEmpty})');

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final url = Uri.parse(ApiConfig.loginUrl);
    final l10n = AppLocalizations.of(context)!;

    final requestBody = jsonEncode({'username': phone, 'password': password});
    AppLogger.d('🔐 URL: $url');
    AppLogger.d('🔐 Payload: $requestBody');

    try {
      final response = await HttpClientService.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'WeCoop/1.6.2',
        },
        body: requestBody,
      );

      AppLogger.d('📡 Response status: ${response.statusCode}');
      AppLogger.d('📡 Response body: ${response.body}');

      final decodedData = HttpClientService.decodeJsonResponse(response);
      AppLogger.d('📦 Decoded type: ${decodedData.runtimeType}');
      final data = decodedData is Map<String, dynamic>
          ? decodedData
          : <String, dynamic>{};
      AppLogger.d('📦 token presente: ${data['token'] != null}');
      AppLogger.d('📦 user_email=${data['user_email']} display=${data['user_display_name']} nicename=${data['user_nicename']} user_id=${data['user_id']}');

      if (response.statusCode == 200 && data['token'] != null) {
        AppLogger.d('✅ Login riuscito, salvataggio dati...');
        await storage.write(key: 'jwt_token', value: data['token']);
        AppLogger.d('   ✓ jwt_token');
        // Refresh token opaco: usato per rinnovare il JWT senza ri-inviare la
        // password. Sostituisce il vecchio "re-login" con credenziali salvate.
        if (data['refresh_token'] != null) {
          await storage.write(key: 'refresh_token', value: data['refresh_token']);
          AppLogger.d('   ✓ refresh_token');
        }
        await storage.write(key: 'auth_username', value: phone);
        AppLogger.d('   ✓ auth username');

        // Salva SEMPRE le credenziali biometriche dopo un login riuscito.
        await storage.write(key: 'biometric_username', value: phone);
        await storage.write(key: 'biometric_password', value: password);
        AppLogger.d('   ✓ biometric credentials');
        await storage.write(key: 'user_email', value: data['user_email'] ?? '');
        await storage.write(
          key: 'user_display_name',
          value: data['user_display_name'] ?? '',
        );
        await storage.write(key: 'user_nicename', value: data['user_nicename'] ?? '');
        AppLogger.d('   ✓ user_* fields');

        if (data['user_id'] != null) {
          await storage.write(
            key: 'user_id',
            value: data['user_id'].toString(),
          );
        }
        AppLogger.d('   ✓ user_id');

        await storage.write(key: 'last_login_phone', value: phone);

        if (rememberPassword) {
          await storage.write(key: 'saved_phone', value: phone);
          await storage.write(key: 'saved_password', value: password);
        } else {
          await storage.delete(key: 'saved_phone');
          await storage.delete(key: 'saved_password');
        }
        AppLogger.d('   ✓ preferenze; chiamo _fetchUserMeta...');

        await _fetchUserMeta(data['token'], data['user_nicename'] ?? '');
        AppLogger.d('   ✓ _fetchUserMeta OK');

        await _loadBiometricState();

        try {
          await PushNotificationService().initialize();
        } catch (e) {
          AppLogger.d('⚠️ Push init fallita (non bloccante): $e');
        }

        // Utenti creati dalla piattaforma cloud hanno must_reset_password:
        // forzano il cambio password prima di entrare in home (come il portale).
        final mustResetPassword = data['must_reset_password'] == true;
        AppLogger.d(
          mustResetPassword
              ? '🔐 must_reset_password=true → cambio password obbligatorio'
              : '🎉 Navigazione a /home',
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          if (mustResetPassword) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => const ChangePasswordScreen(mustResetPassword: true),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        AppLogger.d('⚠️ Login NON riuscito (status ${response.statusCode}, token=${data['token'] != null})');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        if (fromBiometrics && response.statusCode == 401) {
          AppLogger.d('🧹 Credenziali biometriche obsolete, le rimuovo');
          await storage.delete(key: 'biometric_username');
          await storage.delete(key: 'biometric_password');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.translate('biometricCredentialsMissing')),
              ),
            );
          }
          return;
        }
        final message = data['message'] ?? l10n.networkError;
        final decodedMessage = decodeHtmlEntities(message);
        AppLogger.d('⚠️ Messaggio mostrato: $decodedMessage');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(decodedMessage)));
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      AppLogger.d('❌❌❌ ECCEZIONE durante il login: $e');
      AppLogger.d('❌ Tipo eccezione: ${e.runtimeType}');
      AppLogger.d('❌ StackTrace:\n$stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.networkError)));
    }
  }

  Future<void> _fetchUserMeta(String token, String nicename) async {
    // Usa il nuovo endpoint /soci/me per ottenere tutti i dati dell'utente
    final url = Uri.parse('${ApiConfig.baseUrl}/soci/me');

    AppLogger.d('🔄 Chiamata a /soci/me...');
    AppLogger.d('URL: $url');
    AppLogger.d('Token: ${token.substring(0, 20)}...');

    try {
      final response = await HttpClientService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
        return;
      }

      AppLogger.d('📥 GET /soci/me status: ${response.statusCode}');
      AppLogger.d('📥 GET /soci/me body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // L'endpoint può restituire {success, data:{...}} oppure i campi in radice.
        final data = (responseData is Map<String, dynamic> &&
                responseData['data'] is Map<String, dynamic>)
            ? responseData['data'] as Map<String, dynamic>
            : (responseData as Map<String, dynamic>);

        AppLogger.d('📦 Dati ricevuti:');
        AppLogger.d('  - id: ${data['id']}');
        AppLogger.d('  - nome: ${data['nome']}');
        AppLogger.d('  - cognome: ${data['cognome']}');
        AppLogger.d('  - telefono: ${data['telefono']}');
        AppLogger.d('  - citta: ${data['citta']}');
        AppLogger.d('  - numero_tessera: ${data['numero_tessera']}');

        // Salva tutti i dati dell'utente socio
        // Salva sia socio_id (ID tabella soci) che user_id (ID WordPress)
        if (data['id'] != null) {
          await storage.write(key: 'socio_id', value: data['id'].toString());
          // 'id' in /soci/me è il WordPress user ID (wp_get_current_user()->ID)
          await storage.write(key: 'user_id', value: data['id'].toString());
        }
        if (data['socio_id'] != null) {
          await storage.write(key: 'socio_id', value: data['socio_id'].toString());
        }
        if (data['user_id'] != null) {
          await storage.write(
            key: 'user_id',
            value: data['user_id'].toString(),
          );
        }
        if (data['nome'] != null) {
          await storage.write(key: 'first_name', value: data['nome']);
        }
        if (data['cognome'] != null) {
          await storage.write(key: 'last_name', value: data['cognome']);
        }
        if (data['codice_fiscale'] != null) {
          await storage.write(
            key: 'codice_fiscale',
            value: data['codice_fiscale'],
          );
        }
        if (data['data_nascita'] != null) {
          final normalized = ItalianValidators.normalizeIsoDate(
                data['data_nascita'].toString(),
              ) ??
              data['data_nascita'].toString();
          await storage.write(key: 'data_nascita', value: normalized);
        }
        if (data['luogo_nascita'] != null) {
          await storage.write(
            key: 'luogo_nascita',
            value: data['luogo_nascita'],
          );
        }
        if (data['indirizzo'] != null) {
          await storage.write(key: 'indirizzo', value: data['indirizzo']);
        }
        if (data['citta'] != null) {
          await storage.write(key: 'citta', value: data['citta']);
        }
        if (data['cap'] != null) {
          await storage.write(key: 'cap', value: data['cap']);
        }
        if (data['provincia'] != null) {
          await storage.write(key: 'provincia', value: data['provincia']);
        }
        if (data['telefono'] != null) {
          await storage.write(key: 'telefono', value: data['telefono']);
        }
        if (data['professione'] != null) {
          await storage.write(key: 'professione', value: data['professione']);
        }
        if (data['paese_origine'] != null) {
          await storage.write(
            key: 'paese_origine',
            value: data['paese_origine'],
          );
        }
        if (data['nazionalita'] != null) {
          await storage.write(key: 'nazionalita', value: data['nazionalita']);
        }
        if (data['status_socio'] != null ||
            data['status'] != null ||
            data['stato'] != null) {
          await storage.write(
            key: 'stato_socio',
            value: (data['status_socio'] ?? data['status'] ?? data['stato'])
                .toString(),
          );
        }
        if (data['data_adesione'] != null || data['created_at'] != null) {
          await storage.write(
            key: 'data_iscrizione',
            value: (data['data_adesione'] ?? data['created_at']).toString(),
          );
        }
        if (data['numero_tessera'] != null) {
          await storage.write(
            key: 'tessera_numero',
            value: data['numero_tessera'],
          );
        }
        if (data['tessera_url'] != null) {
          await storage.write(key: 'tessera_url', value: data['tessera_url']);
        }
        if (data['quota_pagata'] != null) {
          await storage.write(
            key: 'quota_pagata',
            value: data['quota_pagata'].toString(),
          );
        }
        if (data['anni_socio'] != null) {
          await storage.write(
            key: 'anni_socio',
            value: data['anni_socio'].toString(),
          );
        }

        // Crea nome completo
        final nome = data['nome'] ?? '';
        final cognome = data['cognome'] ?? '';
        if (nome.isNotEmpty || cognome.isNotEmpty) {
          final fullName = '$nome $cognome'.trim();
          await storage.write(key: 'full_name', value: fullName);
          AppLogger.d('✅ Nome completo salvato: $fullName');
        }

        AppLogger.d('✅ Dati socio salvati con successo');
        AppLogger.d('Tessera: ${data['numero_tessera']}');
        AppLogger.d('Anni socio: ${data['anni_socio']}');
        AppLogger.d('Quota pagata: ${data['quota_pagata']}');
        AppLogger.d('Paese origine: ${data['paese_origine']}');
        AppLogger.d('Nazionalità: ${data['nazionalita']}');
      } else if (response.statusCode == 404) {
        AppLogger.d('⚠️ Utente non trovato come socio nel database');
        AppLogger.d('⚠️ Response: ${response.body}');
      } else {
        AppLogger.d('⚠️ Errore nel recupero dei dati socio: ${response.statusCode}');
        AppLogger.d('⚠️ Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      AppLogger.d('❌ Eccezione durante il recupero dei dati socio: $e');
      AppLogger.d('Stack trace: $stackTrace');
    }
  }

  void _goToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirstAccessScreen()),
    );
  }

  Widget _buildRegistrationCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Non sei ancora registrato?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _goToRegistration,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Registrati'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final biometricsReady =
        _biometricLoginEnabled &&
        _canUseBiometrics &&
        _hasStoredBiometricCredentials;
    final showPasswordForm = !biometricsReady || _forceShowPasswordLogin;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        actions: const [LanguageSelector()],
      ),
      body:
          showPasswordForm
              ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset('assets/images/wecoop_logo.png', height: 120),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: prefixController.text,
                          isExpanded: true,
                          items:
                              PhonePrefixes.prefixes.map((prefix) {
                                return DropdownMenuItem<String>(
                                  value: prefix,
                                  child: Text(prefix),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              prefixController.text = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: l10n.translate('prefix'),
                            hintText: '+39',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                PhonePrefixes.flagFor(prefixController.text),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.translate('phoneNumber'),
                            hintText: '3891234567',
                            helperStyle: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberPassword,
                          onChanged: (value) {
                            setState(() {
                              rememberPassword = value ?? false;
                            });
                          },
                        ),
                        Text(l10n.rememberPassword),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: isLoading ? l10n.sending : l10n.login,
                      loading: isLoading,
                      onPressed: isLoading ? null : _login,
                    ),
                    if (biometricsReady) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  setState(() {
                                    _forceShowPasswordLogin = false;
                                  });
                                },
                        child: Text(l10n.translate('useBiometricsInstead')),
                      ),
                    ],
                    const SizedBox(height: 16),

                    _buildRegistrationCta(),

                    const SizedBox(height: 16),

                    // Password Dimenticata
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text(
                        l10n.translate('forgotPassword'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.home),
                      label: Text(
                        l10n.translate('continueWithoutLogin'),
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/wecoop_logo.png',
                          height: 120,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _loginWithBiometrics,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(l10n.translate('loginWithBiometrics')),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                    setState(() {
                                      _forceShowPasswordLogin = true;
                                    });
                                  },
                          child: Text(l10n.translate('usePasswordInstead')),
                        ),
                        const SizedBox(height: 16),

                        _buildRegistrationCta(),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            l10n.translate('forgotPassword'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          icon: const Icon(Icons.home),
                          label: Text(
                            l10n.translate('continueWithoutLogin'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
