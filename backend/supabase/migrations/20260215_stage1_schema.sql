create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  theme_mode text not null default 'calm' check (theme_mode in ('calm', 'discipline')),
  prayer_method text not null default 'mwl',
  lock_before_minutes int not null default 15,
  lock_after_minutes int not null default 20,
  strictness_mode text not null default 'soft' check (strictness_mode in ('strict', 'soft', 'reminder')),
  early_supporter boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  provider text not null default 'unknown',
  status text not null default 'expired' check (status in ('active', 'grace', 'expired')),
  plan_code text not null default 'free',
  renewal_at timestamptz,
  is_premium boolean not null default false,
  raw jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_usage_counters (
  user_id uuid not null references auth.users(id) on delete cascade,
  period_type text not null check (period_type in ('daily', 'monthly')),
  period_key text not null,
  prompt_count int not null default 0,
  token_input int not null default 0,
  token_output int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, period_type, period_key)
);

create table if not exists public.habit_daily (
  user_id uuid not null references auth.users(id) on delete cascade,
  day date not null,
  prayed_on_time_count int not null default 0,
  lock_success_count int not null default 0,
  streak int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);z

create table if not exists public.blocked_apps (
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null check (platform in ('android', 'ios')),
  app_identifier text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, platform, app_identifier)
);

alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.ai_usage_counters enable row level security;
alter table public.habit_daily enable row level security;
alter table public.blocked_apps enable row level security;

create policy "profiles_own" on public.profiles
for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "subscriptions_own_read" on public.subscriptions
for select using (auth.uid() = user_id);

create policy "ai_usage_own" on public.ai_usage_counters
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "habit_own" on public.habit_daily
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "blocked_apps_own" on public.blocked_apps
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
