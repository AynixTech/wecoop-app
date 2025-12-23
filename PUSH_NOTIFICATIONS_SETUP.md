# 📱 Push Notifications Setup - WeCoop App

## ✅ Implementazione Completata

Il codice per le notifiche push Firebase è stato completamente integrato nell'app WeCoop.

---

## 🎯 Cosa è Stato Fatto

### 1. **Dipendenze Aggiunte** (`pubspec.yaml`)
- ✅ `firebase_core: ^2.24.0`
- ✅ `firebase_messaging: ^14.7.9`
- ✅ `flutter_local_notifications: ^16.3.0`

### 2. **Servizio Push Creato**
- ✅ `lib/services/push_notification_service.dart`
  - Gestione permessi notifiche
  - Registrazione FCM token
  - Invio token al backend WordPress
  - Handler per notifiche in foreground/background/terminated
  - Navigazione automatica alle schermate
  - Rimozione token al logout

### 3. **Integrazione Main App**
- ✅ `lib/main.dart`
  - Inizializzazione Firebase
  - Background message handler
  
- ✅ `lib/app.dart`
  - Inizializzazione push notifications all'avvio
  - NavigatorKey per navigazione da notifiche
  - Gestione navigazione alle schermate

### 4. **Login/Logout**
- ✅ `lib/screens/login/login_screen.dart`
  - Inizializza push notifications dopo login
  - Salva FCM token automaticamente
  
- ✅ `lib/screens/profilo/profilo_screen.dart`
  - Rimuove FCM token dal backend al logout
  - Pulizia completa dei dati

### 5. **Configurazione Android**
- ✅ `android/app/build.gradle.kts`
  - Aggiunta dipendenza `firebase-messaging-ktx`
  
- ✅ `android/app/src/main/AndroidManifest.xml`
  - Permesso `POST_NOTIFICATIONS`
  - Firebase Messaging Service
  - Default notification channel

### 6. **Configurazione iOS**
- ✅ `ios/Runner/Info.plist`
  - UIBackgroundModes per remote-notification
  - FirebaseAppDelegateProxyEnabled
  
- ✅ `ios/Runner/AppDelegate.swift`
  - Configurazione Firebase
  - Registrazione APNs token

---

## 🚀 Setup Rimanente

### 1. **Configurazione Firebase** (IMPORTANTE!)

#### A. Scarica File di Configurazione

