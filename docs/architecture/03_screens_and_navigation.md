# 03 Screens & Navigation

## Section 3 — Application Screens

The application is structured into discrete screen flows, connected via GoRouter for Deep Linking and declarative URL-based navigation.

### 1. Onboarding & Auth Flow (`/auth`)
*   **Splash Screen**: Minimalist branded loading; checks for stored auth tokens and handles initial deep links.
*   **Phone/Email Auth**: Seamless login with OTP.
*   **Intent Selection**: The pivotal first question: "What are you looking for?" (Romance / Friendship / Quick Collab). Sets the initial algorithmic bias.

### 2. Profile Creation Flow (`/onboarding`)
*   **Basic Info**: Name, Gender, University (locked to `.edu` emails for trust), Graduation Year.
*   **Interests Discovery**: A visually rich grid of categorized tags (e.g., *Music*, *Late Night Study*, *Hiking*).
*   **Prompt Selection**: Users pick 3 out of 50 prompts (e.g., "The most controversial opinion I hold is...", "Let's debate...").
*   **Media Upload**: Uploading 3-6 photos. The UI explains the "Progressive Reveal" mechanic here.

### 3. Discovery Feed (`/feed`)
*   **Swipe Interface**: A full-screen, immersive card stack.
*   **Progressive Reveal UI**: The first photo is lightly blurred. The user sees prompt answers and shared interests clearly.
*   **Intent Badge View**: Clearly shows what the viewed user is looking for.
*   **Trust Badge View**: Displays university verification status and community reliability score (e.g., "Highly Responsive").

### 4. Matching & Chat (`/matches`, `/chat`)
*   **Match Confirmation**: An overlay screen: "You matched with Sarah! 🎯 Mutual Intent: Coffee & Chill."
*   **Chat List**: Displays all active threads. Unread messages are sorted to the top. Threads with low time remaining (Slow Dating rule) are highlighted in red.
*   **Chat Conversation**:
    *   Messaging UI with text and voice note capabilities.
    *   **Activity Suggestions**: A drawer to challenge the match to a micro-game or prompt (e.g., "Send an icebreaker").
    *   **Reveal Progress Indicator**: A persistent top-bar filling up as messages are exchanged, visually showing when the photo blur will fully drop.

### 5. Profile & Settings (`/profile`)
*   **Edit Profile**: Re-arrange photos, update prompts, change mood.
*   **Mood Update**: A daily status feature (e.g., "Looking for a study buddy today").
*   **Safety Settings**: Privacy toggles, full "Blur Mode" flag (user can opt to stay fully blurred indefinitely until *they* reveal).
*   **Reliability Score View**: A private dashboard showing the user their own score: "You respond to 80% of matches. Keep it up!"

### 6. Specialized Discovery (`/explore`)
*   **Campus Discovery**: A map/list view of users currently checked into specific campus locations (e.g., Main Library, Student Union) *only if* they opted in.
*   **Shared Activity Discovery**: Users looking to do something *right now* (e.g., "Anyone want to grab boba?").
