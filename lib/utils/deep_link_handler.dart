import 'package:flutter/material.dart';
import '../screens/servizi/pagamento_screen.dart';

class DeepLinkHandler {
  /// Naviga alla schermata corretta in base all'URI
  static void handleDeepLink(BuildContext context, Uri uri) {
    print('📍 Gestisco deep link: ${uri.path}');
    
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // wecoop://app/richieste o wecoop://app/calendar
    if (path == '/richieste' || path == '/calendar') {
      Navigator.of(context).pushNamed('/calendar');
      return;
    }

    // wecoop://app/richieste/405
    if (path.startsWith('/richieste/')) {
      final id = path.split('/').last;
      _navigateToRichiesta(context, id);
      return;
    }
    
    // wecoop://app/richieste?id=405
    if (path == '/richieste' && queryParams.containsKey('id')) {
      _navigateToRichiesta(context, queryParams['id']!);
      return;
    }

    // wecoop://app/pagamento/405
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
    
    // wecoop://app/pagamento?richiesta_id=405
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

    // wecoop://app/profilo o wecoop://app/profile
    if (path == '/profilo' || path == '/profile') {
      // Naviga alla tab profilo nel MainScreen
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      return;
    }

    // wecoop://app/servizi o wecoop://app/services
    if (path == '/servizi' || path == '/services') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      return;
    }

    // wecoop://app/home o wecoop://app/
    if (path == '/home' || path == '/' || path.isEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      return;
    }

    // Link non riconosciuto
    print('⚠️ Deep link non gestito: $path');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link non valido'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void _navigateToRichiesta(BuildContext context, String id) {
    print('🔄 Navigazione a richiesta ID: $id');
    // Naviga al calendario con l'ID della richiesta da aprire
    Navigator.of(context).pushNamed(
      '/calendar',
      arguments: {'richiesta_id': id},
    );
  }
}
