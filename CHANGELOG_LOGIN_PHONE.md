# Cambios Login - Username = Número de Teléfono

## 📱 Resumen de Cambios

Se ha modificado el sistema de login para usar el **número de teléfono como username** en lugar del email.

---

## 🔄 Cambios Realizados

### 1. **login_screen.dart** - Pantalla de Login

#### Antes:
```dart
final TextEditingController emailController = TextEditingController();

// Login con email
final email = emailController.text.trim();
body: jsonEncode({'username': email, 'password': password})

// Campo de entrada
TextField(
  controller: emailController,
  decoration: InputDecoration(labelText: l10n.email),
)
```

#### Después:
```dart
final TextEditingController phoneController = TextEditingController();

// Login con teléfono (solo números)
final phone = phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
body: jsonEncode({'username': phone, 'password': password})

// Campo de entrada
TextField(
  controller: phoneController,
  keyboardType: TextInputType.phone,
  decoration: InputDecoration(
    labelText: l10n.translate('phoneOrUsername'),
    hintText: l10n.translate('enterPhoneNumber'),
    helperText: 'Ejemplo: 393331234567 o +39 333 1234567',
    prefixIcon: const Icon(Icons.phone),
  ),
)
```

**Características:**
- ✅ Acepta formato con o sin símbolos: `+39 333 1234567` o `393331234567`
- ✅ Limpia automáticamente el input dejando solo números
- ✅ Teclado numérico para mejor UX
- ✅ Helper text con ejemplo

---

### 2. **Cambios en Storage/Persistencia**

#### Claves Modificadas:

| Antes | Después | Uso |
|-------|---------|-----|
| `last_login_email` | `last_login_phone` | Último teléfono usado para login |
| `saved_email` | `saved_phone` | Teléfono guardado (remember me) |

#### Funciones Actualizadas:

**`_loadLastPhone()` (antes `_loadLastEmail`):**
```dart
Future<void> _loadLastPhone() async {
  final lastPhone = await storage.read(key: 'last_login_phone');
  if (lastPhone != null && lastPhone.isNotEmpty) {
    phoneController.text = lastPhone;
  }
}
```

**Guardar teléfono después del login:**
```dart
// Salva sempre l'ultimo telefono usato (username)
await storage.write(key: 'last_login_phone', value: phone);

if (rememberPassword) {
  await storage.write(key: 'saved_phone', value: phone);
  await storage.write(key: 'saved_password', value: password);
}
```

---

### 3. **profilo_screen.dart** - Logout

#### Cambios en `_logout()`:

**Antes:**
```dart
final currentEmail = await storage.read(key: 'user_email');
if (currentEmail != null) {
  await storage.write(key: 'last_login_email', value: currentEmail);
}

await storage.delete(key: 'saved_email');
```

**Después:**
```dart
final currentPhone = await storage.read(key: 'telefono');
if (currentPhone != null) {
  await storage.write(key: 'last_login_phone', value: currentPhone);
}

await storage.delete(key: 'saved_phone');
```

---

### 4. **app_localizations.dart** - Traducciones

#### Nuevas Traducciones Agregadas:

**Italiano:**
```dart
'phoneNumber': 'Numero di telefono',
'phoneOrUsername': 'Telefono (Username)',
'enterPhoneNumber': 'Inserisci il tuo numero di telefono',
```

**Inglés:**
```dart
'phoneNumber': 'Phone number',
'phoneOrUsername': 'Phone (Username)',
'enterPhoneNumber': 'Enter your phone number',
```

**Español:**
```dart
'phoneNumber': 'Número de teléfono',
'phoneOrUsername': 'Teléfono (Usuario)',
'enterPhoneNumber': 'Ingresa tu número de teléfono',
```

---

## 🔑 Cómo Funciona el Username

### Formato del Username

**El backend genera el username combinando prefix + teléfono (solo números):**

| Entrada Usuario | Limpieza | Username Final |
|-----------------|----------|----------------|
| `+39 333 1234567` | → `393331234567` | ✅ `393331234567` |
| `393331234567` | → `393331234567` | ✅ `393331234567` |
| `+593 99 123 4567` | → `593991234567` | ✅ `593991234567` |
| `51-987-654-321` | → `51987654321` | ✅ `51987654321` |

