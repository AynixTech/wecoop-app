# 📡 WeCoop App - Documentazione API Backend

## Base URLs
- **WeCoop Custom API**: `https://www.wecoop.org/wp-json/wecoop/v1`
- **WordPress API**: `https://www.wecoop.org/wp-json/wp/v2`
- **Push Notifications**: `https://www.wecoop.org/wp-json/push/v1`

---

## 🔐 Autenticazione

Tutte le chiamate autenticate richiedono:
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
Accept-Language: {language_code} (it, en, es)
```

---

## 👥 SOCI (Membri)

### 1. Verifica Socio (PUBBLICO)
**Endpoint**: `GET /soci/verifica/{email}`

**Descrizione**: Verifica se un utente è un socio attivo

**Headers**: Nessuna autenticazione richiesta

**Response Success (200)**:
```json
{
  "success": true,
  "is_socio": true,
  "status": "attivo",
  "data_adesione": "2024-01-10"
}
```

**Response Richiesta Pending (200)**:
```json
{
  "success": true,
  "is_socio": false,
  "status": "pending"
}
```

---

### 2. Richiesta Adesione Socio (PUBBLICO)
**Endpoint**: `POST /soci/richiesta`

**Descrizione**: Invia richiesta per diventare socio

**Headers**: Nessuna autenticazione richiesta

**Body** (7 campi obbligatori):
```json
{
  "nome": "Mario",
  "cognome": "Rossi",
  "prefix": "+39",
  "telefono": "3331234567",
  "nazionalita": "IT",
  "email": "mario.rossi@example.com",
  "privacy_accepted": true,
  
  // Campi opzionali
  "codice_fiscale": "RSSMRA80A01H501U",
  "data_nascita": "1980-01-01",
  "luogo_nascita": "Roma",
  "indirizzo": "Via Roma 123",
  "citta": "Roma",
  "cap": "00100",
  "provincia": "RM",
  "professione": "Ingegnere"
}
```

**Note**:
- Username generato automaticamente: `prefix + telefono` (solo numeri, es: `393331234567`)
- Password generata automaticamente e inviata via email

**Response Success (200/201)**:
```json
{
  "success": true,
  "message": "Registrazione completata con successo",
  "data": {
    "username": "393331234567",
    "password": "TempPass123",
    "tessera_url": "https://wecoop.org/tessere/123456.pdf"
  }
}
```

**Response Error (400)**:
```json
{
  "success": false,
  "message": "Parametro mancante o non valido"
}
```

**Response Error (409)**:
```json
{
  "success": false,
  "message": "Esiste già una registrazione con questo telefono o email"
}
```

---

### 3. Get Dati Socio Corrente (AUTENTICATO)
**Endpoint**: `GET /soci/me`

**Descrizione**: Ottiene tutti i dati del socio loggato

**Headers**: JWT Bearer Token richiesto

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "id": 42,
    "user_id": 123,
    "nome": "Mario",
    "cognome": "Rossi",
    "email": "mario.rossi@example.com",
    "telefono": "3331234567",
    "prefix": "+39",
    "codice_fiscale": "RSSMRA80A01H501U",
    "data_nascita": "1980-01-01",
    "luogo_nascita": "Roma",
    "indirizzo": "Via Roma 123",
    "citta": "Roma",
    "cap": "00100",
    "provincia": "RM",
    "professione": "Ingegnere",
    "paese_origine": "IT",
    "nazionalita": "IT",
    "data_adesione": "2024-01-10",
    "status": "attivo",
    "profilo_completo": true,
    "percentuale_completamento": 100,
    "campi_mancanti": [],
    "documenti": {
      "carta_identita": "https://wecoop.org/uploads/doc123.pdf",
      "codice_fiscale": "https://wecoop.org/uploads/doc456.pdf"
    }
  }
}
```

**Response Error (401)**:
```json
{
  "success": false,
  "message": "Non autenticato. Effettua il login.",
  "code": "not_logged_in"
}
```

---

### 4. Completa Profilo (AUTENTICATO)
**Endpoint**: `POST /soci/me/completa-profilo`

**Descrizione**: Aggiorna i dati del profilo del socio

**Headers**: JWT Bearer Token richiesto

