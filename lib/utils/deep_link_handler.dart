import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/utils/app_navigation.dart';
import '../screens/profilo/change_password_screen.dart';
import '../screens/servizi/pagamento_screen.dart';
import '../screens/annunci/annunci_screen.dart';
import '../screens/eventi/evento_detail_screen.dart';
import '../screens/servizi/studiare_in_italia_screen.dart';

class DeepLinkHandler {
  /// Naviga alla schermata corretta in base all'URI
  static void handleDeepLink(BuildContext context, Uri uri) {
    AppLogger.d('📍 Gestisco deep link: ${uri.path}');

    final path = uri.path;
    final queryParams = uri.queryParameters;
    final l10n = AppLocalizations.of(context);

    if (path.startsWith('/annunci/')) {
      final id = int.tryParse(path.split('/').last);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnnunciScreen(initialAnnuncioId: id),
          ),
        );
        return;
      }
    }

    if (path.startsWith('/eventi/')) {
      final id = int.tryParse(path.split('/').last);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventoDetailScreen(eventoId: id),
          ),
        );
        return;
      }
    }

    if (path.startsWith('/offerte-lavoro/')) {
      final id = int.tryParse(path.split('/').last);
      AppNavigation.navigateToOfferteLavoro(offertaId: id);
      return;
    }

    if (path.startsWith('/offerte-formative/')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const StudiareInItaliaScreen()),
      );
      return;
    }

    if (path == '/richieste' || path == '/calendar') {
      AppNavigation.navigateToMainTab(MainTab.calendar);
      return;
    }

    if (path.startsWith('/richieste/')) {
      final id = path.split('/').last;
      _navigateToRichiesta(context, id);
      return;
    }

    if (path == '/richieste' && queryParams.containsKey('id')) {
      _navigateToRichiesta(context, queryParams['id']!);
      return;
    }

    if (path.startsWith('/pagamento/')) {
      final id = int.tryParse(path.split('/').last);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PagamentoScreen(richiestaId: id),
          ),
        );
      }
      return;
    }

    if (path == '/pagamento' && queryParams.containsKey('richiesta_id')) {
      final id = int.tryParse(queryParams['richiesta_id']!);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PagamentoScreen(richiestaId: id),
          ),
        );
      }
      return;
    }

    if (path == '/reset-password') {
      final token = queryParams['token'];
      if (token != null && token.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(resetToken: token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.translate('invalidResetPasswordLink') ?? ''),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (path == '/profilo' || path == '/profile') {
      AppNavigation.navigateToMainTab(MainTab.profilo);
      return;
    }

    if (path == '/servizi' || path == '/services') {
      AppNavigation.navigateToMainTab(MainTab.home);
      return;
    }

    if (path == '/home' || path == '/' || path.isEmpty) {
      AppNavigation.navigateToMainTab(MainTab.home);
      return;
    }

    AppLogger.d('⚠️ Deep link non gestito: $path');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.translate('invalidDeepLink') ?? ''),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _navigateToRichiesta(BuildContext context, String id) {
    AppLogger.d('🔄 Navigazione a richiesta ID: $id');
    AppNavigation.navigateToMainTab(MainTab.calendar, richiestaId: id);
  }
}
