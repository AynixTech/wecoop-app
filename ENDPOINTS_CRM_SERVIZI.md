# WECOOP CRM - API REST Endpoints
## Documentazione completa per app Dart/Flutter

**Base URL:** `https://www.wecoop.org/wp-json/wecoop/v1`

---

## 🔐 AUTENTICAZIONE

Per endpoint protetti usa:
```dart
// JWT Token (Consigliato)
headers: {
  'Authorization': 'Bearer YOUR_JWT_TOKEN',
  'Content-Type': 'application/json',
}
```

**Endpoint pubblici (no auth):**
- `POST /soci/richiesta` - Richiesta adesione socio
- `GET /soci/verifica/{email}` - Verifica socio attivo
- `POST /servizi/richiesta` - Richiesta servizio (se socio)

**Endpoint protetti (admin):**
- Tutti gli altri endpoint richiedono JWT token

---

## 🏗️ STRUTTURA GENERALE

### Formato Richiesta POST
```json
{
  "servizio": "Nome servizio",
  "categoria": "Categoria specifica",
  "dati": {
    "campo1": "valore1",
    "campo2": "valore2"
  }
}
```

### Formato Risposta Successo (200)
```json
{
  "success": true,
  "message": "Operazione completata",
  "data": {
    "id": 123,
    "numero_pratica": "WECOOP-2025-00123"
  }
}
```

### Formato Risposta Errore (4xx/5xx)
```json
{
  "code": "error_code",
  "message": "Descrizione errore",
  "data": { "status": 400 }
}
```

---

## 👥 SOCI - Gestione Completa

### 1. **CREATE - Nuova Richiesta Adesione** ✅ Pubblico
```http
POST /soci/richiesta
```

**Body (JSON):**
```json
{
  "nome": "Mario",
  "cognome": "Rossi",
  "email": "mario.rossi@example.com",
  "telefono": "+39 333 1234567",
  "data_nascita": "1985-03-15",
  "luogo_nascita": "Roma",
  "codice_fiscale": "RSSMRA85C15H501A",
  "indirizzo": "Via Roma 123",
  "citta": "Milano",
  "cap": "20100",
  "provincia": "MI",
  "professione": "Ingegnere",
  "motivazione": "Voglio contribuire alla cooperativa..."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Richiesta adesione inviata con successo",
  "data": {
    "id": 123,
    "numero_pratica": "RS-2025-00123",
    "status": "pending"
  }
}
```

**Dart Example:**
```dart
Future<Map<String, dynamic>> inviaRichiestaAdesione(Socio socio) async {
  final response = await http.post(
    Uri.parse('$baseUrl/soci/richiesta'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(socio.toJson()),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Errore invio richiesta');
  }
}
```

---

### 2. **READ - Lista Richieste Adesione** 🔒 Admin
```http
GET /soci/richieste?status=pending&page=1&per_page=20&search=mario
```

**Query Parameters:**
- `status` (string): `pending`, `publish`, `draft`, `any` (default: `any`)
- `page` (int): Numero pagina (default: `1`)
- `per_page` (int): Risultati per pagina (default: `20`)
- `search` (string): Cerca per nome/cognome/email

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "numero_pratica": "RS-2025-00123",
      "nome": "Mario",
      "cognome": "Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "+39 333 1234567",
      "citta": "Milano",
      "status": "pending",
      "data_richiesta": "2025-12-21T10:30:00"
    }
  ],
  "pagination": {
    "total": 45,
    "pages": 3,
    "current_page": 1,
    "per_page": 20
  }
}
```

---

### 3. **READ - Dettaglio Richiesta** 🔒 Admin
```http
GET /soci/richiesta/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "status": "pending",
    "nome": "Mario",
    "cognome": "Rossi",
    "email": "mario.rossi@example.com",
    "telefono": "+39 333 1234567",
    "data_nascita": "1985-03-15",
    "luogo_nascita": "Roma",
    "codice_fiscale": "RSSMRA85C15H501A",
    "indirizzo": "Via Roma 123",
    "citta": "Milano",
    "cap": "20100",
    "provincia": "MI",
    "professione": "Ingegnere",
    "motivazione": "Voglio contribuire...",
    "note_admin": "Da verificare documenti"
  }
}
```

---

### 4. **UPDATE - Approva Richiesta** 🔒 Admin
```http
POST /soci/richiesta/{id}/approva
```

**Body:**
```json
{
  "numero_tessera": "COOP-2025-00123",
  "data_adesione": "2025-12-21",
  "quota_pagata": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Richiesta approvata e socio creato",
  "data": {
    "user_id": 456,
    "numero_tessera": "COOP-2025-00123"
  }
}
```

**Cosa fa:**
- Crea utente WordPress
- Assegna ruolo "socio"
- Copia tutti i dati dalla richiesta
- Invia email di benvenuto
- Cambia status richiesta a "publish"

---

### 5. **UPDATE - Rifiuta Richiesta** 🔒 Admin
```http
POST /soci/richiesta/{id}/rifiuta
```

**Body:**
```json
{
  "motivo": "Documenti incompleti"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Richiesta rifiutata"
}
```

---

### 6. **READ - Lista Soci Attivi** 🔒 Admin
```http
GET /soci?status=attivo&page=1&per_page=50&search=rossi&order_by=cognome
```

**Query Parameters:**
- `status` (string): `attivo`, `sospeso`, `cessato`, `all` (default: `attivo`)
- `page` (int): default `1`
- `per_page` (int): default `50`
- `search` (string): Cerca in nome/cognome/email
- `order_by` (string): `cognome`, `nome`, `data_adesione` (default: `cognome`)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 456,
      "numero_tessera": "COOP-2025-00123",
      "nome": "Mario",
      "cognome": "Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "+39 333 1234567",
      "status": "attivo",
      "data_adesione": "2025-12-21"
    }
  ],
  "pagination": {
    "total": 150,
    "current_page": 1,
    "per_page": 50
  }
}
```

