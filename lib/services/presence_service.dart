import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:wecoop_app/config/api_config.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';

/// Invia heartbeat di presenza al backend così gli operatori in /utenti
/// vedono se l'utente è online e su quale schermata si trova.
class PresenceService {
  PresenceService._();
  static final PresenceService instance = PresenceService._();

  final _storage = SecureStorageService();
  Timer? _heartbeat;
  String? _currentScreen;
  String? _currentRoute;
  String _appState = 'active';
  bool _started = false;

  /// Avvia heartbeat periodico (ogni 30s). Idempotente.
  void start() {
    if (_started) return;
    _started = true;
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(ping());
    });
    unawaited(ping());
  }

  void stop() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _started = false;
  }

  /// Aggiorna la schermata corrente e invia subito un ping.
  void setScreen({String? screen, String? route}) {
    if (screen != null && screen.trim().isNotEmpty) {
      _currentScreen = _humanizeScreen(screen.trim());
    }
    if (route != null) _currentRoute = route;
    unawaited(ping());
  }

  void setAppState(String state) {
    _appState = state;
    unawaited(ping(force: true));
  }

  Future<void> ping({bool force = false}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return;

      final body = <String, dynamic>{
        'app_state': _appState,
        if (_currentScreen != null) 'current_screen': _currentScreen,
        if (_currentRoute != null) 'current_route': _currentRoute,
      };

      final res = await HttpClientService.post(
        Uri.parse('${ApiConfig.baseUrl}/presence'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode >= 400 && force) {
        AppLogger.d('Presence ping failed: ${res.statusCode}');
      }
    } catch (e) {
      // Silenzioso: la presenza non deve mai interrompere l'UX.
      if (force) AppLogger.d('Presence ping error: $e');
    }
  }

  /// Converte nomi tecnici di route/widget in etichette leggibili per l'operatore.
  static String _humanizeScreen(String raw) {
    final map = <String, String>{
      'MainScreen': 'Home',
      'HomeScreen': 'Home',
      'LoginScreen': 'Login',
      'MediazioneFiscaleScreen': 'Mediazione fiscale',
      'RichiestaFormScreen': 'Compilazione richiesta',
      'PermessoSoggiornoScreen': 'Permesso di soggiorno',
      'DocumentiScreen': 'Documenti',
      'ProfiloScreen': 'Profilo',
      'MieRichiesteScreen': 'Le mie richieste',
      'NotificheScreen': 'Notifiche',
      'PrenotaAppuntamentoScreen': 'Prenota appuntamento',
      'CompletaProfiloScreen': 'Completa profilo',
      'CvAiScreen': 'CV AI',
      'ChatbotAssistenzaScreen': 'Assistenza chatbot',
      'OfferteLavoroScreen': 'Offerte di lavoro',
      'SupportoContabileScreen': 'Supporto contabile',
    };
    if (map.containsKey(raw)) return map[raw]!;
    // Se arriva già un'etichetta "Servizio · Categoria", lasciala.
    if (raw.contains(' · ') || raw.contains(' - ')) return raw;
    // CamelCase → spazi
    final spaced = raw
        .replaceAll(RegExp(r'Screen$'), '')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    return spaced.trim().isEmpty ? raw : spaced.trim();
  }
}

/// Observer che aggiorna la presenza a ogni cambio di route.
class PresenceNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _update(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _update(previousRoute);
  }

  void _update(Route<dynamic> route) {
    final name = route.settings.name;
    final widgetName = route.settings.arguments?.toString();
    // Preferisci il nome della route; fallback al tipo del widget se disponibile.
    String? screen = name;
    if (screen == null || screen.isEmpty || screen == '/') {
      final settingsName = route.settings.name;
      screen = settingsName;
    }
    // Per MaterialPageRoute senza name, usa il runtimeType del builder context
    // non è disponibile qui: usiamo almeno il nome settings o "App".
    PresenceService.instance.setScreen(
      screen: (screen != null && screen.isNotEmpty && screen != '/')
          ? screen
          : (widgetName ?? 'App'),
      route: name,
    );
  }
}
