import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool rememberPassword = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final url = Uri.parse('https://www.wecoop.org/wp-json/jwt-auth/v1/token');

    print('Invio richiesta login a $url');
    print('Credenziali: $email / $password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        print('Login riuscito. Token ricevuto: ${data['token']}');

        await storage.write(key: 'jwt_token', value: data['token']);
        await storage.write(key: 'user_email', value: data['user_email']);
        await storage.write(
          key: 'user_display_name',
          value: data['user_display_name'],
        );
        await storage.write(key: 'user_nicename', value: data['user_nicename']);

        if (rememberPassword) {
          await storage.write(key: 'saved_email', value: email);
          await storage.write(key: 'saved_password', value: password);
        }

        // Recupera metadati utente
        await _fetchUserMeta(data['token'], data['user_nicename']);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final message = data['message'] ?? 'Login fallito';
        print('Login fallito: $message');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print('Eccezione durante il login: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Errore di rete')));
    }
  }

  Future<void> _fetchUserMeta(String token, String nicename) async {
    // Usa il nuovo endpoint /soci/me per ottenere tutti i dati dell'utente
    final url = Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/soci/me');

    print('🔄 Chiamata a /soci/me...');
    print('URL: $url');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📥 GET /soci/me status: ${response.statusCode}');
      print('📥 GET /soci/me body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // L'endpoint restituisce {success: true, data: {...}}
        // I dati del socio sono dentro responseData['data']
        final data = responseData['data'] as Map<String, dynamic>;

        print('📦 Dati ricevuti:');
        print('  - nome: ${data['nome']}');
        print('  - cognome: ${data['cognome']}');
        print('  - telefono: ${data['telefono']}');
        print('  - citta: ${data['citta']}');
        print('  - numero_tessera: ${data['numero_tessera']}');

        // Salva tutti i dati dell'utente socio
        await storage.write(key: 'socio_id', value: data['id']?.toString());
        await storage.write(key: 'first_name', value: data['nome']);
        await storage.write(key: 'last_name', value: data['cognome']);
        await storage.write(
          key: 'codice_fiscale',
          value: data['codice_fiscale'],
        );
        await storage.write(key: 'data_nascita', value: data['data_nascita']);
        await storage.write(key: 'luogo_nascita', value: data['luogo_nascita']);
        await storage.write(key: 'indirizzo', value: data['indirizzo']);
        await storage.write(key: 'citta', value: data['citta']);
        await storage.write(key: 'cap', value: data['cap']);
        await storage.write(key: 'provincia', value: data['provincia']);
        await storage.write(key: 'telefono', value: data['telefono']);
        await storage.write(key: 'professione', value: data['professione']);
        await storage.write(key: 'stato_socio', value: data['status_socio']);
        await storage.write(
          key: 'data_iscrizione',
          value: data['data_adesione'],
        );
        await storage.write(
          key: 'tessera_numero',
          value: data['numero_tessera'],
        );
        await storage.write(key: 'tessera_url', value: data['tessera_url']);
        await storage.write(
          key: 'quota_pagata',
          value: data['quota_pagata']?.toString(),
        );
        await storage.write(
          key: 'anni_socio',
          value: data['anni_socio']?.toString(),
        );

        // Crea nome completo
        final nome = data['nome'] ?? '';
        final cognome = data['cognome'] ?? '';
        if (nome.isNotEmpty || cognome.isNotEmpty) {
          final fullName = '$nome $cognome'.trim();
          await storage.write(key: 'full_name', value: fullName);
          print('✅ Nome completo salvato: $fullName');
        }

        print('✅ Dati socio salvati con successo');
        print('Tessera: ${data['numero_tessera']}');
        print('Anni socio: ${data['anni_socio']}');
        print('Quota pagata: ${data['quota_pagata']}');
      } else if (response.statusCode == 404) {
        print('⚠️ Utente non trovato come socio nel database');
        print('⚠️ Response: ${response.body}');
      } else {
        print('⚠️ Errore nel recupero dei dati socio: ${response.statusCode}');
        print('⚠️ Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Eccezione durante il recupero dei dati socio: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/wecoop_logo.png', height: 120),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
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
                const Text('Ricorda password'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _login, child: const Text('Accedi')),
          ],
        ),
      ),
    );
  }
}