---

### 7. **READ - Dettaglio Socio** 🔒 Admin
```http
GET /soci/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "email": "mario.rossi@example.com",
    "numero_tessera": "COOP-2025-00123",
    "nome": "Mario",
    "cognome": "Rossi",
    "telefono": "+39 333 1234567",
    "data_nascita": "1985-03-15",
    "luogo_nascita": "Roma",
    "codice_fiscale": "RSSMRA85C15H501A",
    "indirizzo": "Via Roma 123",
    "citta": "Milano",
    "cap": "20100",
    "provincia": "MI",
    "professione": "Ingegnere",
    "status_socio": "attivo",
    "data_adesione": "2025-12-21",
    "quota_pagata": true
  }
}
```

---

### 8. **UPDATE - Modifica Dati Socio** 🔒 Admin
```http
PUT /soci/{id}
```

**Body (JSON):**
```json
{
  "telefono": "+39 333 9999999",
  "indirizzo": "Via Nuova 456",
  "citta": "Roma",
  "cap": "00100",
  "provincia": "RM"
}
```

**Campi modificabili:**
- `nome`, `cognome`, `telefono`, `indirizzo`, `citta`, `cap`, `provincia`, `professione`, `numero_tessera`

---

### 9. **UPDATE - Cambia Status Socio** 🔒 Admin
```http
POST /soci/{id}/status
```

**Body:**
```json
{
  "status": "sospeso",
  "motivo": "Mancato pagamento quota",
  "data_effetto": "2025-12-21"
}
```

**Status possibili:**
- `attivo`
- `sospeso`
- `cessato`

---

### 10. **READ - Verifica Socio Attivo** ✅ Pubblico
```http
GET /soci/verifica/{email}
```

**Esempio:**
```
GET /soci/verifica/mario.rossi@example.com
```

**Response:**
```json
{
  "success": true,
  "is_socio": true,
  "is_attivo": true,
  "status": "attivo",
  "numero_tessera": "COOP-2025-00123",
  "data_adesione": "2025-12-21"
}
```

**Se NON è socio:**
```json
{
  "success": true,
  "is_socio": false
}
```

**Dart Example:**
```dart
Future<bool> verificaSocioAttivo(String email) async {
  final encodedEmail = Uri.encodeComponent(email);
  final response = await http.get(
    Uri.parse('$baseUrl/soci/verifica/$encodedEmail'),
  );
  final data = jsonDecode(response.body);
  return data['is_attivo'] ?? false;
}
```

---

### 11. **READ - Statistiche Soci** 🔒 Admin
```http
GET /soci/stats
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totale_soci": 150,
    "attivi": 142,
    "sospesi": 8,
    "cessati": 23,
    "richieste_pending": 12,
    "nuovi_questo_mese": 5
  }
}
```

---

### 12. **READ - Storico Pagamenti** 🔒 Admin
```http
GET /soci/{id}/pagamenti
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "pag_abc123",
      "importo": 50.00,
      "tipo": "quota_associativa",
      "data_pagamento": "2025-12-21",
      "metodo": "bonifico",
      "note": "Quota anno 2025"
    }
  ]
}
```

---

### 13. **CREATE - Aggiungi Pagamento** 🔒 Admin
```http
POST /soci/{id}/pagamenti
```

**Body:**
```json
{
  "importo": 50.00,
  "tipo": "quota_associativa",
  "data_pagamento": "2025-12-21",
  "metodo": "bonifico",
  "note": "Quota anno 2025"
}
```

**Tipi pagamento:**
- `quota_associativa`
- `quota_straordinaria`
- `donazione`
- `servizio`

---

### 14. **READ - Documenti Socio** 🔒 Admin
```http
GET /soci/{id}/documenti
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 789,
      "title": "Carta Identità",
      "filename": "CI_Mario_Rossi.pdf",
      "url": "https://wecoop.org/wp-content/uploads/2025/12/CI_Mario_Rossi.pdf",
      "tipo": "carta_identita",
      "data_upload": "2025-12-21T10:30:00"
    }
  ]
}
```

---

### 15. **CREATE - Upload Documento** 🔒 Admin
```http
POST /soci/{id}/documenti
Content-Type: multipart/form-data
```

**Form Data:**
- `file`: (binary)
- `tipo_documento`: `carta_identita`, `codice_fiscale`, `certificato`, `altro`

**Dart Example:**
```dart
Future<void> uploadDocumento(int socioId, File file, String tipo) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/soci/$socioId/documenti'),
  );
  request.headers['Authorization'] = 'Bearer $token';
  request.fields['tipo_documento'] = tipo;
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  
  await request.send();
}
```

---

## 📋 SERVIZI - Richieste di Assistenza

### ENDPOINT PRINCIPALE
```http
POST /servizi/richiesta
```

**Autenticazione:** Solo per soci attivi (verifica `is_socio: true`)

