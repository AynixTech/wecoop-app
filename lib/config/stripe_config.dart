/// Configurazione Stripe per WeCoop App
///
/// IMPORTANTE: Non committare mai chiavi segrete (Secret Key) in questo file!
/// Solo la Publishable Key può essere inclusa nell'app mobile.
library;

class StripeConfig {
  // Configurazione tramite dart-define per evitare chiavi di test hardcoded.
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Publishable key recuperata a runtime dal backend (wp-config-stripe.php).
  /// Ha priorita' sulla chiave passata via dart-define.
  static String? runtimePublishableKey;

  /// Chiave effettivamente usata: prima il backend, poi il dart-define.
  static String get effectivePublishableKey =>
      (runtimePublishableKey != null && runtimePublishableKey!.isNotEmpty)
          ? runtimePublishableKey!
          : publishableKey;

  // Merchant Display Name
  static const String merchantDisplayName = 'WeCoop';

  // URL Scheme per deep linking (iOS)
  static const String urlScheme = String.fromEnvironment(
    'STRIPE_URL_SCHEME',
    defaultValue: 'wecoop',
  );

  // Merchant Identifier (iOS Apple Pay)
  static const String merchantIdentifier = String.fromEnvironment(
    'STRIPE_MERCHANT_IDENTIFIER',
    defaultValue: 'merchant.org.wecoop',
  );

  // Colore primario per Payment Sheet
  static const int primaryColor = 0xFF00A86B; // Verde WeCoop

  /// Indica se siamo in modalità test
  static bool get isTestMode => effectivePublishableKey.startsWith('pk_test_');

  /// Consente eccezioni esplicite per build release interne.
  static const bool allowTestKeyInRelease = bool.fromEnvironment(
    'ALLOW_TEST_STRIPE_IN_RELEASE',
    defaultValue: false,
  );

  /// Verifica se Stripe è configurato correttamente
  static bool get isConfigured =>
      effectivePublishableKey.startsWith('pk_test_') ||
      effectivePublishableKey.startsWith('pk_live_');

  static bool get canEnablePaymentsInRelease =>
      effectivePublishableKey.startsWith('pk_live_') || allowTestKeyInRelease;

  /// Backend URL per creare Payment Intent
  static const String backendUrl = String.fromEnvironment(
    'STRIPE_BACKEND_URL',
    defaultValue: 'https://www.wecoop.org/wp-json/wecoop/v1',
  );
}
