-- Trip-collaborator invite accept/decline flow. Run this once in the
-- Supabase SQL Editor (project xvbtracxtlwpideblnvm). Purely additive: no
-- existing table, column, or RLS policy is touched or replaced — these are
-- three new SECURITY DEFINER functions that each check `auth.email()` /
-- `auth.uid()` internally, so they only ever act on invites addressed to
-- the calling user. `claim_trip_invites` (the old silent auto-join) is no
-- longer called from the app but is left in place, unused.

-- Pending invites addressed to the signed-in user's email, joined with the
-- trip's destination/dates and the inviter's display name — needed to show
-- an "X invited you to Y" banner before the invite is accepted (RLS on
-- `trips` alone wouldn't let the invitee see it yet).
create or replace function public.get_pending_invites()
returns table (
  invite_id uuid,
  trip_id uuid,
  destination text,
  start_date date,
  end_date date,
  inviter_name text
)
language sql
security definer
set search_path = public
as $$
  select
    tc.id as invite_id,
    tc.trip_id,
    t.destination,
    t.start_date,
    t.end_date,
    p.display_name as inviter_name
  from trip_collaborators tc
  join trips t on t.id = tc.trip_id
  left join profiles p on p.id = t.user_id
  where tc.invited_email = auth.email()
    and tc.user_id is null;
$$;

grant execute on function public.get_pending_invites() to authenticated;

-- Accepts one specific invite addressed to the signed-in user's email.
create or replace function public.accept_trip_invite(p_invite_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update trip_collaborators
  set user_id = auth.uid()
  where id = p_invite_id
    and invited_email = auth.email()
    and user_id is null;
$$;

grant execute on function public.accept_trip_invite(uuid) to authenticated;

-- Declines (deletes) one specific invite addressed to the signed-in user's
-- email — only ever touches a still-pending row addressed to that email,
-- never anything already claimed or belonging to someone else.
create or replace function public.decline_trip_invite(p_invite_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  delete from trip_collaborators
  where id = p_invite_id
    and invited_email = auth.email()
    and user_id is null;
$$;

grant execute on function public.decline_trip_invite(uuid) to authenticated;
