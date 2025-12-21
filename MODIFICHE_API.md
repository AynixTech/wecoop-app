# ✅ Adattamento App per Nuovi Endpoint API

## 📋 Modifiche Implementate

### 1. **Aggiornato `socio_service.dart`**

Nuovo file basato sulla documentazione API WECOOP:

**Endpoint Soci:**
- `POST /soci/richiesta` - Richiesta adesione (PUBBLICO)
- `GET /soci/verifica/{email}` - Verifica socio attivo (PUBBLICO)

**Endpoint Servizi:**
- `POST /servizi/richiesta` - Richiesta servizio (SOLO SOCI)

**Metodi principali:**
```dart
// Verifica se utente è socio attivo
static Future<bool> isSocio()

// Verifica se ha richiesta pending
static Future<bool> hasRichiestaInAttesa()

// Invia richiesta adesione (no auth)
static Future<Map<String, dynamic>> richiestaAdesioneSocio({...})

// Invia richiesta servizio (con auth JWT)
static Future<Map<String, dynamic>> inviaRichiestaServizio({...})
```

---

### 2. **Aggiornato `richiesta_form_screen.dart`**

**Prima:**
```dart
// Endpoint placeholder non funzionante
final response = await http.post(
  Uri.parse('https://your-crm-api.com/richieste'),
  ...
);
```

**Dopo:**
```dart
// Endpoint API reale WECOOP
final result = await SocioService.inviaRichiestaServizio(
  servizio: widget.servizio,
  categoria: widget.categoria,
  dati: _formData,
);
```

**Miglioramenti:**
- ✅ Usa endpoint reale `/servizi/richiesta`
- ✅ Gestione errori dettagliata (401, 403, timeout, no internet)
- ✅ Mostra numero pratica se ricevuto
- ✅ Dialog di successo/errore personalizzati

---

### 3. **Endpoint Utilizzati dall'App**

#### Pubblici (no autenticazione):
1. **Verifica Socio**
   ```
   GET /soci/verifica/{email}
   ```
   - Usato da: `servizi_gate_screen.dart`
   - Controlla se utente può accedere ai servizi

2. **Richiesta Adesione**
   ```
   POST /soci/richiesta
   ```
   - Usato da: `adesione_socio_screen.dart`
   - Non richiede login
   - Campi: nome, cognome, email, telefono, CF, data_nascita, indirizzo, ecc.

#### Protetti (JWT token richiesto):
3. **Richiesta Servizio**
   ```
   POST /servizi/richiesta
   ```
   - Usato da: `richiesta_form_screen.dart`
   - Solo per soci attivi
   - Campi: servizio, categoria, dati (dinamici)

---

## 🔧 Cosa Serve nel Backend WordPress

### 1. Plugin JWT Authentication
```bash
# Installa via WordPress Admin o Composer
composer require firebase/php-jwt
```

### 2. Configurazione wp-config.php
```php
define('JWT_AUTH_SECRET_KEY', 'your-secret-key-here');
define('JWT_AUTH_CORS_ENABLE', true);
```

### 3. Endpoint da Creare

#### `/soci/richiesta` (POST - Pubblico)
```php
register_rest_route('wecoop/v1', '/soci/richiesta', [
    'methods' => 'POST',
    'callback' => 'wecoop_handle_richiesta_adesione',
    'permission_callback' => '__return_true', // PUBBLICO
]);
```

**Body ricevuto:**
```json
{
  "nome": "Mario",
  "cognome": "Rossi",
  "email": "mario@example.com",
  "telefono": "+39 333 1234567",
  "codice_fiscale": "RSSMRA85C15H501A",
  "data_nascita": "1985-03-15",
  "luogo_nascita": "Roma",
  "indirizzo": "Via Roma 123",
  "citta": "Milano",
  "cap": "20100",
  "provincia": "MI",
  "professione": "Ingegnere",
  "motivazione": "Voglio contribuire..."
}
```

**Response attesa:**
```json
{
  "success": true,
  "message": "Richiesta inviata con successo",
  "data": {
    "id": 123,
    "numero_pratica": "RS-2025-00123",
    "status": "pending"
  }
}
```

---

#### `/soci/verifica/{email}` (GET - Pubblico)
```php
register_rest_route('wecoop/v1', '/soci/verifica/(?P<email>[^/]+)', [
    'methods' => 'GET',
    'callback' => 'wecoop_verifica_socio',
    'permission_callback' => '__return_true', // PUBBLICO
]);
```

**Response se è socio attivo:**
```json
{
  "success": true,
  "is_socio": true,
  "is_attivo": true,
  "status": "attivo",
  "numero_tessera": "COOP-2025-00123"
}
```

