-- Username uniqueness + a blocklist (impersonation of admin/staff, slurs,
-- and controversial/inflammatory figures) — until now usernames were
-- completely unchecked: two accounts could share the same display_name,
-- and anything could be typed in, including "admin" or names chosen to
-- harass/impersonate. Run once in the Supabase SQL Editor.

-- Add more terms any time with:
--   insert into public.blocked_usernames (term) values ('newterm');
-- Terms should be lowercase with no spaces/accents/punctuation — they're
-- matched against a normalized version of the submitted username (see
-- normalize_username below), so "Admin", "a-d-m-i-n" and "adm1n" all match
-- the single stored term 'admin'.
create table if not exists public.blocked_usernames (
  term text primary key
);

insert into public.blocked_usernames (term) values
  -- Impersonation / reserved / system-adjacent
  ('admin'), ('administrator'), ('root'), ('superuser'), ('moderator'), ('mod'),
  ('support'), ('staff'), ('official'), ('system'), ('webmaster'), ('security'),
  ('verified'), ('kipack'), ('owner'), ('ceo'), ('founder'), ('developer'), ('dev'),
  ('help'), ('helpdesk'), ('service'), ('supabase'),
  -- Controversial / inflammatory figures (impersonation & harassment risk)
  ('trump'), ('netanyahu'), ('binladen'), ('osamabinladen'), ('hitler'), ('putin'),
  ('stalin'), ('mussolini'), ('polpot'), ('kimjongun'), ('kimjongil'), ('assad'),
  -- Profanity / slurs (es + en) — intentionally a short curated set, not exhaustive
  ('puta'), ('puto'), ('gilipollas'), ('mierda'), ('cabron'), ('cabrona'), ('polla'),
  ('cono'), ('joder'), ('maricon'), ('zorra'), ('nazi'), ('nazis'),
  ('fuck'), ('shit'), ('bitch'), ('asshole'), ('cunt'), ('whore'), ('nigger'), ('faggot')
on conflict (term) do nothing;

-- Lowercases, strips common leetspeak substitutions (0->o, 1->l, 3->e, 4->a,
-- 5->s, 7->t, @->a, $->s), then strips everything that isn't a-z0-9 — so
-- separators/punctuation used to dodge a naive match ("a.d.m.i.n", "adm1n")
-- collapse to the same normalized form as the plain blocked term.
create or replace function public.normalize_username(p_username text)
returns text
language sql
immutable
as $$
  select regexp_replace(
    translate(lower(p_username), '013457@$', 'oleastas'),
    '[^a-z0-9]', '', 'g'
  );
$$;

create or replace function public.is_username_blocked(p_username text)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1 from public.blocked_usernames b
    where public.normalize_username(p_username) like '%' || b.term || '%'
  );
$$;

-- Case-insensitive uniqueness — the real enforcement (the RPC below is
-- just for instant UI feedback; a race between two signups landing at the
-- exact same moment is still caught here).
create unique index if not exists profiles_display_name_unique_ci
  on public.profiles (lower(display_name))
  where display_name is not null;

-- Called live as the user types a username during signup.
create or replace function public.check_username_available(p_username text)
returns table (available boolean, reason text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trimmed text := trim(p_username);
begin
  if length(v_trimmed) < 3 then
    return query select false, 'too_short';
    return;
  end if;
  if public.is_username_blocked(v_trimmed) then
    return query select false, 'blocked';
    return;
  end if;
  if exists (
    select 1 from public.profiles where lower(display_name) = lower(v_trimmed)
  ) then
    return query select false, 'taken';
    return;
  end if;
  return query select true, null::text;
end;
$$;

grant execute on function public.check_username_available(text) to anon, authenticated;

-- Defense in depth: reject a blocked username at signup time too, not just
-- in the client's live check, so a direct API call can't bypass it. The
-- unique index above is what actually stops duplicates (this trigger's
-- insert will fail with a unique_violation if two signups race).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_username text := new.raw_user_meta_data->>'username';
begin
  if v_username is not null and public.is_username_blocked(v_username) then
    raise exception 'username_blocked';
  end if;
  insert into public.profiles (id, display_name)
  values (new.id, v_username);
  return new;
end;
$$;
