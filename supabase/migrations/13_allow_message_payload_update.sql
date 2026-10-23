-- Migration 13: Allow participants in a match to update message content (activities & view-once snaps)
-- Drop restrictive message read-only policy
DROP POLICY IF EXISTS "Users can only mark received messages as read" ON public.messages;
DROP POLICY IF EXISTS "Users can update messages in their matches" ON public.messages;

CREATE POLICY "Users can update messages in their matches"
  ON public.messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.matches m
      WHERE m.id = messages.match_id
      AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.matches m
      WHERE m.id = messages.match_id
      AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
    )
  );
