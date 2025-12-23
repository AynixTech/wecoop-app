# Password Management Flow - WECOOP App

## Panoramica

Sistema completo di gestione password integrato con l'API WECOOP, che supporta:
- ✅ Password dimenticata (reset via telefono o email)
- ✅ Cambio password (utente autenticato)
- ✅ Password memorabili generate dal backend
- ✅ Multi-lingua (IT/EN/ES)

---

## 📱 Schermate Implementate

### 1. Login Screen (`lib/screens/login/login_screen.dart`)
- Login con numero di telefono (username) e password
- Link "Password dimenticata?" che naviga a `/forgot-password`
- Auto-pulizia numero telefono (rimuove simboli)

### 2. Forgot Password Screen (`lib/screens/login/forgot_password_screen.dart`)
**Rotta:** `/forgot-password`

**Funzionalità:**
- Scelta tra reset via **telefono** o **email**
- Validazione input (lunghezza telefono, formato email)
- Chiamata API: `POST /soci/reset-password`
- Feedback utente con SnackBar
- Auto-redirect al login dopo successo

**UI/UX:**
- SegmentedButton per switch telefono/email
- Icone chiare e descrizioni multilingua
- Box informativo su come funziona il reset

### 3. Change Password Screen (`lib/screens/profilo/change_password_screen.dart`)
**Rotta:** `/change-password`

**Funzionalità:**
- Cambio password per utente autenticato
- Validazione completa:
  - Password attuale corretta
  - Nuova password ≥ 6 caratteri
  - Nuova ≠ attuale
  - Conferma password match
- Chiamata API: `POST /soci/me/change-password`
- Toggle visibilità password per tutti i campi

**UI/UX:**
- 3 campi: password attuale, nuova, conferma
- Box "Consigli per la password" con best practices
- Feedback immediato con validazioni

### 4. Profile Screen (aggiornato)
**Aggiunte:**
- ListTile "Cambia Password" nella sezione Sicurezza
- Icona `Icons.security`
- Naviga a `/change-password`
- Mostra SnackBar di successo al ritorno

---

## 🔌 API Service (`lib/services/socio_service.dart`)

### Metodi Aggiunti

#### 1. `checkUsername(String username)`
```dart
static Future<Map<String, dynamic>> checkUsername(String username)
```
- **Endpoint:** `GET /soci/check-username?username={username}`
- **Scopo:** Verifica se username/telefono esiste
- **Pulizia automatica:** rimuove simboli dal numero

**Response:**
```json
{
  "esiste": true,
  "user_id": 13,
  "telefono_completo": "+393891733185"
}
```

#### 2. `resetPassword({String? telefono, String? email})`
```dart
static Future<Map<String, dynamic>> resetPassword({
  String? telefono,
  String? email,
})
```
- **Endpoint:** `POST /soci/reset-password`
- **Body:** `{"telefono": "3891733185"}` oppure `{"email": "user@example.com"}`
- **Pulizia automatica:** telefono pulito da simboli
- **Auth:** Non richiesta (endpoint pubblico)

**Response Success:**
```json
{
  "success": true,
  "message": "Password resettata. Controlla la tua email.",
  "email_sent_to": "user@example.com"
}
```

#### 3. `changePassword({required oldPassword, required newPassword})`
```dart
static Future<Map<String, dynamic>> changePassword({
  required String oldPassword,
  required String newPassword,
})
```
- **Endpoint:** `POST /soci/me/change-password`
- **Body:** `{"old_password": "xxx", "new_password": "yyy"}`
- **Auth:** Richiesta (JWT Bearer token)
- **Log sicurezza:** Password NON loggiate

**Response Success:**
```json
{
  "success": true,
  "message": "Password cambiata con successo"
}
```

---

## 🌍 Traduzioni (`lib/services/app_localizations.dart`)

### Chiavi Aggiunte (35 nuove stringhe)

