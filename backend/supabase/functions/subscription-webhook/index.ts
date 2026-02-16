import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const RECEIPT_VALIDATION_MODE = Deno.env.get("RECEIPT_VALIDATION_MODE") ?? "basic";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return json({ error: "server_not_configured" }, 500);
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }
  const accessToken = auth.replace("Bearer ", "").trim();

  const body = await req.json().catch(() => ({}));

  const userId = String(body.user_id ?? "").trim();
  const provider = String(body.provider ?? "unknown").toLowerCase();
  const productId = String(body.product_id ?? "").trim();
  const receiptToken = String(body.receipt_token ?? "").trim();
  const orderId = body.order_id ? String(body.order_id) : null;

  if (!userId || !productId || !receiptToken) {
    return json({ error: "missing_required_fields" }, 400);
  }

  const tokenUser = await resolveUser(accessToken);
  if (!tokenUser || tokenUser.id !== userId) {
    return json({ error: "user_mismatch" }, 403);
  }

  if (!["android", "ios", "google_play", "play_store", "app_store"].includes(provider)) {
    return json({ error: "unsupported_provider" }, 400);
  }

  const normalizedProvider = normalizeProvider(provider);

  const validation = await validateReceipt({
    provider: normalizedProvider,
    productId,
    receiptToken,
  });

  if (!validation.valid) {
    return json({ error: "receipt_invalid", details: validation.reason }, 400);
  }

  const status = validation.isPremium ? "active" : "expired";

  await upsertSubscription({
    userId,
    provider: normalizedProvider,
    status,
    productId,
    isPremium: validation.isPremium,
    renewalAt: validation.renewalAt,
    rawPayload: {
      ...body,
      validation_mode: RECEIPT_VALIDATION_MODE,
      validation_reason: validation.reason,
    },
    orderId,
  });

  await syncProfilePremiumFlag(userId, validation.isPremium);

  return json({
    ok: true,
    is_premium: validation.isPremium,
    status,
    renewal_at: validation.renewalAt,
  });
});

type ReceiptValidationResult = {
  valid: boolean;
  isPremium: boolean;
  renewalAt: string | null;
  reason: string;
};

async function validateReceipt(params: {
  provider: "android" | "ios";
  productId: string;
  receiptToken: string;
}): Promise<ReceiptValidationResult> {
  if (RECEIPT_VALIDATION_MODE === "strict") {
    // Placeholder for strict provider-side verification integration.
    // In strict mode, reject until provider validators are configured.
    return {
      valid: false,
      isPremium: false,
      renewalAt: null,
      reason: "strict_validation_not_configured",
    };
  }

  // Basic mode: structural validation, product allow-list checks, and token sanity.
  const expectedProduct = "premium_annual_jpy_10000";
  if (params.productId !== expectedProduct) {
    return {
      valid: false,
      isPremium: false,
      renewalAt: null,
      reason: "unexpected_product_id",
    };
  }

  if (params.receiptToken.length < 12) {
    return {
      valid: false,
      isPremium: false,
      renewalAt: null,
      reason: "receipt_token_too_short",
    };
  }

  const renewal = new Date();
  renewal.setFullYear(renewal.getFullYear() + 1);

  return {
    valid: true,
    isPremium: true,
    renewalAt: renewal.toISOString(),
    reason: "basic_validation_passed",
  };
}

async function upsertSubscription(args: {
  userId: string;
  provider: string;
  status: string;
  productId: string;
  isPremium: boolean;
  renewalAt: string | null;
  rawPayload: Record<string, unknown>;
  orderId: string | null;
}) {
  await fetch(`${SUPABASE_URL}/rest/v1/subscriptions`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      Prefer: "resolution=merge-duplicates",
      "Content-Type": "application/json",
    },
    body: JSON.stringify([
      {
        user_id: args.userId,
        provider: args.provider,
        status: args.status,
        plan_code: args.isPremium ? "premium_annual_jpy_10000" : "free",
        renewal_at: args.renewalAt,
        is_premium: args.isPremium,
        raw: {
          ...args.rawPayload,
          order_id: args.orderId,
        },
        updated_at: new Date().toISOString(),
      },
    ]),
  });
}

async function syncProfilePremiumFlag(userId: string, isPremium: boolean) {
  await fetch(`${SUPABASE_URL}/rest/v1/profiles?id=eq.${userId}`, {
    method: "PATCH",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      early_supporter: isPremium,
      updated_at: new Date().toISOString(),
    }),
  });
}

function normalizeProvider(provider: string): "android" | "ios" {
  if (provider === "android" || provider === "google_play" || provider === "play_store") {
    return "android";
  }
  return "ios";
}

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

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
