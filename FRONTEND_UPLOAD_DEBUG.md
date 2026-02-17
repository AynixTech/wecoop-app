# Frontend Upload Documenti - Debug & Troubleshooting

## 🚨 PROBLEMA CRITICO IDENTIFICATO

**Il frontend NON sta caricando i documenti sul backend!**

I documenti vengono salvati SOLO localmente sul dispositivo dell'utente, ma NON vengono mai inviati al server WordPress.

---

## 📱 Come Funziona Attualmente (SBAGLIATO)

### Flusso Attuale:

1. **Utente apre "I miei documenti"** → `documenti_screen.dart`
2. **Utente clicca "Carica documento"** → Sceglie fonte (fotocamera/galleria/file)
3. **Viene chiamato** `DocumentoService.caricaDocumento()` → `documento_service.dart`
4. **File viene salvato SOLO localmente** in `Application Documents Directory`
5. **File NON viene inviato al backend** ❌
6. **Backend non riceve nulla** ❌

### Codice Attuale (documento_service.dart):

```dart
Future<Documento?> _salvaDocumento({
  required File file,
  required String fileName,
  required String tipo,
  DateTime? dataScadenza,
}) async {
  // ❌ Salva SOLO localmente
  final appDir = await getApplicationDocumentsDirectory();
  final documentiDir = Directory('${appDir.path}/documenti');
  final savedFile = await file.copy(newPath);
  
  // Crea oggetto Documento (solo locale)
  final documento = Documento(...);
  
  // Salva in Local Storage (solo locale)
  await _saveDocumenti(documenti);
  
  // ⚠️ NON chiama SocioService.uploadDocumento() ⚠️
  
  return documento;
}
```

**PROBLEMA:** Il metodo `SocioService.uploadDocumento()` esiste ma NON viene mai chiamato!

---

## ✅ Come Dovrebbe Funzionare (CORRETTO)

### Flusso Corretto:

1. Utente seleziona documento
2. File viene salvato localmente (per cache/preview)
3. **File viene inviato al backend via API** ✅
4. Backend salva file e crea wp_posts + wp_postmeta
5. Backend risponde con successo
6. Frontend aggiorna stato locale

### Codice Corretto (da implementare):

```dart
Future<Documento?> _salvaDocumento({
  required File file,
  required String fileName,
  required String tipo,
  DateTime? dataScadenza,
}) async {
  // 1. Salva localmente (per cache)
  final appDir = await getApplicationDocumentsDirectory();
  final documentiDir = Directory('${appDir.path}/documenti');
  if (!await documentiDir.exists()) {
    await documentiDir.create(recursive: true);
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final newFileName = '${tipo}_$timestamp${_getFileExtension(fileName)}';
  final newPath = '${documentiDir.path}/$newFileName';
  final savedFile = await file.copy(newPath);

  // 2. ✅ INVIA AL BACKEND
  print('📤 Invio documento al backend...');
  final uploadResult = await SocioService.uploadDocumento(
    file: savedFile,
    tipoDocumento: tipo,
  );

  if (uploadResult['success'] != true) {
    print('❌ Errore upload backend: ${uploadResult['message']}');
    // Rimuovi file locale se upload fallisce
    await savedFile.delete();
    return null;
  }

  print('✅ Documento caricato sul backend!');
  
  // 3. Crea documento locale con ID dal backend
  final documento = Documento(
    id: uploadResult['data']['id']?.toString() ?? timestamp.toString(),
    tipo: tipo,
    filePath: savedFile.path,
    fileName: fileName,
    dataCaricamento: DateTime.now(),
    dataScadenza: dataScadenza,
    uploadedToBackend: true, // Nuovo campo da aggiungere
  );

  // 4. Rimuove documento precedente dello stesso tipo
  await rimuoviDocumentoByTipo(tipo);

  // 5. Salva nel storage locale
  final documenti = await getDocumenti();
  documenti.add(documento);
  await _saveDocumenti(documenti);

  return documento;
}
```

---

## 🔧 FIX RICHIESTO

### File da Modificare:

**`lib/services/documento_service.dart`**

Aggiungere chiamata a `SocioService.uploadDocumento()` nel metodo `_salvaDocumento()`.

### Modifiche Necessarie:

1. Importare `SocioService`:
```dart
import 'socio_service.dart';
```

2. Modificare `_salvaDocumento()` per includere upload backend (vedi codice sopra)

3. Gestire errori di upload:
```dart
// Se upload fallisce, informare l'utente
if (uploadResult['success'] != true) {
  throw Exception('Errore caricamento documento: ${uploadResult['message']}');
}
```

4. (Opzionale) Aggiungere flag `uploadedToBackend` al modello `Documento`:
```dart
class Documento {
  final String id;
  final String tipo;
  final String filePath;
  final String fileName;
  final DateTime dataCaricamento;
  final DateTime? dataScadenza;
  final bool uploadedToBackend; // ← Nuovo campo
  
  // ...
}
```

