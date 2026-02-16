# 1Deen Engineering Handoff (v2)

Last updated: 2026-02-16

## Current Status

- Flutter app runs on Chrome.
- `flutter analyze` passes with 0 issues.
- Stage 1 backend schema migration exists and was applied:
  - `backend/supabase/migrations/20260215_stage1_schema.sql`
- Supabase functions exist:
  - `backend/supabase/functions/ai-proxy/index.ts`
  - `backend/supabase/functions/subscription-webhook/index.ts`

## What Is Implemented

### UI / UX

- Modular tab architecture and design system are in place.
- `app/lib/features/app_shell/presentation/app_shell.dart` is a coordinator, not a monolith.
- Tabs are split:
  - `Guard`, `Habits`, `Quran`, `AI`, `Settings`
- Shared widgets + theme tokens + animation helpers exist under:
  - `app/lib/shared/widgets/`
  - `app/lib/core/theme/`
  - `app/lib/core/animation/`

### App Features (Stage 1)

- Prayer times (local calculation + location)
- Prayer lock window logic (before/after prayer)
- Local calendar conflict checks
- Habit tracking with local persistence
- Lean Quran text reader
- AI tab with caps and proxy hook
- Settings (theme, strictness, prayer method, lock timing)
- Subscription gating model (free/premium + early supporter)

### Backend Assets

- Supabase tables + RLS policies for profiles, subscriptions, ai usage, habits, blocked apps
- AI proxy function with cap enforcement scaffolding
- Subscription webhook function scaffolding

## Native / Platform Reality

### Android

Native edits exist and are active.

- Method channel wiring:
  - `app/android/app/src/main/kotlin/com/example/app/LockEngineMethodChannel.kt`
- Accessibility service + lock overlay + unlock controller:
  - `SalahAccessibilityService.kt`
  - `LockOverlayActivity.kt`
  - `EmergencyUnlockController.kt`
  - `LockWindowStore.kt`
  - `BlockedAppsStore.kt`
- Manifest/service declarations exist.

### iOS

- Platform channel handlers/stubs exist in:
  - `app/ios/Runner/AppDelegate.swift`
- Full iOS Screen Time production path is NOT complete yet:
  - Missing full `FamilyControls + DeviceActivity + ManagedSettings` extension-target implementation and entitlement hardening.

### Platform Channel Usage

Yes, active usage exists via:
- `MethodChannel("salah_guard/lock_engine")`
- Flutter bridge methods include:
  - `syncConfiguration`
  - `syncLockWindows`
  - `syncBlockedApps`
  - `requestEmergencyUnlock`
  - `isEngineHealthy`

## Gaps to Production

1. Android device/OEM hardening and full real-device QA for lock reliability.
2. iOS production-grade lock stack completion (entitlements + extension targets + schedule/shield flow).
3. Billing production integration (RevenueCat/App Store/Play) and end-to-end entitlement sync.
4. Full backend deployment validation with real keys and auth/profile sync paths.

## Notes

- This codebase is NOT purely UI-layer.
- It includes UI + backend scaffolding + Android native/platform-channel integration.
