// Supabase project configuration.
//
// SECURITY NOTE:
// - SUPABASE_URL and SUPABASE_ANON_KEY are intentionally hardcoded here.
//   The anon key is a *publishable* key designed to be embedded in client apps.
//   Supabase Row Level Security (RLS) policies enforce all access control.
//
// - The Service Role (secret) key must NEVER appear in this file or anywhere
//   in the Flutter codebase. It belongs only in server-side Edge Functions,
//   accessed via Deno.env.get('SUPABASE_SERVICE_ROLE_KEY').
//
// If you rotate your keys, update only these two constants.
class SupabaseConfig {
  static const String url = 'https://lhrtltchvbshelpowpbz.supabase.co';

  // The anon key is safe to be public. It provides only the access that RLS allows.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxocnRsdGNodmJzaGVscG93cGJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2NzcwNzksImV4cCI6MjA4NzI1MzA3OX0.hmossBIL2xB7vqzrOVdxh2RcYdM_Dp9jDQyLw8S23m0';

  // ❌ No secret key here. Ever.
}