---

## 📡 Endpoint Backend Chiamato

### Request da Flutter:

```http
POST /soci/me/upload-documento
Host: wecoop.org
Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="carta_identita_1708174800000.jpg"
Content-Type: image/jpeg

{binary_data}

--boundary
Content-Disposition: form-data; name="tipo_documento"

carta_identita
--boundary--
```

### Parametri:

| Campo | Tipo | Valore | Descrizione |
|-------|------|--------|-------------|
| `file` | File (multipart) | Binary data | File documento (JPG, PNG, PDF) |
| `tipo_documento` | String (field) | `carta_identita` \| `passaporto` \| `codice_fiscale` \| `permesso_soggiorno` | Tipo del documento |

### Headers:

```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGci...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary...
```

### Response Attesa (Success):

```json
{
  "success": true,
  "message": "Documento caricato con successo",
  "data": {
    "id": 789,
    "tipo_documento": "carta_identita",
    "file_url": "https://wecoop.org/wp-content/uploads/2026/02/carta_identita.jpg",
    "data_caricamento": "2026-02-17T10:30:00Z"
  }
}
```

### Response Attesa (Error):

```json
{
  "success": false,
  "message": "Errore: File troppo grande"
}
```

---

## 🧪 Test Frontend

### Test 1: Verificare se Upload Backend Viene Chiamato

**Aggiungere log temporaneo in `documento_service.dart`:**

```dart
Future<Documento?> _salvaDocumento({...}) async {
  print('🔍 DEBUG: Inizio _salvaDocumento()');
  print('   Tipo: $tipo');
  print('   FileName: $fileName');
  
  // ... codice esistente ...
  
  // ⚠️ AGGIUNGERE QUESTO:
  print('🔍 DEBUG: Chiamo SocioService.uploadDocumento()...');
  final uploadResult = await SocioService.uploadDocumento(
    file: savedFile,
    tipoDocumento: tipo,
  );
  print('🔍 DEBUG: Upload result: $uploadResult');
  
  // ... resto del codice ...
}
```

**Eseguire test:**

1. Aprire app Flutter in debug mode
2. Navigare a "I miei documenti"
3. Caricare un documento
4. Controllare console per vedere:
   - ✅ Log "Chiamo SocioService.uploadDocumento()"
   - ✅ Request HTTP viene inviata
   - ✅ Response viene ricevuta

### Test 2: Simulare Upload Manuale

**Codice di test da eseguire:**

```dart
// Da eseguire in un pulsante di test
Future<void> _testUploadDocumento() async {
  print('🧪 TEST: Inizio test upload documento...');
  
  // Seleziona file di test
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  );
  
  if (result == null) {
    print('❌ TEST: Nessun file selezionato');
    return;
  }
  
  final file = File(result.files.single.path!);
  
  print('📤 TEST: Chiamo API upload...');
  final uploadResult = await SocioService.uploadDocumento(
    file: file,
    tipoDocumento: 'carta_identita',
  );
  
  print('📥 TEST: Result:');
  print(uploadResult);
  
  if (uploadResult['success'] == true) {
    print('✅ TEST: Upload funziona correttamente!');
  } else {
    print('❌ TEST: Upload fallito: ${uploadResult['message']}');
  }
}
```

---

## 🔍 Debug Backend

### Cosa Verificare Backend:

Il backend deve implementare correttamente l'endpoint `/soci/me/upload-documento`.

**1. Verificare che riceve la richiesta:**

```php
// In functions.php o nel file REST API
add_action('rest_api_init', function() {
    register_rest_route('wc/v1', '/soci/me/upload-documento', array(
        'methods' => 'POST',
        'callback' => 'wecoop_upload_documento',
        'permission_callback' => function() {
            return is_user_logged_in();
        }
    ));
});

function wecoop_upload_documento($request) {
    error_log('🔍 WECOOP: Upload documento chiamato');
    error_log('🔍 User ID: ' . get_current_user_id());
    error_log('🔍 Files: ' . print_r($_FILES, true));
    error_log('🔍 POST: ' . print_r($_POST, true));
    
    // ... resto implementazione ...
}
```

**2. Verificare ricezione file:**

```php
if (!isset($_FILES['file'])) {
    error_log('❌ WECOOP: Nessun file ricevuto!');
    return new WP_Error('no_file', 'Nessun file ricevuto', array('status' => 400));
}

$file = $_FILES['file'];
error_log('✅ WECOOP: File ricevuto: ' . $file['name']);
error_log('   Size: ' . $file['size'] . ' bytes');
error_log('   Type: ' . $file['type']);
```

**3. Verificare tipo_documento:**

