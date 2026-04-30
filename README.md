# wecoop_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android Play Store Release

1. Prepare signing secrets locally:

```bash
cp android/key.properties.example android/key.properties
```

2. Build the release App Bundle (AAB):

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle \
	--release \
	--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
	--dart-define=STRIPE_URL_SCHEME=wecoop \
	--dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.org.wecoop \
	--dart-define=STRIPE_BACKEND_URL=https://www.wecoop.org/wp-json/wecoop/v1
```

3. Upload the generated file:

`build/app/outputs/bundle/release/app-release.aab`
