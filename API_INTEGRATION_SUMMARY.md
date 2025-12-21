# 📱 WECOOP App - Integrazione API Aggiornata

**Data aggiornamento:** 21 dicembre 2025

---

## 🔗 Endpoint Base

```
https://www.wecoop.org/wp-json/wecoop/v1
```

---

## ✅ Modifiche Implementate

### 1. **SocioService.dart** - Completamente Aggiornato

#### Metodi Implementati:

**GET /soci/verifica/{email}** (PUBBLICO)
```dart
static Future<bool> isSocio() // Verifica se utente è socio attivo
static Future<bool> hasRichiestaInAttesa() // Verifica richiesta pending
```

**POST /soci/richiesta** (PUBBLICO - no auth)
```dart
static Future<Map<String, dynamic>> richiestaAdesioneSocio({...})
// Response: {"success": true, "message": "...", "data": {"richiesta_id": 123, "status": "pending"}}
```

**POST /richiesta-servizio** (AUTENTICATO - JWT required)
```dart
static Future<Map<String, dynamic>> inviaRichiestaServizio({
  required String servizio,
  required String categoria,
  required Map<String, dynamic> dati,
})
// Response: {"success": true, "id": 789, "numero_pratica": "WECOOP-2025-00001"}
```

**GET /soci/me** (AUTENTICATO)
```dart
static Future<Map<String, dynamic>?> getMe()
// Response: {"success": true, "data": {id, nome, cognome, numero_tessera, tessera_url, ...}}
```

**GET /soci** (AUTENTICATO - admin)
```dart
static Future<List<Map<String, dynamic>>> getSoci({
  String status = 'attivo',
  int perPage = 50,
  int page = 1,
  String? search,
})
```

---

### 2. **Login Screen** - Già Corretto

```dart
// POST /jwt-auth/v1/token
final response = await http.post(
  Uri.parse('https://www.wecoop.org/wp-json/jwt-auth/v1/token'),
  body: jsonEncode({'username': email, 'password': password}),
);
// Salva: jwt_token, user_email, user_display_name, user_nicename, last_login_email

// GET /soci/me
await _fetchUserMeta(token);
// Salva tutti i campi socio: nome, cognome, tessera_numero, tessera_url, ecc.
```

---

### 3. **Richiesta Form Screen** - Compatibile

Il form screen utilizza correttamente:
- `result['numero_pratica']` per mostrare il numero pratica dopo l'invio
- `result['success']` e `result['message']` per gestire la risposta

---

### 4. **Adesione Socio Screen** - Compatibile

Utilizza:
- `result['success']` e `result['message']`
- Non dipende da `numero_pratica` (non necessario per adesioni)

---

## 📋 Mappatura Campi API vs Storage

### Campi salvati dopo GET /soci/me:

| Campo API | Storage Key | Tipo |
|-----------|-------------|------|
| id | socio_id | string |
| nome | first_name | string |
| cognome | last_name | string |
| email | user_email | string |
| numero_tessera | tessera_numero | UUID string |
| tessera_url | tessera_url | string |
| telefono | telefono | string |
| data_nascita | data_nascita | string (YYYY-MM-DD) |
| luogo_nascita | luogo_nascita | string |
| codice_fiscale | codice_fiscale | string |
| indirizzo | indirizzo | string |
| citta | citta | string |
| cap | cap | string |
| provincia | provincia | string |
| professione | professione | string |
| status_socio | stato_socio | string (attivo/sospeso/cessato) |
| data_adesione | data_iscrizione | string (YYYY-MM-DD) |
| quota_pagata | quota_pagata | boolean string |
| anni_socio | anni_socio | int string |

---

## 🎯 Campi Obbligatori per Servizi

### Permesso di Soggiorno

**Lavoro Subordinato:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_provenienza' // OBBLIGATORIO
'tipo_contratto' // OBBLIGATORIO
'nome_azienda' // OBBLIGATORIO
```

**Lavoro Autonomo:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_provenienza' // OBBLIGATORIO
'tipo_attivita' // OBBLIGATORIO
```

