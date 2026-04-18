-- 1. Add indices for better join and filtering performance
CREATE INDEX IF NOT EXISTS idx_profiles_college_id ON public.profiles(college_id);
CREATE INDEX IF NOT EXISTS idx_profiles_is_onboarded ON public.profiles(is_onboarded);

-- 2. Update the recommendation candidates logic with smart same-college filtering
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
    -- If we need same college only, fetch the caller's college_id first
    IF p_same_college_only THEN
        SELECT college_id INTO v_caller_college_id FROM public.profiles WHERE id = p_user_id;
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
      -- Filter by same college if requested
      AND (NOT p_same_college_only OR p.college_id = v_caller_college_id)
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