**Struttura Generale:**
```json
{
  "servizio": "Nome servizio",
  "categoria": "Categoria specifica",
  "data_richiesta": "2025-12-21T10:30:00Z",
  "dati": {
    // Campi dinamici specifici per ogni servizio
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Richiesta ricevuta con successo",
  "data": {
    "id": 123,
    "numero_pratica": "WECOOP-2025-00123",
    "status": "pending"
  }
}
```

---

## 📂 SERVIZIO 1: ACCOGLIENZA E ORIENTAMENTO

### 1.1 Permesso di Soggiorno - Lavoro Subordinato
**Categoria**: `Lavoro Subordinato`

**Campi**:
```json
{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Lavoro Subordinato",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_provenienza": "string (required)",
    "tipo_contratto": "select: Determinato | Indeterminato (required)",
    "nome_azienda": "string (required)",
    "durata_contratto_mesi": "number (required)",
    "note_aggiuntive": "text (optional)"
  }
}
```

---

### 1.2 Permesso di Soggiorno - Lavoro Autonomo
**Categoria**: `Lavoro Autonomo`

**Campi**:
```json
{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Lavoro Autonomo",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_provenienza": "string (required)",
    "tipo_attivita": "string (required)",
    "ha_partita_iva": "select: Sì | No (required)",
    "descrizione_attivita": "textarea (required)"
  }
}
```

---

### 1.3 Permesso di Soggiorno - Motivi Familiari
**Categoria**: `Motivi Familiari`

**Campi**:
```json
{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Motivi Familiari",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_provenienza": "string (required)",
    "relazione_familiare": "select: Coniuge | Figlio/a | Genitore | Altro (required)",
    "nome_familiare_italia": "string (required)",
    "documento_identita_familiare": "string (required)"
  }
}
```

---

### 1.4 Permesso di Soggiorno - Studio
**Categoria**: `Studio`

**Campi**:
```json
{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Studio",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_provenienza": "string (required)",
    "nome_istituto_universita": "string (required)",
    "tipo_corso": "select: Laurea triennale | Laurea magistrale | Master | Dottorato | Altro (required)",
    "anno_iscrizione": "string (required)"
  }
}
```

---

### 1.5 Cittadinanza Italiana
**Categoria**: `Per residenza`

**Campi**:
```json
{
  "servizio": "Cittadinanza Italiana",
  "categoria": "Per residenza",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_nascita": "string (required)",
    "data_arrivo_italia": "date (required)",
    "indirizzo_residenza_attuale": "string (required)",
    "ha_precedenti_penali": "select: No | Sì (required)",
    "certificazione_lingua_italiana": "select: A2 | B1 | B2 | C1 | Non ho certificazione (required)",
    "situazione_lavorativa": "select: Dipendente | Autonomo | Disoccupato | Studente | Pensionato (required)",
    "note_aggiuntive": "textarea (optional)"
  }
}
```

---

### 1.6 Asilo Politico
**Categoria**: `Protezione Internazionale`

**Campi**:
```json
{
  "servizio": "Asilo Politico",
  "categoria": "Protezione Internazionale",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "paese_origine": "string (required)",
    "data_arrivo_italia": "date (required)",
    "motivo_richiesta": "select: Persecuzione politica | Persecuzione religiosa | Persecuzione per orientamento sessuale | Guerra/conflitto armato | Altro (required)",
    "descrizione_situazione": "textarea (required)",
    "ha_familiari_italia": "select: Sì | No (required)",
    "note_aggiuntive": "textarea (optional)"
  }
}
```

---

### 1.7 Visa per Turismo
**Categoria**: `Visto turistico`

**Campi**:
```json
{
  "servizio": "Visa per Turismo",
  "categoria": "Visto turistico",
  "dati": {
    "nome_completo": "string (required)",
    "data_nascita": "date (required)",
    "nazionalita": "string (required)",
    "numero_passaporto": "string (required)",
    "data_arrivo_prevista": "date (required)",
    "data_partenza_prevista": "date (required)",
    "motivo_viaggio": "select: Turismo | Visita famiglia | Affari | Altro (required)",
    "indirizzo_soggiorno_italia": "string (required)"
  }
}
```

---

## 📂 SERVIZIO 2: MEDIAZIONE FISCALE

### 2.1 Dichiarazione 730
**Categoria**: `730`

**Campi**:
```json
{
  "servizio": "Mediazione Fiscale",
  "categoria": "730",
  "dati": {
    "nome_completo": "string (required)",
    "codice_fiscale": "string (required)",
    "data_nascita": "date (required)",
    "indirizzo_residenza": "string (required)",
    "tipologia_contribuente": "select: Lavoratore dipendente | Pensionato (required)",
    "anno_fiscale": "select: 2024 | 2023 | 2022 (required)",
    "ha_spese_detraibili_deducibili": "select: Sì | No (required)",
    "note_informazioni_aggiuntive": "textarea (optional)"
  }
}
```

---

### 2.2 Persona Fisica
**Categoria**: `Persona Fisica`

**Campi**:
```json
{
  "servizio": "Mediazione Fiscale",
  "categoria": "Persona Fisica",
  "dati": {
    "nome_completo": "string (required)",
    "codice_fiscale": "string (required)",
    "data_nascita": "date (required)",
    "indirizzo_residenza": "string (required)",
    "tipologia_reddito": "select: Lavoro dipendente | Lavoro autonomo | Pensione | Redditi da capitale | Redditi diversi | Più tipologie (required)",
    "anno_fiscale": "select: 2024 | 2023 | 2022 (required)",
    "ha_immobili": "select: Sì | No (required)",
    "dettagli_note": "textarea (optional)"
  }
}
```

