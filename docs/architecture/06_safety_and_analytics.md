# 06 Safety, Moderation & Analytics

## Section 12 — Safety & Moderation Architecture

Emotional and physical safety are paramount, especially for collegiate demographics.

### 1. Moderation Hooks & Toxicity Detection
*   **Chat Content**: Messages containing flagged keywords trigger an async Edge Function (e.g., interfacing with Perspective API or OpenAI moderation endpoint).
*   **Intervention**: If toxicity > 0.8, the message is blurred for the recipient with a warning: "This message may contain offensive content." The sender's Trust Score is temporarily frozen.

### 2. Reporting Workflow
A seamless UI accessible from every profile and chat screen.
1.  **Block & Report**: Immediately severs the match (Soft deletes the `matches` row for the user's view, flags the admin dashboard).
2.  **Categorized Context**: "Spam", "Inappropriate Behavior", "Offline Safety Concern".
3.  **Screenshot Protection**: Screenshots of chat logs (detected via Flutter's `windowmanager` or similar native channel plugins) dynamically replace sensitive images with placeholders.

### 3. Graceful Exits & "Take a Break"
If a user is overwhelmed, they can trigger a "Cool Down" mode. The app automatically sends a polite, non-confrontational system message to active matches: "[User] is taking a screen-time break and will be back in a few days." This prevents the interaction from being logged as 'Ghosting'.

---

## Section 13 — Analytics & Behavioral Insights

### Event Taxonomy
Analytics are processed via PostHog or segment.com to understand feature usage and match success.

*   `swipe_action`: Properties: {target_intent, target_reliability_tier, swipe_direction}.
*   `conversation_depth_milestone`: Triggered at 5, 10, 50 messages. Essential for tuning the Progressive Reveal mechanic.
*   `intent_toggle`: When a user switches from Romance to Friendship. Maps how fluid campus relationships are.
*   `ghosting_incident_logged`: System event. Helps identify if UI changes increase/decrease ghosting rates.
*   `activity_completed`: E.g., {type: "icebreaker_quiz", match_id: "xyz"}. Identifies which minigames drive engagement.

### Behavioral Insights
We track the "Match to Meet" funnel:
1.  Total Swipes
2.  Mutual Matches
3.  Message Initiated (The hardest drop-off point)
4.  Photo Reveal Unlocked
5.  Contact Info Shared (Regex detection for phone numbers/snapchat handles in chat to estimate real-world transition).
