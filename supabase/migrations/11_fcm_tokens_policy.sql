-- 11_fcm_tokens_policy.sql
-- Fix RLS policy for FCM push notification tokens

-- Drop old policies on fcm_tokens if any
DROP POLICY IF EXISTS "Users can view their own tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "Users can insert their own tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "Users can update their own tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "Users can delete their own tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "Users can manage their own tokens" ON public.fcm_tokens;

-- 1. SELECT: Users can only query their own tokens
CREATE POLICY "Users can view their own tokens"
  ON public.fcm_tokens FOR SELECT
  USING (auth.uid() = user_id);

-- 2. INSERT: Users can register their device token
CREATE POLICY "Users can insert their own tokens"
  ON public.fcm_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 3. UPDATE: Users can reassign an existing device token (e.g. across logins on the same device)
CREATE POLICY "Users can update their own tokens"
  ON public.fcm_tokens FOR UPDATE
  USING (true)
  WITH CHECK (auth.uid() = user_id);

-- 4. DELETE: Users can remove their tokens upon logout
CREATE POLICY "Users can delete their own tokens"
  ON public.fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);
