import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import '../config/api_config.dart';

/// Servizio per gestire le notifiche push Firebase
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SecureStorageService _storage = SecureStorageService();

  // Callback per navigazione
  Function(RemoteMessage)? onMessageTap;

  /// NavigatorKey globale per la navigazione dal tap sulle notifiche
  /// (impostato una volta all'avvio dell'app).
  static GlobalKey<NavigatorState>? navigatorKey;

  // URL API backend Node
  static const String apiUrl = ApiConfig.baseUrl;

  /// Inizializza il servizio push
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('Push notifications disabilitate: Firebase non disponibile');
      return;
    }

    // Richiedi permessi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.d('✅ Permessi notifiche concessi');

      // Inizializza local notifications
      await _initializeLocalNotifications();

      // Ottieni FCM token
      await _getFCMToken();

      // Configura handlers
      _configureMessageHandlers();
    } else {
      AppLogger.d('❌ Permessi notifiche negati');
    }
  }

  /// Inizializza local notifications per foreground
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gestisci tap su notifica locale
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          _handleNotificationTap(data);
        }
      },
    );
  }

  /// Ottieni e salva FCM token
  Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        AppLogger.d('📱 FCM Token: ${token.substring(0, 20)}...');

        // Salva token localmente
        await _storage.write(key: 'fcm_token', value: token);

        // Invia token al backend WordPress
        await _sendTokenToBackend(token);

        // Listener per refresh token
        _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
      }
    } catch (e) {
      AppLogger.d('❌ Errore ottenimento FCM token: $e');
    }
  }

  /// Invia token FCM al backend WordPress
  Future<void> _sendTokenToBackend(String token) async {
    try {
      AppLogger.d('🔄 Inizio invio FCM token al backend...');

      // Recupera JWT token
      final jwtToken = await _storage.read(key: 'jwt_token');

      if (jwtToken == null) {
        AppLogger.d('⚠️ JWT token non trovato, impossibile salvare FCM token');
        AppLogger.d('💡 Verifica che il login sia stato completato correttamente');
        return;
      }

      AppLogger.d('✅ JWT token trovato: ${jwtToken.substring(0, 20)}...');

      // Ottieni info dispositivo
      final deviceInfo = await _getDeviceInfo();

      final url = Uri.parse('$apiUrl/push/token');
      AppLogger.d('📡 POST $url');
      AppLogger.d(
        '📝 Headers: Authorization: Bearer ${jwtToken.substring(0, 20)}...',
      );
      AppLogger.d(
        '📝 Body: {"token": "${token.substring(0, 20)}...", "device_info": "$deviceInfo"}',
      );

      final response = await HttpClientService.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'token': token, 'device_info': deviceInfo}),
      );

      AppLogger.d('📥 Response Status: ${response.statusCode}');
      AppLogger.d('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AppLogger.d('✅ FCM token salvato su backend: ${data['message']}');
      } else if (response.statusCode == 401) {
        AppLogger.d('❌ Errore 401: JWT token non valido o scaduto');
        AppLogger.d('💡 L\'utente deve rifare il login');
      } else if (response.statusCode == 404) {
        AppLogger.d('❌ Errore 404: Endpoint /push/token non trovato');
        AppLogger.d('💡 Verifica che il plugin WordPress sia attivo');
      } else {
        AppLogger.d('❌ Errore salvataggio token: ${response.statusCode}');
        AppLogger.d('📄 Response: ${response.body}');
      }
    } catch (e) {
      AppLogger.d('❌ Errore invio token a backend: $e');
      AppLogger.d(
        '💡 Verifica connessione internet e che il server sia raggiungibile',
      );
    }
  }

  /// Ottieni informazioni dispositivo reali (device_info_plus).
  Future<String> _getDeviceInfo() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model} · Android ${a.version.release} (SDK ${a.version.sdkInt})';
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return '${i.name} · ${i.model} · iOS ${i.systemVersion}';
      }
      return 'Flutter App';
    } catch (e) {
      AppLogger.e('device info errore', e);
      return 'Flutter App';
    }
  }

  /// Configura handlers per messaggi Firebase
  void _configureMessageHandlers() {
    // App in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.d('📬 Notifica ricevuta in foreground');
      _showLocalNotification(message);
    });

    // App aperta da notifica (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d('📬 App aperta da notifica');
      _handleNotificationTap(message.data);
    });

    // App aperta da stato terminated
    _checkInitialMessage();
  }

  /// Controlla se app aperta da notifica quando era terminated
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      AppLogger.d('📬 App aperta da notifica (terminated)');
      _handleNotificationTap(initialMessage.data);
    }
  }

  /// Mostra notifica locale (foreground)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'wecoop_channel',
            'WeCoop Notifications',
            channelDescription: 'Notifiche dalla piattaforma WeCoop',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: json.encode(data),
      );
    }
  }

  /// Gestisci tap su notifica
  void _handleNotificationTap(Map<String, dynamic> data) {
    AppLogger.d('👆 Tap su notifica: $data');

    if (onMessageTap != null) {
      onMessageTap!(RemoteMessage(data: data));
    } else {
      // Navigazione diretta se callback non settato
      _navigateToScreen(data);
    }
  }

  /// Naviga alla schermata specificata dal payload della notifica.
  void _navigateToScreen(Map<String, dynamic> data) {
    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      AppLogger.d('🔄 navigatorKey non disponibile, navigazione ignorata');
      return;
    }

    final screen = (data['screen'] ?? data['type'] ?? '').toString();
    switch (screen) {
      case 'appuntamento':
      case 'calendar':
        navigator.pushNamed('/calendar');
        break;
      default:
        // Le altre sezioni (eventi, richieste, profilo) sono tab dentro la
        // MainScreen: portiamo alla home come punto d'ingresso sicuro.
        navigator.pushNamed('/home');
    }
  }

  /// Rimuovi token FCM dal backend (logout)
  Future<void> removeToken() async {
    try {
      final jwtToken = await _storage.read(key: 'jwt_token');

      if (jwtToken == null) return;

      final response = await HttpClientService.delete(
        Uri.parse('$apiUrl/push/token'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        AppLogger.d('✅ FCM token rimosso da backend');
        await _storage.delete(key: 'fcm_token');
      }
    } catch (e) {
      AppLogger.d('❌ Errore rimozione token: $e');
    }
  }

  /// Subscribe a topic (opzionale)
  Future<void> subscribeToTopic(String topic) async {
    if (Firebase.apps.isEmpty) return;
    await _firebaseMessaging.subscribeToTopic(topic);
    AppLogger.d('📢 Iscritto al topic: $topic');
  }

  /// Unsubscribe da topic (opzionale)
  Future<void> unsubscribeFromTopic(String topic) async {
    if (Firebase.apps.isEmpty) return;
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    AppLogger.d('🔕 Disiscritto dal topic: $topic');
  }
}