---

## 📂 SERVIZIO 3: SUPPORTO CONTABILE

### 3.1 Aprire Partita IVA
**Categoria**: `Aprire Partita IVA`

**Campi**:
```json
{
  "servizio": "Supporto Contabile",
  "categoria": "Aprire Partita IVA",
  "dati": {
    "nome_completo": "string (required)",
    "codice_fiscale": "string (required)",
    "data_nascita": "date (required)",
    "indirizzo_residenza": "string (required)",
    "tipo_attivita": "select: Commercio | Servizi | Artigianato | Libera professione | Altro (required)",
    "descrizione_attivita": "textarea (required)",
    "regime_fiscale_previsto": "select: Forfettario | Semplificato | Ordinario | Non so (required)",
    "fatturato_annuo_previsto_euro": "number (optional)"
  }
}
```

---

### 3.2 Gestire la Partita IVA
**Categoria**: `Gestire Partita IVA`

**Campi**:
```json
{
  "servizio": "Supporto Contabile",
  "categoria": "Gestire Partita IVA",
  "dati": {
    "nome_ragione_sociale": "string (required)",
    "partita_iva": "string (required)",
    "tipo_supporto_richiesto": "select: Fatturazione elettronica | Registrazione fatture | Gestione prima nota | Bilancio annuale | Consulenza generale (required)",
    "regime_fiscale_attuale": "select: Forfettario | Semplificato | Ordinario (required)",
    "descrivi_esigenza": "textarea (required)"
  }
}
```

---

### 3.3 Tasse e Contributi
**Categoria**: `Tasse e Contributi`

**Campi**:
```json
{
  "servizio": "Supporto Contabile",
  "categoria": "Tasse e Contributi",
  "dati": {
    "nome_ragione_sociale": "string (required)",
    "partita_iva": "string (required)",
    "tipo_adempimento": "select: Pagamento IVA | Contributi INPS | Acconto imposte | Saldo imposte | Altro (required)",
    "periodo_riferimento": "select: Trimestrale | Mensile | Annuale | Altro (required)",
    "descrizione": "textarea (optional)"
  }
}
```

---

### 3.4 Chiarimenti e Consulenza
**Categoria**: `Consulenza`

**Campi**:
```json
{
  "servizio": "Supporto Contabile",
  "categoria": "Consulenza",
  "dati": {
    "nome_completo": "string (required)",
    "email": "string (required)",
    "telefono": "string (required)",
    "ha_partita_iva": "select: Sì | No (required)",
    "argomento_consulenza": "select: Aspetti fiscali | Aspetti contributivi | Regime fiscale | Detrazioni/Deduzioni | Altro (required)",
    "descrivi_domanda": "textarea (required)"
  }
}
```

---

### 3.5 Chiudere o Cambiare Attività
**Categoria**: `Chiudere/Cambiare Attività`

**Campi**:
```json
{
  "servizio": "Supporto Contabile",
  "categoria": "Chiudere/Cambiare Attività",
  "dati": {
    "nome_ragione_sociale": "string (required)",
    "partita_iva": "string (required)",
    "cosa_vuoi_fare": "select: Chiudere partita IVA | Cambiare attività | Cambiare regime fiscale (required)",
    "data_prevista": "date (required)",
    "motivazione": "textarea (required)"
  }
}
```

---

## 🗂️ RIEPILOGO SERVIZI E CATEGORIE

| # | Servizio | Categoria | Endpoint |
|---|----------|-----------|----------|
| 1 | Permesso di Soggiorno | Lavoro Subordinato | `/richiesta-servizio` |
| 2 | Permesso di Soggiorno | Lavoro Autonomo | `/richiesta-servizio` |
| 3 | Permesso di Soggiorno | Motivi Familiari | `/richiesta-servizio` |
| 4 | Permesso di Soggiorno | Studio | `/richiesta-servizio` |
| 5 | Cittadinanza Italiana | Per residenza | `/richiesta-servizio` |
| 6 | Asilo Politico | Protezione Internazionale | `/richiesta-servizio` |
| 7 | Visa per Turismo | Visto turistico | `/richiesta-servizio` |
| 8 | Mediazione Fiscale | 730 | `/richiesta-servizio` |
| 9 | Mediazione Fiscale | Persona Fisica | `/richiesta-servizio` |
| 10 | Supporto Contabile | Aprire Partita IVA | `/richiesta-servizio` |
| 11 | Supporto Contabile | Gestire Partita IVA | `/richiesta-servizio` |
| 12 | Supporto Contabile | Tasse e Contributi | `/richiesta-servizio` |
| 13 | Supporto Contabile | Consulenza | `/richiesta-servizio` |
| 14 | Supporto Contabile | Chiudere/Cambiare Attività | `/richiesta-servizio` |

**Totale: 14 servizi/categorie**

---

## 💾 CUSTOM POST TYPE WordPress

### Nome CPT: `richiesta_servizio`

### Struttura Database

**Post Fields**:
- `post_title`: `{servizio} - {categoria} - {nome_completo}`
- `post_content`: JSON completo dei dati (per backup)
- `post_status`: `pending` (in attesa), `processing` (in lavorazione), `completed` (completato), `cancelled` (annullato)
- `post_type`: `richiesta_servizio`
- `post_author`: User ID (se loggato) o 0 (se anonimo)

