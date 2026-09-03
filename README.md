# WeCoop App (Flutter)

Mobile app for WeCoop members and guests.

## Requirements

- Flutter SDK ^3.7
- Xcode (iOS) / Android Studio (Android)

## Setup

```bash
flutter pub get
```

## Run (development)

```bash
# Auth = JWT (login). WECOOP_API_URL è opzionale (default = prod).
flutter run \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx \
  --dart-define=STRIPE_URL_SCHEME=wecoop \
  --dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.org.wecoop
```


## Quality checks

```bash
dart analyze lib
flutter test
```

## Android release (Play Store)

1. Copy signing config:

```bash
cp android/key.properties.example android/key.properties
```

2. Build App Bundle:

```bash
flutter clean
flutter pub get
flutter build appbundle --release \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
  --dart-define=STRIPE_URL_SCHEME=wecoop \
  --dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.org.wecoop
```


Output: `build/app/outputs/bundle/release/app-release.aab`

## Architecture notes

- **API:** default `https://wecoop-backend-s9gl.onrender.com/api` (`ApiConfig`). Override with `--dart-define=WECOOP_API_URL=…`.
- **Integrations / API keys:** configure Stripe, AI, Maps, SMS, FCM, etc. in the platform UI at [cloud.wecoop.org/integrazioni](https://cloud.wecoop.org/integrazioni) (DB `settings`, env is only fallback). The app loads Stripe publishable key at runtime from `GET /stripe-config`. Optional dart-define for local builds — see `stripe.env.example.json` (Node `/api`, not WordPress).
- **Navigation:** use `AppNavigation` (`lib/utils/app_navigation.dart`) for tabs, login, and push/deep-link routing.
- **Member services:** use `openMemberService()` (`lib/utils/member_service_navigation.dart`) for gated flows.
- **i18n:** runtime strings live in `lib/services/app_localizations.dart` (it, en, es, ar, zh).
- **Contents:** `ContenutiService` (posts/partners/leads) talks to the Node backend — not WordPress REST.