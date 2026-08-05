-- Security fix: without this, the same Google Play purchaseToken can be
-- submitted to verify-play-purchase from ANY signed-in account and each
-- one independently passes Google's "is this subscription active" check —
-- there was nothing stopping one real purchase from being replayed to
-- grant Premium to unlimited accounts. This unique index makes a second
-- account claiming an already-claimed token fail at the database level
-- (race-safe, unlike an application-side "check then write"), and the
-- edge function is updated to turn that failure into a clean error
-- instead of a raw 500. Run once in the Supabase SQL Editor.

create unique index if not exists profiles_premium_purchase_token_unique
  on public.profiles (premium_purchase_token)
  where premium_purchase_token is not null;
