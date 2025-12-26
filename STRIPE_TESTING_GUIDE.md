# 🧪 Guida Test Pagamenti Stripe

## ✅ Backend Configurato

Il backend WordPress è ora pronto con:
- ✅ Endpoint `/create-payment-intent` attivo
- ✅ Stripe PHP SDK v19.1.0 installato
- ✅ Secret Key configurata
- ✅ Webhook handler implementato

---

## 📱 Come Testare dall'App

### 1️⃣ Preparazione

```bash
# Assicurati che l'app sia aggiornata
cd /Users/aynix/Documents/GitHub/wecoop-app
flutter clean
flutter pub get
flutter run
```

### 2️⃣ Controlla i Log all'Avvio

Nella console dovresti vedere:
```
💳 Stripe inizializzato (TEST MODE)
```

Se vedi `⚠️ Stripe NON inizializzato` → La Publishable Key non è valida

### 3️⃣ Crea un Pagamento di Test

Hai bisogno di un pagamento in stato `awaiting_payment` o `pending`:

**Opzione A - Dalla app:**
1. Vai alla sezione "Richiedi Servizio"
2. Compila la richiesta
3. Se il servizio richiede pagamento, vedrai il bottone "Paga"

**Opzione B - Manualmente nel DB:**
```sql
INSERT INTO wp_wecoop_payments (
  user_id, 
  richiesta_id, 
  importo, 
  status, 
  descrizione,
  created_at
) VALUES (
  123,        -- Sostituisci con tuo user_id
  456,        -- Sostituisci con richiesta_id esistente
  15.00,      -- €15.00
  'pending',
  'Test pagamento Stripe',
  NOW()
);
```

### 4️⃣ Naviga alla Schermata Pagamento

Nella app, apri la richiesta e clicca su "Visualizza Pagamento" o "Paga Ora"

### 5️⃣ Clicca "Paga con Carta"

**Cosa dovrebbe succedere:**

```
[Console Log]
🔄 Creo Payment Intent per €15.00...
📤 Body richiesta: {"amount":1500,"currency":"eur","payment_id":123}
📥 POST /create-payment-intent status: 200
📥 Response body: {"success":true,"clientSecret":"pi_...","paymentIntentId":"pi_..."}
✅ Client Secret ricevuto
🔄 Inizializzo Payment Sheet...
✅ Payment Sheet inizializzato, mostro UI...
```

**Cosa vedrai:**
- ⏳ Spinner di caricamento (2-3 secondi)
- 📋 **Payment Sheet Stripe** si apre dal basso
- 💳 Form per inserire dati carta

### 6️⃣ Inserisci Carta di Test

Usa queste carte Stripe test:

| Numero Carta | Risultato |
|--------------|-----------|
| `4242 4242 4242 4242` | ✅ Pagamento riuscito |
| `4000 0000 0000 0002` | ❌ Carta rifiutata |
| `4000 0027 6000 3184` | 🔐 Richiede 3D Secure |

**Altri campi:**
- **Scadenza**: `12/25` (qualsiasi data futura)
- **CVV**: `123` (qualsiasi 3 cifre)
- **Nome**: `Test User`
- **ZIP**: `12345` (qualsiasi)

### 7️⃣ Conferma Pagamento

Clicca il bottone **"Pay €15.00"** nel Payment Sheet

**Cosa dovrebbe succedere:**

```
[Console Log]
✅ Pagamento completato con successo!
```

**Cosa vedrai:**
- ✅ Dialog di successo
- 💚 Stato pagamento aggiornato a "Pagato"
- 🔄 Torna alla schermata precedente

---

## 🐛 Risoluzione Problemi

### ❌ Errore: "Stripe non disponibile"

**Causa**: `publishableKey` non è configurata  
**Fix**: Verifica in `lib/config/stripe_config.dart` che la chiave inizi con `pk_test_`

```dart
static const String publishableKey = 'pk_test_51SiYvcAJaLsqAD1p...';
```

### ❌ Errore: "Impossibile creare il pagamento"

**Causa**: Backend non risponde o restituisce errore

**Debug**:
1. Controlla i log nella console dell'app:
   ```
   📥 POST /create-payment-intent status: ???
   📥 Response body: ???
   ```