**Motivi Familiari:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_provenienza' // OBBLIGATORIO
'relazione_familiare' // OBBLIGATORIO
```

**Studio:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_provenienza' // OBBLIGATORIO
'nome_istituto_universita' // OBBLIGATORIO
```

### Cittadinanza Italiana

**Per residenza:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_nascita' // OBBLIGATORIO
'data_arrivo_italia' // OBBLIGATORIO (YYYY-MM-DD)
'indirizzo_residenza_attuale' // OBBLIGATORIO
```

### Asilo Politico

**Protezione Internazionale:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'paese_origine' // OBBLIGATORIO
'data_arrivo_italia' // OBBLIGATORIO
'motivo_richiesta' // OBBLIGATORIO
```

### Visa per Turismo

**Visto turistico:**
```dart
'nome_completo' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'nazionalita' // OBBLIGATORIO
'numero_passaporto' // OBBLIGATORIO
'data_arrivo_prevista' // OBBLIGATORIO
```

### Mediazione Fiscale

**730 / Persona Fisica:**
```dart
'nome_completo' // OBBLIGATORIO
'codice_fiscale' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'indirizzo_residenza' // OBBLIGATORIO
'anno_fiscale' // OBBLIGATORIO
```

### Supporto Contabile

**Aprire Partita IVA:**
```dart
'nome_completo' // OBBLIGATORIO
'codice_fiscale' // OBBLIGATORIO
'data_nascita' // OBBLIGATORIO
'tipo_attivita' // OBBLIGATORIO
```

**Gestire Partita IVA:**
```dart
'nome_completo' // OBBLIGATORIO
'partita_iva' // OBBLIGATORIO
'tipo_supporto_richiesto' // OBBLIGATORIO
```

**Tasse e Contributi:**
```dart
'nome_completo' // OBBLIGATORIO
'partita_iva' // OBBLIGATORIO
'tipo_adempimento' // OBBLIGATORIO
```

**Consulenza:**
```dart
'nome_completo' // OBBLIGATORIO
'email' // OBBLIGATORIO
'telefono' // OBBLIGATORIO
'argomento_consulenza' // OBBLIGATORIO
```

**Chiudere/Cambiare Attività:**
```dart
'nome_completo' // OBBLIGATORIO
'partita_iva' // OBBLIGATORIO
'cosa_vuoi_fare' // OBBLIGATORIO
```

---

## 🔧 Codici Errore Gestiti

| HTTP Status | Gestione App |
|-------------|--------------|
| 200/201 | Success - mostra numero pratica |
| 400 | Bad Request - mostra messaggio errore API |
| 401 | Unauthorized - "Devi essere autenticato" |
| 403 | Forbidden - "Solo i soci possono richiedere servizi" |
| 404 | Not Found - "Risorsa non trovata" |
| 409 | Conflict - "Email già esistente" |
| Timeout | "Il server non risponde. Riprova più tardi." |
| Socket Error | "Nessuna connessione internet" |

---

## ✅ Checklist Completamento

- [x] Aggiornato endpoint POST /richiesta-servizio (era /servizi/richiesta)
- [x] Corretto parsing risposta GET /soci/verifica (is_socio, status)
- [x] Aggiunto metodo getMe() per GET /soci/me
- [x] Aggiunto metodo getSoci() per GET /soci
- [x] Gestione corretta campo numero_pratica nella risposta
- [x] Gestione corretta campo richiesta_id per adesioni
- [x] Headers corretti per tutte le chiamate
- [x] Timeout di 30 secondi su tutte le richieste
- [x] Gestione errori completa con codici HTTP
- [x] Email persistence (last_login_email)
- [x] Precompilazione form con dati storage
- [x] QR code tessera con UUID

---

## 🚀 Prossimi Passi

1. **Backend WordPress**: Implementare tutti gli endpoint documentati
2. **Testing**: Testare end-to-end quando backend sarà pronto
3. **Produzione**: Impostare `_useTestData = false` prima del deploy
4. **Monitoraggio**: Verificare che GET /soci/me ritorni 200 invece di 404

---

## 📞 Support

Per problemi API contattare il backend team o verificare i log con:
```dart
print('Response: ${response.body}');
```

Tutti i metodi in `SocioService` hanno logging completo.