1. Vai su [Firebase Console](https://console.firebase.google.com/)
2. Seleziona il progetto WeCoop (o creane uno nuovo)
3. Scarica i file di configurazione:

**Android:**
- Vai su Project Settings → General → Your apps
- Scarica `google-services.json`
- Posizionalo in: `android/app/google-services.json`

**iOS:**
- Vai su Project Settings → General → Your apps
- Scarica `GoogleService-Info.plist`
- Posizionalo in: `ios/Runner/GoogleService-Info.plist`

#### B. Configura APNs per iOS

1. In Firebase Console → Project Settings → Cloud Messaging
2. Carica il tuo APNs Authentication Key o Certificate
3. Abilita Push Notifications in Xcode:
   - Apri `ios/Runner.xcworkspace` in Xcode
   - Seleziona il target Runner
   - Vai su "Signing & Capabilities"
   - Clicca "+" → Aggiungi "Push Notifications"
   - Clicca "+" → Aggiungi "Background Modes" → Seleziona "Remote notifications"

### 2. **Genera `firebase_options.dart`**

Installa FlutterFire CLI e genera il file di configurazione:

```bash
# Installa FlutterFire CLI
dart pub global activate flutterfire_cli

# Genera firebase_options.dart
flutterfire configure
```

Questo creerà automaticamente `lib/firebase_options.dart` con le configurazioni per Android e iOS.

### 3. **Aggiorna `main.dart`**

Aggiungi l'import del file generato:

```dart
import 'firebase_options.dart'; // Aggiungi questa riga

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Firebase con le opzioni specifiche della piattaforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Usa le opzioni generate
  );
  
  // ... resto del codice
}
```

### 4. **Installa Dipendenze**

```bash
flutter clean
flutter pub get
```

### 5. **Backend WordPress**

Assicurati che il backend WordPress abbia implementato:

- ✅ Endpoint `POST /wp-json/push/v1/token`
  - Salva FCM token nel database
  - Associa token all'utente autenticato (JWT)
  
- ✅ Endpoint `DELETE /wp-json/push/v1/token`
  - Rimuove FCM token dal database

- ✅ Invio notifiche push tramite Firebase Admin SDK
  - Notifiche per eventi (nuovo, reminder, conferma iscrizione)
  - Notifiche per soci (approvazione, scadenza quota)
  - Notifiche per servizi (richiesta evasa/rifiutata)

**Payload esempio:**
```json
{
  "notification": {
    "title": "Nuovo Evento",
    "body": "Workshop WordPress - 30 Dicembre"
  },
  "data": {
    "screen": "EventDetail",
    "id": "123",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

---

## 🎬 Testing

### Test Locale

1. **Avvia l'app:**
```bash
flutter run
```

2. **Fai login:**
   - L'app richiederà i permessi per le notifiche
   - Controlla il log per vedere il FCM token:
     ```
     📱 FCM Token: AbCdEf123456...
     ✅ FCM token salvato su backend
     ```

3. **Test notifica:**
   - Da WordPress admin → Push Notifications
   - Invia una notifica test all'utente loggato
   - L'app dovrebbe riceverla e navigare alla schermata corretta

### Debug

Se le notifiche non arrivano, controlla:

1. **FCM Token salvato:**
```dart
final fcmToken = await storage.read(key: 'fcm_token');
print('FCM Token: $fcmToken');
```

2. **JWT Token presente:**
```dart
final jwtToken = await storage.read(key: 'jwt_token');
print('JWT: ${jwtToken != null ? "✅" : "❌"}');
```

3. **Log Firebase:**
```bash
# Android
flutter run --verbose

# iOS
Xcode → Product → Scheme → Edit Scheme → Arguments → -FIRDebugEnabled
```

4. **Test diretto FCM:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_FIREBASE_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_QUI",
    "notification": {
      "title": "Test",
      "body": "Notifica di test"
    },
    "data": {
      "screen": "Profile"
    }
  }'
```

---

## 📋 Checklist Finale

- [ ] File Firebase scaricati e posizionati:
  - [ ] `android/app/google-services.json`
  - [ ] `ios/Runner/GoogleService-Info.plist`
- [ ] `firebase_options.dart` generato con `flutterfire configure`
- [ ] Import di `firebase_options.dart` aggiunto in `main.dart`
- [ ] APNs configurato su Firebase Console (solo iOS)
- [ ] Push Notifications capability aggiunta in Xcode (solo iOS)
- [ ] `flutter pub get` eseguito
- [ ] Backend WordPress con endpoint `/push/v1/token` funzionante
- [ ] Test login → FCM token salvato
- [ ] Test notifica → App riceve e naviga correttamente
- [ ] Test logout → FCM token rimosso

---

## 🔔 Schermate Disponibili per Navigazione

Le notifiche possono navigare alle seguenti schermate:

| Screen | Parametri | Descrizione |
|--------|-----------|-------------|
| `EventDetail` | `id` (required) | Dettaglio evento |
| `ServiceDetail` | `id` (required) | Dettaglio servizio |
| `Profile` | - | Profilo utente |
| `Notifications` | - | Lista notifiche |
| Nessuno | - | Home (default) |

**Esempio payload WordPress:**
```php
$payload = [
    'notification' => [
        'title' => 'Nuovo Evento',
        'body' => 'Workshop WordPress - 30 Dicembre',
    ],
    'data' => [
        'screen' => 'EventDetail',
        'id' => '456',
    ],
];
```

---

## 📚 Risorse

- [Firebase Messaging Flutter](https://firebase.flutter.dev/docs/messaging/overview/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firebase Console](https://console.firebase.google.com/)
- [APNs Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)

---

## ⚠️ Note Importanti

1. **iOS richiede dispositivo reale** per testare le notifiche push (non funzionano su simulatore)
2. **Android richiede Google Play Services** installati
3. **Backend deve validare JWT token** prima di salvare FCM token
4. **Rate limiting consigliato** per evitare spam di notifiche
5. **Cache FCM token per 60 giorni** se possibile

---

**Versione:** 1.0.0  
**Data:** 23 Dicembre 2025  
**Compatibilità:** Flutter 3.16+, Firebase Messaging 14.7+
