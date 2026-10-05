import 'dart:io';
import 'package:wecoop_app/utils/app_logger.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/config/api_config.dart';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/account_service.dart';
import '../../services/auth_helper.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import '../../services/locale_provider.dart';
import '../../services/app_localizations.dart';
import '../../utils/app_navigation.dart';
import '../../services/eventi_service.dart';
import '../../services/socio_service.dart';
import '../../services/user_avatar_store.dart';
import '../../services/push_notification_service.dart';
import '../../models/evento_model.dart';
import '../eventi/evento_detail_screen.dart';
import 'completa_profilo_screen.dart';
import 'documenti_screen.dart';
import 'mie_richieste_screen.dart';
import 'storico_pratiche_screen.dart';

final storage = SecureStorageService();

enum _AvatarCropShape { square, circle }

class ProfiloScreen extends StatefulWidget {
  const ProfiloScreen({super.key});

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  String _appVersion = '';

  String userName = '...';
  String userEmail = '...';
  String? avatarUrl;
  bool profiloCompleto = true; // Assume completo finché non verifichiamo

  String selectedLanguageCode = 'it';
  String selectedInterest = 'culture';
  bool _biometricLoginEnabled = true;

  List<Evento> _mieiEventi = [];
  bool _isLoadingEventi = false;
  bool _isUploadingAvatar = false;
  bool _isLoadingProfile = true;
  bool _isLoggingOut = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    UserAvatarStore.hydrate();
    _loadUserData();
    _loadMieiEventi();
    _checkProfiloCompleto();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (e) {
      AppLogger.d('Errore lettura versione app: $e');
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://www.wecoop.org/privacy-policy/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchGdprApp() async {
    final url = Uri.parse('https://www.wecoop.org/gdpr-app/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteAccountFlow() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.translate('deleteAccountTitle')),
            content: Text(l10n.translate('deleteAccountConfirmMsg')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: scheme.error),
                child: Text(l10n.translate('deleteAccountAction')),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    bool success;
    try {
      success = await AccountService.deleteCurrentUser();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('deleteAccountError')),
          backgroundColor: scheme.error,
        ),
      );
      return;
    }
    if (!mounted) return;
    if (success) {
      // logout e mutex
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(l10n.translate('accountDeletedTitle')),
              content: Text(l10n.translate('accountDeletedMessage')),
            ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _logout(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('deleteAccountError')),
          backgroundColor: scheme.error,
        ),
      );
    }
  }

  Future<void> _checkProfiloCompleto() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) return;

    try {
      final userData = await SocioService.getMeData();
      if (userData != null && userData['success'] == true) {
        final isCompleto = userData['data']['profilo_completo'] ?? true;
        if (mounted) {
          setState(() {
            profiloCompleto = isCompleto;
          });
        }
        // Salva in storage
        await storage.write(
          key: 'profilo_completo',
          value: isCompleto.toString(),
        );
      }
    } catch (e) {
      AppLogger.d('Errore verifica profilo: $e');
    }
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
      });
    }

    final name = await storage.read(key: 'full_name');
    final displayName = await storage.read(key: 'user_display_name');
    final email = await storage.read(key: 'user_email');
    final storedAvatar = await storage.read(key: 'avatar_url');
    final langCode = await storage.read(key: 'language_code');
    final interest = await storage.read(key: 'selected_interest');
    final biometricSetting = await storage.read(key: 'biometric_login_enabled');

    final token = await storage.read(key: 'jwt_token');
    final loggedIn = token != null && token.isNotEmpty;

    if (mounted) {
      setState(() {
        userName = name ?? displayName ?? '';
        userEmail = email ?? '';
        avatarUrl = storedAvatar;
        selectedLanguageCode = langCode ?? 'it';
        selectedInterest = interest ?? 'culture';
        _biometricLoginEnabled =
            biometricSetting == null || biometricSetting == 'true';
        _isLoggedIn = loggedIn;
      });
    }

    if (loggedIn) {
      try {
        final userData = await SocioService.getMeData();
        if (userData != null && userData['success'] == true) {
          final data = (userData['data'] as Map?)?.cast<String, dynamic>() ?? {};
          final nome = (data['nome'] ?? '').toString().trim();
          final cognome = (data['cognome'] ?? '').toString().trim();
          final fullName = '$nome $cognome'.trim();
          final freshAvatar = (data['avatar_url'] ?? '').toString().trim();
          final freshEmail = (data['email'] ?? '').toString().trim();

          await UserAvatarStore.setAvatarUrl(freshAvatar);

          if (mounted) {
            setState(() {
              userName =
                  fullName.isNotEmpty
                      ? fullName
                      : (data['display_name'] ?? userName).toString();
              userEmail = freshEmail.isNotEmpty ? freshEmail : userEmail;
              avatarUrl = freshAvatar.isNotEmpty ? freshAvatar : avatarUrl;
            });
          }
        }
      } catch (e) {
        AppLogger.d('Errore refresh dati profilo: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (picked == null || !mounted) return;

    final cropShape = await _selectCropShape();
    if (cropShape == null || !mounted) return;

    final croppedFile = await _cropAvatarImage(
      sourcePath: picked.path,
      cropShape: cropShape,
    );

    if (croppedFile == null || !mounted) return;

    setState(() {
      _isUploadingAvatar = true;
    });

    Map<String, dynamic> result;
    try {
      result = await SocioService.uploadAvatar(file: croppedFile);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('avatarUpdateError')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isUploadingAvatar = false;
    });

    if (result['success'] == true) {
      final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final freshAvatar = (data['avatar_url'] ?? '').toString().trim();
      if (freshAvatar.isNotEmpty) {
        await UserAvatarStore.setAvatarUrl(freshAvatar);
        if (!mounted) return;
        setState(() {
          avatarUrl = freshAvatar;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('avatarUpdatedSuccess'))),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (result['message'] ?? l10n.translate('avatarUpdateError')).toString(),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<_AvatarCropShape?> _selectCropShape() async {
    final l10n = AppLocalizations.of(context)!;

    return showModalBottomSheet<_AvatarCropShape>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.crop_square_rounded),
                title: Text(l10n.translate('avatarCropSquareTitle')),
                subtitle: Text(l10n.translate('avatarCropSquareSubtitle')),
                onTap: () => Navigator.pop(context, _AvatarCropShape.square),
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined),
                title: Text(l10n.translate('avatarCropCircleTitle')),
                subtitle: Text(l10n.translate('avatarCropCircleSubtitle')),
                onTap: () => Navigator.pop(context, _AvatarCropShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _cropAvatarImage({
    required String sourcePath,
    required _AvatarCropShape cropShape,
  }) async {
    final sourceFile = File(sourcePath);
    final sourceBytes = await sourceFile.readAsBytes();

    if (!mounted) return null;

    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => _AvatarCropScreen(
              imageBytes: sourceBytes,
              cropShape: cropShape,
            ),
      ),
    );

    if (croppedBytes == null || croppedBytes.isEmpty) {
      return null;
    }

    final decodedImage = img.decodeImage(croppedBytes);
    final normalizedBytes =
        decodedImage == null
            ? croppedBytes
            : Uint8List.fromList(img.encodePng(decodedImage));

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/wecoop_avatar_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(normalizedBytes, flush: true);
    return file;
  }

  Future<void> _showAvatarOptions() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.translate('chooseFromGallery')),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.translate('takePhoto')),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              if ((avatarUrl ?? '').trim().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: Text(l10n.translate('viewAvatar')),
                  onTap: () {
                    Navigator.pop(context);
                    _openImagePreview(avatarUrl!);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openImagePreview(String imageUrl) async {
    if (imageUrl.trim().isEmpty || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProfileImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _toggleBiometricLogin(bool value) async {
    await storage.write(
      key: 'biometric_login_enabled',
      value: value.toString(),
    );

    if (!value) {
      await storage.delete(key: 'biometric_username');
      await storage.delete(key: 'biometric_password');
    }

    if (!mounted) return;
    setState(() {
      _biometricLoginEnabled = value;
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('biometricSettingUpdated')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadMieiEventi() async {
    if (!mounted) return;

    // Verifica se l'utente è loggato
    final token = await storage.read(key: 'jwt_token');
    if (!mounted) return;
    if (token == null) {
      AppLogger.d('⚠️ Utente non loggato, impossibile caricare eventi');
      // Utente non loggato, non caricare eventi
      setState(() {
        _mieiEventi = [];
        _isLoadingEventi = false;
      });
      return;
    }

    setState(() {
      _isLoadingEventi = true;
    });

    try {
      AppLogger.d('🔄 Caricamento miei eventi...');
      final response = await EventiService.getMieiEventi();

      AppLogger.d('📥 Risposta getMieiEventi RAW: $response');
      AppLogger.d('📥 success=${response['success']}');
      AppLogger.d('📥 totale=${response['totale']}');

      if (response['success'] == true) {
        final eventiList = (response['eventi'] as List?)?.cast<Evento>() ?? [];
        AppLogger.d('✅ ${eventiList.length} miei eventi caricati');

        // Log dettagliato per ogni evento
        for (var i = 0; i < eventiList.length; i++) {
          final evento = eventiList[i];
          AppLogger.d('📌 Mio Evento #$i: ${evento.titolo}');
          AppLogger.d('   - ID: ${evento.id}');
          AppLogger.d('   - Data: ${evento.dataInizio} ${evento.oraInizio ?? ""}');
          AppLogger.d('   - Categoria: ${evento.categoria ?? "nessuna"}');
          AppLogger.d(
            '   - Immagine copertina: ${evento.immagineCopertina ?? "NESSUNA"}',
          );
          AppLogger.d(
            '   - Luogo: ${evento.luogo ?? evento.citta ?? "non specificato"}',
          );
          AppLogger.d('   - Online: ${evento.online}');
          AppLogger.d('   - Sono iscritto: ${evento.sonoIscritto}');
        }

        if (mounted) {
          setState(() {
            _mieiEventi = eventiList;
            _isLoadingEventi = false;
          });
        }
      } else {
        AppLogger.d('❌ Errore: ${response['message']}');
        if (mounted) {
          setState(() {
            _isLoadingEventi = false;
          });
        }
      }
    } catch (e) {
      AppLogger.d('❌ Errore getMieiEventi: $e');
      if (mounted) {
        setState(() {
          _isLoadingEventi = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final l10n = AppLocalizations.of(context)!;
    final logoutMessage = l10n.logoutConfirm;

    try {
      HttpClientService.suppressSessionExpired = true;
      // Salva el teléfono antes de hacer logout para poder recargarlo
      final currentPhone = await storage.read(key: 'telefono');
    if (currentPhone != null) {
      await storage.write(key: 'last_login_phone', value: currentPhone);
    }

    // Rimuovi FCM token dal backend prima di cancellare i dati locali
    try {
      await PushNotificationService().removeToken();
      AppLogger.d('✅ FCM token rimosso dal backend');
    } catch (e) {
      AppLogger.d('⚠️ Errore rimozione FCM token: $e');
      // Continua comunque con il logout
    }

    // Revoca il refresh token lato server (best-effort).
    try {
      final rt = await storage.read(key: 'refresh_token');
      if (rt != null && rt.isNotEmpty) {
        await HttpClientService.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
          body: jsonEncode({'refresh_token': rt}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      AppLogger.d('⚠️ Errore revoca refresh token: $e');
    }

    // Cancella token, biometriche e PII (mantiene last_login_phone)
    await AuthHelper.clearSessionForLogout(keepLastLoginPhone: true);
    await UserAvatarStore.clear();

    AppLogger.d('Utente disconnesso');

    final rootContext = PushNotificationService.navigatorKey?.currentContext;
    if (rootContext != null) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text(logoutMessage)),
      );
    }

    AppNavigation.navigateToLogin();
    } finally {
      HttpClientService.suppressSessionExpired = false;
      _isLoggingOut = false;
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(Locale(languageCode));
    if (mounted) {
      setState(() {
        selectedLanguageCode = languageCode;
      });
    }
  }

  // Metodo per salvare l'interesse dell'utente (da usare in futuro)
  // ignore: unused_element
  Future<void> _saveInterest(String interest) async {
    await storage.write(key: 'selected_interest', value: interest);
    if (mounted) {
      setState(() {
        selectedInterest = interest;
      });
    }
  }

  String get _appVersionDisplay {
    if (_appVersion.isEmpty) return '...';
    final parts = _appVersion.split('+');
    if (parts.length == 2) {
      return '${parts[0]} (${parts[1]})';
    }
    return _appVersion;
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2430),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSectionCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, const Color(0xFF1496C1)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Image.asset('assets/icons/app_icon.png', height: 72),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('guestProfileTitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('guestProfileSubtitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => Navigator.pushReplacementNamed(context, '/login'),
                      icon: const Icon(Icons.login),
                      label: Text(l10n.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.onPrimary,
                        foregroundColor: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('language'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLanguageCode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'it', child: Text('Italiano')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                    ],
                    onChanged: (value) {
                      if (value != null) _changeLanguage(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('profileAppInfoTitle'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.translate('profileAppVersion')}: $_appVersionDisplay',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: _launchGdprApp,
              icon: const Icon(Icons.gavel_outlined),
              label: Text(l10n.translate('gdprLinkLabel')),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _launchPrivacyPolicy,
              icon: const Icon(Icons.privacy_tip_outlined),
              label: Text(l10n.translate('privacyPolicy')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final displayUserName =
        userName.trim().isEmpty || userName.trim() == '...'
            ? l10n.translate('genericUser')
            : userName;
    final displayUserEmail =
        userEmail.trim().isEmpty || userEmail.trim() == '...'
            ? l10n.translate('emailNotAvailable')
            : userEmail;

    if (_isLoadingProfile) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surfaceContainerLowest,
                Color.alphaBlend(
                  scheme.primary.withOpacity(0.08),
                  scheme.surface,
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset('assets/icons/app_icon.png'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.translate('profileLoadingTitle'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.translate('profileLoadingSubtitle'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: scheme.primary.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isLoggedIn) {
      return _buildGuestProfile(context);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!profiloCompleto)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.secondary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: scheme.secondary.withOpacity(0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.profileIncomplete,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.completeProfileMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const CompletaProfiloScreen(),
                            ),
                          );
                          if (result == true) {
                            _checkProfiloCompleto();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.secondary,
                          foregroundColor: scheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.completeNow),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, const Color(0xFF1496C1)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final currentAvatar = avatarUrl?.trim() ?? '';
                            if (currentAvatar.isNotEmpty) {
                              _openImagePreview(currentAvatar);
                            }
                          },
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            backgroundImage:
                                (avatarUrl ?? '').trim().isNotEmpty
                                    ? NetworkImage(avatarUrl!.trim())
                                    : null,
                            child:
                                (avatarUrl ?? '').trim().isEmpty
                                    ? Text(
                                      displayUserName.isNotEmpty
                                          ? displayUserName[0]
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: scheme.surface,
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap:
                                  _isUploadingAvatar
                                      ? null
                                      : _showAvatarOptions,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child:
                                    _isUploadingAvatar
                                        ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: scheme.primary,
                                          ),
                                        )
                                        : Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: scheme.primary,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayUserName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayUserEmail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildActionCard(
              context: context,
              icon: Icons.folder_outlined,
              accentColor: scheme.secondary,
              title: l10n.myDocumentsTitle,
              subtitle: l10n.translate('myDocumentsSubtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentiScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.history_edu_outlined,
              accentColor: scheme.primary,
              title: l10n.translate('storicoPraticheTitle'),
              subtitle: l10n.translate('storicoPraticheSubtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoricoPraticheScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.support_agent_outlined,
              accentColor: const Color(0xFF25D366),
              title: AppLocalizations.of(context)!.myRequests,
              subtitle: AppLocalizations.of(context)!
                  .translate('mySupportRequestsSubtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MieRichiesteScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildSectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.event,
                          color: scheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.myEvents,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingEventi)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else if (_mieiEventi.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            l10n.notEnrolledInEvents,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withOpacity(0.65),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _loadMieiEventi,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.reload),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mieiEventi.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final evento = _mieiEventi[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EventoDetailScreen(
                                        eventoId: evento.id,
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  if (evento.immagineCopertina != null &&
                                      evento.immagineCopertina!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        evento.immagineCopertina!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: scheme.primary
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.event,
                                                color: scheme.primary,
                                              ),
                                            ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.event,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          evento.titolo,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: scheme.onSurface
                                                  .withOpacity(0.65),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              evento.dataInizio,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: scheme.onSurface
                                                        .withOpacity(0.65),
                                                  ),
                                            ),
                                            if (evento.luogo != null) ...[
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: scheme.onSurface
                                                    .withOpacity(0.65),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  evento.luogo!,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: scheme.onSurface
                                                            .withOpacity(0.65),
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preferences,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.language,
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: selectedLanguageCode,
                    items: [
                      DropdownMenuItem(
                        value: 'it',
                        child: Text(l10n.translate('languageItalian')),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.translate('languageEnglish')),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Text(l10n.translate('languageSpanish')),
                      ),
                      DropdownMenuItem(
                        value: 'fr',
                        child: Text(l10n.translate('languageFrench')),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(l10n.translate('languageArabic')),
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text(l10n.translate('languageChinese')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _changeLanguage(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        value: _biometricLoginEnabled,
                        onChanged: _toggleBiometricLogin,
                        title: Text(l10n.translate('useBiometricLoginSetting')),
                        subtitle: Text(
                          l10n.translate('useBiometricLoginSettingDescription'),
                        ),
                        secondary: const Icon(Icons.fingerprint),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.person_outline,
              accentColor: scheme.primary,
              title: l10n.completeProfile,
              subtitle: l10n.updateYourPersonalData,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletaProfiloScreen(),
                  ),
                );
                if (result == true) {
                  _checkProfiloCompleto();
                }
              },
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.security,
              accentColor: scheme.secondary,
              title: l10n.translate('changePassword'),
              subtitle: l10n.translate('updateYourPassword'),
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/change-password',
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('passwordChangedSuccess')),
                      backgroundColor: scheme.secondary,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.delete_forever_rounded,
              accentColor: scheme.error,
              title: l10n.translate('deleteAccountButton'),
              subtitle: l10n.translate('deleteAccountSubtitle'),
              onTap: _deleteAccountFlow,
            ),

            const SizedBox(height: 20),

            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: scheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.translate('profileAppInfoTitle'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.translate('profileAppVersion')}: $_appVersionDisplay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      l10n.translate('profileWecoopCompanyDetails'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('profileWecoopBillingNotice'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.82),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('profileWecoopInvoiceFlow'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.72),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: _launchGdprApp,
              icon: const Icon(Icons.gavel_outlined),
              label: Text(l10n.translate('gdprLinkLabel')),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _launchPrivacyPolicy,
              icon: const Icon(Icons.privacy_tip_outlined),
              label: Text(l10n.translate('privacyPolicy')),
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageViewer extends StatelessWidget {
  final String imageUrl;

  const _ProfileImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported,
                color: Colors.white70,
                size: 72,
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}

class _AvatarCropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final _AvatarCropShape cropShape;

  const _AvatarCropScreen({required this.imageBytes, required this.cropShape});

  @override
  State<_AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<_AvatarCropScreen> {
  final CropController _controller = CropController();
  bool _isCropping = false;

  void _handleCropResult(CropResult result) {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(Uint8List.fromList(croppedImage));
      case CropFailure(:final cause):
        setState(() {
          _isCropping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('cropError')}: $cause'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          widget.cropShape == _AvatarCropShape.circle
              ? l10n.translate('avatarCircularCrop')
              : l10n.translate('avatarSquareCrop'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _controller,
              image: widget.imageBytes,
              onCropped: _handleCropResult,
              withCircleUi: widget.cropShape == _AvatarCropShape.circle,
              aspectRatio: 1,
              interactive: true,
              radius: widget.cropShape == _AvatarCropShape.circle ? 180 : 28,
              initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                size: 0.88,
                aspectRatio: 1,
              ),
              baseColor: const Color(0xFF0F172A),
              maskColor: Colors.black.withOpacity(0.52),
              progressIndicator: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isCropping
                              ? null
                              : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isCropping
                              ? null
                              : () {
                                setState(() {
                                  _isCropping = true;
                                });
                                _controller.crop();
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon:
                          _isCropping
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check_rounded),
                      label: Text(
                        _isCropping
                            ? l10n.processing
                            : l10n.translate('applyAction'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
