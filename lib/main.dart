import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'services/locale_provider.dart';
import 'services/secure_storage_service.dart';
import 'config/stripe_config.dart';
import 'app.dart';

// Handler per notifiche in background (deve essere top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Notifica ricevuta in background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verifica integrita' secure storage (pulisce se corrotto dopo reinstallazione)
  final storageService = SecureStorageService();
  final isStorageValid = await storageService.checkIntegrity();
  if (!isStorageValid) {
    print('⚠️ Storage corrotto rilevato e pulito automaticamente');
  }
  
  // Inizializza Firebase
  await Firebase.initializeApp();
  
  // Registra background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inizializza Stripe SOLO se la chiave è configurata
  if (StripeConfig.publishableKey.startsWith('pk_test_') || 
      StripeConfig.publishableKey.startsWith('pk_live_')) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
    Stripe.urlScheme = StripeConfig.urlScheme;
    await Stripe.instance.applySettings();
    print('💳 Stripe inizializzato (${StripeConfig.isTestMode ? "TEST MODE" : "LIVE MODE"})');
  } else {
    print('⚠️ Stripe NON inizializzato: Publishable Key non configurata');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const WECOOPApp(),
    ),
  );
}
