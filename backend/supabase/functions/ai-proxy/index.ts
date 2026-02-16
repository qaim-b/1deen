import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const FREE_DAILY_CAP = 3;
const PREMIUM_MONTHLY_CAP = 150;
const MAX_PROMPT_LENGTH = 700;
const MAX_OUTPUT_TOKENS = 500;

const PERIOD_DAILY = "daily";
const PERIOD_MONTHLY = "monthly";

type SubscriptionRow = {
  is_premium: boolean;
};

type QuotaReservation = {
  allowed: boolean;
  current_count: number;
};

type UsageStats = {
  input_tokens: number;
  output_tokens: number;
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  if (!OPENAI_API_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return json({ error: "server_not_configured" }, 500);
  }

  const token = auth.replace("Bearer ", "").trim();
  const user = await resolveUser(token);
  if (!user) {
    return json({ error: "invalid_token" }, 401);
  }

  const body = await req.json().catch(() => ({}));
  const prompt = String(body.prompt ?? "").trim();
  if (!prompt) {
    return json({ error: "prompt_required" }, 400);
  }
  if (prompt.length > MAX_PROMPT_LENGTH) {
    return json({ error: "prompt_too_long" }, 400);
  }

  const isPremium = await resolvePremiumStatus(user.id);
  const now = new Date();
  const dailyKey = now.toISOString().slice(0, 10);
  const monthlyKey = now.toISOString().slice(0, 7);

  const periodType = isPremium ? PERIOD_MONTHLY : PERIOD_DAILY;
  const periodKey = isPremium ? monthlyKey : dailyKey;
  const cap = isPremium ? PREMIUM_MONTHLY_CAP : FREE_DAILY_CAP;

  const reservation = await reserveQuota(user.id, periodType, periodKey, cap);
  if (!reservation.allowed) {
    return json(
      {
        error: isPremium ? "premium_cap_reached" : "free_cap_reached",
        cap,
        used: reservation.current_count,
      },
      429,
    );
  }

  const modelResponse = await queryOpenAI(prompt);

  await addTokenUsage(
    user.id,
    periodType,
    periodKey,
    modelResponse.usage.input_tokens,
    modelResponse.usage.output_tokens,
  );

  return json({
    answer: modelResponse.answer,
    usage: {
      input_tokens: modelResponse.usage.input_tokens,
      output_tokens: modelResponse.usage.output_tokens,
    },
  });
});

async function resolveUser(accessToken: string): Promise<{ id: string } | null> {
  const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!res.ok) {
    return null;
  }

  const payload = await res.json();
  return payload?.id ? { id: payload.id as string } : null;
}

async function resolvePremiumStatus(userId: string): Promise<boolean> {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/subscriptions?user_id=eq.${userId}&select=is_premium&limit=1`,
    {
      headers: serviceHeaders(),
    },
  );

  if (!res.ok) {
    return false;
  }

  const rows = (await res.json()) as SubscriptionRow[];
  return rows[0]?.is_premium ?? false;
}

async function reserveQuota(
  userId: string,
  periodType: string,
  periodKey: string,
  cap: number,
): Promise<QuotaReservation> {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/reserve_ai_quota`, {
    method: "POST",
    headers: {
      ...serviceHeaders(),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      p_user_id: userId,
      p_period_type: periodType,
      p_period_key: periodKey,
      p_cap: cap,
    }),
  });

  if (!res.ok) {
    return { allowed: false, current_count: cap };
  }

  const payload = await res.json();
  if (Array.isArray(payload) && payload.length > 0) {
    return {
      allowed: Boolean(payload[0].allowed),
      current_count: Number(payload[0].current_count ?? 0),
    };
  }

  return {
    allowed: Boolean(payload?.allowed),
    current_count: Number(payload?.current_count ?? 0),
  };
}

async function addTokenUsage(
  userId: string,
  periodType: string,
  periodKey: string,
  tokenInput: number,
  tokenOutput: number,
): Promise<void> {
  await fetch(`${SUPABASE_URL}/rest/v1/rpc/add_ai_token_usage`, {
    method: "POST",
    headers: {
      ...serviceHeaders(),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      p_user_id: userId,
      p_period_type: periodType,
      p_period_key: periodKey,
      p_token_input: tokenInput,
      p_token_output: tokenOutput,
    }),
  });
}

async function queryOpenAI(prompt: string): Promise<{ answer: string; usage: UsageStats }> {
  const res = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4.1-mini",
      max_output_tokens: MAX_OUTPUT_TOKENS,
      input: [
        {
          role: "system",
          content:
            "You are DeenLearner. Give concise practical guidance for salah discipline. No long essays. Keep under 400 words.",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
    }),
  });

  if (!res.ok) {
    throw new Error("openai_error");
  }

  const data = await res.json();
  return {
    answer: String(data?.output_text ?? "No answer returned."),
    usage: {
      input_tokens: Number(data?.usage?.input_tokens ?? 0),
      output_tokens: Number(data?.usage?.output_tokens ?? 0),
    },
  };
}

function serviceHeaders() {
  return {
    apikey: SUPABASE_SERVICE_ROLE_KEY,
    Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
  };
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
