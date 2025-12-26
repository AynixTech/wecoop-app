# Deep Links Setup - WeCoop App

Questo documento spiega come implementare i deep links nell'app WeCoop per aprire sezioni specifiche da email o link esterni.

## 📋 Indice

1. [Configurazione Android](#configurazione-android)
2. [Configurazione iOS](#configurazione-ios)
3. [Implementazione Flutter](#implementazione-flutter)
4. [Schema URL Supportati](#schema-url-supportati)
5. [Esempi di utilizzo nelle Email](#esempi-di-utilizzo-nelle-email)
6. [Testing](#testing)

---

## 🤖 Configurazione Android

### 1. Modifica `android/app/src/main/AndroidManifest.xml`

Aggiungi gli intent filters per gestire i deep links:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <!-- Deep Links con schema custom -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="wecoop"
                    android:host="app" />
            </intent-filter>

            <!-- App Links (HTTPS) -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="tuosito.com"
                    android:pathPrefix="/app" />
            </intent-filter>

            <!-- ... existing intent filters ... -->
        </activity>
    </application>
</manifest>
```

### 2. Verifica file `assetlinks.json` (per App Links HTTPS)

Carica questo file su `https://tuosito.com/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.wecoop.app",
    "sha256_cert_fingerprints": [
      "INSERISCI_QUI_IL_TUO_SHA256_FINGERPRINT"
    ]
  }
}]
```

Per ottenere il fingerprint:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## 🍎 Configurazione iOS

### 1. Modifica `ios/Runner/Info.plist`

Aggiungi lo schema custom URL:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.wecoop.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wecoop</string>
        </array>
    </dict>
</array>
```

### 2. Universal Links (HTTPS)

Aggiungi in `Info.plist`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:tuosito.com</string>
</array>
```

### 3. File `apple-app-site-association`

Carica su `https://tuosito.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.wecoop.app",
        "paths": ["/app/*"]
      }
    ]
  }
}
```

### 4. Xcode Configuration

1. Apri `ios/Runner.xcworkspace` in Xcode
2. Seleziona il target `Runner`
3. Tab `Signing & Capabilities`
4. Clicca `+ Capability` → Aggiungi `Associated Domains`
5. Aggiungi: `applinks:tuosito.com`

---

## 📱 Implementazione Flutter

### 1. Aggiungi dipendenze in `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  uni_links: ^0.5.1
  app_links: ^3.5.0  # Alternativa moderna
```

Esegui:
```bash
flutter pub get
```

### 2. Crea `lib/services/deep_link_service.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription? _sub;
  String? _initialLink;
  Function(Uri)? _onLink;

  /// Inizializza il servizio e gestisce il link iniziale
  Future<void> initialize(Function(Uri) onLink) async {
    _onLink = onLink;

    // Gestisci il link iniziale (app aperta da chiusa)
    try {
      _initialLink = await getInitialLink();
      if (_initialLink != null) {
        _handleLink(Uri.parse(_initialLink!));
      }
    } catch (e) {
      print('Errore recupero link iniziale: $e');
    }

    // Ascolta nuovi link (app già aperta)
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(Uri.parse(link));
      }
    }, onError: (err) {
      print('Errore deep link: $err');
    });
  }

  void _handleLink(Uri uri) {
    print('🔗 Deep link ricevuto: $uri');
    _onLink?.call(uri);
  }

  /// Pulisce le risorse
  void dispose() {
    _sub?.cancel();
  }
}
```

### 3. Crea `lib/utils/deep_link_handler.dart`

```dart
import 'package:flutter/material.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/servizi/pagamento_screen.dart';
import '../screens/profilo/profilo_screen.dart';
import '../screens/home/home_screen.dart';

