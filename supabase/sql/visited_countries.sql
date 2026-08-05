-- Cloud sync for manually-marked "visited" countries on the map (the ones
-- a user taps on the map screen for a country they've been to before this
-- app existed, independent of any trip). Until now these only lived in
-- SharedPreferences on-device, so they silently vanished on any other
-- device signed into the same account (e.g. tablet + phone). Run this once
-- in the Supabase SQL Editor (project xvbtracxtlwpideblnvm). Purely
-- additive: new table only, no existing table/column/policy touched.

create table if not exists public.manually_visited_countries (
  user_id uuid not null references auth.users(id) on delete cascade,
  country_code text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, country_code)
);

alter table public.manually_visited_countries enable row level security;

create policy "select own visited countries"
  on public.manually_visited_countries
  for select
  using (auth.uid() = user_id);

create policy "insert own visited countries"
  on public.manually_visited_countries
  for insert
  with check (auth.uid() = user_id);

create policy "delete own visited countries"
  on public.manually_visited_countries
  for delete
  using (auth.uid() = user_id);
