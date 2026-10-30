# Flow — Full-stack Flutter Community App Architecture Template

> A **real fork-and-run** architecture reference for building community apps in Flutter.
>
> Not another social app — it's the **starting point** that lets a solo developer see a working feed in 30 minutes and ship their own community in 7 days.
>
> Target platforms: iOS / Android / Web / macOS · Flutter 3.47 · Node 24 · SQLite

<p align="center">
  <strong>Status</strong>: v0.1 — fully working on three platforms, backed by a real Node/TypeScript API server
</p>

## Why Flow exists

State management, routing, networking, theming, i18n — every Flutter community app re-solves the same dozen problems. Flow ships them solved, **plus a runnable backend**, so you spend your first week on actual product decisions instead of boilerplate.

It is designed for three audiences:

- **Indie Flutter devs** who want a reference they can Fork and modify without re-architecting
- **Small teams** shipping a content/community product and looking for a Feature-First foundation
- **Self-hosters** (next) who want a single command for the whole stack

## What you get

| Module | Coverage |
|---|---|
| Auth | Email/password · JWT · auto-persisted token · redirect guard |
| Feed | Pagination · pull-to-refresh · optimistic like with rollback · delete |
| Posts | Compose (text + optional image URL) · push-to-top on create |
| Comments | List per post · send with live counter · bottom sheet composer |
| Theme | Light / Dark / Follow system · FlexColorScheme gold · persistence |
| i18n | Chinese (zh-CN) + English (en-US) · easy_localization |
| Error handling | `AppException` sealed class + Dio interceptor chain |
| Tests | 1 smoke test · 4 integration tests (skipped unless backend running) |
| Backend | Express + TypeScript + SQLite (single file DB, no extra process) |
| CI | GitHub Actions: `flutter analyze` + `flutter test` |

## Quick start (full stack)

```bash
# 1. Backend
cd server
npm install
npm run init-db   # seeds demo user + sample posts
npm run dev       # http://localhost:3000

# 2. Client (new terminal)
cd ..
flutter pub get
dart run build_runner build
flutter run -d chrome    # or macos, iOS, Android

# Demo credentials seeded by init-db
alice@flow.com / 123456
```

Production build with a custom API endpoint:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-api.com
```

## Architecture overview

```
flow/
├── lib/                         # Flutter client (Dart 3.13)
│   ├── main.dart                # EasyLocalization → ProviderScope → FlowApp
│   ├── core/                    # ⚠️ must NOT import features/
│   │   ├── errors/app_exception.dart
│   │   ├── network/             # dioProvider + auth + error interceptors
│   │   ├── storage/app_storage.dart
│   │   ├── router/app_router.dart
│   │   ├── theme/app_theme.dart
│   │   ├── i18n/app_localization.dart
│   │   ├── widgets/
│   │   └── utils/constants.dart
│   └── features/                # ⚠️ features must NOT import each other
│       ├── auth/   (domain / data / providers / presentation)
│       ├── feed/   (domain: Post, Comment / data / providers / presentation)
│       └── profile/(presentation + widgets)
├── server/                      # Node backend (Express 5 + TypeScript + SQLite)
│   ├── src/
│   │   ├── index.ts             # Express entry
│   │   ├── auth.ts              # JWT middleware
│   │   ├── db.ts                # SQLite connection + schema
│   │   ├── seed.ts              # demo data
│   │   └── routes/(auth.ts, feed.ts)
│   └── package.json
├── assets/translations/
└── .github/workflows/ci.yml
```

### Client stack

| Layer | Package | Version | Notes |
|---|---|---|---|
| State management | `flutter_riverpod` | 3.x | **Explicit providers** only — no `@riverpod` generation — so intent is visible |
| Routing | `go_router` | 18.x | `StatefulShellRoute` + redirect guard based on `authProvider` |
| Networking | `dio` | 5.x | Interceptor chain · `ApiConfig.baseUrl` is the single environment switch |
| Models | `freezed` + `json_serializable` | 4.x | Use `abstract class Foo with _$Foo` (freezed 4 requirement) |
| Theme | `flex_color_scheme` | 8.x | Material 3 · 9.x has breaking changes so we pin 8 |
| Storage | `shared_preferences` | 2.x | Token + theme mode |
| Logging | `logger` | 2.x | PrettyPrinter |
| i18n | `easy_localization` | 3.x | **Must wrap `ProviderScope` from the outermost layer** |

### Server API surface

All responses are JSON. Errors return `{ "error": "message" }`.

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/api/auth/register` | — | `{ username, email, password }` |
| POST | `/api/auth/login`    | — | → `{ token, user }` |
| GET  | `/api/auth/me`       | ✅ | Current user from JWT |
| GET  | `/api/feed`          | optional | Query: `?page=&size=` |
| POST | `/api/feed/posts`    | ✅ | `{ content, imageUrl? }` → 201 |
| POST | `/api/feed/posts/:id/like` | ✅ | Toggle, returns updated post |
| GET  | `/api/feed/posts/:id/comments` | — | |
| POST | `/api/feed/posts/:id/comments` | ✅ | `{ content }` → 201 |

## Build status

| Platform | Build | Run | Notes |
|---|---|---|---|
| iOS 27.1 Simulator | ✅ 22.7s | ✅ Boot, route guard works | Xcode 27, Impeller/Metal |
| macOS arm64 | ✅ 46.5 MB | ✅ Feed + FAB + nav | Release |
| Chrome Web | ✅ 28.9s | ✅ Full redirect chain | Release, 99% icon tree-shake |
| Android | build chain ready | ⏳ waiting for physical device | |

## Switching the backend

`Repository` method signatures are frozen. Swap the internal implementation for **any** backend (NestJS / Go / Deno / Flask) as long as it returns the same JSON shape — **the client changes zero files**.

```dart
// lib/features/auth/data/auth_repository.dart
Future<User> login({required String email, required String password}) async {
  final response = await _dio.post('/api/auth/login', data: {...});
  // ...
}
```

Then point `ApiConfig.baseUrl` to your backend via `--dart-define` or by editing the default.

## Development constraints

1. `core/` must **never** import `features/`
2. `features/` modules must **never** import each other — cross-module talk goes through providers in `core/`
3. Repository methods return `Future` only — state transitions belong in providers
4. All data models use `@freezed` + `abstract class` (freezed 4)
5. `AsyncValue` loading/data/error tri-state goes through `AsyncValueBuilder`, not ad-hoc `isLoading` checks

## Tests

```bash
flutter test                    # smoke test + skipped integration tests
# or with backend running:
cd server && npm run dev
flutter test --plain-name "集成"  # integration tests require the server
```

## Roadmap

- [x] Working client + real Node backend · Apr 2025
- [ ] Search (users / posts / topics)
- [ ] Multi-account switching
- [ ] Notifications (replies / @ / likes)
- [ ] FCM / APNs push
- [ ] Docker Compose `up` for the full stack
- [ ] ActivityPub interoperability (Lemmy / Mastodon) — long-term

## License

MIT