**Post Meta**:
```php
// Dati struttura
'servizio' => 'string',
'categoria' => 'string',
'data_richiesta' => 'ISO8601 datetime',
'numero_pratica' => 'WECOOP-YYYY-NNNNN',

// Dati dinamici (variano per ogni servizio)
'dati_json' => 'JSON serializzato di tutti i campi',

// Campi comuni (se presenti)
'nome_completo' => 'string',
'email' => 'string',
'telefono' => 'string',
'codice_fiscale' => 'string',
'data_nascita' => 'date',

// Gestione pratica
'stato_pratica' => 'pending|processing|completed|cancelled',
'assegnato_a' => 'user_id dell\'operatore',
'note_interne' => 'text',
'data_completamento' => 'datetime',
```

---

## 🔐 SECURITY & VALIDATION

### Validazioni Obbligatorie

1. **Campi Required**
   - Verificare che tutti i campi con `"required": true` siano presenti
   - Ritornare errore 400 con messaggio specifico se mancanti

2. **Formato Email**
   ```php
   if (!is_email($email)) {
       return new WP_Error('invalid_email', 'Email non valida', ['status' => 400]);
   }
   ```

3. **Formato Codice Fiscale** (se presente)
   ```php
   if (strlen($codice_fiscale) !== 16) {
       return new WP_Error('invalid_cf', 'Codice fiscale deve essere 16 caratteri', ['status' => 400]);
   }
   ```

4. **Formato Date**
   - Accettare formati: `YYYY-MM-DD`, `DD/MM/YYYY`, ISO8601
   - Convertire sempre in formato WordPress standard

5. **Sanitization**
   ```php
   $nome = sanitize_text_field($dati['nome_completo']);
   $email = sanitize_email($dati['email']);
   $note = sanitize_textarea_field($dati['note']);
   ```

---

## 📧 EMAIL NOTIFICATIONS

### Email all'Utente (Conferma Ricezione)

**Subject**: `Richiesta {servizio} ricevuta - Pratica #{numero_pratica}`

**Body**:
```
Gentile {nome},

abbiamo ricevuto la tua richiesta per il servizio:
{servizio} - {categoria}

Numero pratica: {numero_pratica}
Data richiesta: {data_richiesta}

Ti contatteremo al più presto per darti assistenza.

Cordiali saluti,
Il team WECOOP
```

---

### Email all'Admin (Nuova Richiesta)

**Subject**: `[WECOOP] Nuova richiesta: {servizio} - {categoria}`

**Body**:
```
Nuova richiesta servizio ricevuta:

PRATICA: {numero_pratica}
SERVIZIO: {servizio}
CATEGORIA: {categoria}
DATA: {data_richiesta}

RICHIEDENTE:
Nome: {nome_completo}
Email: {email}
Telefono: {telefono}

DATI COMPLETI:
{lista tutti i campi}

Vai al pannello admin per gestire la pratica:
{link_admin_edit}
```

---

## 🎨 PANNELLO ADMIN WORDPRESS

### Menu Custom

**Posizione**: Menu principale WordPress
**Icon**: `dashicons-clipboard`
**Label**: "Richieste Servizi"

### Colonne Lista

| Colonna | Descrizione |
|---------|-------------|
| Numero Pratica | `WECOOP-2025-00123` |
| Servizio | Nome servizio principale |
| Categoria | Categoria specifica |
| Richiedente | Nome + Email + Telefono |
| Data Richiesta | gg/mm/aaaa hh:mm |
| Stato | Badge colorato (Pending/Processing/Completed/Cancelled) |
| Assegnato a | Nome operatore |
| Azioni | Visualizza / Modifica / Completa / Annulla |

### Filtri

- **Per Servizio**: Dropdown con tutti i servizi
- **Per Stato**: Pending / Processing / Completed / Cancelled
- **Per Data**: Range date
- **Per Operatore**: Se assegnato

### Metabox Dettaglio Pratica

**Box 1: Informazioni Generali**
- Numero pratica
- Servizio e categoria
- Data richiesta
- Stato pratica
- Assegnato a (dropdown per cambiare operatore)

**Box 2: Dati Richiedente**
- Nome completo
- Email (con link mailto)
- Telefono (con link tel)
- Altri dati comuni

**Box 3: Dettagli Servizio**
- Tabella con tutti i campi specifici del servizio
- Formato: `Label: Valore`

**Box 4: Gestione Pratica**
- Select stato pratica
- Textarea note interne
- Bottone "Salva modifiche"
- Bottone "Invia email al richiedente"
- Bottone "Segna come completata"

---

## 🔄 STATI PRATICA & WORKFLOW

### Stati Disponibili

1. **pending** (Giallo)
   - Pratica appena ricevuta
   - In attesa di presa in carico
   - Email di conferma inviata all'utente

2. **processing** (Blu)
   - Pratica assegnata a un operatore
   - In lavorazione
   - Possibile inviare email di aggiornamento

3. **completed** (Verde)
   - Pratica completata con successo
   - Email di completamento all'utente
   - Data completamento registrata

4. **cancelled** (Rosso)
   - Pratica annullata
   - Email di notifica all'utente con motivazione

### Workflow Automatico

```
Ricezione richiesta
    ↓
[PENDING] + Email conferma utente + Email notifica admin
    ↓
Operatore assegna a sé stesso
    ↓
[PROCESSING] + Email "In lavorazione" all'utente
    ↓
Operatore completa
    ↓
[COMPLETED] + Email "Completata" all'utente
```

