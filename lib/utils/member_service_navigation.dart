import 'package:flutter/material.dart';

import '../screens/onboarding/first_access_screen.dart';
import '../screens/servizi/servizi_gate_screen.dart';
import '../services/auth_helper.dart';

/// Apre un servizio riservato ai soci con gate coerente.
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
      MaterialPageRoute(builder: (_) => const FirstAccessScreen()),
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
