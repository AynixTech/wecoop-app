import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'login/login_screen.dart';

/// Gate per schermate che richiedono autenticazione.
///
/// Utenti creati dalla piattaforma cloud esistono già nel backend ma non
/// hanno il flag locale `primo_accesso_completato`: devono poter fare login
/// con le credenziali fornite, non essere forzati alla registrazione.
class AuthGate extends StatelessWidget {
  final Widget protectedScreen;

  AuthGate({super.key, required this.protectedScreen});

  final storage = SecureStorageService();

  Future<bool> _isLoggedIn() async {
    final token = await storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return protectedScreen;
        }

        // LoginScreen include già la CTA "Registrati" → FirstAccessScreen.
        return const LoginScreen();
      },
    );
  }
}
