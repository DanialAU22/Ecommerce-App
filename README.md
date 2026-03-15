# ecommerce_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase setup (local only)

This repo is configured to avoid committing Firebase API keys.

1. Generate Firebase config locally with `flutterfire configure`.
2. Keep `android/app/google-services.json` local (it is gitignored).
3. Run the app with API keys via dart defines:

```bash
flutter run \
	--dart-define=FIREBASE_WEB_API_KEY=YOUR_WEB_KEY \
	--dart-define=FIREBASE_ANDROID_API_KEY=YOUR_ANDROID_KEY \
	--dart-define=FIREBASE_IOS_API_KEY=YOUR_IOS_KEY \
	--dart-define=FIREBASE_MACOS_API_KEY=YOUR_MACOS_KEY \
	--dart-define=FIREBASE_WINDOWS_API_KEY=YOUR_WINDOWS_KEY
```

Use `android/app/google-services.json.example` as a structure reference only.
