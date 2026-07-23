import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'services/locale_provider.dart';
import 'services/secure_storage_service.dart';
import 'services/firma_digitale_provider.dart';
import 'config/stripe_config.dart';
import 'app.dart';

// Handler per notifiche in background (deve essere top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    debugPrint('Notifica ricevuta in background: ${message.messageId}');
  } catch (error) {
    debugPrint('Firebase background non inizializzato: $error');
  }
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (error) {
    debugPrint(
      'Firebase non configurato completamente. L\'app continua senza notifiche push: $error',
    );
  }
}

Future<void> _initializeStripe() async {
  final isReleaseMode = const bool.fromEnvironment('dart.vm.product');

  if (!StripeConfig.isConfigured) {
    debugPrint('Stripe non inizializzato: chiave publishable assente');
    return;
  }

  if (isReleaseMode && !StripeConfig.canEnablePaymentsInRelease) {
    debugPrint('Stripe disabilitato in release: configura una chiave live');
    return;
  }

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
  Stripe.urlScheme = StripeConfig.urlScheme;
  await Stripe.instance.applySettings();
  debugPrint(
    'Stripe inizializzato (${StripeConfig.isTestMode ? "TEST MODE" : "LIVE MODE"})',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica integrita' secure storage (pulisce se corrotto dopo reinstallazione)
  final storageService = SecureStorageService();
  final isStorageValid = await storageService.checkIntegrity();
  if (!isStorageValid) {
    debugPrint('Storage corrotto rilevato e pulito automaticamente');
  }

  // Inizializza Firebase senza bloccare l'avvio se manca la configurazione nativa.
  await _initializeFirebase();

  if (Firebase.apps.isNotEmpty) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await _initializeStripe();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FirmaDigitaleProvider()),
      ],
      child: const WECOOPApp(),
    ),
  );
}