```php
$tipo_documento = isset($_POST['tipo_documento']) ? sanitize_text_field($_POST['tipo_documento']) : '';

if (empty($tipo_documento)) {
    error_log('❌ WECOOP: tipo_documento mancante!');
    return new WP_Error('missing_tipo', 'tipo_documento mancante', array('status' => 400));
}

error_log('✅ WECOOP: tipo_documento = ' . $tipo_documento);
```

**4. Salvare file in WordPress media library:**

```php
// WordPress handle upload
require_once(ABSPATH . 'wp-admin/includes/file.php');
require_once(ABSPATH . 'wp-admin/includes/media.php');
require_once(ABSPATH . 'wp-admin/includes/image.php');

$uploaded_file = wp_handle_upload($_FILES['file'], array('test_form' => false));

if (isset($uploaded_file['error'])) {
    error_log('❌ WECOOP: Errore upload: ' . $uploaded_file['error']);
    return new WP_Error('upload_failed', $uploaded_file['error'], array('status' => 500));
}

error_log('✅ WECOOP: File salvato: ' . $uploaded_file['file']);
```

**5. Creare attachment post:**

```php
$attachment_id = wp_insert_attachment(array(
    'post_mime_type' => $uploaded_file['type'],
    'post_title' => sanitize_file_name($file['name']),
    'post_content' => '',
    'post_status' => 'inherit',
    'post_author' => get_current_user_id()
), $uploaded_file['file']);

if (is_wp_error($attachment_id)) {
    error_log('❌ WECOOP: Errore creazione attachment');
    return $attachment_id;
}

error_log('✅ WECOOP: Attachment creato: ID = ' . $attachment_id);
```

**6. Aggiungere meta corretti:**

```php
// Meta per identificare documento socio
update_post_meta($attachment_id, 'documento_socio', 'yes');
update_post_meta($attachment_id, 'tipo_documento', $tipo_documento);

error_log('✅ WECOOP: Meta salvati:');
error_log('   documento_socio = yes');
error_log('   tipo_documento = ' . $tipo_documento);
```

**7. Response finale:**

```php
return array(
    'success' => true,
    'message' => 'Documento caricato con successo',
    'data' => array(
        'id' => $attachment_id,
        'tipo_documento' => $tipo_documento,
        'file_url' => wp_get_attachment_url($attachment_id),
        'data_caricamento' => current_time('mysql')
    )
);
```

---

## 🎯 Codice Completo Backend (PHP)

```php
<?php
/**
 * Endpoint: POST /wp-json/wc/v1/soci/me/upload-documento
 */

add_action('rest_api_init', function() {
    register_rest_route('wc/v1', '/soci/me/upload-documento', array(
        'methods' => 'POST',
        'callback' => 'wecoop_upload_documento',
        'permission_callback' => function() {
            return is_user_logged_in();
        }
    ));
});

function wecoop_upload_documento($request) {
    $user_id = get_current_user_id();
    
    error_log('🔍 WECOOP Upload Documento - User #' . $user_id);
    
    // 1. Verifica file
    if (!isset($_FILES['file'])) {
        error_log('❌ Nessun file ricevuto');
        return new WP_Error('no_file', 'Nessun file ricevuto', array('status' => 400));
    }
    
    // 2. Verifica tipo_documento
    $tipo_documento = isset($_POST['tipo_documento']) ? sanitize_text_field($_POST['tipo_documento']) : '';
    
    if (empty($tipo_documento)) {
        error_log('❌ tipo_documento mancante');
        return new WP_Error('missing_tipo', 'tipo_documento mancante', array('status' => 400));
    }
    
    // 3. Valida tipo_documento
    $tipi_validi = array('carta_identita', 'passaporto', 'codice_fiscale', 'permesso_soggiorno');
    if (!in_array($tipo_documento, $tipi_validi)) {
        error_log('❌ tipo_documento non valido: ' . $tipo_documento);
        return new WP_Error('invalid_tipo', 'tipo_documento non valido', array('status' => 400));
    }
    
    error_log('✅ File: ' . $_FILES['file']['name']);
    error_log('✅ Tipo: ' . $tipo_documento);
    
    // 4. Upload file
    require_once(ABSPATH . 'wp-admin/includes/file.php');
    require_once(ABSPATH . 'wp-admin/includes/media.php');
    require_once(ABSPATH . 'wp-admin/includes/image.php');
    
    $uploaded_file = wp_handle_upload($_FILES['file'], array('test_form' => false));
    
    if (isset($uploaded_file['error'])) {
        error_log('❌ Errore upload: ' . $uploaded_file['error']);
        return new WP_Error('upload_failed', $uploaded_file['error'], array('status' => 500));
    }
    
    error_log('✅ File salvato: ' . $uploaded_file['file']);
    
    // 5. Crea attachment
    $attachment_id = wp_insert_attachment(array(
        'post_mime_type' => $uploaded_file['type'],
        'post_title' => sanitize_file_name($_FILES['file']['name']),
        'post_content' => '',
        'post_status' => 'inherit',
        'post_author' => $user_id
    ), $uploaded_file['file']);
    
    if (is_wp_error($attachment_id)) {
        error_log('❌ Errore creazione attachment');
        return $attachment_id;
    }
    
    error_log('✅ Attachment ID: ' . $attachment_id);
    
    // 6. Genera metadata immagine
    $attach_data = wp_generate_attachment_metadata($attachment_id, $uploaded_file['file']);
    wp_update_attachment_metadata($attachment_id, $attach_data);
    
    // 7. Aggiungi meta custom
    update_post_meta($attachment_id, 'documento_socio', 'yes');
    update_post_meta($attachment_id, 'tipo_documento', $tipo_documento);
    
    error_log('✅ Meta salvati:');
    error_log('   documento_socio = yes');
    error_log('   tipo_documento = ' . $tipo_documento);
    
    // 8. Response
    return array(
        'success' => true,
        'message' => 'Documento caricato con successo',
        'data' => array(
            'id' => $attachment_id,
            'tipo_documento' => $tipo_documento,
            'file_url' => wp_get_attachment_url($attachment_id),
            'data_caricamento' => current_time('mysql')
        )
    );
}
```

