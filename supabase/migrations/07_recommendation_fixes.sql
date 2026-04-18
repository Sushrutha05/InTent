-- ============================================================
-- Migration 07: Recommendation System Bug Fixes
-- ============================================================

-- FIX 1: Add an index on last_active for faster ORDER BY on the RPC
CREATE INDEX IF NOT EXISTS idx_profiles_last_active ON public.profiles(last_active DESC NULLS LAST);

-- ============================================================
-- FIX 2: Re-create get_recommendation_candidates with NULL college guard
-- If the caller has no college_id (NULL), same_college_only will show all
-- users rather than incorrectly returning zero results (NULL = NULL is FALSE
-- in SQL, which would filter out every candidate).
-- ============================================================
DROP FUNCTION IF EXISTS get_recommendation_candidates(UUID, INT, BOOLEAN);

CREATE OR REPLACE FUNCTION get_recommendation_candidates(
    p_user_id UUID, 
    p_limit INT DEFAULT 100,
    p_same_college_only BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    id UUID,
    email TEXT,
    first_name TEXT,
    primary_intent TEXT,
    interests TEXT[],
    photo_urls TEXT[],
    bio TEXT,
    vibe_prompt TEXT,
    vibe_answer TEXT,
    college_id UUID,
    college_name TEXT,
    college_city TEXT,
    major TEXT,
    date_of_birth TIMESTAMP WITH TIME ZONE,
    last_active TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_college_id UUID;
BEGIN
    -- Only fetch caller's college_id when the filter is active
    IF p_same_college_only THEN
        SELECT p.college_id INTO v_caller_college_id
        FROM public.profiles p
        WHERE p.id = p_user_id;
    END IF;

    RETURN QUERY
    SELECT 
        p.id,
        p.email,
        p.first_name,
        p.primary_intent,
        p.interests,
        p.photo_urls,
        p.bio,
        p.vibe_prompt,
        p.vibe_answer,
        p.college_id,
        c.name AS college_name,
        c.city AS college_city,
        p.major,
        p.date_of_birth,
        p.last_active
    FROM public.profiles p
    LEFT JOIN public.colleges c ON p.college_id = c.id
    WHERE p.id != p_user_id
      AND p.is_onboarded = true
      -- FIX: Correct NULL college_id handling.
      -- If same_college_only is FALSE  → no college filter
      -- If same_college_only is TRUE and caller HAS a college → filter to same college
      -- If same_college_only is TRUE and caller has NO college → show all (graceful fallback)
      AND (
        NOT p_same_college_only
        OR v_caller_college_id IS NULL
        OR p.college_id = v_caller_college_id
      )
      -- Exclude users the current user has already acted upon
      AND NOT EXISTS (
          SELECT 1 
          FROM public.interactions i
          WHERE i.actor_id = p_user_id AND i.target_id = p.id
      )
      -- Exclude blocks in both directions
      AND NOT EXISTS (
          SELECT 1 
          FROM public.blocks b 
          WHERE (b.blocker_id = p_user_id AND b.blocked_id = p.id)
             OR (b.blocker_id = p.id AND b.blocked_id = p_user_id)
      )
    ORDER BY p.last_active DESC NULLS LAST
    LIMIT p_limit;
END;
$$;

-- ============================================================
-- FIX 3: Create the missing increment_exposure RPC
-- Called by ExposureBalancer in Flutter to track how many times
-- a profile has been shown in other users' feeds.
-- ============================================================
CREATE OR REPLACE FUNCTION increment_exposure(profile_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.profiles
    SET exposure_count = COALESCE(exposure_count, 0) + 1
    WHERE id = profile_id;
END;
$$;

-- Add exposure_count column to profiles if it doesn't exist yet
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS exposure_count INT DEFAULT 0;

-- Add index on exposure_count to speed up queries that order by it
CREATE INDEX IF NOT EXISTS idx_profiles_exposure_count ON public.profiles(exposure_count);

-- ============================================================
-- FIX 4: Create a lightweight update_last_active RPC
-- Called by the Flutter app on every discovery load so that
-- users who are actively browsing always have a fresh last_active
-- timestamp, making the recency score (+10) meaningful.
-- ============================================================
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.profiles
    SET last_active = NOW()
    WHERE id = auth.uid();
END;
$$;
