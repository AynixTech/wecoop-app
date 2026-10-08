import 'package:flutter/material.dart';

import '../screens/eventi/evento_detail_screen.dart';
import '../screens/lavoro/offerte_lavoro_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/profilo/documenti_screen.dart';
import '../screens/profilo/mie_richieste_screen.dart';
import '../screens/profilo/storico_pratica_dettaglio_screen.dart';
import '../screens/servizi/pagamento_screen.dart';
import '../services/auth_helper.dart';
import '../services/push_notification_service.dart';
import '../services/socio_service.dart';
import '../utils/practice_status.dart';

/// Indici tab di [MainScreen].
abstract final class MainTab {
  static const int home = 0;
  static const int eventi = 1;
  static const int annunci = 2;
  /// Tab "Le mie richieste" (alias storico: calendar).
  static const int calendar = 3;
  static const int richieste = calendar;
  static const int lavoro = 4;
  static const int sportello = 5;
  static const int profilo = 6;
}

/// Navigazione centralizzata: evita duplicare schermate nello stack.
abstract final class AppNavigation {
  static NavigatorState? get _navigator =>
      PushNotificationService.navigatorKey?.currentState;

  static void navigateToMainTab(
    int index, {
    String? richiestaId,
    bool clearStack = true,
  }) {
    final navigator = _navigator;
    if (navigator == null) return;

    final args = <String, dynamic>{'initialIndex': index};
    if (richiestaId != null && richiestaId.isNotEmpty) {
      args['richiesta_id'] = richiestaId;
    }

    if (clearStack) {
      navigator.pushNamedAndRemoveUntil('/home', (_) => false, arguments: args);
    } else {
      navigator.pushNamed('/home', arguments: args);
    }
  }

  static void navigateToLogin({bool clearStack = true}) {
    final navigator = _navigator;
    if (navigator == null) return;

    if (clearStack) {
      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      navigator.pushReplacementNamed('/login');
    }
  }

  static void navigateToNotifications() {
    _navigator?.pushNamed('/notifications');
  }

