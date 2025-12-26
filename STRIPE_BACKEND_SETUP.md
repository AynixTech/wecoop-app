# Setup Backend WordPress per Pagamenti Stripe

## ⚠️ PROBLEMA ATTUALE

L'app tenta di aprire il Payment Sheet Stripe ma **il backend WordPress non risponde** all'endpoint `/create-payment-intent`.

**Errore**: L'endpoint `POST /wecoop/v1/create-payment-intent` non è ancora implementato sul backend.

---

## 📋 COSA SERVE

### 1. Installare Stripe PHP SDK su WordPress

```bash
cd /path/to/wordpress/wp-content/plugins/wecoop-api
composer require stripe/stripe-php
```

### 2. Aggiungere Secret Key a WordPress

**IMPORTANTE**: La Secret Key NON deve mai essere nell'app, solo sul server!

```php
// wp-config.php o come costante nel plugin
define('WECOOP_STRIPE_SECRET_KEY', 'sk_test_YOUR_SECRET_KEY_HERE');
```

**⚠️ SICUREZZA**: Sostituisci `YOUR_SECRET_KEY_HERE` con la tua chiave segreta da Stripe Dashboard → API Keys.

### 3. Creare Endpoint `/create-payment-intent`

**File**: `wp-content/plugins/wecoop-api/includes/endpoints/class-payment-intent-endpoint.php`

```php
<?php
/**
 * Endpoint per creare Stripe Payment Intent
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Stripe\Stripe;
use Stripe\PaymentIntent;

class WeCoop_Payment_Intent_Endpoint {
    
    public function __construct() {
        add_action('rest_api_init', array($this, 'register_routes'));
    }
    
    public function register_routes() {
        register_rest_route('wecoop/v1', '/create-payment-intent', array(
            'methods' => 'POST',
            'callback' => array($this, 'create_payment_intent'),
            'permission_callback' => array($this, 'check_permissions'),
        ));
    }
    
    /**
     * Verifica che l'utente sia autenticato
     */
    public function check_permissions($request) {
        return is_user_logged_in();
    }
    
    /**
     * Crea un Payment Intent su Stripe
     */
    public function create_payment_intent($request) {
        try {
            // Ottieni parametri dalla richiesta
            $params = json_decode($request->get_body(), true);
            $amount = intval($params['amount'] ?? 0); // Importo in centesimi
            $currency = sanitize_text_field($params['currency'] ?? 'eur');
            $payment_id = intval($params['payment_id'] ?? 0);
            
            // Validazione
            if ($amount <= 0) {
                return new WP_Error('invalid_amount', 'Importo non valido', array('status' => 400));
            }
            
            if ($payment_id <= 0) {
                return new WP_Error('invalid_payment_id', 'Payment ID non valido', array('status' => 400));
            }
            
            // Verifica che il pagamento esista e appartenga all'utente
            global $wpdb;
            $table = $wpdb->prefix . 'wecoop_payments';
            $payment = $wpdb->get_row($wpdb->prepare(
                "SELECT * FROM $table WHERE id = %d AND user_id = %d",
                $payment_id,
                get_current_user_id()
            ));
            
            if (!$payment) {
                return new WP_Error('payment_not_found', 'Pagamento non trovato', array('status' => 404));
            }
            
            // Inizializza Stripe
            Stripe::setApiKey(WECOOP_STRIPE_SECRET_KEY);
            
            // Crea Payment Intent
            $paymentIntent = PaymentIntent::create([
                'amount' => $amount,
                'currency' => $currency,
                'metadata' => [
                    'payment_id' => $payment_id,
                    'user_id' => get_current_user_id(),
                    'richiesta_id' => $payment->richiesta_id ?? null,
                ],
                'automatic_payment_methods' => [
                    'enabled' => true,
                ],
            ]);
            
            // Salva il Payment Intent ID nel database per tracking
            $wpdb->update(
                $table,
                array(
                    'stripe_payment_intent_id' => $paymentIntent->id,
                    'updated_at' => current_time('mysql'),
                ),
                array('id' => $payment_id),
                array('%s', '%s'),
                array('%d')
            );
            
            // Restituisci il client secret
            return rest_ensure_response(array(
                'success' => true,
                'clientSecret' => $paymentIntent->client_secret,
                'paymentIntentId' => $paymentIntent->id,
            ));
            
        } catch (\Stripe\Exception\ApiErrorException $e) {
            error_log('Stripe API Error: ' . $e->getMessage());
            return new WP_Error('stripe_error', $e->getMessage(), array('status' => 500));
        } catch (Exception $e) {
            error_log('Payment Intent Error: ' . $e->getMessage());
            return new WP_Error('server_error', 'Errore durante la creazione del pagamento', array('status' => 500));
        }
    }
}

// Inizializza l'endpoint
new WeCoop_Payment_Intent_Endpoint();
```

