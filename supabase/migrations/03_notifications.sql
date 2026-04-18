-- 3. FCM Token Storage for Push Notifications
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    token TEXT PRIMARY KEY,
    device_type TEXT, -- 'android' or 'ios'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Row Level Security
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their own tokens
CREATE POLICY "Users can insert their own tokens"
  ON public.fcm_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tokens"
  ON public.fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tokens"
  ON public.fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Trigger to call Edge Function on new message
CREATE OR REPLACE FUNCTION public.notify_message_recipient()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- We assume you've set up a Webhook in the Supabase Dashboard
  -- or we use pg_net to call the function directly.
  -- For maximum compatibility, we recommend setting this up in the
  -- Supabase Dashboard -> Database -> Webhooks -> 'send-notification'.
  -- But if you have pg_net enabled, you can uncomment below:
  /*
  PERFORM
    net.http_post(
      url := 'https://[YOUR_PROJECT_REF].functions.supabase.co/send-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || 'YOUR_SERVICE_ROLE_KEY'
      ),
      body := jsonb_build_object('record', row_to_json(NEW))
    );
  */
  RETURN NEW;
END;
$$;

-- Attach trigger to messages table
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'messages') THEN
        DROP TRIGGER IF EXISTS on_message_inserted ON public.messages;
        CREATE TRIGGER on_message_inserted
          AFTER INSERT ON public.messages
          FOR EACH ROW
          EXECUTE FUNCTION public.notify_message_recipient();
    END IF;
END $$;