**Limpieza automática:**
```dart
final phone = phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
```
- Elimina: `+`, `-`, espacios, paréntesis, etc.
- Mantiene: Solo dígitos `0-9`

---

## 📊 Flujo Completo de Login

### 1️⃣ Usuario Ingresa Credenciales
```
Campo Teléfono: +39 333 1234567
Campo Password: MiPassword123
```

### 2️⃣ App Limpia y Envía al Backend
```json
{
  "username": "393331234567",
  "password": "MiPassword123"
}
```

### 3️⃣ Backend Valida y Retorna Token
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJ...",
  "user_email": "mario@example.com",
  "user_display_name": "Mario Rossi",
  "user_id": 123
}
```

### 4️⃣ App Guarda Datos
```dart
await storage.write(key: 'jwt_token', value: token);
await storage.write(key: 'last_login_phone', value: '393331234567');
await storage.write(key: 'user_email', value: userEmail);
```

### 5️⃣ Próximo Login
- Campo teléfono se pre-rellena con `393331234567`
- Usuario solo ingresa password

---

## ✅ Testing

### Casos de Prueba

#### Test 1: Login con formato internacional
```
Input: +39 333 1234567
Password: test123
Expected: ✅ Login exitoso
Username enviado: 393331234567
```

#### Test 2: Login con solo números
```
Input: 393331234567
Password: test123
Expected: ✅ Login exitoso
Username enviado: 393331234567
```

#### Test 3: Login Ecuador
```
Input: +593 99 123 4567
Password: test123
Expected: ✅ Login exitoso
Username enviado: 593991234567
```

#### Test 4: Login Perú
```
Input: +51 987 654 321
Password: test123
Expected: ✅ Login exitoso
Username enviado: 51987654321
```

#### Test 5: Remember Me
```
1. Login con +39 333 1234567
2. Marcar "Remember Password"
3. Cerrar app
4. Abrir app
Expected: ✅ Campo teléfono pre-rellenado con 393331234567
```

#### Test 6: Logout y Re-login
```
1. Login exitoso
2. Logout
3. Volver a login screen
Expected: ✅ Campo teléfono pre-rellenado con último número usado
```

---

## 🚨 Puntos Importantes

### ⚠️ Email vs Teléfono

**Email sigue siendo necesario para:**
- ✅ Registro de nuevos socios (campo obligatorio)
- ✅ Recibir credenciales por email
- ✅ Recuperación de contraseña (futuro)
- ✅ Comunicaciones del sistema

**Teléfono se usa para:**
- ✅ Username de login
- ✅ Identificador único del socio
- ✅ Contacto principal

### 🔐 Seguridad

- El teléfono es único por socio (backend lo valida)
- Se almacena el último teléfono usado para mejor UX
- El password nunca se muestra (solo en dialog después del registro)

---

## 📋 Checklist de Verificación

- ✅ Login funciona con número de teléfono
- ✅ Campo acepta formato con o sin símbolos
- ✅ Limpieza automática de caracteres especiales
- ✅ Teclado numérico en el campo de entrada
- ✅ Último teléfono se guarda y pre-rellena
- ✅ Remember me funciona con teléfono
- ✅ Logout guarda teléfono para próxima sesión
- ✅ Traducciones IT/EN/ES completas
- ✅ Helper text con ejemplo visible
- ✅ Sin errores de compilación

---

## 🔄 Migración de Datos

**Para usuarios existentes:**

Si un usuario tenía `last_login_email` guardado pero ahora se usa `last_login_phone`:
- La app buscará `last_login_phone` (no encontrará nada)
- Campo aparecerá vacío
- Usuario debe ingresar su teléfono manualmente la primera vez
- Después quedará guardado en `last_login_phone`

**No es necesaria migración porque:**
- Los usuarios de prueba son nuevos
- La app está en desarrollo
- El cambio es transparente para nuevos usuarios

---

**Fecha de implementación:** 23 Diciembre 2025  
**Archivos modificados:** 3
- `lib/screens/login/login_screen.dart`
- `lib/screens/profilo/profilo_screen.dart`
- `lib/services/app_localizations.dart`