**Body** (tutti i campi opzionali):
```json
{
  "nome": "Mario",
  "cognome": "Rossi",
  "email": "mario.rossi@example.com",
  "telefono": "3331234567",
  "prefix": "+39",
  "codice_fiscale": "RSSMRA80A01H501U",
  "data_nascita": "1980-01-01",
  "luogo_nascita": "Roma",
  "indirizzo": "Via Roma 123",
  "citta": "Roma",
  "cap": "00100",
  "provincia": "RM",
  "professione": "Ingegnere",
  "paese_provenienza": "IT",
  "nazionalita": "IT"
}
```

**Campi obbligatori per profilo_completo = true (9)**:
- nome, cognome, email, telefono
- citta, indirizzo, codice_fiscale
- data_nascita, nazionalita

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Profilo aggiornato con successo",
  "data": {
    "profilo_completo": true,
    "percentuale_completamento": 100,
    "campi_mancanti": []
  }
}
```

---

### 5. Upload Documento (AUTENTICATO)
**Endpoint**: `POST /soci/me/upload-documento`

**Descrizione**: Carica documento (carta identità o codice fiscale)

**Headers**: 
- JWT Bearer Token richiesto
- Content-Type: multipart/form-data

**Body** (multipart/form-data):
```
file: [File] (PDF, JPG, PNG - max 5MB)
tipo_documento: "carta_identita" | "codice_fiscale"
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Documento caricato con successo",
  "url": "https://wecoop.org/uploads/doc789.pdf"
}
```

---

### 6. Verifica Username (PUBBLICO)
**Endpoint**: `GET /soci/check-username?username={username}`

**Descrizione**: Verifica se un username (telefono) esiste già

**Query Params**:
- `username`: Numero di telefono senza simboli (es: `393331234567`)

**Response Success (200)**:
```json
{
  "esiste": true
}
```

o

```json
{
  "esiste": false
}
```

---

### 7. Reset Password (PUBBLICO)
**Endpoint**: `POST /soci/reset-password`

**Descrizione**: Resetta la password e invia nuova password via email

**Body** (almeno uno richiesto):
```json
{
  "telefono": "3331234567",
  "email": "mario.rossi@example.com"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Password resettata. Controlla la tua email.",
  "email_sent_to": "mario.rossi@example.com"
}
```

**Response Error (404)**:
```json
{
  "success": false,
  "message": "Utente non trovato",
  "code": "user_not_found"
}
```

---

### 8. Cambia Password (AUTENTICATO)
**Endpoint**: `POST /soci/me/change-password`

**Descrizione**: Cambia password per utente autenticato

**Headers**: JWT Bearer Token richiesto

**Body**:
```json
{
  "old_password": "OldPass123",
  "new_password": "NewPass456"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Password cambiata con successo"
}
```

**Response Error (400)**:
```json
{
  "success": false,
  "message": "Password attuale non corretta",
  "code": "wrong_password"
}
```

---

### 9. Lista Soci (AUTENTICATO - ADMIN)
**Endpoint**: `GET /soci?status={status}&per_page={n}&page={p}&search={q}`

**Descrizione**: Ottiene lista soci (solo admin)

**Query Params**:
- `status`: "attivo" | "pending" | "sospeso" (default: "attivo")
- `per_page`: Numero risultati per pagina (default: 50)
- `page`: Numero pagina (default: 1)
- `search`: Ricerca per nome/email/telefono (opzionale)

**Response Success (200)**:
```json
{
  "success": true,
  "data": [
    {
      "id": 42,
      "nome": "Mario",
      "cognome": "Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "+393331234567",
      "username": "393331234567",
      "status": "attivo",
      "data_adesione": "2024-01-10"
    }
  ],
  "pagination": {
    "total": 150,
    "per_page": 50,
    "current_page": 1,
    "total_pages": 3
  }
}
```

---

## 🎫 EVENTI

### 1. Lista Eventi
**Endpoint**: `GET /eventi?page={p}&per_page={n}&categoria={cat}&data_da={d1}&data_a={d2}&stato={s}`

**Descrizione**: Ottiene lista eventi con filtri

**Query Params** (tutti opzionali):
- `page`: Numero pagina (default: 1)
- `per_page`: Risultati per pagina (default: 10)
- `categoria`: Categoria evento (es: "formazione", "sociale", "culturale")
- `data_da`: Data inizio range (formato: YYYY-MM-DD)
- `data_a`: Data fine range (formato: YYYY-MM-DD)
- `stato`: "pubblicato" | "bozza" | "passato"

**Response Success (200)**:
```json
{
  "success": true,
  "eventi": [
    {
      "id": 123,
      "titolo": "Corso di Italiano",
      "slug": "corso-italiano-2024",
      "descrizione": "Corso base di lingua italiana",
      "data_inizio": "2024-03-15",
      "data_fine": "2024-06-15",
      "ora_inizio": "18:00",
      "ora_fine": "20:00",
      "online": false,
      "luogo": "Sede WeCoop",
      "indirizzo": "Via Roma 123",
      "citta": "Milano",
      "link_online": null,
      "max_partecipanti": 20,
      "partecipanti_count": 15,
      "posti_disponibili": 5,
      "richiede_iscrizione": true,
      "prezzo": 0.00,
      "prezzo_formattato": "Gratuito",
      "organizzatore": "WeCoop",
      "email_organizzatore": "info@wecoop.org",
      "telefono_organizzatore": "02-1234567",
      "stato": "pubblicato",
      "immagine_copertina": "https://wecoop.org/uploads/evento123.jpg",
      "categoria": "formazione",
      "galleria": [
        {
          "id": 1,
          "url": "https://wecoop.org/uploads/gallery1.jpg",
          "thumbnail": "https://wecoop.org/uploads/gallery1-thumb.jpg",
          "medium": "https://wecoop.org/uploads/gallery1-medium.jpg",
          "large": "https://wecoop.org/uploads/gallery1-large.jpg"
        }
      ],
      "sono_iscritto": false,
      "programma": "Dettagli del programma...",
      "data_pubblicazione": "2024-01-10"
    }
  ],
  "pagination": {
    "total": 45,
    "per_page": 10,
    "current_page": 1,
    "total_pages": 5
  }
}
```

---

### 2. Dettaglio Evento
**Endpoint**: `GET /eventi/{id}`

**Descrizione**: Ottiene dettagli di un singolo evento

**Response Success (200)**:
```json
{
  "success": true,
  "id": 123,
  "titolo": "Corso di Italiano",
  "descrizione": "...",
  "data_inizio": "2024-03-15",
  "sono_iscritto": true,
  "stato_iscrizione": "confermato",
  "data_iscrizione": "2024-01-15 10:30:00",
  ... // tutti gli altri campi
}
```

**Note**: Il campo `sono_iscritto` è `true` solo se l'utente è autenticato e iscritto all'evento

---

### 3. Iscrizione Evento (AUTENTICATO)
**Endpoint**: `POST /eventi/{id}/iscrizione`

**Descrizione**: Iscrive l'utente autenticato all'evento

**Headers**: JWT Bearer Token richiesto

**Body** (tutti opzionali se profilo completo):
```json
{
  "nome": "Mario Rossi",
  "email": "mario.rossi@example.com",
  "telefono": "3331234567",
  "note": "Ho esigenze alimentari particolari"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Iscrizione completata con successo",
  "partecipante": {
    "id": 456,
    "nome": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "stato": "confermato",
    "data_iscrizione": "2024-01-15 10:30:00"
  }
}
```

**Response Error (400)**:
```json
{
  "success": false,
  "message": "Posti esauriti"
}
```

**Response Error (409)**:
```json
{
  "success": false,
  "message": "Sei già iscritto a questo evento"
}
```

---

### 4. Cancella Iscrizione (AUTENTICATO)
**Endpoint**: `DELETE /eventi/{id}/iscrizione`

**Descrizione**: Cancella l'iscrizione dell'utente all'evento

**Headers**: JWT Bearer Token richiesto

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Iscrizione cancellata con successo"
}
```

