# 🚀 Quick Start - Push Notifications

## ⚡ Setup Rapido (5 minuti)

### 1. Scarica File Firebase

**Android:**
```
Firebase Console → Project Settings → Your apps → Android app
Scarica: google-services.json
Posiziona: android/app/google-services.json
```

**iOS:**
```
Firebase Console → Project Settings → Your apps → iOS app
Scarica: GoogleService-Info.plist
Posiziona: ios/Runner/GoogleService-Info.plist
```

### 2. Genera Configurazione

```bash
# Installa FlutterFire CLI (solo prima volta)
dart pub global activate flutterfire_cli

# Genera firebase_options.dart
flutterfire configure
```

### 3. Aggiorna main.dart

Aggiungi dopo le altre import:
```dart
import 'firebase_options.dart';
```

Modifica inizializzazione Firebase (riga ~17):
```dart
// Da:
await Firebase.initializeApp();

// A:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Test!

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 Checklist Veloce

- [ ] File Firebase scaricati e posizionati
- [ ] `flutterfire configure` eseguito
- [ ] Import `firebase_options.dart` aggiunto in main.dart
- [ ] Modifica `Firebase.initializeApp()` con options
- [ ] (iOS) Capabilities aggiunte in Xcode
- [ ] Test login → Vedi "📱 FCM Token: ..." in console
- [ ] Backend endpoint `/push/v1/token` funzionante

---

## 🧪 Test Rapido

### Verifica FCM Token

Dopo il login, controlla console per:
```
📱 FCM Token: AbCdEf123456...
✅ FCM token salvato su backend
```

### Invia Notifica Test

Da Firebase Console:
1. Vai su **Cloud Messaging**
2. Click **Send your first message**
3. Inserisci titolo e testo
4. Click **Send test message**
5. Incolla FCM token (copiato da console)
6. Click **Test**

### Verifica Navigazione

Payload notifica con navigazione:
```json
{
  "notification": {
    "title": "Test Navigazione",
    "body": "Tap per andare al profilo"
  },
  "data": {
    "screen": "Profile"
  }
}
```

---

## ❌ Troubleshooting

### Token non salvato

```dart
// Verifica in profilo_screen.dart
final fcmToken = await storage.read(key: 'fcm_token');
print('FCM Token salvato: ${fcmToken != null ? "SÌ" : "NO"}');
```

### Notifiche non arrivano

1. Controlla permessi: Settings → App → WeCoop → Notifications
2. Verifica Firebase Server Key in WordPress
3. Test diretto con curl:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_FIREBASE_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_QUI",
    "notification": {"title": "Test", "body": "Funziona!"}
  }'
```

### iOS: Notifiche non funzionano

1. Xcode → Runner → Signing & Capabilities
2. Aggiungi "Push Notifications"
3. Aggiungi "Background Modes" → Remote notifications
4. Firebase Console → Cloud Messaging → Upload APNs key

---

## 📚 Documenti Completi

- `PUSH_NOTIFICATIONS_SETUP.md` - Setup completo
- `IMPLEMENTAZIONE_PUSH_NOTIFICATIONS.md` - Riepilogo implementazione

---

## 🎯 Endpoint Backend Richiesti

```
POST /wp-json/push/v1/token
DELETE /wp-json/push/v1/token
```

Vedi documentazione completa per esempi payload.

---

**Hai bisogno di aiuto?** Consulta `PUSH_NOTIFICATIONS_SETUP.md` per istruzioni dettagliate.
