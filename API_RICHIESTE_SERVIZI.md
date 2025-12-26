# 📋 API Richieste Servizi - WeCoop

**Base URL**: `https://www.wecoop.org/wp-json/wecoop/v1`

---

## 🔐 Autenticazione

Tutti gli endpoint richiedono autenticazione JWT:
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
Accept-Language: it|en|es
```

**Requisito**: Solo utenti con `status = 'attivo'` nella tabella `wp_wecoop_soci` possono inviare richieste.

---

## 1. Invia Richiesta Servizio

**Endpoint**: `POST /richiesta-servizio`

**Descrizione**: Crea una nuova richiesta di servizio

**Headers**:
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
Accept-Language: it
```

**Body Base**:
```json
{
  "servizio": "Chiave standard servizio (vedi tabella)",
  "categoria": "Chiave standard categoria (vedi tabella)",
  "dati": {
    // campi dinamici basati sul tipo di servizio
  }
}
```

### 🔑 Chiavi Standardizzate

Per garantire consistenza tra le diverse lingue dell'app (italiano/inglese/spagnolo), il campo `servizio` e `categoria` vengono inviati con **chiavi standardizzate in inglese**.

**Servizi disponibili**:
- `caf_tax_assistance` - CAF - Assistenza Fiscale / Tax Assistance / Asistencia Fiscal
- `immigration_desk` - Sportello Immigrazione / Immigration Desk / Oficina de Inmigración
- `accounting_support` - Supporto Contabile / Accounting Support / Soporte Contable
- `tax_mediation` - Mediazione Fiscale / Tax Mediation / Mediación Fiscal

**Categorie disponibili**:
- `tax_return_730` - Dichiarazione dei Redditi (730)
- `form_compilation` - Compilazione Modelli
- `residence_permit` - Permesso di Soggiorno / Residence Permit / Permiso de Residencia
- `citizenship` - Cittadinanza / Citizenship / Ciudadanía
- `tourist_visa` - Visto Turistico / Tourist Visa / Visa Turística
- `asylum_request` - Richiesta Asilo / Asylum Request / Solicitud de Asilo
- `income_tax_return` - Dichiarazione Redditi
- `vat_number_opening` - Apertura Partita IVA
- `accounting_management` - Gestione Contabilità
- `tax_compliance` - Adempimenti Fiscali
- `tax_consultation` - Consulenza Fiscale
- `tax_debt_management` - Gestione Debiti Fiscali

---

### Campi "dati" per Tipologia di Servizio

