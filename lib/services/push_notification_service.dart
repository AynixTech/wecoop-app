import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';

/// Servizio per gestire le notifiche push Firebase
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SecureStorageService _storage = SecureStorageService();

  // Callback per navigazione
  Function(RemoteMessage)? onMessageTap;

  // URL API WordPress
  static const String apiUrl = 'https://www.wecoop.org/wp-json';

  /// Inizializza il servizio push
  Future<void> initialize() async {
    // Richiedi permessi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permessi notifiche concessi');

      // Inizializza local notifications
      await _initializeLocalNotifications();

      // Ottieni FCM token
      await _getFCMToken();

      // Configura handlers
      _configureMessageHandlers();
    } else {
      print('❌ Permessi notifiche negati');
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
        print('📱 FCM Token: ${token.substring(0, 20)}...');

        // Salva token localmente
        await _storage.write(key: 'fcm_token', value: token);

        // Invia token al backend WordPress
        await _sendTokenToBackend(token);

        // Listener per refresh token
        _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
      }
    } catch (e) {
      print('❌ Errore ottenimento FCM token: $e');
    }
  }

  /// Invia token FCM al backend WordPress
  Future<void> _sendTokenToBackend(String token) async {
    try {
      print('🔄 Inizio invio FCM token al backend...');

      // Recupera JWT token
      final jwtToken = await _storage.read(key: 'jwt_token');

      if (jwtToken == null) {
        print('⚠️ JWT token non trovato, impossibile salvare FCM token');
        print('💡 Verifica che il login sia stato completato correttamente');
        return;
      }

      print('✅ JWT token trovato: ${jwtToken.substring(0, 20)}...');

      // Ottieni info dispositivo
      final deviceInfo = await _getDeviceInfo();

      final url = Uri.parse('$apiUrl/push/v1/token');
      print('📡 POST $url');
      print(
        '📝 Headers: Authorization: Bearer ${jwtToken.substring(0, 20)}...',
      );
      print(
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

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ FCM token salvato su backend: ${data['message']}');
      } else if (response.statusCode == 401) {
        print('❌ Errore 401: JWT token non valido o scaduto');
        print('💡 L\'utente deve rifare il login');
      } else if (response.statusCode == 404) {
        print('❌ Errore 404: Endpoint /push/v1/token non trovato');
        print('💡 Verifica che il plugin WordPress sia attivo');
      } else {
        print('❌ Errore salvataggio token: ${response.statusCode}');
        print('📄 Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Errore invio token a backend: $e');
      print(
        '💡 Verifica connessione internet e che il server sia raggiungibile',
      );
    }
  }

  /// Ottieni informazioni dispositivo
  Future<String> _getDeviceInfo() async {
    // Usa package device_info_plus per ottenere info reali
    // Per ora placeholder
    return 'Flutter App - Android/iOS';
  }

  /// Configura handlers per messaggi Firebase
  void _configureMessageHandlers() {
    // App in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Notifica ricevuta in foreground');
      _showLocalNotification(message);
    });

    // App aperta da notifica (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 App aperta da notifica');
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
      print('📬 App aperta da notifica (terminated)');
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
    print('👆 Tap su notifica: $data');

    if (onMessageTap != null) {
      onMessageTap!(RemoteMessage(data: data));
    } else {
      // Navigazione diretta se callback non settato
      _navigateToScreen(data);
    }
  }

  /// Naviga alla schermata specificata
  void _navigateToScreen(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    final id = data['id'] as String?;

    if (screen == null) return;

    // Implementa navigazione in base al tuo router
    switch (screen) {
      case 'EventDetail':
        if (id != null) {
          // Navigator.push o router.go a EventDetailPage
          print('🔄 Navigazione a EventDetail: $id');
        }
        break;

      case 'ServiceDetail':
        if (id != null) {
          print('🔄 Navigazione a ServiceDetail: $id');
        }
        break;

      case 'Profile':
        print('🔄 Navigazione a Profile');
        break;

      case 'Notifications':
        print('🔄 Navigazione a Notifications');
        break;

      default:
        print('🔄 Schermata sconosciuta: $screen');
    }
  }

  /// Rimuovi token FCM dal backend (logout)
  Future<void> removeToken() async {
    try {
      final jwtToken = await _storage.read(key: 'jwt_token');

      if (jwtToken == null) return;

      final response = await HttpClientService.delete(
        Uri.parse('$apiUrl/push/v1/token'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        print('✅ FCM token rimosso da backend');
        await _storage.delete(key: 'fcm_token');
      }
    } catch (e) {
      print('❌ Errore rimozione token: $e');
    }
  }

  /// Subscribe a topic (opzionale)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('📢 Iscritto al topic: $topic');
  }

  /// Unsubscribe da topic (opzionale)
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('🔕 Disiscritto dal topic: $topic');
  }
}
