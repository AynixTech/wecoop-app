import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'login/login_screen.dart';
import 'onboarding/first_access_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget protectedScreen;

  AuthGate({super.key, required this.protectedScreen});

  final storage = SecureStorageService();

  Future<Map<String, bool>> _checkAuthStatus() async {
    // Controlla se ha completato il primo accesso (registrazione semplificata)
    final prefs = await SharedPreferences.getInstance();
    final primoAccessoCompletato = prefs.getBool('primo_accesso_completato') ?? false;
    
    // Controlla se ha fatto login (ha JWT token)
    final token = await storage.read(key: 'jwt_token');
    final isLoggedIn = token != null && token.isNotEmpty;
    
    return {
      'primo_accesso_completato': primoAccessoCompletato,
      'is_logged_in': isLoggedIn,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final status = snapshot.data ?? {};
        final primoAccessoCompletato = status['primo_accesso_completato'] ?? false;
        final isLoggedIn = status['is_logged_in'] ?? false;

        // Se ha già fatto login, mostra schermata protetta
        if (isLoggedIn) {
          return protectedScreen;
        }
        
        // Se non ha completato primo accesso, mostra registrazione semplificata
        if (!primoAccessoCompletato) {
          return const FirstAccessScreen();
        }
        
        // Altrimenti mostra login (per utenti già registrati ma non loggati)
        return const LoginScreen();
      },
    );
  }
}
