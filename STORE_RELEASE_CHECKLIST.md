# Store Release Checklist

Questa checklist copre i passaggi rimasti fuori dal codice per pubblicare WeCoop su Play Store e App Store.

## Gia' sistemato nel repo

- Versione Flutter con build number: `1.3.2`
- Bundle identifier iOS allineato a `com.wecoop.app`
- Stripe configurato via `--dart-define` invece di chiave test hardcoded
- Avvio app tollerante se Firebase iOS non e' ancora configurato
- Permessi Android legacy di storage rimossi
- Metadata iOS aggiunti per encryption disclosure e Photo Library save

## Configurazione obbligatoria prima della release

### Firebase iOS

1. Crea l'app iOS `com.wecoop.app` nel progetto Firebase corretto.
2. Scarica `GoogleService-Info.plist`.
3. Aggiungilo in `ios/Runner/GoogleService-Info.plist` tramite Xcode con target `Runner`.
4. Verifica che notifiche push/APNs siano configurate anche in Apple Developer.

### Stripe release

Passa i valori live tramite `--dart-define` nelle build release.

Esempio Android App Bundle:

```bash
flutter build appbundle \
  --release \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
  --dart-define=STRIPE_URL_SCHEME=wecoop \
  --dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.org.wecoop \
  --dart-define=STRIPE_BACKEND_URL=https://www.wecoop.org/wp-json/wecoop/v1
```

Esempio iOS IPA:

```bash
flutter build ipa \
  --release \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
  --dart-define=STRIPE_URL_SCHEME=wecoop \
  --dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.org.wecoop \
  --dart-define=STRIPE_BACKEND_URL=https://www.wecoop.org/wp-json/wecoop/v1
```

### Signing

#### Android

1. Verifica `android/key.properties`
2. Verifica keystore release valido
3. Esegui una build release reale prima di caricare su Play Console

#### iOS

1. Verifica `com.wecoop.app` in Apple Developer
2. Associa certificati e provisioning profile corretti
3. Verifica capability richieste: Push Notifications, Background Modes se usate

## Check di submission

### Play Store

1. Compila Data safety coerente con notifiche, documenti, autenticazione e pagamenti
2. Compila modulo permessi e dichiara l'uso della fotocamera
3. Carica icona, feature graphic, screenshot smartphone
4. Testa login, upload documenti, pagamenti, deep link, notifiche in build release

### App Store

1. Compila App Privacy coerente con Firebase, notifiche, documenti, pagamenti e account
2. Inserisci privacy policy URL e support URL
3. Verifica account deletion flow se l'utente crea account nell'app
4. Testa iPhone reale con build release/TestFlight

## Distribuzione ai tester iOS

### Scelta consigliata: TestFlight

Per i tester iOS la scelta migliore e' quasi sempre TestFlight.

Vantaggi:

- non devi raccogliere gli UDID dei dispositivi
- Apple gestisce installazione e trust
- e' il canale standard per beta interna ed esterna
- e' piu' vicino alla release reale App Store

Flusso consigliato:

1. in Xcode verifica signing release e team corretti
2. esegui una build archive oppure `flutter build ipa --release`
3. carica la build su App Store Connect
4. in App Store Connect abilita TestFlight
5. invita tester interni oppure esterni

### Quando usare Firebase App Distribution su iOS

Firebase App Distribution su iOS va bene soprattutto per QA interna o piccoli gruppi tecnici, ma e' meno comoda di TestFlight.

Limiti pratici:

- spesso richiede profilo Ad Hoc o Enterprise
- per Ad Hoc devi registrare gli UDID dei tester
- ogni device deve essere incluso nel provisioning profile
- l'esperienza di installazione e' piu' macchinosa rispetto a TestFlight

### Regola pratica per WeCoop

- usa TestFlight per tester iPhone reali e stakeholder
- usa Firebase App Distribution su Android come fai gia'
- usa Firebase App Distribution iOS solo se ti serve una distribuzione tecnica interna molto controllata

## Comandi utili

Analisi:

```bash
flutter analyze
```

Android release:

```bash
flutter build appbundle --release
```

iOS release:

```bash
flutter build ipa --release
```