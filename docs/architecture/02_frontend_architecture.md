# 02 Frontend Architecture

## Section 2 — Frontend Architecture

### Core Tech Stack
*   **Framework**: Flutter (production-ready, strongly typed, 120fps capability).
*   **State Management**: Riverpod (for scalable, testable, and robust provider state).
*   **Routing**: GoRouter (declarative routing, deep linking support out of the box).
*   **Networking**: Dio (advanced HTTP client) + Supabase Flutter SDK.
*   **Realtime**: Supabase Realtime (WebSockets).
*   **Local Caching**: Hive/Isar (NoSQL, extreme speed for offline support).
*   **Animations**: Rive (complex vectors) + Flutter built-in explicit/implicit animations + Custom Shaders.

### Architecture Pattern: Feature-First Clean Architecture
The frontend utilizes a feature-first approach, slicing the app by business domain rather than technical layer.

`lib/features/`
  `-> auth/`
  `-> discovery_feed/`
  `-> chat/`
  `-> profile/`
  `-> matching/`

Inside each feature:
*   `data/` (Repositories, DTOs, API providers, Caching)
*   `domain/` (Entities, Business Logic Models, Freezed classes)
*   `presentation/` (Widgets, Screens, Riverpod Controllers)

### API & Realtime Integration Layer
*   **REST/RPC**: For heavy reads/writes (user profiles, loading initial feed).
*   **WebSockets (Supabase Subscriptions)**: For chat, typing indicators, match notifications, and intent state modifications.
*   **Repository Pattern**: Abstracts APIs. Controllers interact only with Repositories.

### Optimistic UI & Caching
*   **Optimistic Swipes**: When a user swipes, state updates instantly in the UI. The API call happens in the background. If it fails, the UI rolls back with an error toast.
*   **Offline Mode**: Chat histories and cached discovery cards are saved in Isar. Users can view profiles offline; actions are queued and synced upon reconnection.

---

## Section 4 — Component System

Our UI is built on atomic design principles. All components live in `lib/core/components/` and are strictly themed via `ThemeData`.

### Atoms
*   **Intent Badges**: Small chips indicating {Romance, Friendship, Collab}.
*   **Mood Indicators**: Dynamic icons with glowing gradients based on mood state.
*   **Trust Badges**: Verified checkmarks with varying internal shapes based on verification depth.

### Molecules
*   **Prompt Chips**: Reusable bubble widgets displaying user answers to specific prompts.
*   **Chat Bubbles**: Support for text, images, and embedded activity widgets (e.g., "User unlocked a photo!").
*   **Typing Indicator**: Animated 3-dot bounce widget utilizing Riverpod state for presence.
*   **Skeleton Loaders**: Shimmering placeholders for pristine loading states.

### Organisms
*   **Swipe Cards**: The core interactive element. Handles internal gestures, pan physics, and layout of media + info.
*   **Blur Overlay Widget**: Wraps images in a custom `ImageFilter.blur()`. Controlled by an `AnimationController` linked to the chat depth tier.
*   **Match Explanation Widget**: A beautifully designed card appearing beneath a profile detailing "Why we matched you."
*   **Animated Reveal Overlays**: Full-screen or modal overlays that execute micro-interactions when a milestone is reached.

---

## Section 5 — State Management (Riverpod)

### Global State (`lib/core/providers/`)
*   `auth_provider`: Tracks user session, tokens, and initialization state.
*   `theme_provider`: Handles dark/light/system modes.
*   `network_provider`: Tracks connectivity state.

### Feature State (e.g., `lib/features/discovery/presentation/`)
*   `discovery_feed_controller`: Fetches and caches profiles. Handles swipe events (right/left/up/down) and passes them to the matching repository.
*   `swipe_state`: Manages the current physics/drag position of the top card.

### Chat State
*   `chat_list_controller`: Streams the user's active threads, updating unread counts in real-time.
*   `chat_conversation_controller(threadId)`: Streams a specific thread's messages. Handles sending, optimistic UI injection, and retry logic.

### User Metrics State
*   `reliability_score_provider`: Periodically fetches/syncs user's current reliability tier to adjust UI borders or grant perks.
*   `intent_mood_provider`: Tracks the current user's ephemeral toggles (e.g., switching from "Romance" to "Study Collab").

---

## Section 9 — Animation + Blur System

A premium feel demands 60-120fps micro-interactions.

### 1. Gaussian Blur Overlay Shader
Instead of standard Flutter blurs which can be heavy, we will use a custom **Fragment Shader** (via `flutter_shaders`) for performance on lower-end devices, allowing dynamic, animated blur radii.

### 2. Animated Blur Reduction (The Reveal)
When a message threshold is crossed:
*   Trigger a sequence using a mapped `AnimationController`.
*   The blur radius lerps from `CurrentTier (e.g., 20px)` to `NextTier (e.g., 5px)`.
*   Accompany with a subtle haptic feedback (`HapticFeedback.lightImpact()`).

### 3. Reveal Transitions & Match Animation
*   When a mutual match occurs, the screen pauses.
*   Hero animations transition the two avatars to the center.
*   A glowing, particle-based burst (using Rive) engulfs the screen.

### 4. Trust Badge Glow
Trust badges pulse softly (Opacity 0.8 -> 1.0 continuously over 3 seconds) drawing subtle attention to verified safety.

---

## Section 15 — Performance Optimization

*   **Lazy Loading & Virtualization**: The Discovery feed only holds ~5-10 cards in memory at any time. As a card is swiped, a new one is pre-loaded invisibly in the stack. Lists use `ListView.builder`.
*   **Image Caching**: utilizing `cached_network_image`. Images are prefetched and resized at the CDN level via Supabase Storage transformations to prevent high RAM usage.
*   **Batching**: Analytics events and offline swipe queues are accumulated and sent in batches (e.g., every 5 seconds or 10 events) to reduce network calls.
*   **Memoization & Repaints**: Strict use of `const` constructors. `ConsumerWidget` and `Consumer` are used at the lowest possible leaf nodes to prevent entire screen rebuilds when a localized state (like a typing indicator) changes.
*   **Isolate Processing**: Heavy JSON parsing from API responses or background blur calculations are spawned in separate Dart Isolates via `compute()`.