  static void navigateToEventDetail(int eventoId) {
    final navigator = _navigator;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(builder: (_) => EventoDetailScreen(eventoId: eventoId)),
    );
  }

  static void navigateToOfferteLavoro({int? offertaId}) {
    final navigator = _navigator;
    if (navigator == null) return;

    if (offertaId != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => OfferteLavoroScreen(initialOffertaId: offertaId),
        ),
      );
      return;
    }

    navigateToMainTab(MainTab.lavoro);
  }

  static void navigateToDocumenti() {
    final navigator = _navigator;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(builder: (_) => const DocumentiScreen()),
    );
  }

  static Future<void> navigateToMieRichieste({String? ticketId}) async {
    final navigator = _navigator;
    if (navigator == null) return;

    final loggedIn = await AuthHelper.isLoggedIn();
    if (!loggedIn) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => MieRichiesteScreen(initialTicketId: ticketId),
      ),
    );
  }

  /// Apre la schermata di pagamento (stesso path dell'email deep link).
  /// Richiede login; altrimenti porta al LoginScreen.
  static Future<void> navigateToPagamento({
    int? richiestaId,
    int? paymentId,
  }) async {
    final navigator = _navigator;
    if (navigator == null) return;
    if (richiestaId == null && paymentId == null) {
      navigateToMainTab(MainTab.richieste);
      return;
    }

    final loggedIn = await AuthHelper.isLoggedIn();
    if (!loggedIn) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => PagamentoScreen(
          richiestaId: richiestaId,
          paymentId: paymentId ?? 0,
        ),
      ),
    );
  }

  /// Apre documenti solo se autenticato.
  static Future<void> navigateToDocumentiAuthed() async {
    final loggedIn = await AuthHelper.isLoggedIn();
    if (!loggedIn) {
      navigateToLogin();
      return;
    }
    navigateToDocumenti();
  }

  /// Apre una pratica: se chiusa → Storico dettaglio; altrimenti tab Richieste.
  static Future<void> navigateToPratica({
    required String richiestaId,
    String? preferredScreen,
  }) async {
    final rid = int.tryParse(richiestaId);
    if (rid == null) {
      navigateToMainTab(MainTab.calendar, richiestaId: richiestaId);
      return;
    }

    final loggedIn = await AuthHelper.isLoggedIn();
    if (!loggedIn) {
      navigateToLogin();
      return;
    }

    // Completamento → Storico diretto senza dipendere dalla lista attiva.
    if (preferredScreen == 'service_request_completed' ||
        preferredScreen == 'completed') {
      final navigator = _navigator;
      if (navigator == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => StoricoPraticaDettaglioScreen(richiestaId: rid),
        ),
      );
      return;
    }

    final dettaglio = await SocioService.getDettaglioRichiesta(rid);
    final stato =
        (dettaglio?['stato'] ?? dettaglio?['status'] ?? '').toString();
    if (dettaglio != null && PracticeStatus.isClosed(stato)) {
      final navigator = _navigator;
      if (navigator == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => StoricoPraticaDettaglioScreen(
            richiestaId: rid,
            initial: dettaglio,
          ),
        ),
      );
      return;
    }

    navigateToMainTab(MainTab.calendar, richiestaId: richiestaId);
  }

  /// Gestione unificata payload push / notifiche in-app.
  static void handleNotificationPayload(Map<String, dynamic> data) {
    if (data['type']?.toString() == 'badge_sync') return;

    final screen =
        (data['screen'] ?? data['type'] ?? data['tipo'] ?? '').toString();
    final requestId =
        (data['request_id'] ?? data['entity_id'] ?? data['id'])?.toString();
    final eventIdRaw = data['event_id'] ?? data['evento_id'];
    final eventId =
        eventIdRaw is int ? eventIdRaw : int.tryParse(eventIdRaw?.toString() ?? '');

    switch (screen) {
      case 'Notifications':
      case 'notifications':
        navigateToNotifications();
        return;

      case 'EventDetail':
        if (eventId != null) {
          navigateToEventDetail(eventId);
        } else {
          navigateToMainTab(MainTab.eventi);
        }
        return;

      case 'profile':
      case 'membership_expiry':
      case 'Profile':
        navigateToMainTab(MainTab.profilo);
        return;

      case 'appuntamento':
      case 'appuntamento_reminder':
      case 'calendar':
      case 'AppointmentDetail':
        if (requestId != null && requestId.isNotEmpty) {
          navigateToPratica(richiestaId: requestId);
        } else {
          navigateToMainTab(MainTab.calendar);
        }
        return;

      case 'support':
      case 'support_reply':
        final ticketId = (data['ticket_id'] ??
                data['entity_id'] ??
                data['request_id'] ??
                requestId)
            ?.toString();
        navigateToMieRichieste(ticketId: ticketId);
        return;

      case 'documenti':
      case 'document_expiry':
        navigateToDocumentiAuthed();
        return;

      case 'payment':
        final rid = int.tryParse(requestId ?? '');
        final paymentRaw =
            (data['payment_id'] ?? data['pagamento_id'])?.toString();
        final pid = int.tryParse(paymentRaw ?? '');
        if (rid != null || pid != null) {
          navigateToPagamento(richiestaId: rid, paymentId: pid);
        } else {
          navigateToMainTab(MainTab.calendar);
        }
        return;

      case 'service_request_completed':
        if (requestId != null && requestId.isNotEmpty) {
          navigateToPratica(
            richiestaId: requestId,
            preferredScreen: 'service_request_completed',
          );
        } else {
          navigateToMainTab(MainTab.profilo);
        }
        return;

      case 'document_ready':
      case 'status':
      case 'integrazione':
      case 'operator_message':
      case 'service_request':
      case 'ServiceDetail':
        if (requestId != null && requestId.isNotEmpty) {
          navigateToPratica(richiestaId: requestId);
        } else {
          navigateToMainTab(MainTab.calendar);
        }
        return;

      default:
        if (requestId != null && requestId.isNotEmpty) {
          navigateToPratica(richiestaId: requestId);
        } else {
          navigateToNotifications();
        }
    }
  }
}

/// Estrae argomenti route verso [MainScreen].
MainScreenRouteArgs parseMainScreenRouteArgs(Object? arguments) {
  if (arguments is MainScreenRouteArgs) return arguments;

  if (arguments is Map) {
    final index = arguments['initialIndex'];
    final richiestaId = arguments['richiesta_id']?.toString();
    return MainScreenRouteArgs(
      initialIndex: index is int ? index : 0,
      initialRichiestaId: richiestaId,
    );
  }

  if (arguments is int) {
    return MainScreenRouteArgs(initialIndex: arguments);
  }

  return const MainScreenRouteArgs();
}

class MainScreenRouteArgs {
  final int initialIndex;
  final String? initialRichiestaId;

  const MainScreenRouteArgs({
    this.initialIndex = 0,
    this.initialRichiestaId,
  });
}