---

### 5. Miei Eventi (AUTENTICATO)
**Endpoint**: `GET /miei-eventi`

**Descrizione**: Ottiene lista eventi a cui l'utente è iscritto

**Headers**: JWT Bearer Token richiesto

**Response Success (200)**:
```json
{
  "success": true,
  "eventi": [
    {
      "id": 123,
      "titolo": "Corso di Italiano",
      "data_inizio": "2024-03-15",
      "sono_iscritto": true,
      "stato_iscrizione": "confermato",
      "data_iscrizione": "2024-01-15 10:30:00",
      ... // tutti gli altri campi evento
    }
  ],
  "totale": 3
}
```

**Note**: Questa query deve fare JOIN tra:
- `wp_posts` (post_type = 'evento')
- Tabella iscrizioni personalizzata o meta_key `_iscritti`
- Filtrare per `user_id` dell'utente autenticato (dal JWT)

**Query SQL Esempio**:
```sql
SELECT p.*, pm.meta_value as iscritti
FROM wp_posts p
LEFT JOIN wp_postmeta pm ON p.ID = pm.post_id AND pm.meta_key = '_iscritti'
WHERE p.post_type = 'evento'
AND p.post_status = 'publish'
AND FIND_IN_SET({user_id}, pm.meta_value) > 0
ORDER BY p.post_date DESC
```

