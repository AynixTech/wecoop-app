import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import '../screens/profilo/change_password_screen.dart';
import '../screens/servizi/pagamento_screen.dart';
import '../screens/annunci/annunci_screen.dart';
import '../screens/eventi/evento_detail_screen.dart';
import '../screens/lavoro/offerte_lavoro_screen.dart';
import '../screens/servizi/studiare_in_italia_screen.dart';

class DeepLinkHandler {
  /// Naviga alla schermata corretta in base all'URI
  static void handleDeepLink(BuildContext context, Uri uri) {
    AppLogger.d('📍 Gestisco deep link: ${uri.path}');
    
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Universal Link / App Link condivisibile: https://www.wecoop.org/annunci/123
    // (oppure schema custom wecoop://app/annunci/123). Apre il dettaglio annuncio.
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

    // https://www.wecoop.org/eventi/123 → dettaglio evento.
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

    // https://www.wecoop.org/offerte-lavoro/123 → sezione offerte di lavoro.
    // (Il dettaglio si apre dalla lista; qui portiamo l'utente alla sezione.)
    if (path.startsWith('/offerte-lavoro/')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OfferteLavoroScreen()),
      );
      return;
    }

    // https://www.wecoop.org/offerte-formative/123 → sezione offerte formative.
    if (path.startsWith('/offerte-formative/')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const StudiareInItaliaScreen()),
      );
      return;
    }

    // wecoop://app/richieste o wecoop://app/calendar
    if (path == '/richieste' || path == '/calendar') {
      Navigator.of(context).pushNamed('/calendar');
      return;
    }

    // wecoop://app/richieste/405
    // oppure App Link: https://cloud.wecoop.org/richieste/405
    // (email integrazione documenti, firma, appuntamento, completamento)
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
    // oppure App Link: https://cloud.wecoop.org/pagamento/405 (email pagamento)
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
          const SnackBar(
            content: Text('Link reset password non valido'),
            duration: Duration(seconds: 3),
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
    AppLogger.d('⚠️ Deep link non gestito: $path');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link non valido'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void _navigateToRichiesta(BuildContext context, String id) {
    AppLogger.d('🔄 Navigazione a richiesta ID: $id');
    // Naviga al calendario con l'ID della richiesta da aprire
    Navigator.of(context).pushNamed(
      '/calendar',
      arguments: {'richiesta_id': id},
    );
  }
}
