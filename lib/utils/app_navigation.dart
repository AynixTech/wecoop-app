import 'package:flutter/material.dart';

import '../screens/eventi/evento_detail_screen.dart';
import '../screens/lavoro/offerte_lavoro_screen.dart';
import '../screens/profilo/documenti_screen.dart';
import '../screens/profilo/mie_richieste_screen.dart';
import '../services/push_notification_service.dart';

/// Indici tab di [MainScreen].
abstract final class MainTab {
  static const int home = 0;
  static const int eventi = 1;
  static const int annunci = 2;
  static const int calendar = 3;
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

  static void navigateToMieRichieste({String? ticketId}) {
    final navigator = _navigator;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => MieRichiesteScreen(initialTicketId: ticketId),
      ),
    );
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
        navigateToMainTab(
          MainTab.calendar,
          richiestaId: requestId,
        );
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
        navigateToDocumenti();
        return;

      case 'document_ready':
      case 'status':
      case 'payment':
      case 'integrazione':
      case 'operator_message':
      case 'service_request':
      case 'ServiceDetail':
        navigateToMainTab(
          MainTab.calendar,
          richiestaId: requestId,
        );
        return;

      default:
        if (requestId != null && requestId.isNotEmpty) {
          navigateToMainTab(MainTab.calendar, richiestaId: requestId);
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
