import 'package:flutter/foundation.dart';

/// Logger applicativo centralizzato.
///
/// In release i log NON vengono emessi (guard su [kDebugMode]), così da evitare
/// il leak di dati potenzialmente sensibili (token, OTP, dettagli pagamento)
/// nei log di produzione. In debug usa [debugPrint].
class AppLogger {
  const AppLogger._();

  /// Log informativo (solo in debug).
  static void d(Object? message) {
    if (kDebugMode) debugPrint('$message');
  }

  /// Log di errore (solo in debug). `error`/`stack` opzionali.
  static void e(Object? message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
      if (stack != null) debugPrint('$stack');
    }
  }
}