class DeepLinkHandler {
  /// Naviga alla schermata corretta in base all'URI
  static void handleDeepLink(BuildContext context, Uri uri) {
    print('📍 Gestisco deep link: ${uri.path}');
    
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // wecoop://app/richieste
    if (path == '/richieste' || path == '/calendar') {
      Navigator.of(context).pushNamed('/calendar');
      return;
    }

    // wecoop://app/richieste/405
    // wecoop://app/richieste?id=405
    if (path.startsWith('/richieste/')) {
      final id = path.split('/').last;
      _navigateToRichiesta(context, id);
      return;
    }
    if (path == '/richieste' && queryParams.containsKey('id')) {
      _navigateToRichiesta(context, queryParams['id']!);
      return;
    }

    // wecoop://app/pagamento/405
    // wecoop://app/pagamento?richiesta_id=405
    if (path.startsWith('/pagamento/')) {
      final id = int.tryParse(path.split('/').last);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PagamentoScreen(richiestaId: id),
          ),
        );
      }
      return;
    }
    if (path == '/pagamento' && queryParams.containsKey('richiesta_id')) {
      final id = int.tryParse(queryParams['richiesta_id']!);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PagamentoScreen(richiestaId: id),
          ),
        );
      }
      return;
    }

    // wecoop://app/profilo
    if (path == '/profilo' || path == '/profile') {
      Navigator.of(context).pushNamed('/profilo');
      return;
    }

    // wecoop://app/servizi
    // wecoop://app/servizi?categoria=caf
    if (path == '/servizi' || path == '/services') {
      final categoria = queryParams['categoria'];
      Navigator.of(context).pushNamed('/home', arguments: {'categoria': categoria});
      return;
    }

    // wecoop://app/home
    if (path == '/home' || path == '/') {
      Navigator.of(context).pushNamed('/home');
      return;
    }

    // Link non riconosciuto
    print('⚠️ Deep link non gestito: $path');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link non valido')),
    );
  }

  static void _navigateToRichiesta(BuildContext context, String id) {
    // Naviga al calendario e poi apre il dettaglio
    Navigator.of(context).pushNamed('/calendar', arguments: {'richiesta_id': id});
  }
}
```

### 4. Modifica `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'services/deep_link_service.dart';
import 'utils/deep_link_handler.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    await _deepLinkService.initialize((uri) {
      // Aspetta che il navigator sia pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _navigatorKey.currentContext;
        if (context != null) {
          DeepLinkHandler.handleDeepLink(context, uri);
        }
      });
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      // ... resto configurazione
    );
  }
}
```

### 5. Modifica `lib/screens/calendar/calendar_screen.dart`

Aggiungi gestione apertura automatica richiesta:

```dart
class _CalendarScreenState extends State<CalendarScreen> {
  String? _richiestaIdToOpen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Controlla se c'è un ID richiesta da aprire
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['richiesta_id'] != null && _richiestaIdToOpen == null) {
      _richiestaIdToOpen = args['richiesta_id'];
      
      // Apri il dettaglio dopo che le richieste sono caricate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _apriRichiestaById(_richiestaIdToOpen!);
      });
    }
  }

  void _apriRichiestaById(String id) {
    final richiesta = _tutteRichieste.firstWhere(
      (r) => r['id'].toString() == id,
      orElse: () => {},
    );
    
    if (richiesta.isNotEmpty) {
      _mostraDettaglioRichiesta(richiesta);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Richiesta non trovata')),
      );
    }
  }
  
  // ... resto del codice
}
```

---

## 🔗 Schema URL Supportati

### Custom Scheme (`wecoop://`)

| URL | Descrizione | Esempio |
|-----|-------------|---------|
| `wecoop://app/home` | Apre home | `wecoop://app/home` |
| `wecoop://app/richieste` | Apre calendario richieste | `wecoop://app/richieste` |
| `wecoop://app/richieste/405` | Apre richiesta specifica | `wecoop://app/richieste/405` |
| `wecoop://app/richieste?id=405` | Apre richiesta (query param) | `wecoop://app/richieste?id=405` |
| `wecoop://app/pagamento/405` | Apre schermata pagamento | `wecoop://app/pagamento/405` |
| `wecoop://app/profilo` | Apre profilo utente | `wecoop://app/profilo` |
| `wecoop://app/servizi?categoria=caf` | Apre servizi filtrati | `wecoop://app/servizi?categoria=caf` |

### HTTPS Links (`https://tuosito.com/app/...`)

| URL | Descrizione | Esempio |
|-----|-------------|---------|
| `https://tuosito.com/app/richieste/405` | Apre richiesta | Universal Link |
| `https://tuosito.com/app/pagamento/405` | Apre pagamento | Universal Link |
| `https://tuosito.com/app/profilo` | Apre profilo | Universal Link |

---

## 📧 Esempi di utilizzo nelle Email

### Email Conferma Richiesta

```html
<html>
<body>
  <h2>Richiesta Ricevuta!</h2>
  <p>La tua richiesta #12345 è stata ricevuta con successo.</p>
  
  <a href="wecoop://app/richieste/405" 
     style="background: #FFA726; padding: 10px 20px; color: white; text-decoration: none;">
    Vedi Dettagli in App
  </a>
  
  <!-- Fallback per browser -->
  <p>
    <small>
      Non riesci ad aprire l'app? 
      <a href="https://tuosito.com/app/richieste/405">Clicca qui</a>
    </small>
  </p>
</body>
</html>
```

### Email Pagamento Richiesto

```html
<html>
<body>
  <h2>Pagamento Richiesto</h2>
  <p>La tua pratica #12345 richiede un pagamento di €20.00</p>
  
  <a href="wecoop://app/pagamento/405"
     style="background: #FF5722; padding: 10px 20px; color: white; text-decoration: none;">
    Paga Ora
  </a>
  
  <p>
    <a href="https://tuosito.com/app/pagamento/405">
      Apri nel browser
    </a>
  </p>
</body>
</html>
```

### Email Pagamento Confermato

```html
<html>
<body>
  <h2>✅ Pagamento Ricevuto</h2>
  <p>Il tuo pagamento di €20.00 è stato confermato.</p>
  <p>Numero transazione: pi_3SidSQPF9rfBflxG1ImB1iQW</p>
  
  <a href="wecoop://app/richieste/405">
    Vedi lo stato della tua richiesta
  </a>
</body>
</html>
```

