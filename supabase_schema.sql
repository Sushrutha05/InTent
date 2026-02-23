-- RUN THIS ENTIRE FILE IN THE SUPABASE SQL EDITOR --

-- 1. Create the base profiles table (Expanded from Phase 4)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  university TEXT,
  major TEXT,
  date_of_birth TIMESTAMP WITH TIME ZONE,
  primary_intent TEXT,
  interests TEXT[],
  bio TEXT DEFAULT '',
  photo_urls TEXT[] DEFAULT '{}',
  is_onboarded BOOLEAN DEFAULT false,
  vibe_prompt TEXT DEFAULT '',
  vibe_answer TEXT DEFAULT '',
  global_intent_preference TEXT DEFAULT 'friendship',
  exposure_count INTEGER DEFAULT 0,
  last_shown_timestamp TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING ( true );

CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK ( auth.uid() = id );

CREATE POLICY "Users can update own profile."
  ON public.profiles FOR UPDATE
  USING ( auth.uid() = id );


-- 2. Create the interactions table (Swiping)
CREATE TABLE IF NOT EXISTS public.interactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  actor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  target_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  action_type TEXT NOT NULL CHECK (action_type IN ('LIKE', 'PASS', 'SUPER_LIKE', 'ROMANTIC', 'FRIENDSHIP', 'COLLABORATE')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(actor_id, target_id) -- Prevent double swiping
);

ALTER TABLE public.interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view interactions where they are involved"
  ON public.interactions FOR SELECT
  USING ( auth.uid() = actor_id OR auth.uid() = target_id );

CREATE POLICY "Users can create their own interactions"
  ON public.interactions FOR INSERT
  WITH CHECK ( auth.uid() = actor_id );


-- 3. Create the matches table
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user1_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  user2_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  unblur_progress NUMERIC(3, 2) DEFAULT 0.00, -- From 0.00 to 1.00
  intent_type TEXT, -- 'ROMANTIC', 'FRIENDSHIP', 'COLLABORATE'
  UNIQUE(user1_id, user2_id)
);

ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own matches"
  ON public.matches FOR SELECT
  USING ( auth.uid() = user1_id OR auth.uid() = user2_id );

CREATE POLICY "System can insert matches"
  ON public.matches FOR INSERT
  WITH CHECK ( auth.uid() = user1_id OR auth.uid() = user2_id );

CREATE POLICY "System can update matches (unblur progress)"
  ON public.matches FOR UPDATE
  USING ( auth.uid() = user1_id OR auth.uid() = user2_id );


-- 4. Create the messages table
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages in their matches"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.matches m
      WHERE m.id = messages.match_id
      AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
    )
  );

CREATE POLICY "Users can insert messages into their matches"
  ON public.messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.matches m
      WHERE m.id = match_id
      AND (m.user1_id = auth.uid() OR m.user2_id = auth.uid())
    )
  );


-- 5. FUNCTION: Handle Mutual Like Trigger
-- Automatically creates a match when two users like each other with the SAME intent
CREATE OR REPLACE FUNCTION check_and_create_match()
RETURNS TRIGGER AS $$
BEGIN
  -- We only care about ROMANTIC, FRIENDSHIP, and COLLABORATE intents now
  IF NEW.action_type IN ('ROMANTIC', 'FRIENDSHIP', 'COLLABORATE') THEN
    IF EXISTS (
      SELECT 1 FROM public.interactions
      WHERE actor_id = NEW.target_id 
      AND target_id = NEW.actor_id 
      AND action_type = NEW.action_type -- MUST BE IDENTICAL INTENT
    ) THEN
      -- Create a match, ordering IDs to prevent duplicates (e.g., Match(A, B) vs Match(B, A))
      INSERT INTO public.matches (user1_id, user2_id, intent_type)
      VALUES (
        LEAST(NEW.actor_id, NEW.target_id),
        GREATEST(NEW.actor_id, NEW.target_id),
        NEW.action_type
      )
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_create_match
AFTER INSERT ON public.interactions
FOR EACH ROW
EXECUTE FUNCTION check_and_create_match();


-- 6. Storage Bucket for Photos (if not created in Phase 4)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile_photos', 'profile_photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies
CREATE POLICY "Public profile photos are viewable by everyone"
ON storage.objects FOR SELECT
USING ( bucket_id = 'profile_photos' );

CREATE POLICY "Users can upload their own photos"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'profile_photos' AND auth.uid()::text = (storage.foldername(name))[1] );

CREATE POLICY "Users can update their own photos"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'profile_photos' AND auth.uid()::text = (storage.foldername(name))[1] );

CREATE POLICY "Users can delete their own photos"
ON storage.objects FOR DELETE
USING ( bucket_id = 'profile_photos' AND auth.uid()::text = (storage.foldername(name))[1] );


-- 7. Enable Realtime for Chat (CRITICAL)
-- This allows the stream() methods in Flutter to receive live updates
begin;
  -- remove any existing publication if it exists
  drop publication if exists supabase_realtime;
  -- create a new publication
  create publication supabase_realtime;
commit;

-- add tables to the publication
alter publication supabase_realtime add table public.matches;
alter publication supabase_realtime add table public.messages;