#### 📊 CAF - Dichiarazione dei Redditi (730)
```json
{
  "servizio": "caf_tax_assistance",
  "categoria": "tax_return_730",
  "dati": {
    "nome_completo": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "telefono": "3331234567",
    "codice_fiscale": "RSSMRA80A01H501U",
    "anno_fiscale": "2024",
    "tipo_dichiarazione": "730 ordinario",
    "note": "Ho anche redditi da lavoro autonomo",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `codice_fiscale`, `anno_fiscale`

---

#### 📄 CAF - Compilazione Modelli
```json
{
  "servizio": "caf_tax_assistance",
  "categoria": "form_compilation",
  "dati": {
    "nome_completo": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "telefono": "3331234567",
    "tipo_modello": "F24",
    "descrizione": "Necessito compilazione modello F24 per pagamento IMU",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori tipo_modello**: `"F24"`, `"ISEE"`, `"RED"`, `"Altro"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `tipo_modello`

---

#### 🛂 Sportello - Permesso di Soggiorno
```json
{
  "servizio": "immigration_desk",
  "categoria": "residence_permit",
  "dati": {
    "nome_completo": "Ahmed Hassan",
    "email": "ahmed.hassan@example.com",
    "telefono": "3331234567",
    "data_nascita": "1990-05-15",
    "paese_provenienza": "Egitto",
    "tipo_permesso": "Lavoro",
    "tipo_contratto": "Determinato a tempo pieno",
    "nome_azienda": "ABC Srl",
    "data_arrivo_italia": "2023-01-10",
    "indirizzo_residenza_attuale": "Via Roma 123, Milano",
    "motivo_richiesta": "Primo rilascio",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori tipo_permesso**: `"Lavoro"`, `"Studio"`, `"Famiglia"`, `"Protezione internazionale"`

**Campi condizionali**:
- Se `tipo_permesso = "Lavoro"`: richiede `tipo_contratto`, `nome_azienda`
- Se `tipo_permesso = "Famiglia"`: richiede `relazione_familiare`
- Se `tipo_permesso = "Studio"`: richiede `nome_istituto_universita`

**Valori motivo_richiesta**: `"Primo rilascio"`, `"Rinnovo"`, `"Conversione"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `data_nascita`, `paese_provenienza`, `tipo_permesso`, `data_arrivo_italia`, `motivo_richiesta`

---

#### 🇮🇹 Sportello - Cittadinanza
```json
{
  "servizio": "immigration_desk",
  "categoria": "citizenship",
  "dati": {
    "nome_completo": "Maria Silva",
    "email": "maria.silva@example.com",
    "telefono": "3331234567",
    "data_nascita": "1985-03-20",
    "luogo_nascita": "San Paolo",
    "paese_nascita": "Brasile",
    "data_arrivo_italia": "2013-06-01",
    "indirizzo_residenza_attuale": "Via Verdi 45, Roma",
    "motivo_richiesta": "Cittadinanza per residenza (10 anni)",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `data_nascita`, `luogo_nascita`, `paese_nascita`, `data_arrivo_italia`, `indirizzo_residenza_attuale`, `motivo_richiesta`

---

#### ✈️ Sportello - Visto Turistico
```json
{
  "servizio": "immigration_desk",
  "categoria": "tourist_visa",
  "dati": {
    "nome_completo": "John Smith",
    "email": "john.smith@example.com",
    "telefono": "3331234567",
    "nazionalita": "USA",
    "numero_passaporto": "X12345678",
    "data_arrivo_prevista": "2025-07-01",
    "durata_soggiorno_giorni": "30",
    "motivo_viaggio": "Turismo - Visita città d'arte",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `nazionalita`, `numero_passaporto`, `data_arrivo_prevista`, `durata_soggiorno_giorni`, `motivo_viaggio`

---

#### 🆘 Sportello - Richiesta Asilo
```json
{
  "servizio": "immigration_desk",
  "categoria": "asylum_request",
  "dati": {
    "nome_completo": "Ali Mohammed",
    "email": "ali.mohammed@example.com",
    "telefono": "3331234567",
    "data_nascita": "1988-12-10",
    "paese_provenienza": "Siria",
    "data_arrivo_italia": "2024-11-20",
    "motivo_richiesta": "Persecuzione politica",
    "documenti_disponibili": "Passaporto, certificato di nascita",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `data_nascita`, `paese_provenienza`, `data_arrivo_italia`, `motivo_richiesta`

---

#### 💼 Contabilità - Dichiarazione Redditi
```json
{
  "servizio": "accounting_support",
  "categoria": "income_tax_return",
  "dati": {
    "nome_completo": "Laura Bianchi",
    "email": "laura.bianchi@example.com",
    "telefono": "3331234567",
    "codice_fiscale": "BNCLRA75D50H501Z",
    "partita_iva": "12345678901",
    "anno_fiscale": "2024",
    "tipo_reddito": "Misto",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori tipo_reddito**: `"Dipendente"`, `"Autonomo"`, `"Misto"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `codice_fiscale`, `anno_fiscale`, `tipo_reddito`

---

#### 🆕 Contabilità - Apertura Partita IVA
```json
{
  "servizio": "accounting_support",
  "categoria": "vat_number_opening",
  "dati": {
    "nome_completo": "Marco Verdi",
    "email": "marco.verdi@example.com",
    "telefono": "3331234567",
    "codice_fiscale": "VRDMRC80A01F205X",
    "tipo_attivita": "Consulenza informatica",
    "regime_fiscale": "Forfettario",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori regime_fiscale**: `"Forfettario"`, `"Ordinario"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `codice_fiscale`, `tipo_attivita`, `regime_fiscale`

---

#### 📈 Contabilità - Gestione Contabilità
```json
{
  "servizio": "accounting_support",
  "categoria": "accounting_management",
  "dati": {
    "nome_completo": "Giulia Neri",
    "email": "giulia.neri@example.com",
    "telefono": "3331234567",
    "partita_iva": "12345678901",
    "tipo_supporto_richiesto": "Mensile",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori tipo_supporto_richiesto**: `"Mensile"`, `"Trimestrale"`, `"Annuale"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `partita_iva`, `tipo_supporto_richiesto`

---

#### 📝 Contabilità - Adempimenti Fiscali
```json
{
  "servizio": "accounting_support",
  "categoria": "tax_compliance",
  "dati": {
    "nome_completo": "Paolo Gialli",
    "email": "paolo.gialli@example.com",
    "telefono": "3331234567",
    "partita_iva": "12345678901",
    "tipo_adempimento": "IVA",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori tipo_adempimento**: `"IVA"`, `"F24"`, `"Contributi"`, `"Altro"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `partita_iva`, `tipo_adempimento`

---

#### 💡 Contabilità - Consulenza Fiscale
```json
{
  "servizio": "accounting_support",
  "categoria": "tax_consultation",
  "dati": {
    "nome_completo": "Sara Blu",
    "email": "sara.blu@example.com",
    "telefono": "3331234567",
    "argomento_consulenza": "Pianificazione fiscale per nuova attività",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `argomento_consulenza`

---

#### ⚖️ Mediazione Fiscale
```json
{
  "servizio": "tax_mediation",
  "categoria": "tax_debt_management",
  "dati": {
    "nome_completo": "Andrea Grigi",
    "email": "andrea.grigi@example.com",
    "telefono": "3331234567",
    "codice_fiscale": "GRGAND70A01H501W",
    "cosa_vuoi_fare": "Rateizzare",
    "descrizione_situazione": "Cartella esattoriale di €15.000 per IVA non versata",
    "socio_id": "42",
    "user_id": "123"
  }
}
```

**Valori cosa_vuoi_fare**: `"Rateizzare"`, `"Sospendere"`, `"Annullare"`, `"Richiedere Sgravio"`

**Campi obbligatori**: `nome_completo`, `email`, `telefono`, `codice_fiscale`, `cosa_vuoi_fare`, `descrizione_situazione`

---

## Response Success (200/201)

```json
{
  "success": true,
  "message": "Richiesta ricevuta con successo",
  "id": 789,
  "numero_pratica": "WECOOP-2025-00001",
  "data_richiesta": "2024-01-15 10:30:00"
}
```

**Logica numero_pratica**: `WECOOP-{ANNO}-{PROGRESSIVO_5_CIFRE}`

---

## Response Errors

### 400 - Bad Request
```json
{
  "success": false,
  "message": "Campo obbligatorio mancante: email"
}
```

**Cause comuni**:
- Campo obbligatorio mancante
- Formato data non valido (deve essere YYYY-MM-DD)
- Email non valida
- Tipo di dato errato

---

### 401 - Unauthorized
```json
{
  "success": false,
  "message": "Devi essere autenticato. Effettua il login."
}
```

**Cause**:
- Token JWT mancante
- Token JWT scaduto
- Token JWT non valido

---

### 403 - Forbidden
```json
{
  "success": false,
  "message": "Non hai i permessi. Solo i soci possono richiedere servizi."
}
```

**Cause**:
- Utente non è un socio (non presente in `wp_wecoop_soci`)
- Status socio non è `'attivo'` (è `'pending'` o `'sospeso'`)

**Query Validazione**:
```sql
SELECT * FROM wp_wecoop_soci 
WHERE user_id = {user_id_from_jwt} 
AND status = 'attivo'
```

---

## 2. Lista Mie Richieste

**Endpoint**: `GET /mie-richieste?page={p}&per_page={n}&stato={s}`

**Descrizione**: Ottiene lista richieste dell'utente autenticato

**Query Params**:
- `page`: Numero pagina (default: 1)
- `per_page`: Risultati per pagina (default: 20)
- `stato`: `"in_attesa"` | `"in_lavorazione"` | `"completata"` | `"annullata"` (opzionale)

**Response Success (200)**:
```json
{
  "success": true,
  "richieste": [
    {
      "id": 789,
      "numero_pratica": "WECOOP-2025-00001",
      "servizio": "CAF - Assistenza Fiscale",
      "categoria": "Dichiarazione dei Redditi (730)",
      "stato": "in_lavorazione",
      "data_richiesta": "2024-01-15 10:30:00",
      "data_ultima_modifica": "2024-01-16 14:20:00",
      "operatore_assegnato": "Giuseppe Bianchi",
      "note_interne": "In attesa di documentazione"
    },
    {
      "id": 790,
      "numero_pratica": "WECOOP-2025-00002",
      "servizio": "Sportello Immigrazione",
      "categoria": "Permesso di Soggiorno",
      "stato": "completata",
      "data_richiesta": "2024-01-10 09:15:00",
      "data_ultima_modifica": "2024-01-20 16:00:00",
      "operatore_assegnato": "Maria Verdi",
      "note_interne": "Pratica completata con successo"
    }
  ],
  "pagination": {
    "total": 12,
    "per_page": 20,
    "current_page": 1,
    "total_pages": 1
  }
}
```

---

## 3. Dettaglio Richiesta

**Endpoint**: `GET /richiesta-servizio/{id}`

**Descrizione**: Ottiene dettagli completi di una richiesta specifica

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "id": 789,
    "numero_pratica": "WECOOP-2025-00001",
    "servizio": "CAF - Assistenza Fiscale",
    "categoria": "Dichiarazione dei Redditi (730)",
    "stato": "in_lavorazione",
    "data_richiesta": "2024-01-15 10:30:00",
    "data_ultima_modifica": "2024-01-16 14:20:00",
    "operatore_assegnato": "Giuseppe Bianchi",
    "dati_richiesta": {
      "nome_completo": "Mario Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "3331234567",
      "codice_fiscale": "RSSMRA80A01H501U",
      "anno_fiscale": "2024",
      "tipo_dichiarazione": "730 ordinario",
      "note": "Ho anche redditi da lavoro autonomo"
    },
    "cronologia": [
      {
        "data": "2024-01-15 10:30:00",
        "stato": "in_attesa",
        "nota": "Richiesta ricevuta",
        "operatore": null
      },
      {
        "data": "2024-01-16 09:00:00",
        "stato": "in_lavorazione",
        "nota": "Assegnata a Giuseppe Bianchi",
        "operatore": "Admin"
      },
      {
        "data": "2024-01-16 14:20:00",
        "stato": "in_lavorazione",
        "nota": "Richiesta documentazione aggiuntiva via email",
        "operatore": "Giuseppe Bianchi"
      }
    ],
    "documenti": [
      {
        "id": 1,
        "nome": "CU_2024.pdf",
        "url": "https://wecoop.org/uploads/doc123.pdf",
        "tipo": "application/pdf",
        "dimensione_kb": 245,
        "data_caricamento": "2024-01-16 15:00:00",
        "caricato_da": "Mario Rossi"
      }
    ]
  }
}
```

**Response Error (404)**:
```json
{
  "success": false,
  "message": "Richiesta non trovata"
}
```

**Response Error (403)**:
```json
{
  "success": false,
  "message": "Non hai i permessi per visualizzare questa richiesta"
}
```

**Validazione**: L'utente può visualizzare solo le proprie richieste (`user_id` dal JWT deve corrispondere)

---

## 📊 Struttura Database

### Tabella: wp_wecoop_richieste_servizi

```sql
CREATE TABLE wp_wecoop_richieste_servizi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  numero_pratica VARCHAR(50) UNIQUE NOT NULL,
  socio_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  servizio VARCHAR(255) NOT NULL,
  categoria VARCHAR(255) NOT NULL,
  dati_richiesta LONGTEXT NOT NULL,
  stato ENUM('in_attesa', 'in_lavorazione', 'completata', 'annullata') DEFAULT 'in_attesa',
  operatore_assegnato BIGINT UNSIGNED,
  note_interne TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_socio_id (socio_id),
  INDEX idx_user_id (user_id),
  INDEX idx_stato (stato),
  INDEX idx_numero_pratica (numero_pratica),
  FOREIGN KEY (socio_id) REFERENCES wp_wecoop_soci(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES wp_users(ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Note campo `dati_richiesta`**:
- Tipo `LONGTEXT` per contenere JSON con campi dinamici
- Memorizzare come JSON serializzato
- Al salvataggio: `json_encode($dati)`
- Al recupero: `json_decode($dati_richiesta, true)`

---

### Tabella: wp_wecoop_richieste_cronologia (Opzionale)

```sql
CREATE TABLE wp_wecoop_richieste_cronologia (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  richiesta_id BIGINT UNSIGNED NOT NULL,
  stato VARCHAR(50) NOT NULL,
  nota TEXT,
  operatore_id BIGINT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_richiesta_id (richiesta_id),
  FOREIGN KEY (richiesta_id) REFERENCES wp_wecoop_richieste_servizi(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### Tabella: wp_wecoop_richieste_documenti (Opzionale)

```sql
CREATE TABLE wp_wecoop_richieste_documenti (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  richiesta_id BIGINT UNSIGNED NOT NULL,
  nome_file VARCHAR(255) NOT NULL,
  url VARCHAR(500) NOT NULL,
  tipo_mime VARCHAR(100),
  dimensione_kb INT,
  caricato_da BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_richiesta_id (richiesta_id),
  FOREIGN KEY (richiesta_id) REFERENCES wp_wecoop_richieste_servizi(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔧 Implementazione Backend (WordPress)

### File: wp-content/plugins/wecoop-api/endpoints/richieste-servizi.php

```php
<?php

// POST /richiesta-servizio
add_action('rest_api_init', function() {
    register_rest_route('wecoop/v1', '/richiesta-servizio', [
        'methods' => 'POST',
        'callback' => 'wecoop_crea_richiesta_servizio',
        'permission_callback' => 'wecoop_check_socio_attivo'
    ]);
});

function wecoop_crea_richiesta_servizio($request) {
    global $wpdb;
    
    // 1. Estrai user_id dal JWT
    $user_id = get_current_user_id();
    
    // 2. Verifica socio attivo
    $socio = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}wecoop_soci 
         WHERE user_id = %d AND status = 'attivo'",
        $user_id
    ));
    
    if (!$socio) {
        return new WP_Error('forbidden', 'Solo i soci attivi possono richiedere servizi', ['status' => 403]);
    }
    
    // 3. Valida parametri
    $params = $request->get_json_params();
    $servizio = sanitize_text_field($params['servizio'] ?? '');
    $categoria = sanitize_text_field($params['categoria'] ?? '');
    $dati = $params['dati'] ?? [];
    
    if (empty($servizio) || empty($categoria) || empty($dati)) {
        return new WP_Error('bad_request', 'Parametri mancanti', ['status' => 400]);
    }
    
    // 4. Valida campi obbligatori in dati
    $campi_obbligatori = ['nome_completo', 'email', 'telefono'];
    foreach ($campi_obbligatori as $campo) {
        if (empty($dati[$campo])) {
            return new WP_Error('bad_request', "Campo obbligatorio mancante: $campo", ['status' => 400]);
        }
    }
    
    // 5. Genera numero pratica
    $anno = date('Y');
    $ultimo_numero = $wpdb->get_var($wpdb->prepare(
        "SELECT MAX(CAST(SUBSTRING(numero_pratica, -5) AS UNSIGNED)) 
         FROM {$wpdb->prefix}wecoop_richieste_servizi 
         WHERE numero_pratica LIKE %s",
        "WECOOP-$anno-%"
    ));
    $progressivo = str_pad(($ultimo_numero ?? 0) + 1, 5, '0', STR_PAD_LEFT);
    $numero_pratica = "WECOOP-$anno-$progressivo";
    
    // 6. Aggiungi socio_id e user_id ai dati
    $dati['socio_id'] = (string)$socio->id;
    $dati['user_id'] = (string)$user_id;
    
    // 7. Inserisci nel database
    $result = $wpdb->insert(
        "{$wpdb->prefix}wecoop_richieste_servizi",
        [
            'numero_pratica' => $numero_pratica,
            'socio_id' => $socio->id,
            'user_id' => $user_id,
            'servizio' => $servizio,
            'categoria' => $categoria,
            'dati_richiesta' => json_encode($dati, JSON_UNESCAPED_UNICODE),
            'stato' => 'in_attesa'
        ],
        ['%s', '%d', '%d', '%s', '%s', '%s', '%s']
    );
    
    if ($result === false) {
        return new WP_Error('server_error', 'Errore durante il salvataggio', ['status' => 500]);
    }
    
    $richiesta_id = $wpdb->insert_id;
    
    // 8. Crea voce in cronologia (opzionale)
    $wpdb->insert(
        "{$wpdb->prefix}wecoop_richieste_cronologia",
        [
            'richiesta_id' => $richiesta_id,
            'stato' => 'in_attesa',
            'nota' => 'Richiesta ricevuta'
        ]
    );
    
    // 9. Invia email notifica (opzionale)
    // wp_mail(...);
    
    // 10. Response
    return new WP_REST_Response([
        'success' => true,
        'message' => 'Richiesta ricevuta con successo',
        'id' => $richiesta_id,
        'numero_pratica' => $numero_pratica,
        'data_richiesta' => current_time('mysql')
    ], 201);
}

function wecoop_check_socio_attivo($request) {
    if (!is_user_logged_in()) {
        return false;
    }
    
    global $wpdb;
    $user_id = get_current_user_id();
    
    $count = $wpdb->get_var($wpdb->prepare(
        "SELECT COUNT(*) FROM {$wpdb->prefix}wecoop_soci 
         WHERE user_id = %d AND status = 'attivo'",
        $user_id
    ));
    
    return $count > 0;
}
```

---

## 🧪 Testing

### Test con cURL - CAF 730

```bash
curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/richiesta-servizio \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -H "Accept-Language: it" \
  -d '{
    "servizio": "caf_tax_assistance",
    "categoria": "tax_return_730",
    "dati": {
      "nome_completo": "Mario Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "3331234567",
      "codice_fiscale": "RSSMRA80A01H501U",
      "anno_fiscale": "2024",
      "tipo_dichiarazione": "730 ordinario",
      "note": "Ho anche redditi da lavoro autonomo"
    }
  }'
```

### Test con cURL - Permesso Soggiorno

```bash
curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/richiesta-servizio \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{
    "servizio": "immigration_desk",
    "categoria": "residence_permit",
    "dati": {
      "nome_completo": "Ahmed Hassan",
      "email": "ahmed.hassan@example.com",
      "telefono": "3331234567",
      "data_nascita": "1990-05-15",
      "paese_provenienza": "Egitto",
      "tipo_permesso": "Lavoro",
      "tipo_contratto": "Determinato a tempo pieno",
      "nome_azienda": "ABC Srl",
      "data_arrivo_italia": "2023-01-10",
      "indirizzo_residenza_attuale": "Via Roma 123, Milano",
      "motivo_richiesta": "Primo rilascio"
    }
  }'
```

### Test Lista Richieste

```bash
curl https://www.wecoop.org/wp-json/wecoop/v1/mie-richieste?stato=in_lavorazione \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."
```

### Test Dettaglio Richiesta

```bash
curl https://www.wecoop.org/wp-json/wecoop/v1/richiesta-servizio/789 \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."
```

---

## 📋 Checklist Implementazione

### Backend (WordPress)
- [ ] Creare tabella `wp_wecoop_richieste_servizi`
- [ ] Creare tabella `wp_wecoop_richieste_cronologia` (opzionale)
- [ ] Creare tabella `wp_wecoop_richieste_documenti` (opzionale)
- [ ] Implementare `POST /richiesta-servizio`
- [ ] Implementare `GET /mie-richieste`
- [ ] Implementare `GET /richiesta-servizio/{id}`
- [ ] Implementare validazione socio attivo
- [ ] Implementare generazione numero pratica
- [ ] Testare tutti gli endpoint con Postman

### Sicurezza
- [ ] Validare JWT token
- [ ] Verificare status socio = 'attivo'
- [ ] Sanitizzare input utente
- [ ] Validare formato email
- [ ] Validare formato date (YYYY-MM-DD)
- [ ] Limitare dimensione payload JSON (max 1MB)
- [ ] Implementare rate limiting (max 10 richieste/ora per utente)

### Email Notifiche (Opzionale)
- [ ] Email conferma ricezione richiesta all'utente
- [ ] Email notifica nuova richiesta agli operatori
- [ ] Email cambio stato pratica

---

**Documento generato il**: 26 Dicembre 2025  
**Versione**: 1.0  
**Compatibilità**: WordPress 5.0+, PHP 7.4+
