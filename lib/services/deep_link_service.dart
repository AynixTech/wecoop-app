import 'dart:async';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  Function(Uri)? _onLink;

  /// Inizializza il servizio e gestisce il link iniziale
  Future<void> initialize(Function(Uri) onLink) async {
    _onLink = onLink;

    // Gestisci il link iniziale (app aperta da chiusa)
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        AppLogger.d('🔗 Link iniziale: $initialUri');
        _handleLink(initialUri);
      }
    } catch (e) {
      AppLogger.d('⚠️ Errore recupero link iniziale: $e');
    }

    // Ascolta nuovi link (app già aperta)
    _sub = _appLinks.uriLinkStream.listen((uri) {
      AppLogger.d('🔗 Link ricevuto (app aperta): $uri');
      _handleLink(uri);
    }, onError: (err) {
      AppLogger.d('❌ Errore deep link stream: $err');
    });
  }

  void _handleLink(Uri uri) {
    AppLogger.d('📱 Deep link processato:');
    AppLogger.d('   Scheme: ${uri.scheme}');
    AppLogger.d('   Host: ${uri.host}');
    AppLogger.d('   Path: ${uri.path}');
    AppLogger.d('   Query: ${uri.queryParameters}');
    _onLink?.call(uri);
  }

  /// Pulisce le risorse
  void dispose() {
    _sub?.cancel();
  }
}
