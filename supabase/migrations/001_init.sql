-- ============================================
-- TOURNOI ROMAINVILLE - Schema Supabase v1
-- ============================================

-- Extensions
create extension if not exists "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- Groupes / Poules
create table groups (
  id uuid primary key default uuid_generate_v4(),
  name text not null, -- 'A' ou 'B'
  created_at timestamptz default now()
);

-- Équipes
create table teams (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text not null unique,
  logo_url text,
  group_id uuid references groups(id),
  created_at timestamptz default now()
);

-- Joueurs
create table players (
  id uuid primary key default uuid_generate_v4(),
  team_id uuid references teams(id) on delete cascade,
  name text not null,
  number int,
  created_at timestamptz default now()
);

-- Matchs
create table matches (
  id uuid primary key default uuid_generate_v4(),
  group_id uuid references groups(id),
  home_team_id uuid references teams(id),
  away_team_id uuid references teams(id),
  leg int not null default 1, -- 1 = aller, 2 = retour
  home_score int default null,
  away_score int default null,
  status text not null default 'scheduled', -- scheduled | live | finished
  kickoff_at timestamptz default null,
  created_at timestamptz default now()
);

-- Buts
create table goals (
  id uuid primary key default uuid_generate_v4(),
  match_id uuid references matches(id) on delete cascade,
  player_id uuid references players(id),
  team_id uuid references teams(id),
  minute int default null,
  own_goal boolean default false,
  created_at timestamptz default now()
);

-- Classement (cache recalculé à chaque update match)
create table standings (
  id uuid primary key default uuid_generate_v4(),
  group_id uuid references groups(id),
  team_id uuid references teams(id),
  played int default 0,
  won int default 0,
  drawn int default 0,
  lost int default 0,
  goals_for int default 0,
  goals_against int default 0,
  goal_diff int generated always as (goals_for - goals_against) stored,
  points int default 0,
  updated_at timestamptz default now(),
  unique(group_id, team_id)
);

-- Settings tournoi
create table settings (
  id uuid primary key default uuid_generate_v4(),
  tournament_name text default 'Tournoi Romainville',
  subtitle text default 'Edition 2026',
  final4_unlocked boolean default false,
  draw_done boolean default false,
  updated_at timestamptz default now()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

alter table groups enable row level security;
alter table teams enable row level security;
alter table players enable row level security;
alter table matches enable row level security;
alter table goals enable row level security;
alter table standings enable row level security;
alter table settings enable row level security;

-- Lecture publique pour tout le monde
create policy "Public read groups" on groups for select using (true);
create policy "Public read teams" on teams for select using (true);
create policy "Public read players" on players for select using (true);
create policy "Public read matches" on matches for select using (true);
create policy "Public read goals" on goals for select using (true);
create policy "Public read standings" on standings for select using (true);
create policy "Public read settings" on settings for select using (true);

-- Écriture uniquement pour les utilisateurs authentifiés (toi = admin)
create policy "Admin write groups" on groups for all using (auth.role() = 'authenticated');
create policy "Admin write teams" on teams for all using (auth.role() = 'authenticated');
create policy "Admin write players" on players for all using (auth.role() = 'authenticated');
create policy "Admin write matches" on matches for all using (auth.role() = 'authenticated');
create policy "Admin write goals" on goals for all using (auth.role() = 'authenticated');
create policy "Admin write standings" on standings for all using (auth.role() = 'authenticated');
create policy "Admin write settings" on settings for all using (auth.role() = 'authenticated');

-- ============================================
-- DONNÉES INITIALES
-- ============================================

-- Groupes
insert into groups (id, name) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'A'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'B');

-- Équipes Poule A
insert into teams (id, name, slug, logo_url, group_id) values
  ('bbbbbbbb-0000-0000-0000-000000000001', 'PSG', 'psg', 'https://upload.wikimedia.org/wikipedia/en/a/a7/Paris_Saint-Germain_F.C..svg', 'aaaaaaaa-0000-0000-0000-000000000001'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Arsenal', 'arsenal', 'https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg', 'aaaaaaaa-0000-0000-0000-000000000001'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Barcelone', 'barca', 'https://upload.wikimedia.org/wikipedia/en/4/47/FC_Barcelona_%28crest%29.svg', 'aaaaaaaa-0000-0000-0000-000000000001');

-- Équipes Poule B
insert into teams (id, name, slug, logo_url, group_id) values
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Real Madrid', 'real', 'https://upload.wikimedia.org/wikipedia/en/5/56/Real_Madrid_CF.svg', 'aaaaaaaa-0000-0000-0000-000000000002'),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Man City', 'city', 'https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg', 'aaaaaaaa-0000-0000-0000-000000000002'),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'Bayern', 'bayern', 'https://upload.wikimedia.org/wikipedia/commons/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg', 'aaaaaaaa-0000-0000-0000-000000000002');

-- Joueurs Arsenal
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Marvin'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Killian'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Maxime'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Rodrigue'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Koskas');

-- Joueurs Real Madrid
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Ryad'),
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Salah'),
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Yves'),
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Bouthie'),
  ('bbbbbbbb-0000-0000-0000-000000000004', 'Alexandre');

-- Joueurs Barcelone
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Ali'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Sacha'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Nassim'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Abdel'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Norredine');

-- Joueurs PSG
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Adam'),
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Iheb'),
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Marwane'),
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Steven'),
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Slo');

-- Joueurs Bayern
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000006', 'Ali'),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'Elio'),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'Mor'),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'Massi'),
  ('bbbbbbbb-0000-0000-0000-000000000006', 'So');

-- Joueurs Man City
insert into players (team_id, name) values
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Matteo'),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Simon'),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Mathys'),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Ian'),
  ('bbbbbbbb-0000-0000-0000-000000000005', 'Haroon');

-- Matchs Poule A (aller + retour)
insert into matches (group_id, home_team_id, away_team_id, leg) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000002', 1), -- PSG vs Arsenal aller
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 2), -- Arsenal vs PSG retour
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000003', 1), -- PSG vs Barça aller
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000003', 'bbbbbbbb-0000-0000-0000-000000000001', 2), -- Barça vs PSG retour
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000003', 1), -- Arsenal vs Barça aller
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000003', 'bbbbbbbb-0000-0000-0000-000000000002', 2); -- Barça vs Arsenal retour

-- Matchs Poule B (aller + retour)
insert into matches (group_id, home_team_id, away_team_id, leg) values
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000004', 'bbbbbbbb-0000-0000-0000-000000000005', 1), -- Real vs City aller
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000005', 'bbbbbbbb-0000-0000-0000-000000000004', 2), -- City vs Real retour
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000004', 'bbbbbbbb-0000-0000-0000-000000000006', 1), -- Real vs Bayern aller
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000006', 'bbbbbbbb-0000-0000-0000-000000000004', 2), -- Bayern vs Real retour
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000005', 'bbbbbbbb-0000-0000-0000-000000000006', 1), -- City vs Bayern aller
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000006', 'bbbbbbbb-0000-0000-0000-000000000005', 2); -- Bayern vs City retour

-- Classement initial (tout à 0)
insert into standings (group_id, team_id, played, won, drawn, lost, goals_for, goals_against, points) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 0,0,0,0,0,0,0),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000002', 0,0,0,0,0,0,0),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000003', 0,0,0,0,0,0,0),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000004', 0,0,0,0,0,0,0),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000005', 0,0,0,0,0,0,0),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000006', 0,0,0,0,0,0,0);

-- Settings par défaut
insert into settings (tournament_name, subtitle, final4_unlocked, draw_done) values
  ('Tournoi Romainville', 'Edition 2026', false, false);