---

## 📊 STATISTICHE & REPORT

### Dashboard Widget

Mostrare nel WordPress Dashboard:

```
RICHIESTE SERVIZI - OGGI
━━━━━━━━━━━━━━━━━━━━━━━━━
📥 Nuove richieste: 12
⏳ In attesa: 45
🔧 In lavorazione: 28
✅ Completate: 156
```

### Report Mensile

- Totale richieste per mese
- Richieste per servizio (grafico a torta)
- Richieste per categoria (grafico a barre)
- Tempo medio di completamento
- Operatore più produttivo
- Export CSV

---

## 🔑 AUTENTICAZIONE JWT

### Installa Plugin JWT
1. Installa: `JWT Authentication for WP REST API`
2. Configura `wp-config.php`:

```php
define('JWT_AUTH_SECRET_KEY', 'your-secret-key-here');
define('JWT_AUTH_CORS_ENABLE', true);
```

### Login e Ottieni Token
```http
POST /jwt-auth/v1/token
```

**Body:**
```json
{
  "username": "admin",
  "password": "your_password"
}
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_email": "admin@wecoop.org",
  "user_nicename": "admin",
  "user_display_name": "Admin"
}
```

### Usa Token nelle Richieste
```dart
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

---

## 📱 MODELLI DART

### Model: Socio
```dart
class Socio {
  final int? id;
  final String nome;
  final String cognome;
  final String email;
  final String? telefono;
  final String? dataNascita;
  final String? luogoNascita;
  final String? codiceFiscale;
  final String? indirizzo;
  final String? citta;
  final String? cap;
  final String? provincia;
  final String? professione;
  final String? motivazione;
  final String? numeroTessera;
  final String? status;
  final String? dataAdesione;

  Socio({
    this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.telefono,
    this.dataNascita,
    this.luogoNascita,
    this.codiceFiscale,
    this.indirizzo,
    this.citta,
    this.cap,
    this.provincia,
    this.professione,
    this.motivazione,
    this.numeroTessera,
    this.status,
    this.dataAdesione,
  });

  factory Socio.fromJson(Map<String, dynamic> json) => Socio(
    id: json['id'],
    nome: json['nome'] ?? '',
    cognome: json['cognome'] ?? '',
    email: json['email'] ?? '',
    telefono: json['telefono'],
    dataNascita: json['data_nascita'],
    luogoNascita: json['luogo_nascita'],
    codiceFiscale: json['codice_fiscale'],
    indirizzo: json['indirizzo'],
    citta: json['citta'],
    cap: json['cap'],
    provincia: json['provincia'],
    professione: json['professione'],
    numeroTessera: json['numero_tessera'],
    status: json['status'] ?? json['status_socio'],
    dataAdesione: json['data_adesione'],
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'telefono': telefono,
    'data_nascita': dataNascita,
    'luogo_nascita': luogoNascita,
    'codice_fiscale': codiceFiscale,
    'indirizzo': indirizzo,
    'citta': citta,
    'cap': cap,
    'provincia': provincia,
    'professione': professione,
    'motivazione': motivazione,
  };
}
```

---

### Model: RichiestaServizio
```dart
class RichiestaServizio {
  final String servizio;
  final String categoria;
  final Map<String, dynamic> dati;

  RichiestaServizio({
    required this.servizio,
    required this.categoria,
    required this.dati,
  });

  Map<String, dynamic> toJson() => {
    'servizio': servizio,
    'categoria': categoria,
    'data_richiesta': DateTime.now().toIso8601String(),
    'dati': dati,
  };
}
```

---

## 🛠️ SERVICE DART COMPLETO

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class WecoopApiService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  String? _token;

  // ========== AUTENTICAZIONE ==========
  
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://www.wecoop.org/wp-json/jwt-auth/v1/token'),
      body: {'username': username, 'password': password},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return true;
    }
    return false;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ========== SOCI ==========
  
  /// Invia richiesta adesione (PUBBLICO - no auth)
  Future<Map<String, dynamic>> inviaRichiestaAdesione(Socio socio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/soci/richiesta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(socio.toJson()),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Errore invio richiesta');
    }
  }

  /// Lista soci attivi (ADMIN)
  Future<List<Socio>> getSoci({
    String status = 'attivo',
    int page = 1,
    int perPage = 50,
    String? search,
  }) async {
    final queryParams = {
      'status': status,
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (search != null) 'search': search,
    };
    
    final uri = Uri.parse('$baseUrl/soci').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Socio.fromJson(json))
          .toList();
    } else {
      throw Exception('Errore caricamento soci');
    }
  }

  /// Dettaglio socio (ADMIN)
  Future<Socio> getSocioDettaglio(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/soci/$id'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Socio.fromJson(data['data']);
    } else {
      throw Exception('Socio non trovato');
    }
  }

  /// Verifica se email è socio attivo (PUBBLICO)
  Future<bool> verificaSocioAttivo(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final response = await http.get(
      Uri.parse('$baseUrl/soci/verifica/$encodedEmail'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_attivo'] ?? false;
    }
    return false;
  }

  /// Cambia status socio (ADMIN)
  Future<void> cambiaStatusSocio(
    int id,
    String status, {
    String? motivo,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/soci/$id/status'),
      headers: _headers,
      body: jsonEncode({
        'status': status,
        'motivo': motivo,
        'data_effetto': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
  }

  /// Statistiche soci (ADMIN)
  Future<Map<String, dynamic>> getStatsSoci() async {
    final response = await http.get(
      Uri.parse('$baseUrl/soci/stats'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    return data['data'];
  }

  /// Aggiungi pagamento (ADMIN)
  Future<void> aggiungiPagamento(
    int socioId,
    double importo,
    String tipo, {
    String? metodo,
    String? note,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/soci/$socioId/pagamenti'),
      headers: _headers,
      body: jsonEncode({
        'importo': importo,
        'tipo': tipo,
        'data_pagamento': DateTime.now().toIso8601String().split('T')[0],
        'metodo': metodo ?? 'contanti',
        'note': note,
      }),
    );
  }

  // ========== SERVIZI ==========
  
  /// Invia richiesta servizio (SOLO SOCI)
  Future<Map<String, dynamic>> inviaRichiestaServizio(
    RichiestaServizio richiesta,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servizi/richiesta'),
      headers: _headers,
      body: jsonEncode(richiesta.toJson()),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Errore invio richiesta');
    }
  }

  /// Lista richieste servizi (ADMIN)
  Future<List<Map<String, dynamic>>> getRichiesteServizi({
    String? servizio,
    String? status,
    int page = 1,
  }) async {
    final queryParams = {
      if (servizio != null) 'servizio': servizio,
      if (status != null) 'status': status,
      'page': page.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/servizi/richieste')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Errore caricamento richieste');
    }
  }
}
```