---

## 📊 Query di Verifica Database

Dopo aver implementato il fix, verificare nel database:

```sql
-- 1. Verifica attachment creato
SELECT ID, post_title, post_author, post_date, post_mime_type
FROM wp_posts
WHERE post_type = 'attachment'
  AND post_author = 37
ORDER BY post_date DESC
LIMIT 5;

-- 2. Verifica meta documento_socio
SELECT p.ID, p.post_title, pm.meta_key, pm.meta_value
FROM wp_posts p
INNER JOIN wp_postmeta pm ON p.ID = pm.post_id
WHERE p.post_author = 37
  AND p.post_type = 'attachment'
  AND pm.meta_key IN ('documento_socio', 'tipo_documento')
ORDER BY p.post_date DESC;

-- 3. Count documenti per utente
SELECT 
    COUNT(*) as totale_documenti,
    COUNT(DISTINCT pm.post_id) as documenti_con_meta
FROM wp_posts p
LEFT JOIN wp_postmeta pm ON p.ID = pm.post_id AND pm.meta_key = 'documento_socio'
WHERE p.post_type = 'attachment'
  AND p.post_author = 37;
```

---

## ✅ Checklist Implementazione

### Frontend (Flutter)

- [ ] Modificare `lib/services/documento_service.dart`
- [ ] Aggiungere import `import 'socio_service.dart';`
- [ ] Modificare metodo `_salvaDocumento()` per chiamare `SocioService.uploadDocumento()`
- [ ] Gestire errori di upload
- [ ] Testare upload da fotocamera
- [ ] Testare upload da galleria
- [ ] Testare upload da file picker
- [ ] Verificare log console durante upload
- [ ] Testare con diversi tipi di documento (carta_identita, passaporto, etc.)

### Backend (WordPress/PHP)

- [ ] Implementare endpoint `POST /wp-json/wc/v1/soci/me/upload-documento`
- [ ] Verificare autenticazione JWT
- [ ] Accettare multipart/form-data
- [ ] Validare presenza file
- [ ] Validare tipo_documento
- [ ] Salvare file con wp_handle_upload()
- [ ] Creare wp_posts attachment
- [ ] Aggiungere meta 'documento_socio' = 'yes'
- [ ] Aggiungere meta 'tipo_documento' = valore
- [ ] Ritornare response JSON corretta
- [ ] Testare con curl
- [ ] Verificare log error_log
- [ ] Verificare database dopo upload

### Testing End-to-End

- [ ] Upload documento da app → verificare file su server
- [ ] Verificare wp_posts creato
- [ ] Verificare wp_postmeta corretti
- [ ] Creare richiesta servizio → verificare associazione documenti
- [ ] Verificare meta 'documenti_allegati' popolato
- [ ] Verificare admin WordPress visualizza documenti
- [ ] Testare eliminazione documento
- [ ] Testare sovrascrittura documento esistente

---

## 🚀 Priorità Implementazione

1. **PRIORITÀ MASSIMA:** Fix frontend - aggiungere chiamata `SocioService.uploadDocumento()`
2. **PRIORITÀ ALTA:** Verificare/implementare endpoint backend
3. **PRIORITÀ MEDIA:** Testare flusso completo
4. **PRIORITÀ BASSA:** Miglioramenti UI/UX (retry, progress bar, etc.)

---

**Data:** 17 Febbraio 2026  
**Versione:** 1.0  
**Autore:** Debug Session - User #37 Test Case
