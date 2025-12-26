# ⚠️ Problema: Pagamenti Non Creati Automaticamente

## 🐛 Problema Riscontrato

**Sintomo:**
```
I/flutter: 🔄 Chiamata GET /payment/richiesta/385...
I/flutter: 📥 GET /payment/richiesta/385 status: 404
I/flutter: ℹ️ Nessun pagamento trovato per richiesta 385
```

**Causa:**
Quando un utente crea una richiesta di servizio che richiede pagamento, **il pagamento non viene creato automaticamente** nel database.

**Risultato:**
- L'utente non può pagare perché il record di pagamento non esiste
- La schermata pagamento mostra: "Nessun pagamento richiesto per questa richiesta"

---

## ✅ Soluzione Richiesta (Backend WordPress)

### 1. Identificare Servizi a Pagamento

Modificare la tabella `wp_wecoop_servizi` per indicare quali servizi richiedono pagamento:

```sql
ALTER TABLE wp_wecoop_servizi 
ADD COLUMN requires_payment TINYINT(1) DEFAULT 0,
ADD COLUMN prezzo DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN tipo_prezzo ENUM('fisso', 'variabile', 'gratuito') DEFAULT 'gratuito';
```

**Esempio dati:**
```sql
UPDATE wp_wecoop_servizi 
SET requires_payment = 1, 
    prezzo = 50.00, 
    tipo_prezzo = 'fisso'
WHERE id IN (1, 2, 5); -- Servizi che richiedono pagamento
```

### 2. Modificare Endpoint `POST /richiesta-servizio`

**File Backend:** `class-richiesta-servizio-endpoint.php`

```php
public function crea_richiesta($request) {
    global $wpdb;
    
    $params = json_decode($request->get_body(), true);
    $servizio_id = intval($params['servizio_id']);
    $user_id = get_current_user_id();
    
    // 1. Ottieni info servizio
    $servizio = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}wecoop_servizi WHERE id = %d",
        $servizio_id
    ));
    
    if (!$servizio) {
        return new WP_Error('servizio_non_trovato', 'Servizio non trovato', ['status' => 404]);
    }
    
    // 2. Crea la richiesta
    $richiesta_data = [
        'user_id' => $user_id,
        'servizio_id' => $servizio_id,
        // ... altri campi ...
        'status' => 'pending',
        'created_at' => current_time('mysql'),
    ];
    
    $wpdb->insert(
        $wpdb->prefix . 'wecoop_richieste_servizi',
        $richiesta_data
    );
    
    $richiesta_id = $wpdb->insert_id;
    
    // 3. 🔥 CREA PAGAMENTO SE NECESSARIO
    if ($servizio->requires_payment == 1 && $servizio->prezzo > 0) {
        $this->crea_pagamento_per_richiesta($richiesta_id, $servizio, $user_id);
    }
    
    return rest_ensure_response([
        'success' => true,
        'richiesta_id' => $richiesta_id,
        'requires_payment' => (bool)$servizio->requires_payment,
        'importo' => $servizio->prezzo,
    ]);
}

/**
 * Crea automaticamente il pagamento per una richiesta
 */
private function crea_pagamento_per_richiesta($richiesta_id, $servizio, $user_id) {
    global $wpdb;
    
    $user = get_userdata($user_id);
    
    $pagamento_data = [
        'user_id' => $user_id,
        'richiesta_id' => $richiesta_id,
        'importo' => $servizio->prezzo,
        'valuta' => 'EUR',
        'status' => 'pending', // o 'awaiting_payment'
        'descrizione' => sprintf(
            'Pagamento per servizio: %s',
            $servizio->nome
        ),
        'metodo_pagamento' => null, // Verrà impostato quando l'utente paga
        'transaction_id' => null,
        'user_email' => $user->user_email,
        'user_name' => $user->display_name,
        'servizio_nome' => $servizio->nome,
        'created_at' => current_time('mysql'),
        'updated_at' => current_time('mysql'),
    ];
    
    $wpdb->insert(
        $wpdb->prefix . 'wecoop_payments',
        $pagamento_data,
        [
            '%d', // user_id
            '%d', // richiesta_id
            '%f', // importo
            '%s', // valuta
            '%s', // status
            '%s', // descrizione
            '%s', // metodo_pagamento
            '%s', // transaction_id
            '%s', // user_email
            '%s', // user_name
            '%s', // servizio_nome
            '%s', // created_at
            '%s', // updated_at
        ]
    );
    
    $payment_id = $wpdb->insert_id;
    
    error_log("🔔 [WECOOP] Pagamento #{$payment_id} creato per richiesta #{$richiesta_id}, importo €{$servizio->prezzo}");
    
    return $payment_id;
}
```

### 3. Aggiornare Risposta Endpoint GET `/richiesta/{id}`

Quando l'app carica i dettagli della richiesta, deve sapere se esiste un pagamento:

```php
public function get_richiesta($request) {
    global $wpdb;
    
    $richiesta_id = intval($request['id']);
    
    // Carica richiesta
    $richiesta = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}wecoop_richieste_servizi WHERE id = %d",
        $richiesta_id
    ));
    
    // Carica pagamento associato (se esiste)
    $pagamento = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM {$wpdb->prefix}wecoop_payments WHERE richiesta_id = %d",
        $richiesta_id
    ));
    
    return rest_ensure_response([
        'success' => true,
        'richiesta' => $richiesta,
        'pagamento' => $pagamento, // 🔥 Include info pagamento
        'has_payment' => ($pagamento !== null),
        'payment_status' => $pagamento ? $pagamento->status : null,
    ]);
}
```

---

## 🔄 Flow Corretto (Dopo Fix)