---

## 💡 ESEMPIO USO COMPLETO

```dart
void main() async {
  final api = WecoopApiService();
  
  // ========== PUBBLICO - Richiesta Adesione ==========
  
  final nuovoSocio = Socio(
    nome: 'Mario',
    cognome: 'Rossi',
    email: 'mario@example.com',
    telefono: '+39 333 1234567',
    dataNascita: '1985-03-15',
    luogoNascita: 'Roma',
    codiceFiscale: 'RSSMRA85C15H501A',
    indirizzo: 'Via Roma 123',
    citta: 'Milano',
    cap: '20100',
    provincia: 'MI',
    professione: 'Ingegnere',
    motivazione: 'Voglio far parte della cooperativa',
  );
  
  final result = await api.inviaRichiestaAdesione(nuovoSocio);
  print('Pratica creata: ${result['data']['numero_pratica']}');
  
  // ========== PUBBLICO - Verifica Socio ==========
  
  final isSocio = await api.verificaSocioAttivo('mario@example.com');
  print('È socio attivo: $isSocio');
  
  // ========== ADMIN - Login ==========
  
  await api.login('admin', 'password');
  
  // ========== ADMIN - Lista Soci ==========
  
  final soci = await api.getSoci(status: 'attivo');
  print('Soci attivi: ${soci.length}');
  
  // ========== ADMIN - Statistiche ==========
  
  final stats = await api.getStatsSoci();
  print('Totale soci: ${stats['totale_soci']}');
  print('Richieste pending: ${stats['richieste_pending']}');
  
  // ========== SOCIO - Richiesta Servizio ==========
  
  final richiestaServizio = RichiestaServizio(
    servizio: 'Permesso di Soggiorno',
    categoria: 'Lavoro Subordinato',
    dati: {
      'nome_completo': 'Mario Rossi',
      'data_nascita': '1985-03-15',
      'paese_provenienza': 'Romania',
      'tipo_contratto': 'Indeterminato',
      'nome_azienda': 'Acme SRL',
      'durata_contratto_mesi': 12,
    },
  );
  
  final servizioResult = await api.inviaRichiestaServizio(richiestaServizio);
  print('Servizio richiesto: ${servizioResult['data']['numero_pratica']}');
}
```

---

## ⚠️ ERROR HANDLING

**Success Response (200):**
```json
{
  "success": true,
  "data": {...}
}
```

**Error Response (4xx/5xx):**
```json
{
  "code": "not_found",
  "message": "Risorsa non trovata",
  "data": {
    "status": 404
  }
}
```

**Dart Error Handler:**
```dart
Future<T> handleApiCall<T>(Future<http.Response> Function() apiCall) async {
  try {
    final response = await apiCall();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        error['message'] ?? 'Errore sconosciuto',
        statusCode: response.statusCode,
      );
    }
  } on SocketException {
    throw ApiException('Nessuna connessione internet');
  } on TimeoutException {
    throw ApiException('Timeout: server non risponde');
  } catch (e) {
    throw ApiException('Errore: $e');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}
```

---

## 📊 RIEPILOGO ENDPOINTS

### 👥 SOCI (15 endpoints)

**✅ Pubblico (no auth):**
- `POST /soci/richiesta` - Nuova richiesta adesione
- `GET /soci/verifica/{email}` - Verifica socio attivo

**🔒 Admin only:**
- `GET /soci/richieste` - Lista richieste adesione
- `GET /soci/richiesta/{id}` - Dettaglio richiesta
- `POST /soci/richiesta/{id}/approva` - Approva richiesta
- `POST /soci/richiesta/{id}/rifiuta` - Rifiuta richiesta
- `GET /soci` - Lista soci
- `GET /soci/{id}` - Dettaglio socio
- `PUT /soci/{id}` - Modifica dati socio
- `POST /soci/{id}/status` - Cambia status socio
- `GET /soci/stats` - Statistiche soci
- `GET /soci/{id}/pagamenti` - Storico pagamenti
- `POST /soci/{id}/pagamenti` - Aggiungi pagamento
- `GET /soci/{id}/documenti` - Lista documenti
- `POST /soci/{id}/documenti` - Upload documento

