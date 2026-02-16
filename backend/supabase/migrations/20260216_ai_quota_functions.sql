create or replace function public.reserve_ai_quota(
  p_user_id uuid,
  p_period_type text,
  p_period_key text,
  p_cap int
)
returns table(allowed boolean, current_count int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  if p_cap <= 0 then
    return query select false, 0;
    return;
  end if;

  insert into public.ai_usage_counters (
    user_id,
    period_type,
    period_key,
    prompt_count,
    token_input,
    token_output,
    updated_at
  )
  values (p_user_id, p_period_type, p_period_key, 1, 0, 0, now())
  on conflict (user_id, period_type, period_key)
  do update
    set prompt_count = public.ai_usage_counters.prompt_count + 1,
        updated_at = now()
    where public.ai_usage_counters.prompt_count < p_cap
  returning prompt_count into v_count;

  if v_count is null then
    select coalesce(prompt_count, 0)
      into v_count
      from public.ai_usage_counters
     where user_id = p_user_id
       and period_type = p_period_type
       and period_key = p_period_key;

    return query select false, v_count;
    return;
  end if;

  return query select true, v_count;
end;
$$;

create or replace function public.add_ai_token_usage(
  p_user_id uuid,
  p_period_type text,
  p_period_key text,
  p_token_input int,
  p_token_output int
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.ai_usage_counters (
    user_id,
    period_type,
    period_key,
    prompt_count,
    token_input,
    token_output,
    updated_at
  )
  values (
    p_user_id,
    p_period_type,
    p_period_key,
    0,
    greatest(coalesce(p_token_input, 0), 0),
    greatest(coalesce(p_token_output, 0), 0),
    now()
  )
  on conflict (user_id, period_type, period_key)
  do update
    set token_input = public.ai_usage_counters.token_input + greatest(coalesce(p_token_input, 0), 0),
        token_output = public.ai_usage_counters.token_output + greatest(coalesce(p_token_output, 0), 0),
        updated_at = now();
end;
$$;
