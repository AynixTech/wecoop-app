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
  String cartaId = '...';

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
    final name = await storage.read(key: 'user_display_name');
    final email = await storage.read(key: 'user_email');
    final carta = await storage.read(key: 'carta_id');

    setState(() {
      userName = name ?? 'Utente';
      userEmail = email ?? 'email non disponibile';
      cartaId = carta ?? 'ID non disponibile';
    });
  }

  void _logout(BuildContext context) async {
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_display_name');
    await storage.delete(key: 'user_nicename');
    await storage.delete(key: 'saved_email');
    await storage.delete(key: 'saved_password');
    await storage.delete(key: 'carta_id');

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
                    Text(
                      'Tessera Soci WECOOP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data:
                          'https://www.wecoop.org/card-socio/?card_id=$cartaId',
                      version: QrVersions.auto,
                      size: 150,
                      gapless: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Carta ID: $cartaId',
                      style: theme.textTheme.bodyMedium,
                    ),
                
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