---

### 📋 SERVIZI (6 endpoints base + 14 categorie)

**🔐 Solo Soci Attivi:**
- `POST /servizi/richiesta` - Nuova richiesta servizio

**🔒 Admin only:**
- `GET /servizi/richieste` - Lista richieste
- `GET /servizi/richiesta/{id}` - Dettaglio richiesta
- `PUT /servizi/richiesta/{id}` - Modifica richiesta
- `POST /servizi/richiesta/{id}/status` - Cambia status
- `GET /servizi/stats` - Statistiche servizi

---

```php
<?php
add_action('rest_api_init', function() {
    register_rest_route('wecoop/v1', '/richiesta-servizio', [
        'methods' => 'POST',
        'callback' => 'wecoop_handle_richiesta_servizio',
        'permission_callback' => '__return_true', // Pubblico
    ]);
});

function wecoop_handle_richiesta_servizio($request) {
    $params = $request->get_json_params();
    
    // Validazione
    if (empty($params['servizio']) || empty($params['categoria']) || empty($params['dati'])) {
        return new WP_Error('missing_fields', 'Campi obbligatori mancanti', ['status' => 400]);
    }
    
    // Sanitizzazione
    $servizio = sanitize_text_field($params['servizio']);
    $categoria = sanitize_text_field($params['categoria']);
    $dati = $params['dati'];
    
    // Genera numero pratica
    $numero_pratica = wecoop_genera_numero_pratica();
    
    // Crea post
    $post_id = wp_insert_post([
        'post_title' => "{$servizio} - {$categoria} - " . ($dati['nome_completo'] ?? 'N/A'),
        'post_content' => json_encode($dati, JSON_PRETTY_PRINT),
        'post_status' => 'pending',
        'post_type' => 'richiesta_servizio',
        'post_author' => get_current_user_id(),
    ]);
    
    if (is_wp_error($post_id)) {
        return $post_id;
    }
    
    // Salva meta
    update_post_meta($post_id, 'servizio', $servizio);
    update_post_meta($post_id, 'categoria', $categoria);
    update_post_meta($post_id, 'numero_pratica', $numero_pratica);
    update_post_meta($post_id, 'data_richiesta', current_time('c'));
    update_post_meta($post_id, 'dati_json', json_encode($dati));
    update_post_meta($post_id, 'stato_pratica', 'pending');
    
    // Salva campi comuni
    foreach ($dati as $key => $value) {
        update_post_meta($post_id, $key, sanitize_text_field($value));
    }
    
    // Invia email
    wecoop_send_email_conferma($post_id, $dati);
    wecoop_send_email_admin($post_id, $servizio, $categoria, $dati);
    
    return [
        'success' => true,
        'message' => 'Richiesta ricevuta con successo',
        'id' => $post_id,
        'numero_pratica' => $numero_pratica,
    ];
}

function wecoop_genera_numero_pratica() {
    $anno = date('Y');
    $count = wp_count_posts('richiesta_servizio')->publish + 
             wp_count_posts('richiesta_servizio')->pending + 1;
    return "WECOOP-{$anno}-" . str_pad($count, 5, '0', STR_PAD_LEFT);
}
```

---

## 🎓 PROMPT PER AI - GENERAZIONE CODICE COMPLETO

Usa questo prompt con ChatGPT/Claude:

```
Crea un plugin WordPress completo chiamato "WECOOP Gestione Servizi" che:

1. Registri un Custom Post Type "richiesta_servizio"
2. Crei un endpoint REST API POST /wp-json/wecoop/v1/richiesta-servizio
3. Gestisca 14 tipi di servizi con categorie diverse (vedi lista sopra)
4. Salvi tutti i dati come post_meta in formato dinamico
5. Generi numero pratica progressivo annuale (WECOOP-YYYY-NNNNN)
6. Invii email automatiche a utente e admin
7. Crei pannello admin con:
   - Colonne custom (Numero Pratica, Servizio, Categoria, Richiedente, Data, Stato)
   - Filtri per servizio, stato, data
   - Metabox per visualizzare/modificare pratica
   - Cambio stato con workflow
8. Stati: pending, processing, completed, cancelled
9. Validazioni complete e sanitizzazione dati
10. Dashboard widget con statistiche

Il plugin deve essere production-ready, sicuro e ben commentato.
```

---

## 📚 RIFERIMENTI

- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [Custom Post Types](https://developer.wordpress.org/plugins/post-types/)
- [Post Meta API](https://developer.wordpress.org/reference/functions/update_post_meta/)
- [wp_mail()](https://developer.wordpress.org/reference/functions/wp_mail/)

---

## ✅ CHECKLIST IMPLEMENTAZIONE

- [ ] Creare Custom Post Type `richiesta_servizio`
- [ ] Registrare endpoint REST API `/richiesta-servizio`
- [ ] Implementare validazioni per tutti i campi
- [ ] Configurare sanitizzazione dati
- [ ] Generatore numero pratica progressivo
- [ ] Email conferma utente
- [ ] Email notifica admin
- [ ] Pannello admin con colonne custom
- [ ] Filtri per servizio/stato/data
- [ ] Metabox dettaglio pratica
- [ ] Sistema cambio stato
- [ ] Dashboard widget statistiche
- [ ] Testing con dati reali
- [ ] Documentazione utente finale

---

**Ultima revisione**: 21 Dicembre 2025
**Autore**: WECOOP Development Team