#### Password Dimenticata
```dart
'forgotPassword': 'Password dimenticata?' / 'Forgot password?' / '¿Olvidaste tu contraseña?'
'resetPassword': 'Reset Password' / 'Reset Password' / 'Restablecer Contraseña'
'resetPasswordTitle': 'Recupera la tua password' / 'Recover your password' / 'Recupera tu contraseña'
'resetPasswordDescription': '...'
'resetPasswordHelp': '...'
'backToLogin': 'Torna al Login' / 'Back to Login' / 'Volver al Login'
```

#### Cambio Password
```dart
'changePassword': 'Cambia Password' / 'Change Password' / 'Cambiar Contraseña'
'changePasswordTitle': '...'
'changePasswordDescription': '...'
'currentPassword': 'Password Attuale' / 'Current Password' / 'Contraseña Actual'
'newPassword': 'Nuova Password' / 'New Password' / 'Nueva Contraseña'
'confirmPassword': 'Conferma Password' / 'Confirm Password' / 'Confirmar Contraseña'
'updateYourPassword': '...'
```

#### Validazioni
```dart
'passwordMinLength': 'Minimo 6 caratteri' / 'Minimum 6 characters' / 'Mínimo 6 caracteres'
'passwordTooShort': '...'
'passwordMustBeDifferent': '...'
'passwordsDoNotMatch': 'Le password non corrispondono' / 'Passwords do not match' / 'Las contraseñas no coinciden'
'phoneNumberTooShort': '...'
'invalidEmail': 'Email non valida' / 'Invalid email' / 'Email no válido'
```

#### Consigli Sicurezza
```dart
'passwordTips': 'Consigli per la password' / 'Password tips' / 'Consejos para la contraseña'
'passwordTip1': 'Usa almeno 8 caratteri'
'passwordTip2': 'Combina lettere maiuscole e minuscole'
'passwordTip3': 'Aggiungi numeri e simboli'
'passwordTip4': 'Non usare password ovvie o personali'
```

---

## 🔐 Flusso Utente Completo

### Scenario 1: Password Dimenticata

1. **Utente clicca "Password dimenticata?" dalla schermata login**
   ```dart
   Navigator.pushNamed(context, '/forgot-password');
   ```

2. **Schermata Forgot Password**
   - Sceglie metodo: Telefono o Email
   - Inserisce dati (es: `3891733185` o `user@example.com`)
   - Clicca "Reset Password"

3. **App chiama API**
   ```dart
   final result = await SocioService.resetPassword(
     telefono: '3891733185',  // oppure email
   );
   ```

4. **Backend WECOOP**
   - Trova utente tramite telefono_completo o email
   - Genera nuova password memorabile (es: `Sole2025Luna`)
   - Invia email con nuove credenziali
   - Logga operazione

5. **App mostra risultato**
   - ✅ Successo: "Password resettata! Controlla la tua email" (verde)
   - Redirect automatico al login dopo 2 secondi
   - ❌ Errore: Messaggio specifico (rosso)

6. **Utente riceve email**
   - Oggetto: "Reset Password - WECOOP"
   - Username: `393891733185`
   - Password: `Sole2025Luna`

7. **Utente torna al login**
   - Inserisce numero: `3891733185` (accetta anche con +39)
   - Inserisce nuova password
   - Login riuscito ✅

### Scenario 2: Cambio Password (Utente Loggato)

1. **Utente va in Profilo**
   - Scroll fino a sezione "Sicurezza"
   - Clicca "Cambia Password"

2. **Schermata Change Password**
   - Inserisce password attuale
   - Inserisce nuova password (min 6 caratteri)
   - Conferma nuova password

3. **Validazioni client-side**
   - ✅ Password attuale non vuota
   - ✅ Nuova password ≥ 6 caratteri
   - ✅ Nuova ≠ attuale
   - ✅ Conferma = nuova

4. **App chiama API (autenticata)**
   ```dart
   final result = await SocioService.changePassword(
     oldPassword: 'Sole2025Luna',
     newPassword: 'MiaNuovaPassword123',
   );
   ```
   Headers includono: `Authorization: Bearer {jwt_token}`

5. **Backend verifica**
   - Utente autenticato via JWT
   - Password attuale corretta
   - Nuova password valida (≥6 caratteri)
   - Aggiorna password nel database
   - Logga cambio password

