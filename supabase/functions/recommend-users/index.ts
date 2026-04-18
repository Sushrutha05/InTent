import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface Candidate {
  id: string;
  email: string;
  first_name: string;
  primary_intent: string;
  interests: string[];
  photo_urls: string[];
  bio: string;
  vibe_prompt: string;
  vibe_answer: string;
  college_id: string;
  college_name: string;
  college_city: string;
  major: string;
  date_of_birth: string;
  last_active: string;
  score?: number;
}

// 1. Fetch Candidates (with optional same_college_only flag)
async function fetchCandidates(supabaseClient: any, userId: string, sameCollegeOnly: boolean = false): Promise<Candidate[]> {
  const { data, error } = await supabaseClient
    .rpc("get_recommendation_candidates", { 
      p_user_id: userId, 
      p_limit: 100,
      p_same_college_only: sameCollegeOnly
    });

  if (error) {
    throw new Error(`Error fetching candidates: ${error.message}`);
  }
  
  return data || [];
}

// 2. Scoring System
function calculateScore(candidate: Candidate, currentUser: any, currentUserCity: string | undefined): number {
  let score = 0;

  // Same intent -> +60
  if (candidate.primary_intent && currentUser.primary_intent && candidate.primary_intent === currentUser.primary_intent) {
    score += 60;
  }

  // Same college -> +40
  if (candidate.college_id && currentUser.college_id && candidate.college_id === currentUser.college_id) {
    score += 40;
  }

  // Same city -> +20
  if (candidate.college_city && currentUserCity && candidate.college_city === currentUserCity) {
    score += 20;
  }

  // Shared interests -> +10 per match (capped at +50 to prevent score runaway)
  // FIX: Guard against null interests on both sides before calling .filter()
  const candidateInterests = Array.isArray(candidate.interests) ? candidate.interests : [];
  const userInterests = Array.isArray(currentUser.interests) ? currentUser.interests : [];
  if (candidateInterests.length > 0 && userInterests.length > 0) {
    const sharedInterests = candidateInterests.filter(i => userInterests.includes(i));
    score += Math.min(sharedInterests.length * 10, 50); // Cap at +50
  }

  // Recently active (last 24h) -> +10
  if (candidate.last_active) {
    const lastActiveDate = new Date(candidate.last_active);
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    if (lastActiveDate >= twentyFourHoursAgo) {
      score += 10;
    }
  }

  return score;
}

// 3. Ranking
function rankCandidates(candidates: Candidate[]): Candidate[] {
  return candidates.sort((a, b) => (b.score || 0) - (a.score || 0));
}

// 4. Exploration Mix (90% ranked, 10% random for discovery)
function applyExplorationMix(rankedCandidates: Candidate[]): Candidate[] {
  const total = rankedCandidates.length;
  if (total === 0) return [];

  const top90Count = Math.floor(total * 0.90);
  const topRanked = rankedCandidates.slice(0, top90Count);
  
  const remainingPool = rankedCandidates.slice(top90Count);

  // Shuffle the remaining pool using Fisher-Yates
  for (let i = remainingPool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [remainingPool[i], remainingPool[j]] = [remainingPool[j], remainingPool[i]];
  }

  const randomCount = total - top90Count;
  const randomSelection = remainingPool.slice(0, randomCount);

  return [...topRanked, ...randomSelection];
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    let requestData = {} as any;
    if (req.method === "POST" || req.method === "PUT") {
      requestData = await req.json().catch(() => ({}));
    }
    
    const { user_id, same_college_only = false } = requestData;

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

    const supabaseClient = createClient(supabaseUrl, supabaseKey, {
      global: {
        headers: { Authorization: req.headers.get("Authorization")! },
      },
    });

    let targetUserId = user_id;
    if (!targetUserId) {
      const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
      if (authError || !user) {
        throw new Error("Unauthorized or missing user_id");
      }
      targetUserId = user.id;
    }

    // FIX: Update last_active for the requesting user (fire-and-forget — do not await).
    // This ensures the recency score (+10) and feed ordering are always accurate
    // for users who are actively browsing.
    supabaseClient
      .from("profiles")
      .update({ last_active: new Date().toISOString() })
      .eq("id", targetUserId)
      .then(() => {}) // intentionally fire-and-forget
      .catch(() => {}); // silently ignore errors so it never blocks the response

    // Parallelize current user profile fetch and candidates fetch
    const [profileResponse, candidates] = await Promise.all([
      supabaseClient
        .from("profiles")
        .select(`
          id, 
          primary_intent, 
          interests, 
          college_id,
          colleges ( city )
        `)
        .eq("id", targetUserId)
        .single(),
      fetchCandidates(supabaseClient, targetUserId, same_college_only)
    ]);

    const currentUser = profileResponse.data;
    const profileError = profileResponse.error;

    if (profileError || !currentUser) {
      throw new Error("Error fetching current user profile");
    }

    // FIX: Safely extract city regardless of whether Supabase returns the join
    // as an object or a single-element array (varies by client version).
    const currentUserCity = currentUser.colleges && !Array.isArray(currentUser.colleges) 
      ? (currentUser.colleges as any).city 
      : (Array.isArray(currentUser.colleges) && currentUser.colleges.length > 0 ? currentUser.colleges[0].city : undefined);

    if (candidates.length === 0) {
      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // Step C: Score every candidate
    const scoredCandidates = candidates.map(candidate => {
      const score = calculateScore(candidate, currentUser, currentUserCity);
      return { ...candidate, score };
    });

    // Step D: Rank by score (descending)
    const rankedCandidates = rankCandidates(scoredCandidates);

    // Step E: Apply 90/10 exploration mix
    const finalSelection = applyExplorationMix(rankedCandidates);

    return new Response(JSON.stringify(finalSelection), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
