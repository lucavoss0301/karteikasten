-- Karteikasten: Datenbank einrichten
-- In Supabase: SQL Editor → New query → alles hier einfügen → Run

-- Fortschritt: eine Zeile pro Benutzer
create table if not exists public.progress (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  epoch      bigint not null default 0,
  stats      jsonb  not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Eigene Karten: eine Zeile pro Karte
create table if not exists public.own_cards (
  user_id uuid    not null references auth.users(id) on delete cascade,
  id      text    not null,
  fach    text    not null,
  thema   text    not null,
  front   jsonb   not null,
  back    jsonb   not null,
  updated bigint  not null default 0,
  deleted boolean not null default false,
  primary key (user_id, id)
);

-- Sicherheit: Jeder sieht und ändert nur seine eigenen Zeilen
alter table public.progress  enable row level security;
alter table public.own_cards enable row level security;

drop policy if exists "progress_select_own" on public.progress;
drop policy if exists "progress_insert_own" on public.progress;
drop policy if exists "progress_update_own" on public.progress;
drop policy if exists "progress_delete_own" on public.progress;
create policy "progress_select_own" on public.progress for select to authenticated using (auth.uid() = user_id);
create policy "progress_insert_own" on public.progress for insert to authenticated with check (auth.uid() = user_id);
create policy "progress_update_own" on public.progress for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "progress_delete_own" on public.progress for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "cards_select_own" on public.own_cards;
drop policy if exists "cards_insert_own" on public.own_cards;
drop policy if exists "cards_update_own" on public.own_cards;
drop policy if exists "cards_delete_own" on public.own_cards;
create policy "cards_select_own" on public.own_cards for select to authenticated using (auth.uid() = user_id);
create policy "cards_insert_own" on public.own_cards for insert to authenticated with check (auth.uid() = user_id);
create policy "cards_update_own" on public.own_cards for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "cards_delete_own" on public.own_cards for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.progress  to authenticated;
grant select, insert, update, delete on public.own_cards to authenticated;
