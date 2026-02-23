# 05 Matching Algorithm & Scoring Logic

## Section 6 — Swipe + Matching Algorithm

### Swipe Mechanics
*   **Directions**:
    *   Right = Romantic Interest
    *   Up = Collaboration (Study/Project)
    *   Down =Friendship / Platonic 
    *   Left = Pass / Not Interested
*   **Interactions**: Tapping edges cycles through photos/prompts.
*   **Daily Limits**: To combat infinite scrolling fatigue, users receive a finite "energy pool" replenished daily.

### Compatibility Model
Unlike superficial Elo ratings, compatibility ($$C_{final}$$) is a weighted vector calculation.

When User A sees User B, the backend calculates:

$$C_{final} = (w_1 \times I) + (w_2 \times R) + (w_3 \times M) + (w_4 \times A)$$

Where:
*   **I (Intent & Interest Overlap)**: Jaccard index of their `user_interests` and exact match on `primary_intent`.
*   **R (Reliability Weight)**: Closer `reliability_scores` boost compatibility. A Highly Reliable user is matched with other Highly Reliable users, ensuring good actors face good actors.
*   **M (Mood Alignment)**: Are both users looking for "deep chats" or "weekend plans"?
*   **A (Activity Alignment)**: Shared campus proximity or course overlapping.

### Explainable Matching
The output of $$C_{final}$$ drives the `match_insights` table. If the `I` variable is the highest contributor, the AI generates context: "You both have extreme overlap in Interests (Hiking, Coffee, Indie Music)."

---

## Section 11 — Trust & Reliability Scoring Backend Logic

### 1. Reliability Score
Calculated weekly via a cron job (Supabase pg_cron) based on 30-day trailing behavior.

*   **Positive Signals**:
    1.  Response Latency under 4 hours (+ points).
    2.  Conversation Continuity (messages > 20 in a thread) (+ points).
    3.  Completed Activities (played the icebreaker) (+ points).
*   **Negative Signals**:
    1.  Ghosting (Not replying to a mutual match after 48h) (- points).
    2.  Immediate Unmatching post-match without reason (- points).

*Output Tier*: {Unreliable, Standard, Engaging, Highly Responsive}.
Only "Engaging" and "Highly Responsive" statuses are shown on profiles as Badges, providing positive reinforcement without publicly shaming standard users.

### 2. Trust Score
Focuses on safety and authenticity.

*   **Verified .edu Email**: +50 points.
*   **Face Verification (Liveness check)**: +30 points.
*   **Profile Completeness** (Bio, 5 Prompts, 3 Photos): +20 points.
*   **Community Reports**: -100 points (Immediate manual review threshold).

Users exceeding 80 points get the primary "Verified Campus Trust" badge in the UI.