---

### 6. Debug Eventi (AUTENTICATO - DEBUG)
**Endpoint**: `GET /eventi/debug`

**Descrizione**: Ottiene TUTTI gli eventi con meta_fields per debugging

**Response Success (200)**:
```json
{
  "success": true,
  "count": 150,
  "data": [
    {
      "ID": 123,
      "post_title": "Corso di Italiano",
      "post_status": "publish",
      "meta_key": "_iscritti",
      "meta_value": "42,87,156"
    },
    {
      "ID": 123,
      "post_title": "Corso di Italiano",
      "meta_key": "_max_partecipanti",
      "meta_value": "20"
    }
  ]
}
```

---

## 📋 RICHIESTE SERVIZI

### 1. Invia Richiesta Servizio (AUTENTICATO - SOLO SOCI)
**Endpoint**: `POST /richiesta-servizio`

**Descrizione**: Invia richiesta per un servizio (CAF, Sportello, ecc.)

**Headers**: JWT Bearer Token richiesto

**Body**:
```json
{
  "servizio": "CAF - Assistenza Fiscale",
  "categoria": "Dichiarazione dei Redditi (730)",
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

**Campi Dinamici in "dati"** (dipendono dal servizio):

#### CAF - Dichiarazione 730
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "codice_fiscale": "string",
  "anno_fiscale": "string",
  "tipo_dichiarazione": "730 ordinario | 730 precompilato",
  "note": "string (optional)"
}
```

#### CAF - Compilazione Modelli
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "tipo_modello": "F24 | ISEE | RED | Altro",
  "descrizione": "string"
}
```

#### Sportello - Permesso di Soggiorno
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "data_nascita": "YYYY-MM-DD",
  "paese_provenienza": "string",
  "tipo_permesso": "Lavoro | Studio | Famiglia | Protezione internazionale",
  "tipo_contratto": "string (se Lavoro)",
  "nome_azienda": "string (se Lavoro)",
  "relazione_familiare": "string (se Famiglia)",
  "nome_istituto_universita": "string (se Studio)",
  "data_arrivo_italia": "YYYY-MM-DD",
  "indirizzo_residenza_attuale": "string",
  "motivo_richiesta": "Primo rilascio | Rinnovo | Conversione"
}
```

#### Sportello - Cittadinanza
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "data_nascita": "YYYY-MM-DD",
  "luogo_nascita": "string",
  "paese_nascita": "string",
  "data_arrivo_italia": "YYYY-MM-DD",
  "indirizzo_residenza_attuale": "string",
  "motivo_richiesta": "string"
}
```

#### Sportello - Visto Turistico
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "nazionalita": "string",
  "numero_passaporto": "string",
  "data_arrivo_prevista": "YYYY-MM-DD",
  "durata_soggiorno_giorni": "number",
  "motivo_viaggio": "string"
}
```

#### Sportello - Richiesta Asilo
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "data_nascita": "YYYY-MM-DD",
  "paese_provenienza": "string",
  "data_arrivo_italia": "YYYY-MM-DD",
  "motivo_richiesta": "string",
  "documenti_disponibili": "string"
}
```

#### Contabilità - Dichiarazione Redditi
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "codice_fiscale": "string",
  "partita_iva": "string (optional)",
  "anno_fiscale": "string",
  "tipo_reddito": "Dipendente | Autonomo | Misto"
}
```

