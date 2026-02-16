# Salah Guard Stage 1 MVP Architecture

Date: 2026-02-15

## 1) Recommended Tech Stack

- Mobile: Flutter (Dart 3.x)
- Native Android layer: Kotlin (`AccessibilityService`, foreground app detection, overlay activity)
- Native iOS layer: Swift (`FamilyControls`, `DeviceActivity`, `ManagedSettings`, Shield extensions)
- Backend: Supabase (Postgres, Auth, Edge Functions)
- AI provider: OpenAI API via server-side Supabase Edge Function proxy
- Purchases: RevenueCat (maps App Store + Play Billing to a single entitlement)
- Notifications: Local only for Stage 1 (Flutter local notifications)

Why Flutter over React Native for Stage 1:
- Strong cross-platform UI velocity while keeping lock engines native.
- Clean platform channel boundary for sensitive lock controls.
- Lower integration surface than RN + multiple native bridges for this MVP scope.

## 2) Scope Lock (Stage 1)

Only these features are implemented:
- Prayer times (local calculation)
- Salah Guard app lock engine
- Prayer lock timing logic
- Local device calendar conflict prompt
- Habit tracker
- Lean Quran reader (text only)
- DeenLearner AI with strict caps
- Themes (Calm, Discipline)
- Annual subscription only (JPY 10,000)
- Settings + Coming Soon items

Explicitly excluded:
- Maps/masjid locator
- Halal scanner/barcode
- Real-time chat
- AI memory/history
- Large file storage
- Google Calendar cloud sync

## 3) High-Level Architecture

Clients:
- Flutter app (shared UI/business)
- Android native lock module
- iOS native lock module + Shield extension

Backend (Supabase):
- Auth (email/apple/google as needed)
- User profile + preferences
- Subscription status mirror
- AI usage counters (daily + monthly)
- Minimal habit sync + streak snapshots
- Edge Function: AI proxy + quota gate + response limiter

Design rule:
- Lock-time decisions run on device; backend is advisory and for sync/quotas.

## 4) Realistic Lock Architecture

### Android lock engine (real blocking path)

Components:
- `SalahAccessibilityService`: monitors active package and lock windows.
- `PrayerLockScheduler`: computes prayer windows from local prayer engine.
- `BlockedAppsStore`: selected apps + strictness mode.
- `LockOverlayActivity`: non-dismissible shield UI with verse/countdown.
- `EmergencyUnlockController`: 30-second temporary unlock token.

Flow:
1. Scheduler produces current lock window (`start = prayer - X`, `end = prayer + Y`).
2. Accessibility service detects current foreground package.
3. If package in blocked set and window active:
- `Strict`: immediate overlay, no bypass except emergency 30s.
- `Soft`: overlay with continue prompt and delay.
- `Reminder`: notification + optional overlay.
4. "I have prayed" updates local habit state and can relax current lock per configured policy.

Notes:
- Must handle OEM background restrictions (request battery optimization exclusion).
- Accessibility service can be killed; app should detect and guide re-enable.

### iOS lock engine (Apple-compliant path)

Components:
- `FamilyControls` authorization flow.
- App/category selection for restrictions.
- `DeviceActivity` schedules per prayer window.
- `ManagedSettingsStore` shield enforcement.
- Shield configuration extension (custom calm lock screen style).

Flow:
1. User grants Screen Time permissions.
2. App computes daily prayer windows and registers DeviceActivity schedule(s).
3. At interval start, ManagedSettings shields selected apps/categories.
4. At interval end, shields are removed.
5. Emergency unlock is limited by Apple APIs; fallback is temporary relax action where possible, else clear explanatory UI.

Hard limitation:
- iOS cannot replicate Android-style unrestricted foreground interception. Stage 1 must present this transparently in UX copy.

## 5) Prayer Time + Lock Window Logic

Prayer engine:
- Use local library (`adhan_dart` or equivalent) with configurable method.

Defaults:
- `lock_before_minutes = 15`
- `lock_after_minutes = 20` (configurable)

Conflict logic:
- Read local device calendar events (next 30 minutes).
- If event overlaps lock start window, show prompt:
- `Keep lock`
- `Delay lock once`
- `Skip this prayer window`

No cloud calendar sync in Stage 1.

## 6) Folder Structure

```text
salah_guard/
  app/
    lib/
      main.dart
      bootstrap/
      core/
        config/
        theme/
        utils/
        storage/
      features/
        auth/
        onboarding/
        prayer_times/
        salah_guard/
          domain/
          application/
          presentation/
          platform_bridge/
        calendar_conflicts/
        habits/
        quran/
        ai/
        subscription/
        settings/
      shared/
        widgets/
        models/
      services/
        supabase/
        revenuecat/
        notifications/
    android/
      app/src/main/kotlin/.../lock/
        SalahAccessibilityService.kt
        PrayerLockScheduler.kt
        LockOverlayActivity.kt
        EmergencyUnlockController.kt
    ios/
      Runner/
      LockEngine/
      ShieldConfigurationExtension/
      DeviceActivityExtension/
  backend/
    supabase/
      migrations/
      functions/
        ai-proxy/
        subscription-webhook/
  docs/
    stage1-architecture.md
```

## 7) Database Schema (Supabase/Postgres)

### `profiles`
- `id uuid pk` (auth user id)
- `display_name text`
- `theme_mode text check in ('calm','discipline')`
- `prayer_method text`
- `lock_before_minutes int default 15`
- `lock_after_minutes int default 20`
- `strictness_mode text check in ('strict','soft','reminder')`
- `early_supporter boolean default false`
- `created_at timestamptz`
- `updated_at timestamptz`

