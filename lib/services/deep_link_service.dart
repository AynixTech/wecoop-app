import 'dart:async';
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
        print('🔗 Link iniziale: $initialUri');
        _handleLink(initialUri);
      }
    } catch (e) {
      print('⚠️ Errore recupero link iniziale: $e');
    }

    // Ascolta nuovi link (app già aperta)
    _sub = _appLinks.uriLinkStream.listen((uri) {
      print('🔗 Link ricevuto (app aperta): $uri');
      _handleLink(uri);
    }, onError: (err) {
      print('❌ Errore deep link stream: $err');
    });
  }

  void _handleLink(Uri uri) {
    print('📱 Deep link processato:');
    print('   Scheme: ${uri.scheme}');
    print('   Host: ${uri.host}');
    print('   Path: ${uri.path}');
    print('   Query: ${uri.queryParameters}');
    _onLink?.call(uri);
  }

  /// Pulisce le risorse
  void dispose() {
    _sub?.cancel();
  }
}