#### Contabilità - Apertura Partita IVA
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "codice_fiscale": "string",
  "tipo_attivita": "string",
  "regime_fiscale": "Forfettario | Ordinario"
}
```

#### Contabilità - Gestione Contabilità
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "partita_iva": "string",
  "tipo_supporto_richiesto": "Mensile | Trimestrale | Annuale"
}
```

#### Contabilità - Adempimenti Fiscali
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "partita_iva": "string",
  "tipo_adempimento": "IVA | F24 | Contributi | Altro"
}
```

#### Contabilità - Consulenza Fiscale
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "argomento_consulenza": "string"
}
```

#### Mediazione Fiscale
```json
{
  "nome_completo": "string",
  "email": "string",
  "telefono": "string",
  "codice_fiscale": "string",
  "cosa_vuoi_fare": "Rateizzare | Sospendere | Annullare | Richiedere Sgravio",
  "descrizione_situazione": "string"
}
```

**Response Success (200/201)**:
```json
{
  "success": true,
  "message": "Richiesta ricevuta con successo",
  "id": 789,
  "numero_pratica": "WECOOP-2025-00001",
  "data_richiesta": "2024-01-15 10:30:00"
}
```

**Response Error (400)**:
```json
{
  "success": false,
  "message": "Campo obbligatorio mancante: email"
}
```

**Response Error (401)**:
```json
{
  "success": false,
  "message": "Devi essere autenticato. Effettua il login."
}
```

**Response Error (403)**:
```json
{
  "success": false,
  "message": "Non hai i permessi. Solo i soci possono richiedere servizi."
}
```

---

### 2. Mie Richieste (AUTENTICATO)
**Endpoint**: `GET /mie-richieste?page={p}&per_page={n}&stato={s}`

**Descrizione**: Ottiene lista richieste servizi dell'utente

**Query Params**:
- `page`: Numero pagina (default: 1)
- `per_page`: Risultati per pagina (default: 20)
- `stato`: "in_attesa" | "in_lavorazione" | "completata" | "annullata" (opzionale)

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

### 3. Dettaglio Richiesta (AUTENTICATO)
**Endpoint**: `GET /richiesta-servizio/{id}`

