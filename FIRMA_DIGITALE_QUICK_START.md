# 🔐 Firma Digitale - Guida Produzione

## ✅ PRONTO ALL'USO - Basta Integrare!

## 🚀 Integrazione Rapida (3 STEP)

### STEP 1: Importa la schermata 

```dart
import 'package:wecoop_app/screens/firma_digitale/richiesta_dettagli_screen.dart';
```

### STEP 2: Aggiungi route in `app.dart`

Nel `MaterialApp`, aggiungi la route:

```dart
routes: {
  '/richiesta-dettagli': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return RichiestaDettagliScreen(
      richiestaId: args['richiestaId'] as int,
      titolo: args['titolo'] as String,
      descrizione: args['descrizione'] as String,
      stato: args['stato'] as String,
    );
  },
},
```

### STEP 3: Nomina quando l'utente clicca

```dart
Navigator.pushNamed(
  context,
  '/richiesta-dettagli',
  arguments: {
    'richiestaId': 123,
    'titolo': 'Compilazione 730',
    'descrizione': 'Compilazione modulo 730',
    'stato': 'pending_firma',  // o 'firmato', 'rifiutato'
  },
);
```

## 📱 Come Funziona?

Quando l'utente clicca **"Firma Documento"**:

```
1. Scarica il PDF dal server
2. Lo mostra all'utente
3. Chiede l'OTP via SMS
4. L'utente inserisce il codice
5. Verifica il codice
6. Firma il documento
7. Mostra conferma: "✅ Documento Firmato"
```

## 📋 Cosa Serve

L'utente deve avere nel **secure storage**:

```dart
// Salva al login
await SecureStorageService().write(key: 'user_phone', value: '+39 334 123 4567');
await SecureStorageService().write(key: 'user_id', value: '456');
await SecureStorageService().write(key: 'jwt_token', value: 'token_here');
```

Questi dati la schermata li legge **automaticamente**.

## 📦 Dipendenze (Già Installate)

```yaml
webview_flutter: ^4.4.2      # Mostra PDF
device_info_plus: ^9.0.1     # Info dispositivo
```

Eseguito: `flutter pub get` ✅

## ❌ Se Qualcosa Non Funziona

| Problema | Soluzione |
|----------|-----------|
| "Dati utente non disponibili" | Salva `user_phone` e `user_id` al login |
| "401 Unauthorized" | JWT token scaduto? Fai nuovo login |
| "Hash Mismatch" | Il PDF deve essere lo stesso scaricato |
| "OTP Generico Errato" | Solo 3 tentativi. Attendi 1 hour per nuovo OTP |
| "SMS non arriva" | Backend invia SMS. Controlla il numero |

## 🛠️ File Creati

```
lib/
├── models/
│   └── firma_digitale_models.dart
├── services/
│   ├── firma_digitale_service.dart
│   └── firma_digitale_provider.dart
├── screens/firma_digitale/
│   └── richiesta_dettagli_screen.dart        ← USA QUESTA!
│   └── firma_documento_screen.dart          (Orchestratore interno)
└── widgets/firma_digitale/
    └── (Componenti UI interne)
```

## 🔒 Sicurezza

✅ JWT Token in Keychain (iOS) / Keystore (Android)
✅ HTTPS Only
✅ Hash SHA-256 verificato
✅ OTP valido 5 minuti
✅ Max 3 tentativi OTP, poi 1 hour wait
✅ FES (Firma Elettronica Semplice) vs FEA

## 🎯 Sintesi

**Basta:**

1. Importare `RichiestaDettagliScreen`
2. Aggiungere la route
3. Navigare con i dati richiesta
4. L'app fa tutto il resto! ✅

---

**Pronto per la produzione!** 🚀
