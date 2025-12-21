# 📤 Esempio Richiesta Servizio Completa

Quando un utente compila un form per richiedere un servizio, l'app invia automaticamente tutti i dati necessari al backend WordPress, inclusi gli identificativi per collegare la richiesta all'utente.

---

## 🔍 Esempio: Permesso di Soggiorno - Lavoro Subordinato

### 1. **Dati compilati dall'utente nel form:**

```
Nome completo: Mario Rossi
Data di nascita: 15/01/1990
Paese di provenienza: Romania
Tipo di contratto: Tempo determinato
Nome azienda: ABC srl
Durata contratto: 12 mesi
Email: mario.rossi@example.com
Telefono: +39 333 1234567
```

### 2. **Conversione automatica app (snake_case + date ISO + ID utente):**

```json
{
  "socio_id": "123",
  "nome_completo": "Mario Rossi",
  "data_nascita": "1990-01-15",
  "paese_provenienza": "Romania",
  "tipo_contratto": "Tempo determinato",
  "nome_azienda": "ABC srl",
  "durata_contratto_mesi": "12",
  "email": "mario.rossi@example.com",
  "telefono": "+39 333 1234567"
}
```

### 3. **Request HTTP completa:**

```http
POST https://www.wecoop.org/wp-json/wecoop/v1/richiesta-servizio
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...

{
  "servizio": "Permesso di Soggiorno",
  "categoria": "Lavoro Subordinato",
  "dati": {
    "socio_id": "123",
    "nome_completo": "Mario Rossi",
    "data_nascita": "1990-01-15",
    "paese_provenienza": "Romania",
    "tipo_contratto": "Tempo determinato",
    "nome_azienda": "ABC srl",
    "durata_contratto_mesi": "12",
    "email": "mario.rossi@example.com",
    "telefono": "+39 333 1234567"
  }
}
```

### 4. **Response attesa dal backend:**

```json
{
  "success": true,
  "message": "Richiesta ricevuta con successo",
  "id": 789,
  "numero_pratica": "WECOOP-2025-00001",
  "data_richiesta": "2025-12-21T14:30:00+00:00"
}
```

---

## 🎯 Gestione ID Utente

### Priorità di invio:

1. **Se disponibile `socio_id`** → invia `{"socio_id": "123", ...}`
   - Questo è l'ID dalla tabella `wp_soci_meta` 
   - Identifica univocamente il socio
   - È il preferito quando disponibile

2. **Se non disponibile `socio_id` ma c'è `user_id`** → invia `{"user_id": "456", ...}`
   - Questo è l'ID dalla tabella `wp_users` di WordPress
   - Utile per utenti loggati che non sono ancora soci
   - Permette comunque di tracciare la richiesta

3. **Se nessuno dei due** → richiesta senza ID
   - Possibile solo in casi anomali
   - Il backend dovrebbe comunque accettare la richiesta

### Dove vengono salvati:

```dart
// Al login JWT (POST /jwt-auth/v1/token):
await storage.write(key: 'user_id', value: data['user_id'].toString());

// Da GET /soci/me:
await storage.write(key: 'socio_id', value: data['id']?.toString());
await storage.write(key: 'user_id', value: data['user_id'].toString());
```

### Quando vengono cancellati:

```dart
// Al logout:
await storage.delete(key: 'socio_id');
await storage.delete(key: 'user_id');
// Questo forza un nuovo login per future richieste
```

---

## 💡 Benefici per il Backend WordPress

### Con `socio_id` o `user_id` il backend può:

1. **Collegare la pratica all'utente:**
   ```php
   update_post_meta($pratica_id, 'socio_id', $socio_id);
   update_post_meta($pratica_id, 'user_id', $user_id);
   ```

2. **Recuperare info utente:**
   ```php
   $socio = get_socio_by_id($socio_id);
   $email = $socio['email'];
   $nome = $socio['nome'] . ' ' . $socio['cognome'];
   ```

3. **Inviare notifiche:**
   ```php
   wp_mail(
     $email, 
     "Richiesta $servizio ricevuta",
     "Numero pratica: $numero_pratica"
   );
   ```

4. **Mostrare storico:**
   ```php
   $pratiche = get_pratiche_by_socio_id($socio_id);
   foreach ($pratiche as $pratica) {
     // Mostra nel profilo utente
   }
   ```

5. **Statistiche:**
   ```php
   // Quante richieste ha fatto questo socio?
   $count = count_pratiche_by_socio($socio_id);
   
   // Quali servizi usa di più?
   $servizi_usati = get_servizi_by_socio($socio_id);
   ```

---

## 🔐 Sicurezza

L'app invia sempre il **JWT token** nell'header `Authorization`, quindi il backend può:

1. **Verificare che il token sia valido**
2. **Estrarre l'user_id dal token** stesso (se non presente nei dati)
3. **Confrontare l'user_id del token con quello nei dati** (evita manomissioni)
4. **Verificare che l'utente sia un socio attivo** prima di accettare la richiesta

```php
// Esempio validazione backend:
function validate_richiesta_servizio($request) {
  $token_user_id = get_user_id_from_token($request->get_header('Authorization'));
  $data_user_id = $request->get_param('dati')['user_id'];
  
  // L'user_id deve coincidere con quello del token
  if ($token_user_id !== $data_user_id) {
    return new WP_Error('invalid_user', 'User ID mismatch', ['status' => 403]);
  }
  
  // L'utente deve essere un socio attivo
  if (!is_socio_attivo($token_user_id)) {
    return new WP_Error('not_socio', 'Solo i soci possono richiedere servizi', ['status' => 403]);
  }
  
  return true;
}
```

---

## 📊 Log Console App

Quando l'utente invia una richiesta, vedrai nel console:

```
=== DATI FORM ORIGINALI ===
{
  Nome completo: Mario Rossi,
  Data di nascita: 15/01/1990,
  Paese di provenienza: Romania,
  ...
}

📋 Aggiunto socio_id: 123

=== DATI CONVERTITI PER API ===
{
  socio_id: 123,
  nome_completo: Mario Rossi,
  data_nascita: 1990-01-15,
  paese_provenienza: Romania,
  ...
}
```

Questo aiuta a debuggare e verificare che i dati siano corretti prima dell'invio.

---

## ✅ Checklist Backend WordPress

Per gestire correttamente le richieste con ID utente, il backend deve:

- [ ] Accettare `socio_id` e/o `user_id` nel campo `dati`
- [ ] Salvare entrambi gli ID come meta della pratica
- [ ] Validare che l'user_id corrisponda al token JWT
- [ ] Verificare che il socio sia attivo prima di accettare
- [ ] Usare l'ID per collegare la pratica all'utente
- [ ] Inviare notifiche email all'utente quando cambia stato
- [ ] Mostrare lo storico pratiche nel profilo utente
- [ ] Permettere all'utente di vedere solo le sue pratiche
- [ ] (Opzionale) Estrarre l'user_id dal token se non presente nei dati

---

## 🚀 Risultato Finale

Con questa implementazione, **ogni richiesta di servizio è sempre collegata all'utente che l'ha fatta**, permettendo una gestione completa del CRM e tracking delle pratiche! 🎯
