import 'package:flutter/material.dart';

import '../screens/login/login_screen.dart';
import '../screens/servizi/servizi_gate_screen.dart';
import '../services/auth_helper.dart';

/// Apre un servizio per utenti autenticati (socio o utente).
///
/// La membership (socio) si attiva alla firma del documento unico lato backend.
/// Qui si richiede solo il login: nessun blocco "riservato ai soci".
Future<void> openMemberService(
  BuildContext context, {
  required Widget destination,
  required String serviceName,
}) async {
  if (!context.mounted) return;

  final loggedIn = await AuthHelper.isLoggedIn();
  if (!context.mounted) return;

  if (!loggedIn) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => ServiziGateScreen(
            destinationScreen: destination,
            serviceName: serviceName,
          ),
    ),
  );
}