### 4. Aggiungere colonna `stripe_payment_intent_id` alla tabella payments

```sql
ALTER TABLE wp_wecoop_payments 
ADD COLUMN stripe_payment_intent_id VARCHAR(255) NULL AFTER status,
ADD INDEX idx_stripe_payment_intent (stripe_payment_intent_id);
```

### 5. Includere il file nel plugin principale

**File**: `wp-content/plugins/wecoop-api/wecoop-api.php`

```php
// ... altri include ...
require_once plugin_dir_path(__FILE__) . 'includes/endpoints/class-payment-intent-endpoint.php';
```

---

## 🧪 TESTARE L'ENDPOINT

### Con cURL (da terminale):

```bash
curl -X POST https://www.wecoop.org/wp-json/wecoop/v1/create-payment-intent \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1500,
    "currency": "eur",
    "payment_id": 123
  }'
```

### Risposta attesa:

```json
{
  "success": true,
  "clientSecret": "pi_xxxxxxxxxxxxx_secret_xxxxxxxxxxxxx",
  "paymentIntentId": "pi_xxxxxxxxxxxxx"
}
```

---

## 🔐 SICUREZZA

1. ✅ **Secret Key solo sul server** - Mai nell'app mobile
2. ✅ **Autenticazione JWT** - Solo utenti loggati possono creare payment intent
3. ✅ **Verifica ownership** - L'utente può pagare solo i propri pagamenti
4. ✅ **Validazione importi** - Verifica che l'importo sia positivo
5. ✅ **Metadata Stripe** - Traccia payment_id e user_id per riferimento

---

## 📱 FLOW COMPLETO

1. **App** → Utente clicca "Paga con Carta"
2. **App** → Chiama `POST /create-payment-intent` (backend WordPress)
3. **Backend** → Verifica autenticazione e permessi
4. **Backend** → Crea Payment Intent su Stripe (usando Secret Key)
5. **Backend** → Restituisce `clientSecret` all'app
6. **App** → Inizializza Payment Sheet con `clientSecret`
7. **App** → Mostra UI Stripe per inserire dati carta
8. **Utente** → Inserisce dati carta e conferma
9. **Stripe** → Processa il pagamento
10. **App** → Riceve conferma e chiama `POST /payment/{id}/confirm`
11. **Backend** → Aggiorna stato pagamento su `paid`

---

## ⚡ PROSSIMI PASSI

1. Implementare l'endpoint `/create-payment-intent` sul backend WordPress
2. Testare con importi di test Stripe (es. €1.50)
3. Verificare i log nell'app (`flutter run` in console)
4. Controllare Stripe Dashboard per vedere i Payment Intent creati

---

## 🆘 DEBUGGING

Se il Payment Sheet non si apre:

1. Controllare i log Flutter (`flutter run` in terminale)
2. Verificare che l'endpoint risponda `200 OK`
3. Verificare che il `clientSecret` sia presente nella risposta
4. Controllare Stripe Dashboard → Developers → Logs
5. Verificare che la Publishable Key nell'app sia corretta

**Log da cercare nell'app:**
```
🔄 Creo Payment Intent per €15.00...
✅ Client Secret ricevuto: OK
🔄 Inizializzo Payment Sheet...
✅ Payment Sheet inizializzato, mostro UI...
```

Se vedi errori HTTP 404 o 500 → Problema backend WordPress
Se vedi "clientSecret null" → Endpoint non restituisce il campo corretto