### `subscriptions`
- `user_id uuid pk`
- `provider text` (app_store/play_store)
- `status text` (active, grace, expired)
- `plan_code text` (`premium_annual_jpy_10000`)
- `renewal_at timestamptz`
- `is_premium boolean`
- `raw jsonb`
- `updated_at timestamptz`

### `ai_usage_counters`
- `user_id uuid`
- `period_type text` (`daily` or `monthly`)
- `period_key text` (e.g., `2026-02-15`, `2026-02`)
- `prompt_count int default 0`
- `token_input int default 0`
- `token_output int default 0`
- `updated_at timestamptz`
- PK: (`user_id`, `period_type`, `period_key`)

### `habit_daily`
- `user_id uuid`
- `day date`
- `prayed_on_time_count int default 0`
- `lock_success_count int default 0`
- `streak int default 0`
- `updated_at timestamptz`
- PK: (`user_id`, `day`)

### `blocked_apps`
- `user_id uuid`
- `platform text` (`android`, `ios`)
- `app_identifier text`
- `created_at timestamptz`
- PK: (`user_id`, `platform`, `app_identifier`)

RLS:
- User can read/write only own rows.
- Service-role only for webhook + AI proxy privileged writes.

## 8) Subscription Logic

Plan:
- One SKU only: `premium_annual_jpy_10000`

Entitlements:
- `free`
- `premium`

Feature gates:
- AI cap: free 3/day, premium 100-150/month (start at 120/month)
- Premium themes
- Early access flags

Store sync:
- RevenueCat webhook -> Supabase function `subscription-webhook` -> update `subscriptions`.
- Client caches entitlement for offline UX, server is source of truth for AI quota.

## 9) AI Proxy Structure (Cost-Safe)

Endpoint:
- `POST /functions/v1/ai-proxy`

Server responsibilities:
1. Authenticate user token.
2. Read entitlement + counters.
3. Enforce hard caps:
- Free: max 3 prompts/day
- Premium: max 120 prompts/month (configurable 100-150)
4. Enforce prompt length limit (e.g., 700 chars).
5. Inject concise system prompt for DeenLearner scope.
6. Use low-cost model tier; set strict `max_output_tokens`.
7. Return short answer (target <= 400 words free).
8. Atomically increment usage counters.

Cost controls:
- No streaming needed in Stage 1.
- No conversation history.
- Optional cached responses for near-duplicate prompts (hash by normalized prompt + locale).

## 10) Theme System

Modes:
- `calm`: light, soft neutrals
- `discipline`: AMOLED dark, high contrast

Persistence:
- Local: Flutter secure/local storage for instant boot restore.
- Remote: sync `profiles.theme_mode`.

Conflict resolution:
- Last-write-wins with `updated_at` timestamp.

## 11) 6-Week Build Roadmap

Week 1:
- Flutter app scaffold + architecture layers
- Supabase project + auth + base schema migrations
- Prayer calculation module + settings for method

Week 2:
- Android lock engine MVP (accessibility + overlay)
- iOS Screen Time permission + base schedule wiring
- Basic settings UI for strictness and lock windows

Week 3:
- Calendar local integration + conflict prompt
- Habit tracker local store + daily streak logic
- Quran text reader MVP

Week 4:
- AI proxy + quota enforcement + usage UI meter
- Subscription wiring with RevenueCat sandbox
- Theme onboarding + settings switcher + backend sync

Week 5:
- Stabilization on real devices (OEM Android variants + iOS versions)
- Edge cases: DST/timezone changes, reboot recovery, permission loss
- Local notifications polish

Week 6:
- QA hardening + analytics events + store prep
- Final cost monitoring dashboard (AI token + DB writes)
- Soft launch to limited testers

## 12) Cost Plan (Under JPY 8,000/month)

Budget envelope:
- AI: <= JPY 4,000
- Backend: <= JPY 2,500
- Misc: <= JPY 1,000

Controls:
- Hard quota gate in AI proxy.
- Low write frequency (daily aggregates vs event spam).
- Mostly local compute for prayer/lock logic.
- Text-only Quran content.

## 13) Key Risks and Mitigations

1. Android OEM kills accessibility/background services.
- Mitigation: onboarding checks, persistent health monitor, OEM-specific guidance.

2. iOS blocking expectations mismatch.
- Mitigation: explicit UX copy on Apple limitations, reliable schedule updates, shield testing.

3. AI spend spikes from abuse.
- Mitigation: strict server caps, length limits, optional prompt dedupe cache.

4. Time-related bugs (DST/timezone/prayer method changes).
- Mitigation: recompute schedules at midnight, timezone change listener, robust test matrix.

5. Permission fatigue during onboarding.
- Mitigation: progressive permission requests with clear value explanation.

## 14) Stage 2 Scaling Path

After Stage 1 traction:
- Add optional push notifications infra for remote nudges.
- Add halal scanner and masjid map as separate feature modules.
- Add AI conversation history with strict retention controls.
- Add offline Quran audio using selective downloads + CDN.
- Move from daily aggregates to event pipeline only if growth requires it.

## 15) Immediate Module-by-Module Implementation Order

1. `prayer_times` + `settings` foundational models
2. `salah_guard` Android bridge + iOS bridge shell
3. `calendar_conflicts`
4. `habits`
5. `quran`
6. `ai` proxy + client
7. `subscription`
8. theme sync + polish + QA
