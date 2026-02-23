# 01 Core Philosophy & Mechanics

## Section 1 — Core Product Philosophy
This application targets the 18–25 age group (students) and shifts the paradigm from superficial swiping to **personality-first discovery, slow dating, and progressive trust building**.

### Key Principles
*   **Personality-First Discovery**: Photos are progressively revealed or initially blurred to prioritize conversation and intent over immediate physical judgment.
*   **Progressive Trust Building**: Trust is earned through reliable behavior, measured verifications, and interaction depth.
*   **Slow Dating Mechanics**: Daily interaction limits, meaning quality over quantity. Artificial scarcity encourages users to invest time in matches.
*   **Accountability & Reliability Scoring**: A visible yet nuanced score indicating how consistently a user replies, shows up, or completes activities.
*   **Emotional Safety UX**: Clear boundaries, easy reporting mechanisms, non-toxic behavior prompts, and "cool down" periods to reduce fatigue.
*   **Multi-Intent Relationships**: Fluidly supporting romance, friendship (platonic), and collaboration (study buddies, project partners) in the same ecosystem.
*   **Mood-Based Discovery**: Aligning users based on current emotional availability or immediate goals (e.g., "Looking for a coffee chat", "Deep conversations").
*   **Explainable Matching**: Showing exactly *why* someone was recommended ("You both love obscure indie films and have high reliability scores").
*   **Campus/Student Discovery**: Hyper-local matching based on shared courses, university events, or library proximity.
*   **Activity-Based Interaction**: Moving beyond text chat to shared digital/physical activities (e.g., Icebreaker quizzes, "Study together" mode).
*   **Conversation-First Engagement**: Matching is just the start; the real reveal happens through engaging dialogue.
*   **Fairness and Transparency**: Algorithms prioritize mutual compatibility rather than just Elo-based attractiveness.

---

## Section 8 — Unique App Mechanics

### 1. Progressive Blur Reveal
Profiles start with a Gaussian blur on photos. As users exchange messages and reach conversation milestones (e.g., 5, 10, 20 messages), the blur gradually lifts. This anchors initial attraction in personality and shared interests.

### 2. Conversation-First Matching
Matches have a 48-hour expiration timer if no conversation is initiated. The "first move" can be a contextual reply to a prompt rather than a generic "Hey."

### 3. Reliability Score System
A backend-calculated score (hidden from raw view, but represented via trust badges or tier levels like "Highly Responsive") that rewards consistent behavior and discourages ghosting.

### 4. Slow Dating Mode
Limits free users to a finite number of active ongoing matches (e.g., max 5 active chats). You must gracefully close or unmatch inactive conversations to unlock new ones.

### 5. Explainable Matching
UI element reading: *"We think you'd vibe because you both spend weekends hiking and share a 'chill' mood today."*

### 6. Mood-Based Discovery
A dynamic 24-hour status system (e.g., "Brain-dead & need coffee", "Adventurous", "Looking to study"). Re-ranks the feed based on complimentary moods.

### 7. Multi-Intent Dynamic Switching
The UI allows users to toggle their feed between Date / BFF / Collab. The algorithm dynamically adjusts to show different profiles or different facets of the *same* profile based on the intent mode.

### 8. Trust Badges
Earned via university email verification, ID verification, and community vouching. Crucial for campus safety.

### 9. Emotional Safety UX
Features "Ghosting Grace Periods" (soft-closing chats with kind automated messages if someone gets busy), content warnings, and a "Take a Break" mode that pauses visibility without deleting the account.

### 10. Activity-Based Interaction
Mini-games embedded in chat (e.g., "Two Truths and a Lie", "Vibe Check Question") to break the ice and build the interaction metric needed for photograph reveals.

---

## Section 14 — Onboarding Psychology Design

The onboarding flow is designed to reduce churn, lower anxiety, and capture deep psychographic data without feeling like a chore.

### UX Flow & Psychology
1.  **The Hook (Intent Clarity)**: Ask "What kind of connection are you looking for right now?" first. Gives the user immediate control over their experience.
2.  **Basic Details (Low Friction)**: Name, Age, University Email. Keep it standard to build trust.
3.  **Vibe Check (Interest Discovery)**: Instead of long forms, use interactive, visually appealing card carousels to select interests, aesthetic preferences, and lifestyle habits.
4.  **The Canvas (Authentic Expression)**: Require 2-3 text prompts. Provide examples that encourage vulnerability and humor. *Micro-copy:* "Don't overthink it, just tell us something you could talk about for an hour."
5.  **Media Upload (Safety Awareness)**: When asking for photos, explain *how* they will be used (e.g., "Your photos will be gently blurred until you start a good conversation. Pick a photo where your personality shines!").
6.  **Trust & Safety Pledge**: A mandatory, but positively framed, agreement to community guidelines. Framing: "We're building a safe space. Promise to be kind, genuine, and respectful."
7.  **The Mood Capture**: Final step before entering the feed: "How are you feeling right now?" Sets the tone for immediate relevance.

### Progressive Disclosure
Do not ask for everything upfront. Advanced preferences (e.g., political views, specific dating dealbreakers) are prompted dynamically after the first 2 days of usage via in-app cards to spread out the cognitive load.
