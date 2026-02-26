# � Firma Digitale - Guida di Produzione

## ✅ PRONTO ALL'USO - Basta Integrare!

## � Integrazione Rapida (3 STEP)

### STEP 1: Importa la schermata where devi usarla 

```dart
import 'package:wecoop_app/screens/firma_digitale/richiesta_dettagli_screen.dart';
```

### STEP 2: Crea una nuova route in `app.dart`

```dart
routes: {
  '/richiesta-dettagli': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return RichiestaDettagliScreen(
      richiestaId: args['richiestaId'] as int,
      titolo: args['titolo'] as String,
      descrizione: args['descrizione'] as String,
      stato: args['stato'] as String, // 'pending_firma', 'firmato', 'rifiutato'
    );
  },
},
```

### STEP 3: Naviga quando l'utente clicca su una richiesta

```dart
Navigator.pushNamed(
  context,
  '/richiesta-dettagli',
  arguments: {
    'richiestaId': 123,
    'titolo': 'Compilazione 730',
    'descrizione': 'Compilazione modulo 730',
    'stato': 'pending_firma',  // oppure 'firmato', 'rifiutato'
  },
);
```

## 📱 Cosa Fa Quando Clicca "Firma Documento"?

Il flow automatico di firma:

```
1️⃣ Scarica il PDF dal server
   ↓
2️⃣ Mostra il PDF all'utente
   ↓
3️⃣ Richiede di inviargli OTP via SMS
   ↓
4️⃣ L'utente inserisce il codice ricevuto
   ↓
5️⃣ Verifica il codice
   ↓
6️⃣ Firma il documento
   ↓
7️⃣ Mostra "Documento Firmato ✅"
```

## 📦 Dipendenze Aggiunte

Il `pubspec.yaml` è stato aggiornato con:

```yaml
# Firma Digitale
webview_flutter: ^4.4.2      # Visualizzazione PDF
device_info_plus: ^9.0.1     # Info dispositivo
```

Esegui `flutter pub get` per installare i package.

## 🔌 API Endpoints

Tutti gli endpoint usano la base URL:
```
https://www.wecoop.org/wp-json/wecoop/v1
```

### Autenticazione

Tutti gli endpoint richiedono il Bearer JWT token nel header:
```
Authorization: Bearer {jwt_token}
```

Il token è automaticamente gestito da `FirmaDigitaleService` leggendo da `SecureStorageService`.

### Endpoint Utilizzati

| Metodo | Endpoint | Scopo |
|--------|----------|-------|
| GET | `/documento-unico/{id}/send` | Scarica PDF + hash |
| POST | `/firma-digitale/otp/generate` | Genera e invia OTP |
| POST | `/firma-digitale/otp/verify` | Verifica codice OTP |
| POST | `/firma-digitale/sign` | Crea firma digitale |
| GET | `/firma-digitale/status/{id}` | Status firma |
| GET | `/firma-digitale/verifica/{id}` | Verifica integrità |

## 🎨 Personalizzazione

### Cambiare il Colore Principale

Modifica `lib/app.dart` nel `ThemeData`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,  // Cambia qui
  ...
),
```

### Aggiungere Supporto per Altre Lingue

I widget usano le localizzazioni da `AppLocalizations`. Se vuoi tradurre i testi, modifica `lib/l10n/` o usa direttamente i string.

## ⚙️ Configurazione Platform-Specific

### iOS (Flutter WebView)

Aggiungi in `ios/Runner/Info.plist`:

```xml
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
    <string>_https._tcp</string>
