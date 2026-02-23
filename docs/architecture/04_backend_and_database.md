# 04 Backend, Database & Realtime Architecture

## Section 10 — Backend Database Schema (Supabase PostgreSQL)

Applying Row-Level Security (RLS) is paramount so the client only queries data it explicitly owns or is permitted to see.

### Core Tables
*   `users`: ID (UUID, PK), email (UK), phone, created_at, status (Active, Banned), university_domain.
*   `profiles`: user_id (FK), name, dob, bio, gender, preference, is_verified, avatar_url.
*   `trust_scores`: user_id (FK), community_vouch_count, id_verified_boolean, report_count.
*   `reliability_scores`: user_id (FK), response_rate_pct, avg_response_time_ms, ghosting_incidents, current_tier (Enum).
*   `intent_state`: user_id (FK), primary_intent (Romance/Friend/Collab), current_mood, updated_at.

### Discovery & Interaction
*   `swipe_actions`: actor_id (FK), target_id (FK), action (Like, Pass, Undo, Super), intent_context, created_at. (PK is composite: actor_id, target_id)
*   `matches`: id (PK), user_a (FK), user_b (FK), matched_intent, created_at, expires_at, status (Active, Closed).
*   `match_insights`: match_id (FK), generated_reason (Text: "Both like jazz and are highly responsive").

### Media & Details
*   `photos`: id (PK), user_id (FK), bucket_path, sort_order, is_sfw.
*   `profile_prompts`: id (PK), user_id (FK), prompt_id, answer_text.
*   `interests`: id (PK), display_name, category.
*   `user_interests`: user_id (FK), interest_id (FK).

### Chat & Activities
*   `chat_threads`: id (PK), match_id (FK), last_message_at, message_count (for reveal progression), is_active.
*   `messages`: id (PK), thread_id (FK), sender_id (FK), content, type (Text, Action, Photo), is_read, created_at.
*   `activities`: id (PK), type (Quiz, Icebreaker), config (JSON).
*   `activity_participation`: id (PK), thread_id (FK), user_id (FK), state (JSON).

### Safety & Moderation
*   `reports`: id (PK), reporter_id (FK), reported_id (FK), reason, context, status, created_at.
*   `verification_records`: id (PK), user_id (FK), type (Edu, GovtID), status, verified_at.

---

## Section 7 — Realtime Chat Architecture

### Infrastructure (Supabase Realtime)
*   **WebSockets**: Utilizes PostgreSQL logical replication.
*   **Message Streaming**: UI listens to `INSERT` on `messages` table where `thread_id` matches the active view.
*   **Typing Indicators**: Managed via Supabase Presence (ephemeral state not written to DB).
*   **Read Receipts**: Client updates `is_read` to TRUE. UI listens to `UPDATE` events on the `messages` table.

### Resiliency & Optimistic UI
1.  User taps "Send".
2.  Message is immediately rendered in UI (status: pending).
3.  Background API call inserts to Supabase.
4.  If success, status updates to sent.
5.  If fail (offline), message enters an Isar offline queue. A background isolate retries on network recovery.

---

## Section 16 — Security & Privacy

### 1. Row Level Security (RLS)
Every table has strict policies.
*   *Example:* Profiles can only be read by active users. Users can only update their *own* profile. Chat messages can only be read by the two participants listed in `matches`.

### 2. Privacy Mode & Blur Mode Backend Flags
Stored in `profiles`. If `blur_mode_override = TRUE`, the frontend enforces a strict blur. If the frontend is compromised, the CDN serves heavily compressed/blurred images via Edge Functions rather than raw images.

### 3. Media Validation
All uploaded photos hit an Edge Function (e.g., using AWS Rekognition or similar) to verify SFW content *before* writing the final record to the `photos` table.

### 4. Encrypted Local Storage
Auth tokens (`flutter_secure_storage`) are hardware encrypted. The Isar database is initialized with an AES-256 encryption key to prevent scraping from unlocked devices.
