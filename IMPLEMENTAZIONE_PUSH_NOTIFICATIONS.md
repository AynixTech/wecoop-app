# 📝 Riepilogo Implementazione Push Notifications

## ✅ File Modificati/Creati

### 1. **Nuovo File: `lib/services/push_notification_service.dart`** (320 righe)
Servizio completo per gestione notifiche push:
- ✅ Inizializzazione Firebase Messaging
- ✅ Richiesta permessi notifiche
- ✅ Registrazione e invio FCM token al backend WordPress
- ✅ Gestione notifiche in foreground (con local notifications)
- ✅ Gestione notifiche in background e terminated state
- ✅ Navigazione automatica alle schermate basata su payload
- ✅ Rimozione token dal backend al logout
- ✅ Subscribe/Unsubscribe a topics (opzionale)

### 2. **`pubspec.yaml`**
Aggiunte dipendenze Firebase:
```yaml
# Firebase Push Notifications
firebase_core: ^2.24.0
firebase_messaging: ^14.7.9
flutter_local_notifications: ^16.3.0
```

### 3. **`lib/main.dart`**
- ✅ Import Firebase Core e Messaging
- ✅ Background message handler (`_firebaseMessagingBackgroundHandler`)
- ✅ Inizializzazione Firebase prima di runApp
- ✅ Registrazione background handler

### 4. **`lib/app.dart`**
- ✅ Convertito da StatelessWidget a StatefulWidget
- ✅ Import PushNotificationService
- ✅ Inizializzazione push notifications in initState
- ✅ Configurazione callback per navigazione da notifiche
- ✅ Handler navigazione con switch per diversi tipi di schermata
- ✅ Aggiunto GlobalKey<NavigatorState> per navigazione programmatica
- ✅ NavigatorKey passato a MaterialApp

### 5. **`lib/screens/login/login_screen.dart`**
- ✅ Import PushNotificationService
- ✅ Inizializzazione push notifications dopo login riuscito
- ✅ Salvataggio automatico FCM token su backend
- ✅ Gestione errori non bloccanti (login continua anche se push fail)

### 6. **`lib/screens/profilo/profilo_screen.dart`**
- ✅ Import PushNotificationService
- ✅ Rimozione FCM token dal backend prima del logout
- ✅ Pulizia completa dei dati (incluso fcm_token local)
- ✅ Gestione errori non bloccante (logout continua anche se rimozione token fail)

### 7. **`android/app/build.gradle.kts`**
Aggiunta dipendenza Firebase Messaging:
```kotlin
implementation("com.google.firebase:firebase-messaging-ktx")
```

### 8. **`android/app/src/main/AndroidManifest.xml`**
- ✅ Permesso `POST_NOTIFICATIONS`
- ✅ Firebase Messaging Service configuration
- ✅ Default notification channel metadata

### 9. **`ios/Runner/Info.plist`**
- ✅ UIBackgroundModes con remote-notification
- ✅ FirebaseAppDelegateProxyEnabled = false

### 10. **`ios/Runner/AppDelegate.swift`**
- ✅ Import FirebaseCore e FirebaseMessaging
- ✅ Configurazione Firebase in didFinishLaunchingWithOptions
- ✅ Registrazione UNUserNotificationCenter delegate
- ✅ Handler per APNs token

### 11. **Nuovo File: `PUSH_NOTIFICATIONS_SETUP.md`**
Documentazione completa con:
- ✅ Cosa è stato fatto
- ✅ Setup rimanente (Firebase files, flutterfire configure)
- ✅ Istruzioni testing
- ✅ Checklist finale
- ✅ Esempi payload
- ✅ Troubleshooting

---

## 🎯 Funzionalità Implementate

### Flusso Completo

1. **All'avvio app:**
   - Firebase viene inizializzato
   - Background handler viene registrato

2. **Al login:**
   - Push notifications service viene inizializzato
   - Richiesti permessi notifiche
   - FCM token viene ottenuto
   - FCM token viene inviato al backend WordPress (POST /push/v1/token)
   - Token salvato localmente in FlutterSecureStorage

3. **Ricezione notifiche:**
   - **Foreground:** Mostra local notification + può navigare
   - **Background:** Background handler processa, tap naviga
   - **Terminated:** Initial message handler, tap naviga

4. **Navigazione automatica:**
   - Payload con `screen` e `id` naviga alla schermata corretta
   - Supporta: EventDetail, ServiceDetail, Profile, Notifications
   - Default: Home screen

5. **Al logout:**
   - FCM token viene rimosso dal backend (DELETE /push/v1/token)
   - Token locale viene cancellato
   - Tutti i dati utente vengono puliti

---

## 📊 Schermate Supportate

| Screen | ID Required | Azione |
|--------|-------------|--------|
| `EventDetail` | ✅ Yes | Naviga a dettaglio evento |
| `ServiceDetail` | ✅ Yes | Naviga a dettaglio servizio |
| `Profile` | ❌ No | Naviga al profilo |
| `Notifications` | ❌ No | Naviga a lista notifiche |
| `null` | - | Naviga alla home |

---

## 🔧 API Backend Richieste

### 1. POST `/wp-json/push/v1/token`

Salva FCM token associato all'utente.

**Headers:**
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

**Body:**
```json
{
  "token": "FCM_TOKEN_QUI",
  "device_info": "Flutter App - Android/iOS"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token salvato con successo"
}
```

### 2. DELETE `/wp-json/push/v1/token`

