# Changelog API Registrazione Soci - 23 Dicembre 2025

## 🔄 Modifiche Implementate

### Nuova API con 7 Campi Obbligatori

La registrazione soci ora richiede **7 campi obbligatori** invece di 6:

#### Prima (6 campi obbligatori):
```dart
SocioService.richiestaAdesioneSocio(
  nome: 'Mario',
  cognome: 'Rossi',
  telefono: '+393331234567', // Telefono completo
  nazionalita: 'IT',
  email: 'mario@example.com',
  privacyAccepted: true,
)
```

#### Dopo (7 campi obbligatori):
```dart
SocioService.richiestaAdesioneSocio(
  nome: 'Mario',
  cognome: 'Rossi',
  prefix: '+39',              // ⭐ NUOVO: Prefisso separato
  telefono: '3331234567',     // ⭐ MODIFICATO: Solo numero senza prefisso
  nazionalita: 'IT',
  email: 'mario@example.com',
  privacyAccepted: true,
)
```

---

## 📋 Campi Obbligatori (7 totali)

| Campo | Tipo | Formato | Esempio | Descrizione |
|-------|------|---------|---------|-------------|
| `nome` | string | Testo | "Mario" | Nome del socio |
| `cognome` | string | Testo | "Rossi" | Cognome del socio |
| **`prefix`** | **string** | **Codice paese** | **"+39", "+593"** | **⭐ NUOVO: Prefisso internazionale** |
| `telefono` | string | Numerico | "3331234567" | Numero di telefono **senza prefisso** |
| `nazionalita` | string | ISO 3166-1 alpha-2 | "IT", "EC", "ES" | Codice paese a 2 lettere MAIUSCOLE |
| `email` | string | Email valida | "mario@example.com" | Email (deve essere unica) |
| `privacy_accepted` | boolean | true/false | true | Accettazione privacy (deve essere `true`) |

---

## 🔑 Username Generation

### Come viene generato l'username:

**Backend genera:** `username = prefix + telefono` (solo numeri)

**Esempi:**
- Input: `prefix="+39"`, `telefono="3331234567"` → Username: `393331234567`
- Input: `prefix="+593"`, `telefono="991234567"` → Username: `593991234567`
- Input: `prefix="+51"`, `telefono="987654321"` → Username: `51987654321`

⚠️ **IMPORTANTE:** L'utente usa il numero di telefono completo (solo numeri, senza simboli) per fare login!

---

## 📤 Request Body (JSON)

```json
{
  "nome": "Mario",
  "cognome": "Rossi",
  "prefix": "+39",
  "telefono": "3331234567",
  "nazionalita": "IT",
  "email": "mario.rossi@example.com",
  "privacy_accepted": true
}
```

---

## 📥 Response di Successo

```json
{
  "success": true,
  "message": "Registrazione completata con successo! Benvenuto in WECOOP.",
  "data": {
    "post_id": 123,
    "user_id": 456,
    "username": "393331234567",
    "password": "Xy9mK2pL4vN8",
    "tessera_url": "https://www.wecoop.org/tessera-socio/?uuid=abc123...",
    "numero_pratica": "RS-2025-00123",
    "profilo_completo": false,
    "prefix": "+39",
    "telefono": "3331234567",
    "telefono_completo": "+393331234567"
  }
}
```

---

## 📧 Email Automatica

**L'utente riceve automaticamente un'email con:**
- Username: `393331234567` (telefono completo senza simboli)
- Password: Password temporanea generata dal sistema
- Link alla tessera socio digitale

⚠️ **L'app DEVE comunque mostrare le credenziali nel dialog** come backup nel caso l'email non arrivi!

---

## 🔧 Files Modificati

### 1. `lib/services/socio_service.dart`
**Modifiche:**
- Aggiunto parametro `required String prefix`
- Aggiornato body della request per inviare `prefix` e `telefono` separati
- Aggiornata documentazione metodo

```dart
static Future<Map<String, dynamic>> richiestaAdesioneSocio({
  required String nome,
  required String cognome,
  required String prefix,    // ⭐ NUOVO
  required String telefono,  // ⭐ Ora senza prefisso
  required String nazionalita,
  required String email,
  required bool privacyAccepted,
  // ... campi opzionali
})
```

