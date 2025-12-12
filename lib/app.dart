import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wecoop_app/screens/auth_gate.dart';
import 'package:wecoop_app/screens/caf/compilazione_730_screen.dart';
import 'package:wecoop_app/screens/prenota_appuntamento/prenota_appuntamento_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login/login_screen.dart';

void main() {
  
  runApp(const WECOOPApp());
}

class WECOOPApp extends StatelessWidget {
  const WECOOPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WECOOP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
      routes: {
        '/home': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/prenotaAppuntamento': (context) => PrenotaAppuntamentoScreen(),
        '/compila730':
            (context) =>
                AuthGate(protectedScreen: const Compilazione730Screen()),
        // '/assegnoUnico': (context) => AuthGate(protectedScreen: const AssegnoUnicoScreen()),
      },
    );
  }
}