**Descrizione**: Ottiene dettagli di una specifica richiesta

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
      "anno_fiscale": "2024"
    },
    "cronologia": [
      {
        "data": "2024-01-15 10:30:00",
        "stato": "in_attesa",
        "nota": "Richiesta ricevuta"
      },
      {
        "data": "2024-01-16 14:20:00",
        "stato": "in_lavorazione",
        "nota": "Assegnata a Giuseppe Bianchi"
      }
    ],
    "documenti": [
      {
        "nome": "CU_2024.pdf",
        "url": "https://wecoop.org/uploads/doc123.pdf",
        "data_caricamento": "2024-01-16 15:00:00"
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

---

## 📰 WORDPRESS POSTS

### 1. Lista Post/News
**Endpoint**: `GET /wp-json/wp/v2/posts?per_page={n}&_embed`

**Descrizione**: Ottiene lista post/news WordPress

**Query Params**:
- `per_page`: Numero post (default: 5)
- `_embed`: Include immagini e metadati

**Response Success (200)**:
```json
[
  {
    "id": 456,
    "title": {
      "rendered": "Nuovo Corso di Lingua"
    },
    "content": {
      "rendered": "<p>Contenuto del post...</p>"
    },
    "excerpt": {
      "rendered": "<p>Breve estratto...</p>"
    },
    "date": "2024-01-15T10:30:00",
    "featured_media": 789,
    "_embedded": {
      "wp:featuredmedia": [
        {
          "source_url": "https://wecoop.org/uploads/featured.jpg"
        }
      ]
    }
  }
]
```

---

## 🔔 PUSH NOTIFICATIONS

### 1. Registra Token FCM (AUTENTICATO)
**Endpoint**: `POST /push/v1/token`

**Descrizione**: Salva il token FCM dell'utente per le notifiche push

**Headers**: JWT Bearer Token richiesto

**Body**:
```json
{
  "token": "fCmGZXQaTk6...",
  "device_info": "Flutter App - Android/iOS"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Token FCM salvato con successo"
}
```

**Response Error (401)**:
```json
{
  "success": false,
  "message": "JWT token non valido o scaduto"
}
```

**Response Error (404)**:
```json
{
  "success": false,
  "message": "Endpoint non trovato. Verifica che il plugin sia attivo"
}
```

**Database**:
```sql
CREATE TABLE wp_wecoop_push_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token VARCHAR(255) NOT NULL,
  device_info VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_token (user_id, token),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2. Rimuovi Token FCM (AUTENTICATO)
**Endpoint**: `DELETE /push/v1/token`

**Descrizione**: Rimuove il token FCM dell'utente (logout)

**Headers**: JWT Bearer Token richiesto

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Token FCM rimosso con successo"
}
```

---

## 🔒 Note di Sicurezza

### JWT Token
Il JWT token deve contenere nel payload:
```json
{
  "iss": "https://www.wecoop.org",
  "iat": 1735223445,
  "exp": 1735827245,
  "data": {
    "user": {
      "id": 123,
      "email": "mario.rossi@example.com"
    }
  }
}
```

### Validazione Socio
Per endpoint che richiedono "SOLO SOCI":
1. Verificare JWT token valido
2. Estrarre `user_id` dal token
3. Query su tabella soci: `WHERE user_id = {id} AND status = 'attivo'`
4. Se non trovato → 403 Forbidden

### CORS Headers
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type, Accept-Language
```

---

## 📊 Struttura Database

### Tabella: wp_wecoop_soci
```sql
CREATE TABLE wp_wecoop_soci (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  nome VARCHAR(100) NOT NULL,
  cognome VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  telefono VARCHAR(20) NOT NULL,
  prefix VARCHAR(5),
  codice_fiscale VARCHAR(16),
  data_nascita DATE,
  luogo_nascita VARCHAR(100),
  indirizzo VARCHAR(255),
  citta VARCHAR(100),
  cap VARCHAR(10),
  provincia VARCHAR(2),
  professione VARCHAR(100),
  paese_origine VARCHAR(2),
  nazionalita VARCHAR(2),
  data_adesione DATE NOT NULL,
  status ENUM('pending', 'attivo', 'sospeso') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_email (email),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

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
  INDEX idx_numero_pratica (numero_pratica)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Tabella: wp_wecoop_push_tokens
```sql
CREATE TABLE wp_wecoop_push_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token VARCHAR(255) NOT NULL,
  device_info VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_token (user_id, token),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🧪 Testing

### Test Richiesta Servizio
```bash
curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/richiesta-servizio \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "servizio": "CAF - Assistenza Fiscale",
    "categoria": "Dichiarazione dei Redditi (730)",
    "dati": {
      "nome_completo": "Mario Rossi",
      "email": "mario.rossi@example.com",
      "telefono": "3331234567",
      "codice_fiscale": "RSSMRA80A01H501U",
      "anno_fiscale": "2024"
    }
  }'
```

### Test Verifica Socio
```bash
curl https://www.wecoop.org/wp-json/wecoop/v1/soci/verifica/mario.rossi@example.com
```

---

## 📝 Changelog Backend

### Version 1.0 (Richiesto)
- ✅ Endpoint soci (verifica, richiesta, me, completa-profilo)
- ✅ Endpoint eventi (lista, dettaglio, iscrizione, miei-eventi)
- ✅ Endpoint richieste servizi (crea, lista, dettaglio)
- ✅ Endpoint push notifications (token)
- ✅ JWT authentication
- ⚠️ Da implementare: /miei-eventi (attualmente 500)
- ⚠️ Da implementare: /eventi/debug (per troubleshooting)
- ⚠️ Da configurare: WP_DEBUG_DISPLAY = false
- ⚠️ Da creare: Tabelle database

---

## 🚀 Priorità Implementazione

### Alta Priorità (Blocker)
1. **POST /richiesta-servizio** - Core funzionalità servizi
2. **GET /miei-eventi** - Attualmente ritorna 500
3. **Tabelle database** - wp_wecoop_soci, wp_wecoop_richieste_servizi

### Media Priorità
4. **GET /mie-richieste** - Visualizzazione storico
5. **GET /richiesta-servizio/{id}** - Dettaglio pratica
6. **Upload documenti** - Gestione file

### Bassa Priorità (Nice to have)
7. **GET /eventi/debug** - Solo per troubleshooting
8. **Notifiche push backend** - Firebase Admin SDK

---

**Documento generato il**: 26 Dicembre 2025  
**Versione App**: 1.0.0  
**Backend WordPress**: Custom REST API v1