</array>
```

### Android (Flutter WebView)

Aggiungi in `android/app/build.gradle`:

```gradle
android {
    compileSdk 34  // O più recente
    ...
}
```

## 🧪 Testing Locale

### Opzione 1: Mock Provider

Crea un test provider per sviluppo senza backend reale:

```dart
class MockFirmaDigitaleProvider extends FirmaDigitaleProvider {
  @override
  Future<void> scaricaDocumento() async {
    _documento = DocumentoUnico(
      url: 'https://example.com/dummy.pdf',
      contenutoTesto: 'Testo dummy',
      hashSha256: 'abc123...',
      nome: 'documento_test.pdf',
      dataGenerazione: DateTime.now(),
    );
    _step = FirmaStep.documentoCaricato;
    notifyListeners();
  }
}
```

### Opzione 2: Usare Postman

Testa gli endpoint direttamente con Postman:

1. Ottieni token JWT:
   ```
   POST https://wecoop.org/wp-json/jwt-auth/v1/token
   Body: {"username": "...", "password": "..."}
   ```

2. Copia il token nella risposta

3. Testa ogni endpoint aggiungendo header:
   ```
   Authorization: Bearer {token}
   ```

## ❌ Troubleshooting

### Errore: `webview_flutter` non trovato

```bash
flutter pub get
flutter clean
flutter pub get
```

### Errore: 401 Unauthorized

- Verifica che il JWT token sia valido e non scaduto
- Il token scade dopo 7 giorni
- Richiedi nuovo token se necessario

### Errore: Hash Mismatch

- Il PDF deve essere lo stesso scaricato nel Step 1
- Non cambiare il documento tra i step
- Ricaricare il documento torna all'inizio del flow

### OTP Scaduto (> 5 minuti)

L'utente deve ripetere il Step 2 (Richiesta OTP)

### Max 3 Tentativi OTP Falliti

Attendere 1 ora prima di richiedere nuovo OTP

## 📚 Classi Principali

### FirmaDigitaleProvider

Gestisce lo stato del flusso di firma. Stati disponibili:

- `FirmaStep.initial` - Iniziale
- `FirmaStep.loadingDocumento` - Caricamento PDF
- `FirmaStep.documentoCaricato` - PDF pronto
- `FirmaStep.otpInviato` - SMS inviato
- `FirmaStep.verificaOTP` - Verifica in corso
- `FirmaStep.otpVerificato` - OTP validato
- `FirmaStep.firmando` - Firma in corso
- `FirmaStep.firmato` - Firma completata ✅
- `FirmaStep.errore` - Errore durante il processo

### FirmaDigitaleService

Contiene tutti i metodi API:

```dart
// Scarica documento
DocumentoUnico doc = await FirmaDigitaleService.scaricaDocumento(123);

// Genera OTP
OTPGenerateResponse otp = await FirmaDigitaleService.generaOTP(
  richiestaId: 123,
  userId: 456,
  telefono: '+39 334 123 4567',
);

// Verifica OTP
OTPVerifyResponse verified = await FirmaDigitaleService.verificaOTP(
  otpId: 'otp_abc123',
  otpCode: '123456',
);

// Firma documento
FirmaDigitale firma = await FirmaDigitaleService.firmaDocumento(
  otpId: 'otp_abc123',
  richiestaId: 123,
  documentoHash: 'abc123...',
  deviceType: 'iOS',
  deviceModel: 'iPhone 14',
  appVersion: '2.1.0',
);
```

## 🔐 Sicurezza

1. **JWT Token** - Salvato in `SecureStorageService` (Keychain iOS / Keystore Android)
2. **HTTPS Only** - Tutte le comunicazioni su HTTPS
3. **Hash Verification** - SHA-256 del PDF verificato dal backend
4. **OTP Expiration** - 5 minuti di validità
5. **Rate Limiting** - 3 tentativi OTP max, poi 1 ora di wait

## 📞 Supporto

Se riscontri problemi:

1. Verifica i log in console (print statements sono presenti in tutti i metodi)
2. Controlla che il backend risponda con `success: true`
3. Verifica il JWT token sia valido
4. Assicurati di avere connessione Internet
5. Prova con la schermata di test Postman prima

## ✅ Checklist Implementazione

- [ ] Ho aggiunto `webview_flutter` e `device_info_plus` a pubspec.yaml
- [ ] Ho eseguito `flutter pub get`
- [ ] I file modelli sono nella cartella `lib/models/`
- [ ] I file servizi sono nella cartella `lib/services/`
- [ ] Gli screen sono nella cartella `lib/screens/firma_digitale/`
- [ ] I widget sono nella cartella `lib/widgets/firma_digitale/`
- [ ] Ho aggiunto il FirmaDigitaleProvider a main.dart con MultiProvider
- [ ] Ho testato localmente la navigazione allo screen
- [ ] Ho testato gli endpoint con Postman prima

## 🚀 Deploy

1. Aggiorna `version` in `pubspec.yaml`
2. Esegui `flutter test` (se hai test)
3. Esegui `flutter build` per verificare build
4. Testa ampiamente prima di deploy

---

**Buona implementazione! 🎉**
