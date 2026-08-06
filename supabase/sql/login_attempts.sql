-- Per-account (by email) sign-in lockout, independent of Supabase's own
-- IP-based rate limits (Authentication > Rate Limits) — that one protects
-- the project from abuse; this one protects one specific account from
-- being brute-forced from many different IPs, and lets the app show a
-- friendly "N attempts left" message instead of a raw 429.
--
-- Caveat worth knowing: since check_login_attempt/record_failed_login are
-- called with just an email (necessarily, since this runs before the user
-- is authenticated), anyone who knows a victim's email can call
-- record_failed_login directly and lock that account out without ever
-- knowing their password — a standard trade-off of email-keyed lockout
-- schemes. Supabase's own IP-based rate limit is the backstop against that
-- being done at scale. Run once in the Supabase SQL Editor.

create table if not exists public.login_attempts (
  email text primary key,
  failed_count integer not null default 0,
  locked_until timestamptz,
  updated_at timestamptz not null default now()
);

alter table public.login_attempts enable row level security;
-- Deliberately no policies — this table is only ever touched through the
-- SECURITY DEFINER functions below, never read/written directly by clients.

create or replace function public.check_login_attempt(p_email text)
returns table (allowed boolean, remaining_attempts integer, locked_until timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_max_attempts constant integer := 5;
  v_row record;
begin
  select * into v_row from login_attempts where email = lower(p_email);

  if v_row is null or v_row.locked_until is null or v_row.locked_until <= now() then
    return query select true, v_max_attempts - coalesce(v_row.failed_count, 0), null::timestamptz;
    return;
  end if;

  return query select false, 0, v_row.locked_until;
end;
$$;

create or replace function public.record_failed_login(p_email text)
returns table (remaining_attempts integer, locked_until timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_max_attempts constant integer := 5;
  v_lockout_minutes constant integer := 15;
  v_email text := lower(p_email);
  v_new_count integer;
  v_locked_until timestamptz;
begin
  insert into login_attempts (email, failed_count, updated_at)
  values (v_email, 1, now())
  on conflict (email) do update
    set failed_count = login_attempts.failed_count + 1,
        updated_at = now()
  returning failed_count into v_new_count;

  if v_new_count >= v_max_attempts then
    v_locked_until := now() + (v_lockout_minutes || ' minutes')::interval;
    update login_attempts
      set locked_until = v_locked_until, failed_count = 0
      where email = v_email;
    return query select 0, v_locked_until;
  else
    return query select (v_max_attempts - v_new_count), null::timestamptz;
  end if;
end;
$$;

create or replace function public.clear_login_attempts(p_email text)
returns void
language sql
security definer
set search_path = public
as $$
  delete from login_attempts where email = lower(p_email);
$$;
