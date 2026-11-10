# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Context

Deu64 is a Flutter app (package name `mobile`). After a user logs in, it loads a "topic" (tema) with illustrated scenes, then asks a quiz about it. Code comments and UI strings are in Spanish.

This directory (`mobile_Claude_Code`) is the canonical copy of the app: make changes and commits here, not in `../mobile` (an older working copy that git currently tracks). The parent `Deu64/` directory holds the Go backend (`../backend`), several dated backup copies (`Copia de mobile …`, `mobile_ver1`), and project docs (`Bitacora_Proyecto_Deu64.md`, `Documentacion/`, `Reglas_DeNegocio/`). Don't edit the backup copies unless asked.

## Commands

```bash
flutter clean && flutter pub get
flutter run -d <device-id>        # README uses a physical Android device: flutter run -d TITANNEA00013091
flutter analyze                   # lints: package:flutter_lints/flutter.yaml
flutter test                      # all tests
flutter test test/widget_test.dart --plain-name "<test name>"   # single test
```

Backend (run it before the app, from `../backend`): `go build` then `go run main.go`. It serves `/api/v1/leer_tema`, `/api/v1/preguntas_tema?topicId=…` and `/static/` (scene images), with data in `backend/data/tema.json` and `preguntas.json`.

Only Android is actively used and tested (physical device). The `ios/`, `linux/`, `macos/`, `windows/` and `web/` folders are default Flutter scaffolding; don't spend effort on them unless asked.

`test/widget_test.dart` is still the default counter template. It references `MyApp`, which doesn't exist (the app widget is `Deu64App`), so it fails until someone rewrites it.

## Architecture

**Flow.** Each screen replaces the previous one with `pushReplacement`. The only exception is login, which is pushed and returns a result:
`LoadingScreen` → (push) `LoginPage` → pops `AuthorizationTokenResponse` → `ApiClient.fetchTopic()` → `ScenesCarouselScreen` → `StartQuestionsScreen` → `QuizCarouselScreen` (fetches questions) → `ResultScreen`.
`LoadingScreen._load()` starts from `addPostFrameCallback` in `initState`. This is on purpose: it fixes a black-screen bug. While it loads, it prefetches the questions and the scene images in the background without awaiting them.

**API / offline cache** (`lib/api.dart`). `ApiClient` uses plain `http` with a 6s timeout. Each successful response body is saved in `SharedPreferences` (`cache_topic_v1`, `cache_questions_v1_<topicId>`). If a request fails for any reason, the client falls back to the cached copy. Models are hand-written `fromJson` classes in `lib/models.dart`. JSON keys are camelCase English (`topicId`, `scenes`, `imageUrl`, `isCorrect`).

**Backend URL.** `AppConfig.baseUrl` in `lib/config.dart` is a hardcoded LAN IP of the Mac running the backend, and the same IP is hardcoded in every `imageUrl` of `../backend/data/tema.json`. The IP is assigned by DHCP and changes. When it does, the app fails with `No route to host` and both files need updating (check with `ipconfig getifaddr en0`). The backend re-reads `tema.json` on every request, so it doesn't need a restart. The phone must be on the same network as the machine running the backend. The README warns that a USB cable alone doesn't give the phone a route to the server: Wi-Fi must be on, and USB must be set to file-transfer mode.

**Images.** Scene images go through a shared `sceneImagesCacheManager` (`lib/image_cache_manager.dart`: 30-day cache, 500 objects) together with `cached_network_image`. Use that manager instead of creating new caches.

**Auth (AWS Cognito via `flutter_appauth`)**
- Config lives in `lib/config/auth_config.dart`: client ID, user pool `us-east-2_RlzSOWfNF`, discovery URL, and the redirect `deu64://oauth2redirect` / logout `deu64://logout`. The redirect scheme `deu64` must match `appAuthRedirectScheme` in `android/app/build.gradle.kts` and the callback/sign-out URLs set in Cognito.
- There are **two `AuthService` classes**:
  - `lib/services/auth_service.dart` is the one `LoginPage` actually uses. It has debug prints and doesn't persist tokens.
  - `lib/auth/auth_service.dart` additionally saves the refresh token through `TokenStorage` (`lib/auth/auth_token.dart`, `flutter_secure_storage`).

  Check which one you mean before changing auth behavior.
- Background notes on the Cognito setup: `Development Coginito Flutter.md` and `Proceso_Cognito/`.

**Dead/legacy files.** These aren't wired into the app:
- `lib/screens/Spbra_login_screen.dart`: imports a `home_screen.dart` that doesn't exist, so it won't compile if anything imports it.
- `lib/screens/Copia de old_quiz_carousel_screen.dart`
- `lib/main_dart.tmp`

Many files also keep older versions of functions commented out above the active one, with dated notes from the author. Leave those notes alone unless asked to clean them up.
