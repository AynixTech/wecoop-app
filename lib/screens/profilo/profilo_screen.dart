import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  String selectedLanguage = 'Italiano';
  String selectedInterest = 'Cultura';

  final List<String> languages = ['Italiano', 'Inglese', 'Spagnolo', 'Arabo'];
  final List<String> interests = [
    'Cultura',
    'Sport',
    'Formazione',
    'Volontariato',
    'Servizi sociali',
  ];

  final List<String> participationHistory = [
    'Evento culturale - 15 Marzo 2025',
    'Laboratorio di lingua - 10 Febbraio 2025',
    'Cena tematica - 5 Gennaio 2025',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await storage.read(key: 'full_name');
    final displayName = await storage.read(key: 'user_display_name');
    final email = await storage.read(key: 'user_email');
    final tessera = await storage.read(key: 'tessera_numero');
    final url = await storage.read(key: 'tessera_url');

    setState(() {
      userName = name ?? displayName ?? 'Utente';
      userEmail = email ?? 'email non disponibile';
      tesseraNumero = tessera ?? 'Tessera non disponibile';
      tesseraUrl = url;
    });
  }

  void _logout(BuildContext context) async {
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
    ).showSnackBar(const SnackBar(content: Text('Logout effettuato')));

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          'Tessera Socio WECOOP',
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
                      'N° Tessera',
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
                        label: const Text('Apri tessera digitale'),
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

            Text(
              'Preferenze',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Lingua',
                border: OutlineInputBorder(),
              ),
              value: selectedLanguage,
              items:
                  languages
                      .map(
                        (lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value ?? selectedLanguage;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Area di interesse',
                border: OutlineInputBorder(),
              ),
              value: selectedInterest,
              items:
                  interests
                      .map(
                        (interest) => DropdownMenuItem(
                          value: interest,
                          child: Text(interest),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedInterest = value ?? selectedInterest;
                });
              },
            ),

            const Divider(height: 32, thickness: 1),

            Text(
              'Storico partecipazioni',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...participationHistory.map((event) {
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text(event),
              );
            }).toList(),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
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
