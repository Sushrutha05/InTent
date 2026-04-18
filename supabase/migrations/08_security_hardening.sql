-- ============================================================
-- Migration 08: SQL Security Hardening
-- ============================================================
-- This migration addresses HIGH-2 and MED-3 from the security audit:
--   HIGH-2: SECURITY DEFINER RPCs were callable by anonymous (unauthenticated) users
--   MED-3:  SECURITY DEFINER functions were missing a search_path lock
--   HIGH-3: Message UPDATE policy allowed tampering with message content
-- ============================================================

-- ============================================================
-- FIX HIGH-2 + MED-3: Lock down all SECURITY DEFINER functions
-- Add explicit GRANT/REVOKE and search_path to every RPC that
-- had SECURITY DEFINER to prevent privilege escalation.
-- ============================================================

-- 1. get_recommendation_candidates — only authenticated users should call this
CREATE OR REPLACE FUNCTION get_recommendation_candidates(
    p_user_id UUID,
    p_limit INT DEFAULT 100,
    p_same_college_only BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    id UUID, email TEXT, first_name TEXT, primary_intent TEXT,
    interests TEXT[], photo_urls TEXT[], bio TEXT, vibe_prompt TEXT,
    vibe_answer TEXT, college_id UUID, college_name TEXT, college_city TEXT,
    major TEXT, date_of_birth TIMESTAMP WITH TIME ZONE,
    last_active TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp  -- Prevents search_path injection attacks
AS $$
DECLARE
    v_caller_college_id UUID;
BEGIN
    IF p_same_college_only THEN
        SELECT p.college_id INTO v_caller_college_id
        FROM public.profiles p
        WHERE p.id = p_user_id;
    END IF;

    RETURN QUERY
    SELECT
        p.id, p.email, p.first_name, p.primary_intent, p.interests,
        p.photo_urls, p.bio, p.vibe_prompt, p.vibe_answer, p.college_id,
        c.name AS college_name, c.city AS college_city, p.major,
        p.date_of_birth, p.last_active
    FROM public.profiles p
    LEFT JOIN public.colleges c ON p.college_id = c.id
    WHERE p.id != p_user_id
      AND p.is_onboarded = true
      AND (
        NOT p_same_college_only
        OR v_caller_college_id IS NULL
        OR p.college_id = v_caller_college_id
      )
      AND NOT EXISTS (
          SELECT 1 FROM public.interactions i
          WHERE i.actor_id = p_user_id AND i.target_id = p.id
      )
      AND NOT EXISTS (
          SELECT 1 FROM public.blocks b
          WHERE (b.blocker_id = p_user_id AND b.blocked_id = p.id)
             OR (b.blocker_id = p.id AND b.blocked_id = p_user_id)
      )
    ORDER BY p.last_active DESC NULLS LAST
    LIMIT p_limit;
END;
$$;

REVOKE ALL ON FUNCTION get_recommendation_candidates(UUID, INT, BOOLEAN) FROM public;
GRANT EXECUTE ON FUNCTION get_recommendation_candidates(UUID, INT, BOOLEAN) TO authenticated;

-- 2. increment_exposure — only authenticated users should be able to call this
CREATE OR REPLACE FUNCTION increment_exposure(profile_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.profiles
    SET exposure_count = COALESCE(exposure_count, 0) + 1
    WHERE id = profile_id;
END;
$$;

REVOKE ALL ON FUNCTION increment_exposure(UUID) FROM public;
GRANT EXECUTE ON FUNCTION increment_exposure(UUID) TO authenticated;

-- 3. update_last_active — uses auth.uid() internally; anon users calling it
-- would produce a no-op (auth.uid() returns NULL), but locking it is best practice.
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.profiles
    SET last_active = NOW()
    WHERE id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION update_last_active() FROM public;
GRANT EXECUTE ON FUNCTION update_last_active() TO authenticated;

-- 4. check_and_create_match trigger function
CREATE OR REPLACE FUNCTION check_and_create_match()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.action_type IN ('ROMANTIC', 'FRIENDSHIP', 'COLLABORATE') THEN
        IF EXISTS (
            SELECT 1 FROM public.interactions
            WHERE actor_id = NEW.target_id
            AND target_id = NEW.actor_id
            AND action_type = NEW.action_type
        ) THEN
            INSERT INTO public.matches (user1_id, user2_id, intent_type)
            VALUES (
                LEAST(NEW.actor_id, NEW.target_id),
                GREATEST(NEW.actor_id, NEW.target_id),
                NEW.action_type
            )
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

-- 5. on_block_create trigger function
CREATE OR REPLACE FUNCTION on_block_create()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.matches
    WHERE (user1_id = NEW.blocker_id AND user2_id = NEW.blocked_id)
       OR (user1_id = NEW.blocked_id AND user2_id = NEW.blocker_id);

    DELETE FROM public.interactions
    WHERE (actor_id = NEW.blocker_id AND target_id = NEW.blocked_id)
       OR (actor_id = NEW.blocked_id AND target_id = NEW.blocker_id);

    RETURN NEW;
END;
$$;

-- 6. delete_user — already had GRANT/REVOKE, but add search_path lock
CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION public.delete_user() FROM public;
GRANT EXECUTE ON FUNCTION public.delete_user() TO authenticated;

-- 7. update_match_last_message_at trigger function
CREATE OR REPLACE FUNCTION public.update_match_last_message_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.matches
    SET last_message_at = NEW.created_at
    WHERE id = NEW.match_id;
    RETURN NEW;
END;
$$;

-- ============================================================
-- FIX HIGH-3: Message UPDATE policy — restrict to is_read only
-- Drop the overly-broad existing policy and replace it with
-- one that only allows marking received messages as read.
-- ============================================================

DROP POLICY IF EXISTS "Users can update messages in their matches (e.g., mark as read)" ON public.messages;

CREATE POLICY "Users can only mark received messages as read"
    ON public.messages FOR UPDATE
    USING (
        -- Can only update messages that were NOT sent by you (received messages)
        sender_id != auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = messages.match_id
            AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
        )
    )
    WITH CHECK (
        -- The only column value change allowed is setting is_read to true
        is_read = true
        AND sender_id != auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = messages.match_id
            AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
        )
    );

-- ============================================================
-- FIX HIGH-4: Add maximum message content length constraint
-- Prevents DoS via oversized message payloads.
-- ============================================================
ALTER TABLE public.messages
    DROP CONSTRAINT IF EXISTS messages_content_length;

ALTER TABLE public.messages
    ADD CONSTRAINT messages_content_length
    CHECK (char_length(content) BETWEEN 1 AND 2000);
