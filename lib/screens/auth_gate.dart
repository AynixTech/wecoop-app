import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'login/login_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget protectedScreen;

  AuthGate({super.key, required this.protectedScreen});

  final storage = SecureStorageService();

  Future<bool> _checkLogin() async {
    final token = await storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return protectedScreen;
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