6. **App mostra risultato**
   - ✅ Successo: "Password cambiata con successo" (verde)
   - Torna al profilo dopo 1 secondo
   - Profilo mostra SnackBar di conferma
   - ❌ Errore: "Password attuale non corretta" (rosso)

---

## 🛡️ Sicurezza Implementata

### Client-Side
- ✅ Password NON loggata nei print
- ✅ TextField `obscureText: true` di default
- ✅ Toggle visibilità password opzionale
- ✅ Validazione lunghezza minima (6 caratteri)
- ✅ Verifica password attuale ≠ nuova
- ✅ Timeout richieste: 30 secondi

### Server-Side (Backend WECOOP)
- ✅ Password memorabili generate (Parola+Numero+Parola)
- ✅ Verifica identità tramite telefono/email
- ✅ JWT autenticazione per cambio password
- ✅ Logging operazioni sicurezza
- ✅ Email automatiche con credenziali
- ✅ Rate limiting su endpoint reset

---

## 📝 Esempio Completo

### Reset Password via Telefono
```dart
// User input
phoneController.text = "+39 389 1733185";

// App pulisce
final cleanPhone = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
// Result: "393891733185"

// API Call
final result = await SocioService.resetPassword(
  telefono: cleanPhone,
);

// Backend trova utente
SELECT * FROM wp_users u
JOIN wp_usermeta m ON u.ID = m.user_id
WHERE m.meta_key = 'telefono_completo'
AND m.meta_value LIKE '%3891733185';

// Genera nuova password
$password = "Mare456Cielo"; // Parola+Numero+Parola

// Invia email
wp_mail(
  'user@example.com',
  'Reset Password - WECOOP',
  "Username: 393891733185\nPassword: Mare456Cielo"
);

// Response
{
  "success": true,
  "message": "Password resettata. Controlla la tua email.",
  "email_sent_to": "us***@example.com"
}
```

### Cambio Password Autenticato
```dart
// User input
oldPasswordController.text = "Mare456Cielo";
newPasswordController.text = "MiaSicuraPassword2025";

// Validazioni
if (newPassword.length < 6) return "Password troppo corta";
if (newPassword == oldPassword) return "Password deve essere diversa";

// API Call con JWT
final headers = {
  'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJ...',
  'Content-Type': 'application/json',
};

final result = await SocioService.changePassword(
  oldPassword: 'Mare456Cielo',
  newPassword: 'MiaSicuraPassword2025',
);

// Backend verifica
wp_check_password($old_password, $user->user_pass);
// Update
wp_set_password($new_password, $user_id);

// Response
{
  "success": true,
  "message": "Password cambiata con successo"
}
```

---

## 🧪 Testing

### Test Manuali

#### Forgot Password Screen
- [ ] Reset con telefono valido (es: 3891733185)
- [ ] Reset con telefono con simboli (es: +39 389 1733185)
- [ ] Reset con email valida
- [ ] Errore con telefono inesistente
- [ ] Errore con email inesistente
- [ ] Validazione telefono troppo corto (<8 cifre)
- [ ] Validazione email senza @
- [ ] Switch tra telefono/email cancella campi
- [ ] SnackBar verde su successo
- [ ] Redirect al login dopo 2 secondi
- [ ] Traduzioni IT/EN/ES corrette

#### Change Password Screen
- [ ] Cambio con password attuale corretta
- [ ] Errore con password attuale sbagliata
- [ ] Validazione nuova password <6 caratteri
- [ ] Validazione nuova = attuale
- [ ] Validazione conferma ≠ nuova
- [ ] Toggle visibilità per tutti e 3 i campi
- [ ] SnackBar verde su successo
- [ ] Torna al profilo dopo 1 secondo
- [ ] Box consigli password visibile
- [ ] Traduzioni IT/EN/ES corrette

#### Login dopo Reset
- [ ] Login con nuovo numero parziale funziona
- [ ] Login con numero completo funziona
- [ ] Password resettata funziona
- [ ] Link "Password dimenticata?" visibile

---

## 📦 File Modificati

### Nuovi File
- ✅ `lib/screens/login/forgot_password_screen.dart` (285 righe)
- ✅ `lib/screens/profilo/change_password_screen.dart` (315 righe)