**Response se NON è socio:**
```json
{
  "success": true,
  "is_socio": false
}
```

---

#### `/servizi/richiesta` (POST - Solo Soci)
```php
register_rest_route('wecoop/v1', '/servizi/richiesta', [
    'methods' => 'POST',
    'callback' => 'wecoop_handle_richiesta_servizio',
    'permission_callback' => 'wecoop_check_is_socio', // Solo soci
]);

function wecoop_check_is_socio() {
    $user = wp_get_current_user();
    if (!$user->exists()) return false;
    
    $is_socio = get_user_meta($user->ID, 'is_socio', true);
    return $is_socio === true || $is_socio === 'true';
}
```

**Body ricevuto:**
```json
{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Lavoro Subordinato",
  "data_richiesta": "2025-12-21T10:30:00Z",
  "dati": {
    "nome_completo": "Mario Rossi",
    "data_nascita": "1985-03-15",
    "paese_provenienza": "Romania",
    "tipo_contratto": "Indeterminato",
    "nome_azienda": "Acme SRL",
    "durata_contratto_mesi": 12
  }
}
```

**Response attesa:**
```json
{
  "success": true,
  "message": "Richiesta ricevuta con successo",
  "data": {
    "id": 456,
    "numero_pratica": "WECOOP-2025-00456",
    "status": "pending"
  }
}
```

---

## 🧪 Come Testare

### 1. Test Richiesta Adesione
```bash
curl -X POST "https://www.wecoop.org/wp-json/wecoop/v1/soci/richiesta" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Mario",
    "cognome": "Rossi",
    "email": "mario@test.com",
    "telefono": "+39 333 1234567",
    "codice_fiscale": "RSSMRA85C15H501A",
    "data_nascita": "1985-03-15",
    "luogo_nascita": "Roma",
    "indirizzo": "Via Roma 123",
    "citta": "Milano",
    "cap": "20100",
    "provincia": "MI",
    "professione": "Test",
    "motivazione": "Test adesione"
  }'
```

### 2. Test Verifica Socio
```bash
curl "https://www.wecoop.org/wp-json/wecoop/v1/soci/verifica/mario@test.com"
```

### 3. Test Richiesta Servizio (con JWT)
```bash
# Prima ottieni token JWT
TOKEN=$(curl -X POST "https://www.wecoop.org/wp-json/jwt-auth/v1/token" \
  -d "username=admin&password=yourpass" | jq -r '.token')

# Poi invia richiesta servizio
curl -X POST "https://www.wecoop.org/wp-json/wecoop/v1/servizi/richiesta" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "servizio": "Test",
    "categoria": "Test",
    "data_richiesta": "2025-12-21T10:00:00Z",
    "dati": {"test": "valore"}
  }'
```

---

## 📚 File Modificati

1. ✅ `lib/services/socio_service.dart` - Completamente riscritto
2. ✅ `lib/screens/servizi/richiesta_form_screen.dart` - Aggiornato metodo `_submitForm()`
3. 📄 `lib/services/socio_service_old.dart` - Backup del vecchio file

---

## 🎯 Prossimi Passi

### Per il Backend (WordPress):
1. Creare i 3 endpoint REST API descritti sopra
2. Configurare JWT Authentication plugin
3. Testare gli endpoint con curl/Postman
4. Verificare validazioni e sanitizzazione dati
5. Implementare invio email notifiche

### Per l'App (Flutter):
1. ✅ Endpoint socio aggiornati
2. ✅ Endpoint servizi aggiornati
3. ✅ Gestione errori migliorata
4. ⏳ Test end-to-end dopo setup backend
5. ⏳ Aggiungere refresh automatico dopo richiesta approvata

---

## 🔒 Sicurezza

**Pubblici (safe):**
- `/soci/richiesta` - Validare tutti i dati, rate limiting
- `/soci/verifica/{email}` - Solo dati pubblici (status, numero tessera)

**Protetti (JWT required):**
- `/servizi/richiesta` - Verificare `is_socio` prima di accettare

**Note:**
- Sanitizzare tutti gli input
- Usare prepared statements per query
- Implementare rate limiting (max 5 richieste/minuto)
- Validare email, CF, CAP, ecc.

---

## 📞 Supporto

Per problemi con gli endpoint API, verificare:
1. Plugin JWT installato e configurato
2. Permalink WordPress rigenerati
3. CORS abilitato in wp-config.php
4. Debug log WordPress attivo

**Log di debug:**
```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
```

Controlla: `/wp-content/debug.log`
