import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { JWT } from "https://esm.sh/google-auth-library@9.1.0"

serve(async (req) => {
  try {
    // FIX MED-1: Validate the webhook shared secret on every request.
    // Set WEBHOOK_SECRET as an environment variable in Supabase Dashboard →
    // Edge Functions → send-notification → Secrets.
    const webhookSecret = Deno.env.get('WEBHOOK_SECRET')
    const incomingSecret = req.headers.get('x-webhook-secret')
    if (!webhookSecret || incomingSecret !== webhookSecret) {
      console.error('Unauthorized webhook call — bad or missing x-webhook-secret')
      return new Response('Unauthorized', { status: 401 })
    }

    const payload = await req.json()
    const record = payload.record
    // Do NOT log message content in production — it may contain PII
    console.log('Incoming record match_id:', record?.match_id)

    if (!record || !record.match_id || !record.sender_id) {
      console.error('Missing required fields in record')
      return new Response('Missing required fields', { status: 400 })
    }

    // 1. Initialize Supabase Client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Identify recipient from match_id
    console.log('Fetching match details for:', record.match_id)
    const { data: match, error: matchError } = await supabase
      .from('matches')
      .select('user1_id, user2_id')
      .eq('id', record.match_id)
      .single()

    if (matchError || !match) {
      console.error('Error fetching match:', JSON.stringify(matchError))
      return new Response('Match not found', { status: 404 })
    }

    const recipient_id = match.user1_id === record.sender_id ? match.user2_id : match.user1_id

    // 3. Fetch recipient tokens
    const { data: tokens, error: tokenError } = await supabase
      .from('fcm_tokens')
      .select('token')
      .eq('user_id', recipient_id)

    if (tokenError || !tokens || tokens.length === 0) {
      console.log('No tokens found for recipient:', recipient_id)
      return new Response('No tokens found', { status: 200 })
    }

    // 4. Fetch sender name and profile photo
    const { data: sender, error: senderError } = await supabase
      .from('profiles')
      .select('first_name, photo_urls')
      .eq('id', record.sender_id)
      .single()

    const senderName = sender?.first_name ?? 'Someone'
    const senderPhoto = sender?.photo_urls?.[0] ?? ''

    // 5. Get access token from Google
    const serviceAccount = JSON.parse(Deno.env.get('FCM_SERVICE_ACCOUNT') ?? '{}')
    const jwt = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    })

    const { token: accessToken } = await jwt.getAccessToken()

    // 6. Send notification to each token
    const results = await Promise.all(tokens.map(async (t) => {
      const fcmResponse = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: t.token,
              data: {
                title: senderName,
                body: record.content,
                match_id: record.match_id,
                sender_id: record.sender_id,
                sender_name: senderName,
                sender_photo: senderPhoto,
                unblur_progress: match.unblur_progress?.toString() ?? '0',
              },
              android: {
                priority: 'high',
              },
              apns: {
                headers: {
                  'apns-priority': '10',
                },
              },
            },
          }),
        }
      )
      return fcmResponse.status
    }))

    console.log(`Notification results for ${recipient_id}:`, results)

    return new Response(JSON.stringify({
      success: true,
      recipient: recipient_id,
      sent: results.length
    }), {
      headers: { "Content-Type": "application/json" },
    })

  } catch (err) {
    // FIX MED-2: Never return raw error objects — they may contain stack traces,
    // internal file paths, or library versions that help attackers.
    console.error('Unexpected error in send-notification:', err)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