Rimuove FCM token dell'utente.

**Headers:**
```
Authorization: Bearer {jwt_token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token rimosso con successo"
}
```

### 3. Invio Notifiche (Backend → Firebase)

Il backend WordPress dovrebbe usare Firebase Admin SDK per inviare notifiche:

**Payload esempio:**
```json
{
  "token": "FCM_TOKEN_UTENTE",
  "notification": {
    "title": "Nuovo Evento",
    "body": "Workshop WordPress - 30 Dicembre"
  },
  "data": {
    "screen": "EventDetail",
    "id": "456",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": {
    "priority": "high"
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

---

## 🧪 Testing Checklist

- [ ] **Permessi richiesti correttamente** (iOS/Android)
- [ ] **FCM token ottenuto e stampato in console**
- [ ] **Token inviato a backend dopo login** (verifica log backend)
- [ ] **Notifica ricevuta in foreground** (app aperta)
- [ ] **Notifica ricevuta in background** (app in background)
- [ ] **Notifica ricevuta quando app è chiusa** (terminated state)
- [ ] **Tap su notifica naviga a schermata corretta**
- [ ] **Token rimosso dal backend al logout**
- [ ] **Dopo logout, notifiche non arrivano più**

---

## ⚠️ Passi Rimanenti (DA FARE)

### 1. **Configurazione Firebase** (CRITICO)

```bash
# 1. Scarica file da Firebase Console
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# 2. Genera firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure

# 3. Aggiungi import in main.dart
import 'firebase_options.dart';

# 4. Modifica inizializzazione
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 2. **iOS: Configurazione Xcode**

1. Apri `ios/Runner.xcworkspace` in Xcode
2. Seleziona target "Runner"
3. Vai su "Signing & Capabilities"
4. Aggiungi "Push Notifications"
5. Aggiungi "Background Modes" → Seleziona "Remote notifications"

### 3. **Backend WordPress**

Implementare:
- ✅ Endpoint POST `/push/v1/token`
- ✅ Endpoint DELETE `/push/v1/token`
- ✅ Database table per salvare tokens (user_id, token, device_info, created_at)
- ✅ Firebase Admin SDK per invio notifiche
- ✅ Cron job o hook per notifiche automatiche:
  - Nuovo evento pubblicato
  - Reminder eventi (1h prima, 24h prima)
  - Conferma iscrizione evento
  - Richiesta socio approvata
  - Quota in scadenza
  - Richiesta servizio evasa/rifiutata

---

## 📱 Esempio Utilizzo

### Invia Notifica da Backend

```php
<?php
// WordPress - Esempio invio notifica

use Firebase\JWT\JWT;
use Google\Cloud\Firestore\FirestoreClient;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

function send_push_notification($user_id, $title, $body, $screen = null, $id = null) {
    global $wpdb;
    
    // Recupera FCM token dell'utente
    $token = $wpdb->get_var($wpdb->prepare(
        "SELECT token FROM {$wpdb->prefix}wecoop_push_tokens WHERE user_id = %d LIMIT 1",
        $user_id
    ));
    
    if (!$token) {
        return new WP_Error('no_token', 'FCM token non trovato per questo utente');
    }
    
    // Inizializza Firebase Admin SDK
    $factory = (new Factory)->withServiceAccount(__DIR__ . '/firebase-credentials.json');
    $messaging = $factory->createMessaging();
    
    // Prepara payload
    $data = ['click_action' => 'FLUTTER_NOTIFICATION_CLICK'];
    if ($screen) $data['screen'] = $screen;
    if ($id) $data['id'] = (string) $id;
    
    $message = CloudMessage::withTarget('token', $token)
        ->withNotification(Notification::create($title, $body))
        ->withData($data)
        ->withAndroidConfig([
            'priority' => 'high',
        ])
        ->withApnsConfig([
            'payload' => [
                'aps' => [
                    'sound' => 'default',
                    'badge' => 1,
                ],
            ],
        ]);
    
    // Invia
    try {
        $result = $messaging->send($message);
        error_log("✅ Notifica inviata: {$result}");
        return true;
    } catch (Exception $e) {
        error_log("❌ Errore invio notifica: " . $e->getMessage());
        return new WP_Error('send_failed', $e->getMessage());
    }
}

// Esempio: Notifica per nuovo evento
add_action('publish_evento', function($post_id, $post) {
    $evento_id = $post_id;
    $evento_title = get_the_title($post_id);
    
    // Invia a tutti i soci iscritti alla categoria dell'evento
    $users = get_users(['role' => 'socio']);
    
    foreach ($users as $user) {
        send_push_notification(
            $user->ID,
            'Nuovo Evento',
            $evento_title,
            'EventDetail',
            $evento_id
        );
    }
}, 10, 2);
?>
```

---

## 🎉 Risultato Finale

L'app WeCoop ora ha:
- ✅ Sistema completo di push notifications
- ✅ Integrazione Firebase pronta
- ✅ Navigazione automatica da notifiche
- ✅ Gestione lifecycle completa (foreground/background/terminated)
- ✅ Cleanup al logout
- ✅ Supporto Android e iOS
- ✅ Documentazione completa

**Manca solo:**
- File di configurazione Firebase (`google-services.json`, `GoogleService-Info.plist`)
- Generazione `firebase_options.dart`
- Implementazione backend WordPress

---

**Data:** 23 Dicembre 2025  
**Versione:** 1.0.0  
**Stato:** ✅ Implementazione frontend COMPLETA
