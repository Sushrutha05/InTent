-- Add UPDATE policy for messages to allow marking as read
-- This allows a user to update any message in their match, 
-- but in practice the client only updates 'is_read'.
CREATE POLICY "Users can update messages in their matches (e.g., mark as read)"
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
