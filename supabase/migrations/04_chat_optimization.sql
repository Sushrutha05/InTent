-- 1. Add last_message_at to matches for optimized sorting and streaming
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 2. Populate last_message_at for existing records
UPDATE public.matches m
SET last_message_at = COALESCE(
  (SELECT created_at FROM public.messages WHERE match_id = m.id ORDER BY created_at DESC LIMIT 1),
  m.created_at
);

-- 3. Create a function to update last_message_at automatically
CREATE OR REPLACE FUNCTION public.update_match_last_message_at()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.matches
  SET last_message_at = NEW.created_at
  WHERE id = NEW.match_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Attach trigger to messages table
DROP TRIGGER IF EXISTS on_message_update_match ON public.messages;
CREATE TRIGGER on_message_update_match
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_match_last_message_at();
