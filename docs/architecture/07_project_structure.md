# 07 Project Structure & Quality

## Section 17 — Project Structure

We enforce a strict Domain-Driven, Feature-First structure.

```text
lib/
├── core/
│   ├── config/              # Dev/Prod environments
│   ├── theme/               # Colors, Typography, Component styles
│   ├── network/             # Dio client, interceptors
│   ├── errors/              # Failure classes, Exceptions
│   ├── utils/               # Helpers, formatters, validators
│   └── components/          # Global UI (Buttons, Cards, Loaders)
├── features/
│   ├── auth/                # Login, OTP, Session routing
│   ├── onboarding/          # Prompts, Photo upload, Intent setting
│   ├── discovery/           # Swipe feed, algorithmic sorting
│   ├── matches/             # Active match list, chat lists
│   ├── chat/                # Realtime messages, offline queue
│   └── profile/             # Settings, Trust Score dashboard
│       ├── data/            # Repos, Data Sources, DTOs
│       ├── domain/          # Entities, State Models (Freezed)
│       └── presentation/    # Riverpod Providers, Widgets
├── services/
│   ├── analytics_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
└── main.dart                # ProviderScope, App entry, Env init
```

---

## Section 18 — Refactoring & Code Quality

*   **Separation of Concerns**: UI widgets never call the network. They watch Riverpod providers. Providers talk to Repositories. Repositories handle Supabase/API logic.
*   **Immutability**: All states and data models use `freezed` and `equatable` to enforce value equality and prevent accidental state mutation.
*   **Lint Compliance**: Use highly strict `analysis_options.yaml` (e.g., `flutter_lints` + Very Good Analysis rules). Require `.user_return_types`, avoid `dynamic`.
*   **Dependency Injection**: Riverpod operates as an inherent DI framework, overriding provider behaviors in testing.

---

## Section 19 — Test Strategy

Achieving >80% coverage to ensure CI/CD reliability.

1.  **Unit Tests (`test/domain/`, `test/data/`)**:
    *   Test matching algorithm logic (e.g., verifying custom weighted scores).
    *   Test data mappings from Supabase JSON to Dart Entities (using Mocktail).
2.  **State Tests (Provider Tests)**:
    *   Verify Riverpod transition states (`AsyncLoading -> AsyncData -> AsyncError`).
3.  **Widget Tests (`test/presentation/`)**:
    *   Pump widgets in isolation to ensure `MatchExplanationWidget` renders Correctly based on different states.
    *   Use `golden_toolkit` for visual regression testing of complex elements like the `BlurOverlayWidget`.
4.  **Integration Tests (E2E)**:
    *   Run on Firebase Test Lab or local emulators.
    *   Scenario: App launch -> Auth via Email -> Swipe Right -> Open Match -> Send Message -> Verify message appears in list.

---

## Section 20 — Output Summary & Tradeoff Analysis

### Tradeoffs Made
1.  **Isar over SQLite**: Isar offers significantly faster synchronous reads for the swipe stack and offline chat, but has a slight learning curve compared to standard SQL.
2.  **Supabase over Firebase**: Supabase (PostgreSQL) provides true relational integrity and powerful Row Level Security (RLS) crucial for a complex matching app. Firebase's NoSQL becomes highly nested and expensive for complex graph relationships (User A passed on User B who likes User C).
3.  **Progressive Blur UI**: Heavily reliant on custom shaders. It may cause frame drops on extremely old Android devices (e.g., SDK < 26). Fallback implemented: a simple opacity overlay on low-end hardware rather than real-time Gaussian computation.
4.  **Riverpod vs. Bloc**: Riverpod severely reduces boilerplate and context-lookup errors compared to Bloc, enabling faster iteration for MVP phases while retaining enterprise testability.

### Conclusion
This architecture serves as an enterprise-grade blueprint capable of scaling from an MVP to a massive high-DAU campus network. By centering the technical design around user psychology (trust, progressive reveal, safety), the codebase inherently supports the product's nuanced behavior.
