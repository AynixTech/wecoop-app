import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import '../../services/locale_provider.dart';
import '../../services/app_localizations.dart';
import '../../services/eventi_service.dart';
import '../../services/socio_service.dart';
import '../../services/user_avatar_store.dart';
import '../../services/push_notification_service.dart';
import '../../models/evento_model.dart';
import '../eventi/evento_detail_screen.dart';
import 'completa_profilo_screen.dart';
import 'documenti_screen.dart';

final storage = SecureStorageService();

enum _AvatarCropShape { square, circle }

class ProfiloScreen extends StatefulWidget {
  const ProfiloScreen({super.key});

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  String userName = '...';
  String userEmail = '...';
  String tesseraNumero = '...';
  String? tesseraUrl;
  String? avatarUrl;
  bool profiloCompleto = true; // Assume completo finché non verifichiamo

  String selectedLanguageCode = 'it';
  String selectedInterest = 'culture';
  bool _biometricLoginEnabled = true;

  List<Evento> _mieiEventi = [];
  bool _isLoadingEventi = false;
  bool _isUploadingAvatar = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    UserAvatarStore.hydrate();
    _loadUserData();
    _loadMieiEventi();
    _checkProfiloCompleto();
  }

  Future<void> _checkProfiloCompleto() async {
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
      print('Errore verifica profilo: $e');
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
    final tessera = await storage.read(key: 'tessera_numero');
    final url = await storage.read(key: 'tessera_url');
    final storedAvatar = await storage.read(key: 'avatar_url');
    final langCode = await storage.read(key: 'language_code');
    final interest = await storage.read(key: 'selected_interest');
    final biometricSetting = await storage.read(key: 'biometric_login_enabled');

    if (mounted) {
      setState(() {
        userName = name ?? displayName ?? 'Utente';
        userEmail = email ?? 'email non disponibile';
        tesseraNumero = tessera ?? 'Tessera non disponibile';
        tesseraUrl = url;
        avatarUrl = storedAvatar;
        selectedLanguageCode = langCode ?? 'it';
        selectedInterest = interest ?? 'culture';
        _biometricLoginEnabled =
            biometricSetting == null || biometricSetting == 'true';
      });
    }

    try {
      final userData = await SocioService.getMeData();
      if (userData != null && userData['success'] == true) {
        final data = (userData['data'] as Map?)?.cast<String, dynamic>() ?? {};
        final nome = (data['nome'] ?? '').toString().trim();
        final cognome = (data['cognome'] ?? '').toString().trim();
        final fullName = '$nome $cognome'.trim();
        final freshAvatar = (data['avatar_url'] ?? '').toString().trim();
        final freshTessera = (data['numero_tessera'] ?? '').toString().trim();
        final freshTesseraUrl = (data['tessera_url'] ?? '').toString().trim();
        final freshEmail = (data['email'] ?? '').toString().trim();

        await UserAvatarStore.setAvatarUrl(freshAvatar);

        if (mounted) {
          setState(() {
            userName = fullName.isNotEmpty
                ? fullName
                : (data['display_name'] ?? userName).toString();
            userEmail = freshEmail.isNotEmpty ? freshEmail : userEmail;
            tesseraNumero = freshTessera.isNotEmpty
                ? freshTessera
                : tesseraNumero;
            tesseraUrl = freshTesseraUrl.isNotEmpty ? freshTesseraUrl : tesseraUrl;
            avatarUrl = freshAvatar.isNotEmpty ? freshAvatar : avatarUrl;
          });
        }
      }
    } catch (e) {
      print('Errore refresh dati profilo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
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

    final result = await SocioService.uploadAvatar(file: croppedFile);

    if (!mounted) return;

    setState(() {
      _isUploadingAvatar = false;
    });

    if (result['success'] == true) {
      final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final freshAvatar = (data['avatar_url'] ?? '').toString().trim();
      if (freshAvatar.isNotEmpty) {
        await UserAvatarStore.setAvatarUrl(freshAvatar);
        setState(() {
          avatarUrl = freshAvatar;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar aggiornato con successo')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((result['message'] ?? 'Errore aggiornamento avatar').toString()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<_AvatarCropShape?> _selectCropShape() async {
    return showModalBottomSheet<_AvatarCropShape>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.crop_square_rounded),
                title: const Text('Crop quadrato'),
                subtitle: const Text('Ideale se vuoi tenere piu margine nell\'immagine'),
                onTap: () => Navigator.pop(context, _AvatarCropShape.square),
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined),
                title: const Text('Crop circolare'),
                subtitle: const Text('Perfetto per un avatar tondo nell\'app'),
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
        builder: (_) => _AvatarCropScreen(
          imageBytes: sourceBytes,
          cropShape: cropShape,
        ),
      ),
    );

    if (croppedBytes == null || croppedBytes.isEmpty) {
      return null;
    }

    final decodedImage = img.decodeImage(croppedBytes);
    final normalizedBytes = decodedImage == null
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

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Scegli dalla galleria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Scatta una foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              if ((avatarUrl ?? '').trim().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Visualizza avatar'),
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
    if (token == null) {
      print('⚠️ Utente non loggato, impossibile caricare eventi');
      // Utente non loggato, non caricare eventi
      if (mounted) {
        setState(() {
          _mieiEventi = [];
          _isLoadingEventi = false;
        });
      }
      return;
    }

    setState(() {
      _isLoadingEventi = true;
    });

    try {
      print('🔄 Caricamento miei eventi...');
      final response = await EventiService.getMieiEventi();

      print('📥 Risposta getMieiEventi RAW: $response');
      print('📥 success=${response['success']}');
      print('📥 totale=${response['totale']}');

      if (response['success'] == true) {
        final eventiList = (response['eventi'] as List?)?.cast<Evento>() ?? [];
        print('✅ ${eventiList.length} miei eventi caricati');

        // Log dettagliato per ogni evento
        for (var i = 0; i < eventiList.length; i++) {
          final evento = eventiList[i];
          print('📌 Mio Evento #$i: ${evento.titolo}');
          print('   - ID: ${evento.id}');
          print('   - Data: ${evento.dataInizio} ${evento.oraInizio ?? ""}');
          print('   - Categoria: ${evento.categoria ?? "nessuna"}');
          print(
            '   - Immagine copertina: ${evento.immagineCopertina ?? "NESSUNA"}',
          );
          print(
            '   - Luogo: ${evento.luogo ?? evento.citta ?? "non specificato"}',
          );
          print('   - Online: ${evento.online}');
          print('   - Sono iscritto: ${evento.sonoIscritto}');
        }

        if (mounted) {
          setState(() {
            _mieiEventi = eventiList;
            _isLoadingEventi = false;
          });
        }
      } else {
        print('❌ Errore: ${response['message']}');
        if (mounted) {
          setState(() {
            _isLoadingEventi = false;
          });
        }
      }
    } catch (e) {
      print('❌ Errore getMieiEventi: $e');
      if (mounted) {
        setState(() {
          _isLoadingEventi = false;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Salva el teléfono antes de hacer logout para poder recargarlo
    final currentPhone = await storage.read(key: 'telefono');
    if (currentPhone != null) {
      await storage.write(key: 'last_login_phone', value: currentPhone);
    }

    // Rimuovi FCM token dal backend prima di cancellare i dati locali
    try {
      await PushNotificationService().removeToken();
      print('✅ FCM token rimosso dal backend');
    } catch (e) {
      print('⚠️ Errore rimozione FCM token: $e');
      // Continua comunque con il logout
    }

    // Cancella token e credenziali
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'auth_username');
    await storage.delete(key: 'auth_password');
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_display_name');
    await storage.delete(key: 'user_nicename');
    await storage.delete(key: 'saved_phone');
    await storage.delete(key: 'saved_password');
    await storage.delete(key: 'carta_id');

    // Cancella dati socio
    await storage.delete(key: 'socio_id');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'first_name');
    await storage.delete(key: 'last_name');
    await storage.delete(key: 'full_name');
    await storage.delete(key: 'codice_fiscale');
    await storage.delete(key: 'data_nascita');
    await storage.delete(key: 'luogo_nascita');
    await storage.delete(key: 'indirizzo');
    await storage.delete(key: 'citta');
    await storage.delete(key: 'cap');
    await storage.delete(key: 'provincia');
    await storage.delete(key: 'telefono');
    await storage.delete(key: 'professione');
    await storage.delete(key: 'stato_socio');
    await storage.delete(key: 'data_iscrizione');
    await storage.delete(key: 'tessera_numero');
    await storage.delete(key: 'tessera_url');
    await storage.delete(key: 'quota_pagata');
    await storage.delete(key: 'anni_socio');
    await storage.delete(key: 'avatar_url');
    await UserAvatarStore.clear();

    // NON cancellare last_login_phone - serve per precompilare il login

    print('Utente disconnesso');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.logoutConfirm)));

    Navigator.pushReplacementNamed(context, '/login');
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

  bool get _hasTesseraNumero {
    final normalized = tesseraNumero.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != '...' &&
        normalized != 'tessera non disponibile';
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
      child: Padding(
        padding: padding,
        child: child,
      ),
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: accentColor,
              size: 18,
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
                      'Stiamo preparando il tuo profilo',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Recuperiamo tessera, dati personali e preferenze aggiornate.',
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
                              builder: (context) => const CompletaProfiloScreen(),
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
                            child: (avatarUrl ?? '').trim().isEmpty
                                ? Text(
                                    userName.isNotEmpty ? userName[0] : '?',
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
                              onTap: _isUploadingAvatar ? null : _showAvatarOptions,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: _isUploadingAvatar
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
                            userName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userEmail,
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
                          Icons.card_membership_rounded,
                          color: scheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.memberCard,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_hasTesseraNumero) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.outline.withOpacity(0.12),
                        ),
                      ),
                      child: QrImageView(
                        data: tesseraUrl ?? 'https://www.wecoop.org/tessera-socio/?id=$tesseraNumero',
                        version: QrVersions.auto,
                        size: 180,
                        gapless: false,
                        backgroundColor: scheme.surface,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 30,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Numero tessera non disponibile',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.cardNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _hasTesseraNumero ? tesseraNumero : 'Non assegnato',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildActionCard(
              context: context,
              icon: Icons.folder_outlined,
              accentColor: scheme.secondary,
              title: 'I miei documenti',
              subtitle: 'Gestisci i tuoi documenti personali',
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
                                  builder: (context) => EventoDetailScreen(
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
                                        errorBuilder: (_, __, ___) => Container(
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          evento.titolo,
                                          style: theme.textTheme.bodyMedium?.copyWith(
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
                                              color: scheme.onSurface.withOpacity(0.65),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              evento.dataInizio,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: scheme.onSurface.withOpacity(0.65),
                                              ),
                                            ),
                                            if (evento.luogo != null) ...[
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: scheme.onSurface.withOpacity(0.65),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  evento.luogo!,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: scheme.onSurface.withOpacity(0.65),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                    value: selectedLanguageCode,
                    items: const [
                      DropdownMenuItem(value: 'it', child: Text('Italiano')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
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

  const _AvatarCropScreen({
    required this.imageBytes,
    required this.cropShape,
  });

  @override
  State<_AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<_AvatarCropScreen> {
  final CropController _controller = CropController();
  bool _isCropping = false;

  void _handleCropResult(CropResult result) {
    if (!mounted) return;

    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(Uint8List.fromList(croppedImage));
      case CropFailure(:final cause):
        setState(() {
          _isCropping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il crop: $cause'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          widget.cropShape == _AvatarCropShape.circle
              ? 'Crop avatar circolare'
              : 'Crop avatar quadrato',
          style: const TextStyle(fontSize: 16),
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
                      onPressed: _isCropping
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCropping
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
                      icon: _isCropping
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_isCropping ? 'Elaborazione...' : 'Applica'),
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