### Template PHP per WordPress

```php
// In wp-content/themes/your-theme/functions.php o nel tuo plugin

function wecoop_send_richiesta_email($richiesta_id, $user_email) {
    $numero_pratica = get_post_meta($richiesta_id, 'numero_pratica', true);
    $servizio = get_the_title($richiesta_id);
    
    $deep_link = "wecoop://app/richieste/" . $richiesta_id;
    $web_link = "https://tuosito.com/app/richieste/" . $richiesta_id;
    
    $subject = "Richiesta #{$numero_pratica} Ricevuta - WeCoop";
    
    $message = "
    <html>
    <body style='font-family: Arial, sans-serif;'>
        <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
            <h2 style='color: #FFA726;'>Richiesta Ricevuta!</h2>
            <p>Ciao,</p>
            <p>La tua richiesta per <strong>{$servizio}</strong> è stata ricevuta con successo.</p>
            <p>Numero pratica: <strong>#{$numero_pratica}</strong></p>
            
            <div style='margin: 30px 0;'>
                <a href='{$deep_link}' 
                   style='background: #FFA726; padding: 12px 24px; color: white; 
                          text-decoration: none; border-radius: 4px; display: inline-block;'>
                    Vedi Dettagli in App
                </a>
            </div>
            
            <p style='font-size: 12px; color: #666;'>
                Non riesci ad aprire l'app? 
                <a href='{$web_link}'>Clicca qui per aprire nel browser</a>
            </p>
        </div>
    </body>
    </html>
    ";
    
    $headers = array('Content-Type: text/html; charset=UTF-8');
    
    wp_mail($user_email, $subject, $message, $headers);
}

// Invia email quando viene creata una richiesta
add_action('wecoop_richiesta_creata', 'wecoop_send_richiesta_email', 10, 2);
```

---

## 🧪 Testing

### Test Android

```bash
# Test da terminale ADB
adb shell am start -W -a android.intent.action.VIEW -d "wecoop://app/richieste/405"

# Test HTTPS link
adb shell am start -W -a android.intent.action.VIEW -d "https://tuosito.com/app/richieste/405"
```

### Test iOS

```bash
# Test da terminale (con simulatore aperto)
xcrun simctl openurl booted "wecoop://app/richieste/405"

# Test HTTPS link
xcrun simctl openurl booted "https://tuosito.com/app/richieste/405"
```

### Test da Browser Mobile

1. Apri browser su dispositivo reale
2. Vai su `https://tuosito.com/app/richieste/405`
3. Dovrebbe apparire popup "Aprire in WeCoop?"

### Debug Logging

Aggiungi in `deep_link_service.dart`:

```dart
void _handleLink(Uri uri) {
  print('🔗 Deep link ricevuto: $uri');
  print('   Scheme: ${uri.scheme}');
  print('   Host: ${uri.host}');
  print('   Path: ${uri.path}');
  print('   Query params: ${uri.queryParameters}');
  _onLink?.call(uri);
}
```

---

## 📝 Checklist Implementazione

- [ ] Aggiunto `uni_links` in `pubspec.yaml`
- [ ] Configurato `AndroidManifest.xml`
- [ ] Configurato `Info.plist` iOS
- [ ] Creato `deep_link_service.dart`
- [ ] Creato `deep_link_handler.dart`
- [ ] Modificato `main.dart` con navigatorKey
- [ ] Aggiornato `calendar_screen.dart` per aprire richieste
- [ ] Testato custom scheme `wecoop://`
- [ ] Testato HTTPS links (se implementati)
- [ ] Aggiornati template email WordPress
- [ ] Testato su dispositivo Android reale
- [ ] Testato su dispositivo iOS reale

---

## 🚀 Prossimi Passi

1. **Implementa il codice base** (steps 1-4)
2. **Testa con custom scheme** (`wecoop://`)
3. **Opzionale: Configura HTTPS links** per web fallback
4. **Aggiorna email template** nel backend WordPress
5. **Test completo** su dispositivi reali

---

## 🔧 Troubleshooting

### Android: Deep link non funziona

- Verifica che `android:exported="true"` sia nell'activity
- Controlla che lo schema sia corretto
- Disinstalla e reinstalla l'app
- Verifica log con `adb logcat`

### iOS: Deep link non funziona

- Verifica `Info.plist` sia corretto
- Controlla Associated Domains in Xcode
- File `.well-known/apple-app-site-association` deve essere servito con `Content-Type: application/json`
- Disinstalla e reinstalla l'app

### Link non apre la schermata corretta

- Aggiungi log in `deep_link_handler.dart`
- Verifica che il path corrisponda ai casi nello switch
- Controlla che le route siano definite in `main.dart`

---

## 📚 Risorse

- [uni_links package](https://pub.dev/packages/uni_links)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [Flutter Deep Linking Guide](https://docs.flutter.dev/ui/navigation/deep-linking)