```
1. Utente compila form richiesta servizio
   ↓
2. App → POST /richiesta-servizio
   {
     "servizio_id": 5,
     "descrizione": "...",
     ...
   }
   ↓
3. Backend:
   - Crea richiesta (ID 385)
   - Verifica se servizio richiede pagamento
   - Se sì → Crea pagamento automaticamente
     INSERT INTO wp_wecoop_payments (
       richiesta_id = 385,
       importo = 50.00,
       status = 'pending'
     )
   ↓
4. Backend risponde:
   {
     "success": true,
     "richiesta_id": 385,
     "requires_payment": true,
     "importo": 50.00
   }
   ↓
5. App mostra richiesta con badge "Pagamento richiesto"
   ↓
6. Utente clicca "Visualizza Pagamento"
   ↓
7. App → GET /payment/richiesta/385
   ↓
8. Backend risponde 200 OK (pagamento esiste!)
   {
     "id": 123,
     "richiesta_id": 385,
     "importo": 50.00,
     "status": "pending"
   }
   ↓
9. App mostra schermata pagamento con bottoni:
   - Paga con Carta (Stripe)
   - PayPal
   - Bonifico
```

---

## 🧪 Test Manuale (Temporaneo)

Finché il backend non è aggiornato, puoi creare manualmente i pagamenti nel DB:

```sql
-- Trova richieste senza pagamento
SELECT r.id, r.servizio_id, r.user_id, s.nome as servizio
FROM wp_wecoop_richieste_servizi r
LEFT JOIN wp_wecoop_payments p ON p.richiesta_id = r.id
LEFT JOIN wp_wecoop_servizi s ON s.id = r.servizio_id
WHERE p.id IS NULL
AND r.status NOT IN ('cancelled', 'completed');

-- Crea pagamento per richiesta 385
INSERT INTO wp_wecoop_payments (
  user_id, 
  richiesta_id, 
  importo, 
  valuta,
  status, 
  descrizione,
  user_email,
  user_name,
  servizio_nome,
  created_at,
  updated_at
) VALUES (
  45,                          -- user_id della richiesta
  385,                         -- richiesta_id
  50.00,                       -- importo del servizio
  'EUR',
  'pending',                   -- status iniziale
  'Pagamento per Servizio XYZ',
  'user@example.com',
  'Nome Cognome',
  'Servizio XYZ',
  NOW(),
  NOW()
);
```

---

## 📊 Stati Pagamento

| Status | Significato | Quando |
|--------|-------------|--------|
| `pending` | In attesa di pagamento | Appena creato |
| `awaiting_payment` | Uguale a pending | Alias |
| `processing` | Pagamento in corso | Durante transazione Stripe |
| `paid` | Pagato con successo | Dopo conferma |
| `failed` | Pagamento fallito | Errore carta/Stripe |
| `cancelled` | Annullato | Utente o admin annulla |
| `refunded` | Rimborsato | Dopo rimborso |

---

## 🎯 Checklist Fix Backend

- [ ] Aggiungere colonne `requires_payment`, `prezzo`, `tipo_prezzo` a `wp_wecoop_servizi`
- [ ] Configurare quali servizi richiedono pagamento (UPDATE query)
- [ ] Modificare `POST /richiesta-servizio` per creare pagamento automaticamente
- [ ] Aggiungere metodo `crea_pagamento_per_richiesta()`
- [ ] Aggiornare `GET /richiesta/{id}` per includere info pagamento
- [ ] Testare creazione richiesta → verifica pagamento creato
- [ ] Verificare GET `/payment/richiesta/{id}` restituisce 200 OK

---

## 📱 Cosa Succede nell'App (Dopo Fix)

### PRIMA (Attuale - Problema):
```
1. Utente crea richiesta → Backend crea solo la richiesta
2. Utente clicca "Visualizza Pagamento"
3. App chiama GET /payment/richiesta/385
4. ❌ Backend risponde 404 (pagamento non esiste)
5. ❌ App mostra errore "Nessun pagamento trovato"
```

### DOPO (Con Fix):
```
1. Utente crea richiesta → Backend crea richiesta + pagamento
2. Utente clicca "Visualizza Pagamento"
3. App chiama GET /payment/richiesta/385
4. ✅ Backend risponde 200 OK con dati pagamento
5. ✅ App mostra schermata pagamento
6. ✅ Utente può pagare con Stripe/PayPal/Bonifico
```

---

## 🔍 Debug Logs Attesi (Dopo Fix)

```
[APP]
📱 [PagamentoScreen] Carico tramite richiestaId: 385
🔄 Chiamata GET /payment/richiesta/385...

[BACKEND]
SELECT * FROM wp_wecoop_payments WHERE richiesta_id = 385
→ Found: payment_id=123, importo=50.00, status=pending

[APP]
📥 GET /payment/richiesta/385 status: 200
✅ Pagamento trovato per richiesta 385: ID 123, Importo €50.00, Status: pending
✅ [PagamentoScreen] Pagamento caricato: ID 123, €50.00, Status: pending
```

---

## 🆘 Workaround Temporaneo

Se non puoi modificare il backend subito, puoi:

1. **Creare pagamenti manualmente** via SQL (vedi sopra)
2. **Usare solo paymentId** invece di richiestaId quando navighi:
   ```dart
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => PagamentoScreen(
       paymentId: 123, // Invece di richiestaId
     ),
   ));
   ```

3. **Modificare l'app** per creare il pagamento se non esiste (non raccomandato - dovrebbe essere backend):
   ```dart
   // Non ideale ma funziona temporaneamente
   if (pagamento == null && widget.richiestaId != null) {
     // Chiama POST /payment/create
     // con richiesta_id, importo predefinito, ecc.
   }
   ```

---

**Il fix corretto è sul backend: creare automaticamente i pagamenti quando si creano le richieste.**
