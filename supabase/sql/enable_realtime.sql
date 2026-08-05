-- Turns on Supabase Realtime (postgres_changes) for the tables the app now
-- listens to live, so an edit made on one signed-in device shows up on
-- another without needing to background/reopen the app. Run once in the
-- Supabase SQL Editor (project xvbtracxtlwpideblnvm). Purely additive —
-- doesn't touch any table, column, or RLS policy; Realtime already respects
-- the RLS policies that exist on each table, so a client only ever
-- receives change events for rows it's allowed to select.
--
-- If any of these were already turned on before (e.g. via the Database >
-- Replication toggle in the dashboard), Postgres will error on that one
-- line with "relation is already member of publication" — just delete
-- that line and re-run the rest.

alter publication supabase_realtime add table public.trips;
alter publication supabase_realtime add table public.packing_items;
alter publication supabase_realtime add table public.suitcases;
alter publication supabase_realtime add table public.manually_visited_countries;
