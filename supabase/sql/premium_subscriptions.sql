-- Real Premium entitlement backing Google Play subscriptions. Run this once
-- in the Supabase SQL Editor (project xvbtracxtlwpideblnvm). Purely
-- additive: adds columns to the existing `profiles` table plus a trigger
-- that stops normal users from writing them directly. No existing table,
-- column, or RLS policy is removed or replaced.

alter table profiles add column if not exists premium_active boolean not null default false;
alter table profiles add column if not exists premium_expires_at timestamptz;
alter table profiles add column if not exists premium_product_id text;
alter table profiles add column if not exists premium_purchase_token text;

-- RLS is row-level, not column-level — without this trigger, a signed-in
-- user could `update profiles set premium_active = true` on their own row
-- directly, giving themselves free Premium. This resets those four columns
-- back to their previous values on any update that isn't coming from the
-- service-role key (which the `verify-play-purchase` edge function uses).
-- Existing "select own profile" / "update own profile" policies are left
-- untouched — this only clamps four specific columns, nothing else.
create or replace function public.protect_premium_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then
    new.premium_active := old.premium_active;
    new.premium_expires_at := old.premium_expires_at;
    new.premium_product_id := old.premium_product_id;
    new.premium_purchase_token := old.premium_purchase_token;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_premium_columns_trigger on profiles;
create trigger protect_premium_columns_trigger
  before update on profiles
  for each row
  execute function public.protect_premium_columns();