### File Modificati
- ✅ `lib/services/socio_service.dart` (+140 righe)
  - Metodo `checkUsername()`
  - Metodo `resetPassword()`
  - Metodo `changePassword()`
  
- ✅ `lib/screens/login/login_screen.dart` (+10 righe)
  - Link "Password dimenticata?"
  
- ✅ `lib/screens/profilo/profilo_screen.dart` (+20 righe)
  - ListTile "Cambia Password"
  
- ✅ `lib/app.dart` (+2 rotte)
  - `/forgot-password`
  - `/change-password`
  
- ✅ `lib/services/app_localizations.dart` (+105 righe)
  - 35 nuove chiavi × 3 lingue

### Totale
- **6 file modificati**
- **2 file nuovi**
- **~875 righe di codice**

---

## 🚀 Deploy & Configurazione

### Prerequisiti Backend
```bash
# Verifica endpoint disponibili
curl https://www.wecoop.org/wp-json/wecoop/v1/soci/reset-password
curl https://www.wecoop.org/wp-json/wecoop/v1/soci/me/change-password

# Test reset password
curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/soci/reset-password \
  -H "Content-Type: application/json" \
  -d '{"telefono": "3891733185"}'
```

### Configurazione Email WordPress
- Plugin SMTP configurato (es: WP Mail SMTP)
- Template email personalizzati in `/wp-content/plugins/wecoop-soci/emails/`
- Test invio email: `/wp-content/plugins/wecoop-soci/test-email.php`

### App Flutter
```bash
# Clean & rebuild
flutter clean
flutter pub get
flutter run

# Verifica traduzioni
grep -r "forgotPassword" lib/services/app_localizations.dart
grep -r "changePassword" lib/services/app_localizations.dart
```

---

## 🐛 Troubleshooting

### Problema: "Password dimenticata?" non appare
**Soluzione:** Verifica che `login_screen.dart` abbia:
```dart
TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/forgot-password');
  },
  child: Text(l10n.translate('forgotPassword')),
),
```

### Problema: API 401 su cambio password
**Soluzione:** Verifica JWT token valido:
```dart
final token = await storage.read(key: 'jwt_token');
print('JWT Token: $token');
```

### Problema: Email non arrivano
**Soluzione:** Controlla log WordPress:
```bash
tail -f /wp-content/debug.log | grep "wp_mail\|WECOOP"
```

### Problema: Numero telefono non trovato
**Soluzione:** Backend cerca in `telefono_completo`, verifica:
```sql
SELECT user_id, meta_value FROM wp_usermeta 
WHERE meta_key = 'telefono_completo';
```

---

## 📚 Riferimenti API

### Documentazione Completa
Vedi: **API_WECOOP_SOCI_DOCS.md** per dettagli completi su:
- Registrazione nuovo socio
- Login
- Reset password
- Cambio password
- Password memorabili
- Codici errore

### Endpoint Base
```
https://www.wecoop.org/wp-json/wecoop/v1
```

### Endpoint Password
- `POST /soci/reset-password` - Reset password (pubblico)
- `POST /soci/me/change-password` - Cambio password (autenticato)
- `GET /soci/check-username` - Verifica username (pubblico)

---

## ✅ Completamento

**Status:** ✅ Implementazione Completa

**Funzionalità Implementate:**
- [x] Password dimenticata via telefono
- [x] Password dimenticata via email
- [x] Cambio password utente autenticato
- [x] Validazioni client-side complete
- [x] Traduzioni IT/EN/ES
- [x] Integrazione con profilo
- [x] Link da login screen
- [x] Feedback utente con SnackBar
- [x] UI/UX con Material 3
- [x] Sicurezza password (no log)
- [x] Documentazione completa

**Prossimi Step:**
- [ ] Test su dispositivo fisico
- [ ] Verifica email template backend
- [ ] Test con utenti reali
- [ ] Monitoraggio analytics reset password
- [ ] A/B test UI alternative

---

**Last Update:** 23 Dicembre 2025  
**Version:** 1.0.0  
**Author:** WECOOP Development Team
