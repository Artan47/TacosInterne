-- Tacos Factory – Gestion interne
-- À coller une seule fois dans Supabase > SQL Editor > New query, puis "Run".

-- 1. Toutes les données du logiciel (matières, recettes, ventes, charges,
--    tâches, équipe, réglages, journal) dans une seule table.
create table if not exists public.docs (
  collection  text        not null,
  id          text        not null,
  data        jsonb       not null default '{}'::jsonb,
  updated_at  timestamptz not null default now(),
  updated_by  uuid        default auth.uid(),
  primary key (collection, id)
);
create index if not exists docs_date_idx on public.docs (collection, (data->>'date'));

-- 2. Liste des personnes autorisées (toi et le chef).
create table if not exists public.members (
  email     text primary key,
  added_at  timestamptz not null default now()
);

-- 3. Vérifie si la personne connectée fait partie des membres.
create or replace function public.is_member()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.members
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_member() from public;
grant execute on function public.is_member() to authenticated;

-- 4. Règles de sécurité : seuls les membres connectés lisent et écrivent.
alter table public.docs    enable row level security;
alter table public.members enable row level security;

drop policy if exists "membres lisent"    on public.docs;
drop policy if exists "membres ajoutent"  on public.docs;
drop policy if exists "membres modifient" on public.docs;
drop policy if exists "membres suppriment" on public.docs;
create policy "membres lisent"     on public.docs for select to authenticated using (public.is_member());
create policy "membres ajoutent"   on public.docs for insert to authenticated with check (public.is_member());
create policy "membres modifient"  on public.docs for update to authenticated using (public.is_member()) with check (public.is_member());
create policy "membres suppriment" on public.docs for delete to authenticated using (public.is_member());

drop policy if exists "membres voient la liste" on public.members;
create policy "membres voient la liste" on public.members for select to authenticated using (public.is_member());
-- Pas de règle d'écriture sur members : on l'édite uniquement depuis le tableau de bord Supabase.

-- 5. Mise à jour en direct entre les téléphones.
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- 6. Ajoute les e-mails autorisés (remplace par les vrais avant de lancer).
insert into public.members (email) values
  ('email-du-gerant@exemple.ch'),
  ('email-du-chef@exemple.ch')
on conflict do nothing;