### 2. `lib/screens/servizi/adesione_socio_screen.dart`
**Modifiche:**
- Rimosso concatenamento manuale di prefix + telefono
- Aggiornata chiamata a `SocioService.richiestaAdesioneSocio()` per passare parametri separati
- Aggiornato testo dialog credenziali: "Telefono completo" invece di "Telefono"

**Prima:**
```dart
final telefonoCompleto = '${_prefissoController.text}${_telefonoController.text}';

final result = await SocioService.richiestaAdesioneSocio(
  telefono: telefonoCompleto,
  // ...
);
```

**Dopo:**
```dart
final result = await SocioService.richiestaAdesioneSocio(
  prefix: _prefissoController.text.trim(),
  telefono: _telefonoController.text.trim(),
  // ...
);
```

### 3. `lib/examples/api_usage_examples.dart`
**Modifiche:**
- Aggiornato esempio di registrazione con prefix separato
- Aggiunto commento esplicativo su come viene generato lo username

```dart
final result = await SocioService.richiestaAdesioneSocio(
  nome: 'Mario',
  cognome: 'Rossi',
  prefix: '+39',           // ⭐ NUOVO
  telefono: '3331234567',  // ⭐ Solo numero
  nazionalita: 'IT',
  email: 'mario.rossi@example.com',
  privacyAccepted: true,
);
```

---

## ✅ Testing

### Test Case 1: Registrazione Italia
```dart
prefix: '+39'
telefono: '3331234567'
nazionalita: 'IT'
→ Username generato: 393331234567
```

### Test Case 2: Registrazione Ecuador
```dart
prefix: '+593'
telefono: '991234567'
nazionalita: 'EC'
→ Username generato: 593991234567
```

### Test Case 3: Registrazione Perù
```dart
prefix: '+51'
telefono: '987654321'
nazionalita: 'PE'
→ Username generato: 51987654321
```

---

## 🚨 Breaking Changes

⚠️ **Questa modifica è un BREAKING CHANGE**

### App versione precedente (con 6 campi):
- Inviava `telefono: '+393331234567'` (completo)
- Backend accettava telefono completo

### App versione nuova (con 7 campi):
- Invia `prefix: '+39'` e `telefono: '3331234567'` (separati)
- Backend richiede prefix e telefono separati

**Soluzione:** Aggiornare l'app con le modifiche implementate in questa versione.

---

## 📱 UI/UX Impact

### Dialog Credenziali Aggiornato

**Prima:**
```
Username (Telefono): +393331234567
Password: Xy9mK2pL4vN8
```

**Dopo:**
```
Username (Telefono completo): 393331234567
Password: Xy9mK2pL4vN8
```

⚠️ **L'username non include più il simbolo "+"** - solo numeri!

---

## 🔍 Validazione Form

La validazione rimane invariata:

```dart
// Prefix
✅ Obbligatorio
✅ Deve iniziare con '+'
✅ Esempi validi: +39, +593, +51, +34

// Telefono
✅ Obbligatorio
✅ Solo numeri
✅ Min 6 cifre
✅ Esempi validi: 3331234567, 991234567

// Nazionalità
✅ Obbligatorio
✅ Codice ISO a 2 lettere
✅ Esempi validi: IT, EC, PE, ES, FR
```

---

## 📖 Documentazione API

Per la documentazione completa dell'API, vedere:
- File fornito dall'utente: `API Registrazione Soci - WeCoop.md`

---

## ✨ Note Finali

- ✅ Tutte le modifiche sono **backward compatible** nella UI (l'utente vede ancora prefix + telefono separati)
- ✅ La logica di business è aggiornata per il nuovo formato API
- ✅ Gli esempi sono aggiornati
- ✅ Non ci sono errori di compilazione
- ⚠️ Backend deve essere allineato con le nuove specifiche (7 campi)

---

**Data implementazione:** 23 Dicembre 2025
**Versione app:** 1.0.0+1
**API Endpoint:** POST /wp-json/wecoop/v1/soci/richiesta
