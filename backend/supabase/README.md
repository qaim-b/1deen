## This project is muslim super app for keeping our deeen. 

# Supabase Stage 1 Setup

## 1) Apply schema

Run migration in `migrations/20260215_stage1_schema.sql`.
Then apply `migrations/20260216_ai_quota_functions.sql`.

## 2) Deploy functions

- `functions/ai-proxy`
- `functions/subscription-webhook`

Set env vars:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_API_KEY` (ai-proxy only)
- `RECEIPT_VALIDATION_MODE` (`basic` or `strict`, subscription-webhook)

## 3) Cost controls

- Free AI: 3/day (server-enforced)
- Premium AI: 150/month (server-enforced)
- Prompt max length: 700
- Output token cap: 500
- Usage logging: `ai_usage_counters` (`prompt_count`, `token_input`, `token_output`)

## 4) Subscription validation

- Purchase flows are handled on-device by:
  - Android: Google Play Billing
  - iOS: StoreKit
- Backend receipt sync endpoint:
  - `functions/subscription-webhook`
- Validation mode:
  - `basic`: structural receipt validation + plan allow-list
  - `strict`: reserved for full provider-side verification integration
