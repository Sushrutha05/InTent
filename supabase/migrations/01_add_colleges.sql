-- 1. Create the colleges table
CREATE TABLE IF NOT EXISTS public.colleges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for colleges
ALTER TABLE public.colleges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Colleges are viewable by everyone."
  ON public.colleges FOR SELECT
  USING ( true );

-- 2. Update the profiles table to link to colleges
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS college_id UUID REFERENCES public.colleges(id);

-- 3. Add last_active tracking to profiles to support the +10 recent activity score
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_active TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());
