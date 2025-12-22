import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../services/locale_provider.dart';
import '../../services/app_localizations.dart';
import '../../services/eventi_service.dart';
import '../../models/evento_model.dart';
import '../eventi/evento_detail_screen.dart';

final storage = FlutterSecureStorage();

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

  String selectedLanguageCode = 'it';
  String selectedInterest = 'culture';
  
  List<Evento> _mieiEventi = [];
  bool _isLoadingEventi = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMieiEventi();
  }

  Future<void> _loadUserData() async {
    final name = await storage.read(key: 'full_name');
    final displayName = await storage.read(key: 'user_display_name');
    final email = await storage.read(key: 'user_email');
    final tessera = await storage.read(key: 'tessera_numero');
    final url = await storage.read(key: 'tessera_url');
    final langCode = await storage.read(key: 'language_code');
    final interest = await storage.read(key: 'selected_interest');

    if (mounted) {
      setState(() {
        userName = name ?? displayName ?? 'Utente';
        userEmail = email ?? 'email non disponibile';
        tesseraNumero = tessera ?? 'Tessera non disponibile';
        tesseraUrl = url;
        selectedLanguageCode = langCode ?? 'it';
        selectedInterest = interest ?? 'culture';
      });
    }
  }

  Future<void> _loadMieiEventi() async {
    if (!mounted) return;

    // Verifica se l'utente è loggato
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
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
      final response = await EventiService.getMieiEventi();
      
      if (response['success'] == true) {
        final eventiList = (response['eventi'] as List?)?.cast<Evento>() ?? [];
        if (mounted) {
          setState(() {
            _mieiEventi = eventiList;
            _isLoadingEventi = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingEventi = false;
          });
        }
      }
    } catch (e) {
      print('Errore getMieiEventi: $e');
      if (mounted) {
        setState(() {
          _isLoadingEventi = false;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Salva l'email prima di fare logout per poterla ricaricare
    final currentEmail = await storage.read(key: 'user_email');
    if (currentEmail != null) {
      await storage.write(key: 'last_login_email', value: currentEmail);
    }

    // Cancella token e credenziali
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_display_name');
    await storage.delete(key: 'user_nicename');
    await storage.delete(key: 'saved_email');
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

    // NON cancellare last_login_email - serve per precompilare il login

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

  Future<void> _saveInterest(String interest) async {
    await storage.write(key: 'selected_interest', value: interest);
    if (mounted) {
      setState(() {
        selectedInterest = interest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.amber.shade700,
                child: Text(
                  userName.isNotEmpty ? userName[0] : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                userName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                userEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.card_membership,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.memberCard,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data:
                            tesseraUrl ??
                            'https://www.wecoop.org/tessera-socio/?id=$tesseraNumero',
                        version: QrVersions.auto,
                        size: 180,
                        gapless: false,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.cardNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tesseraNumero,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (tesseraUrl != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Apri URL tessera nel browser
                        },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(l10n.openDigitalCard),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 32, thickness: 1),

            // Sezione I miei eventi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event,
                          color: Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'I miei eventi',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
                              'Non sei iscritto a nessun evento',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _loadMieiEventi,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Ricarica'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _mieiEventi.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final evento = _mieiEventi[index];
                          return InkWell(
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
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  if (evento.immagineCopertina != null && evento.immagineCopertina!.isNotEmpty)
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
                                            color: const Color(0xFF2196F3).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.event,
                                            color: Color(0xFF2196F3),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.event,
                                        color: Color(0xFF2196F3),
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
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              evento.dataInizio,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            if (evento.luogo != null) ...[
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  evento.luogo!,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade600,
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
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const Divider(height: 32, thickness: 1),

            Text(
              l10n.preferences,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.areaOfInterest,
                border: const OutlineInputBorder(),
              ),
              value: selectedInterest,
              items: [
                DropdownMenuItem(value: 'culture', child: Text(l10n.culture)),
                DropdownMenuItem(value: 'sport', child: Text(l10n.sport)),
                DropdownMenuItem(value: 'training', child: Text(l10n.training)),
                DropdownMenuItem(
                  value: 'volunteering',
                  child: Text(l10n.volunteering),
                ),
                DropdownMenuItem(
                  value: 'socialServices',
                  child: Text(l10n.socialServices),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _saveInterest(value);
                }
              },
            ),

            const Divider(height: 32, thickness: 1),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
