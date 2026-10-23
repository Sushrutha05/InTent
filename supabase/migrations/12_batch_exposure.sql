-- Batch increment exposure count for multiple profiles in a single query
CREATE OR REPLACE FUNCTION batch_increment_exposure(profile_ids UUID[])
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.profiles
    SET exposure_count = COALESCE(exposure_count, 0) + 1
    WHERE id = ANY(profile_ids);
END;
$$;

REVOKE ALL ON FUNCTION batch_increment_exposure(UUID[]) FROM public;
GRANT EXECUTE ON FUNCTION batch_increment_exposure(UUID[]) TO authenticated;
