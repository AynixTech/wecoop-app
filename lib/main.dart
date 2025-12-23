import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/locale_provider.dart';
import 'app.dart';

// Handler per notifiche in background (deve essere top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Notifica ricevuta in background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Firebase
  await Firebase.initializeApp();
  
  // Registra background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const WECOOPApp(),
    ),
  );
}
