-- ============================================================
-- Migration 10: Fix Interactions RLS and Schema
-- ============================================================
-- Ensures interactions table allows inserts from authenticated users
-- ============================================================

-- Ensure the policy exists and allows users to insert their own interactions
DROP POLICY IF EXISTS "Users can insert their own interactions" ON public.interactions;
CREATE POLICY "Users can insert their own interactions" 
ON public.interactions FOR INSERT 
TO authenticated 
WITH CHECK (actor_id = auth.uid());

-- Ensure they can also select their own interactions (needed for the NOT EXISTS check in the RPC)
DROP POLICY IF EXISTS "Users can view their own interactions" ON public.interactions;
CREATE POLICY "Users can view their own interactions" 
ON public.interactions FOR SELECT 
TO authenticated 
USING (actor_id = auth.uid() OR target_id = auth.uid());
