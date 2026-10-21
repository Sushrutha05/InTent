-- ============================================================
-- Migration 09: Update get_recommendation_candidates for Same Domain
-- ============================================================
-- Modifies get_recommendation_candidates to filter by email domain
-- instead of college_id when p_same_college_only is true.
-- ============================================================

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
SET search_path = public, pg_temp
AS $$
DECLARE
    v_caller_domain TEXT;
BEGIN
    IF p_same_college_only THEN
        SELECT split_part(p.email, '@', 2) INTO v_caller_domain
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
        OR v_caller_domain IS NULL
        OR split_part(p.email, '@', 2) = v_caller_domain
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
