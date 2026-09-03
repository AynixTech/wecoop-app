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

- **Navigation:** use `AppNavigation` (`lib/utils/app_navigation.dart`) for tabs, login, and push/deep-link routing.
- **Member services:** use `openMemberService()` (`lib/utils/member_service_navigation.dart`) for gated flows.
- **i18n:** runtime strings live in `lib/services/app_localizations.dart` (it, en, es, ar, zh).
