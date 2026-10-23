# Changelog

All notable changes to the **InTent (Student Dating App)** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-23

### 🚀 Highlights
- **Campus Explore & Live Spots**: Real-time campus hotspot check-ins with 2-hour TTL expiration, active study sessions, and privacy/ghost mode.
- **Interactive In-Chat Activities**: Embedded icebreaker mini-games (*Two Truths and a Lie*, *Would You Rather*, *Campus Q&A*) with live Supabase synchronization.
- **Blind Intent Matching**: Strict double-blind alignment protocol ensuring mutual intent matching across Dating, Study, Casual, and Projects.
- **Resilient Offline Swipe Queue**: Local interaction caching and batch processing with backend RPC synchronization.
- **Aesthetic Dark Mode & Discovery**: Fluid swipe physics, progressive blur protections, and shimmering skeleton loaders.

---

### ✨ Added
#### Campus Explore & Hangouts (`lib/features/explore/`)
- **Interactive Campus Spots**: Spot check-in and live visitor count tracker across campus locations (Library, Cafeteria, Student Lounge, Study Pods, Quad).
- **Time-To-Live Expiration**: Automatic 2-hour TTL expiration for check-in records to preserve student safety and live relevance.
- **Category & Intent Filtering**: Real-time filtering by category (Study, Chill, Social, Events) and instant intent matching at specific venues.
- **Campus Spot Domain & State Architecture**: Scalable provider (`campus_explore_provider.dart`), repository (`campus_explore_repository.dart`), and data models (`campus_spot_models.dart`).

#### In-Chat Mini-Games & Icebreakers (`lib/features/chat/`)
- **Chat Activity Protocol**: Interactive game models (`chat_activity_model.dart`) supporting *Two Truths and a Lie*, *Would You Rather*, and customizable questions.
- **Interactive Activity Sheet**: Bottom sheet modal (`chat_activities_sheet.dart`) enabling users to craft and launch icebreakers directly inside any chat thread.
- **Dynamic Activity Bubbles**: Dedicated rich chat bubbles (`chat_activity_bubble.dart`) rendering real-time option voting, live score reveal, and completed match states.

#### Blind Intent Matching (`lib/features/intents/`)
- **Incoming Signals Feed**: Real-time feed (`incoming_signal_model.dart`) allowing students to respond to incoming interest signals blindly.
- **Double-Blind Reciprocity**: Matches unlock strictly when both users independently select the matching intent type (e.g. Study Partner, Dating, Gym Buddy, Project Collaborator).
- **Intents Repository Expansion**: Enhanced `intents_repository.dart` and `my_intents_screen.dart` with mutual match detection and signal resolution.

#### Offline & High-Throughput Resilience (`lib/core/services/`)
- **`SwipeQueueService`**: Client-side resilient queue storing swipes locally in memory / persistent store during intermittent campus network drops.
- **Batch Exposure Logging**: Supabase database migration (`12_batch_exposure.sql`) with RPC function `batch_log_exposure` to optimize backend transactions.
- **FCM Token Security Policy**: Supabase migration (`11_fcm_tokens_policy.sql`) enforcing authenticated device push notification tokens.

#### Automated Testing Suite (`test/`)
- **`features_test.dart`**: End-to-end automated verification covering:
  - In-Chat Activities serialization and round-trip state updates.
  - Offline Swipe Queue batching and pending counter accuracy.
  - Campus Spot TTL calculation and expiration logic.
  - Blind Intent matching reciprocity invariants.
- **`widget_test.dart`**: App initialization, Supabase bootstrapping, and startup routing regression test.

---

### 🎨 Changed & Improved
- **Discovery Experience**:
  - Enhanced gesture responsiveness and drag velocity thresholds on `interactive_swipe_card.dart`.
  - Added empty deck fallback with auto-refresh mechanism.
  - Updated exposure balancer (`exposure_balancer.dart`) and romantic cap limiter (`romantic_cap_manager.dart`).
- **Media & Privacy**:
  - Upgraded `progressive_blur_image.dart` and `primary_photo_widget.dart` for improved render performance and placeholder loading states.
  - Refined shimmer loading skeletons (`shimmer_loading.dart`) across cards, feeds, and chat rooms.
- **Profile & Settings**:
  - Redesigned `edit_profile_screen.dart` and `settings_screen.dart` with theme controls, push notification toggles, and account management.
  - Updated `intent_selection_screen.dart` and `photo_upload_screen.dart` onboarding flows.
- **Android Platform & Build**:
  - Added Android Proguard optimizations (`android/app/proguard-rules.pro`).
  - Updated Gradle wrapper, Kotlin build scripts, and Android compile configurations.

---

### 🧹 Removed
- Removed deprecated legacy UI widgets (`lib/components/match_cards.dart`, `lib/components/my_textfield.dart`, `lib/components/square_tile.dart`).
- Purged unused legacy image assets (`flutter_01.png`, `lib/images/icons8-apple-38.png`, `lib/images/icons8-google-36.png`).

---

### 📌 Next Up (Friend Testing Feedback & Bug Fixes)
- Resolve edge-case interaction glitches and visual refinements identified during initial user testing.
- Optimize real-time chat socket reconnects on flaky mobile connections.
- Enhance profile photo cropping and compression before upload.
- Additional campus-specific event integrations and notifications tuning.
