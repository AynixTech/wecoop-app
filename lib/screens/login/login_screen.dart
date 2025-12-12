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
    final url = Uri.parse(
      'https://www.wecoop.org/wp-json/wecoop/v1/user-meta/$nicename',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('GET user-meta status: ${response.statusCode}');
      print('GET user-meta body: ${response.body}');

      if (response.statusCode == 200) {
        final meta = jsonDecode(response.body);
        await storage.write(key: 'telefono', value: meta['telefono']);
        await storage.write(key: 'citta', value: meta['citta']);
        await storage.write(key: 'interessi', value: meta['interessi']);
        await storage.write(key: 'carta_id', value: meta['carta_id']);
      } else {
        print('Errore nel recupero dei metadati utente');
      }
    } catch (e) {
      print('Eccezione durante il recupero dei metadati: $e');
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
