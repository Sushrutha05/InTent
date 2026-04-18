-- Drop existing function if it exists to allow updates
DROP FUNCTION IF EXISTS get_recommendation_candidates(UUID, INT);

-- RPC to fetch candidate users for recommendation
CREATE OR REPLACE FUNCTION get_recommendation_candidates(p_user_id UUID, p_limit INT DEFAULT 100)
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
BEGIN
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
    LIMIT p_limit;
END;
$$;
