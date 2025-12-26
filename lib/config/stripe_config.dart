/// Configurazione Stripe per WeCoop App
/// 
/// IMPORTANTE: Non committare mai chiavi segrete (Secret Key) in questo file!
/// Solo la Publishable Key può essere inclusa nell'app mobile.

class StripeConfig {
  // Publishable Key (sicura da includere nell'app)
  // Test: pk_test_...
  // Live: pk_live_...
  // IMPORTANTE: Inserisci la tua Publishable Key, NON la Secret Key!
  static const String publishableKey = 'pk_test_51SiYvcAJaLsqAD1peNd7cC8x2rhxsScURg2onqqA8wjkCWjmgky7IQgnChUxaUVuLEwKmbJGe177r6eamIL1nbur00bGOc7Lcx';
  
  // Merchant Display Name
  static const String merchantDisplayName = 'WeCoop';
  
  // URL Scheme per deep linking (iOS)
  static const String urlScheme = 'wecoop-app';
  
  // Merchant Identifier (iOS Apple Pay)
  static const String merchantIdentifier = 'merchant.org.wecoop';
  
  // Colore primario per Payment Sheet
  static const int primaryColor = 0xFF00A86B; // Verde WeCoop
  
  /// Indica se siamo in modalità test
  static bool get isTestMode => publishableKey.startsWith('pk_test_');
  
  /// Backend URL per creare Payment Intent
  static const String backendUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
}