2. Testa l'endpoint manualmente:
   ```bash
   curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/create-payment-intent \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"amount":1500,"currency":"eur","payment_id":1}'
   ```

**Possibili cause:**
- Status 404 → Endpoint non registrato (verifica plugin attivo)
- Status 403 → Utente non autorizzato (pagamento non appartiene all'utente)
- Status 500 → Errore server (controlla `wp-content/debug.log`)

### ❌ Payment Sheet non si apre

**Causa**: `clientSecret` non valido o inizializzazione fallita

**Debug**:
Controlla log per vedere se arriva a:
```
🔄 Inizializzo Payment Sheet...
✅ Payment Sheet inizializzato, mostro UI...
```

Se si ferma prima di "mostro UI" → Problema con `initPaymentSheet()`

**Possibili cause:**
- `clientSecret` non è nel formato corretto
- Stripe SDK non inizializzato (app non riavviata dopo configurazione)
- Errore tema Android (già risolto)

### ❌ Errore dopo inserimento carta

**Causa**: Carta test rifiutata o errore Stripe

**Debug**:
Controlla quale carta hai usato:
- `4242 4242 4242 4242` → Dovrebbe funzionare sempre
- `4000 0000 0000 0002` → **Intenzionalmente** rifiutata

Se usi `4242` e fallisce comunque:
1. Verifica Stripe Dashboard → Test Data
2. Controlla che Secret Key sia corretta nel backend
3. Verifica log backend WordPress

### ❌ Pagamento riuscito ma stato non si aggiorna

**Causa**: Chiamata `/confirm` fallita o webhook non configurato

**Debug**:
1. Controlla log app per chiamata POST `/payment/{id}/confirm`
2. Verifica in Stripe Dashboard che il Payment Intent sia `succeeded`
3. Configura webhook per aggiornamento automatico

**Workaround**:
Aggiorna manualmente nel DB:
```sql
UPDATE wp_wecoop_payments 
SET status = 'paid', 
    transaction_id = 'pi_xxxxxxxx',
    paid_at = NOW()
WHERE id = 123;
```

---

## 📊 Verifiche Post-Pagamento

### 1. Stripe Dashboard

Vai su: https://dashboard.stripe.com/test/payments

**Dovresti vedere:**
- ✅ Nuovo Payment Intent con importo corretto
- ✅ Stato: `Succeeded`
- ✅ Metadata:
  ```json
  {
    "payment_id": "123",
    "user_id": "45",
    "richiesta_id": "678",
    "servizio": "Nome Servizio"
  }
  ```

### 2. Database WordPress

```sql
SELECT * FROM wp_wecoop_payments WHERE id = 123;
```

**Campi da verificare:**
- `status` = `'paid'`
- `transaction_id` = `'pi_xxxxxxxx'` (da Stripe)
- `paid_at` = timestamp corrente
- `metodo_pagamento` = `'stripe'`

### 3. App Mobile

**Nella schermata richiesta:**
- ✅ Badge "Pagato" verde
- ✅ Bottone "Paga" non più visibile
- ✅ Dettagli pagamento mostrano importo e data

---

## 🎯 Test Scenari Completi

### Scenario 1: Pagamento Riuscito

1. Crea richiesta servizio (€15.00)
2. Clicca "Paga con Carta"
3. Usa carta `4242 4242 4242 4242`
4. Conferma
5. ✅ Verifica stato = `paid`

### Scenario 2: Pagamento Rifiutato

1. Crea richiesta servizio (€10.00)
2. Clicca "Paga con Carta"
3. Usa carta `4000 0000 0000 0002`
4. Conferma
5. ❌ Vedi errore "Carta rifiutata"
6. ✅ Stato rimane `pending`

### Scenario 3: Utente Annulla

1. Crea richiesta servizio (€20.00)
2. Clicca "Paga con Carta"
3. Payment Sheet si apre
4. Clicca "X" per chiudere
5. ✅ Nessun errore mostrato
6. ✅ Stato rimane `pending`

### Scenario 4: 3D Secure

1. Crea richiesta servizio (€25.00)
2. Clicca "Paga con Carta"
3. Usa carta `4000 0027 6000 3184`
4. Conferma
5. 🔐 Si apre finestra autenticazione 3DS
6. Clicca "Authorize Test Payment"
7. ✅ Verifica stato = `paid`

---

## 📱 Test su Dispositivi Diversi

### Android

✅ Già testato - Funziona

**Requisiti:**
- MainActivity extends `FlutterFragmentActivity` ✅
- Tema usa `Theme.AppCompat` ✅

### iOS (Se disponibile)

**Setup aggiuntivo necessario:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>wecoop-app</string>
    </array>
  </dict>
</array>
```

---

## 🔄 Workflow Completo

```
┌─────────────┐
│   Utente    │
│  Richiede   │
│  Servizio   │
└──────┬──────┘
       │
       v
┌─────────────────────┐
│  Backend WordPress  │
│  Crea Pagamento DB  │
│  status = pending   │
└──────┬──────────────┘
       │
       v
┌─────────────────────┐
│    App Mobile       │
│  Mostra Bottone     │
│  "Paga con Carta"   │
└──────┬──────────────┘
       │
       v
┌─────────────────────────────────┐
│  User clicca "Paga con Carta"   │
└──────┬──────────────────────────┘
       │
       v
┌──────────────────────────────────┐
│  App → POST /create-payment-intent│
│  Backend → Chiama Stripe API      │
│  Backend ← Riceve Payment Intent  │
│  App ← Riceve clientSecret        │
└──────┬───────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  App inizializza Payment Sheet  │
│  Stripe SDK gestisce UI         │
└──────┬──────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  Utente inserisce dati carta    │
│  Stripe processa pagamento      │
└──────┬──────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  Stripe → Webhook → Backend     │
│  Backend aggiorna status=paid   │
└──────┬──────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  App → POST /payment/{id}/confirm│
│  App ricarica dati               │
│  Mostra messaggio successo       │
└──────────────────────────────────┘
```

---

## 🆘 Log Completi Esempio (Successo)

```
[APP START]
💳 Stripe inizializzato (TEST MODE)

[USER CLICKS "Paga con Carta"]
🔄 Creo Payment Intent per €15.00...
📤 Body richiesta: {"amount":1500,"currency":"eur","payment_id":123}

[BACKEND /create-payment-intent]
[WECOOP STRIPE] Payment Intent creato: pi_3ABC123xyz per pagamento #123

[APP RECEIVES RESPONSE]
📥 POST /create-payment-intent status: 200
📥 Response body: {"success":true,"clientSecret":"pi_3ABC123xyz_secret_DEF456","paymentIntentId":"pi_3ABC123xyz"}
✅ Client Secret ricevuto
🔄 Inizializzo Payment Sheet...
✅ Payment Sheet inizializzato, mostro UI...

[USER ENTERS CARD AND CONFIRMS]
[STRIPE PROCESSES PAYMENT]

[STRIPE WEBHOOK → BACKEND]
[WECOOP STRIPE] Webhook ricevuto: payment_intent.succeeded
[WECOOP STRIPE] Pagamento riuscito: PI pi_3ABC123xyz, Payment #123
[WECOOP PAYMENT] Stato pagamento #123 aggiornato a: paid

[APP CONFIRMS]
✅ Pagamento completato con successo!

[APP SHOWS SUCCESS DIALOG]
Pagamento Completato!
Il tuo pagamento di €15.00 è stato processato con successo.
```

---

## ✅ Checklist Test

Prima di considerare completato:

- [ ] App si avvia senza errori
- [ ] Log mostra "Stripe inizializzato (TEST MODE)"
- [ ] Bottone "Paga con Carta" visibile per pagamenti pending
- [ ] Click bottone apre Payment Sheet (non crash)
- [ ] Carta 4242 completa pagamento con successo
- [ ] Stato aggiornato a "paid" in app
- [ ] Stato aggiornato a "paid" in database
- [ ] Payment Intent visibile in Stripe Dashboard
- [ ] Metadata corretti in Stripe
- [ ] Carta 0002 viene correttamente rifiutata
- [ ] Annullamento Payment Sheet non causa errori
- [ ] 3D Secure (carta 3184) funziona correttamente

---

**Pronto per testare! 🚀**

Apri l'app, crea un pagamento test, e clicca "Paga con Carta"!
