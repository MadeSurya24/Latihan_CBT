-- Jalankan file ini di Supabase SQL Editor setelah schema utama sudah berhasil.
-- Fitur: akun regu, profile regu, histori milik user, dan draft pengerjaan autosave.

create extension if not exists pgcrypto;

create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  team_name text not null default '',
  team_number text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.attempts
add column if not exists user_id uuid references auth.users(id) on delete set null;

create index if not exists attempts_user_id_finished_at_idx
on public.attempts(user_id, finished_at desc);

create table if not exists public.attempt_drafts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exam_id uuid not null references public.exams(id) on delete cascade,
  team_name text not null default '',
  team_number text not null default '',
  started_at timestamptz not null default now(),
  current_index int not null default 0,
  answers jsonb not null default '{}'::jsonb,
  doubtful jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, exam_id)
);

alter table public.user_profiles enable row level security;
alter table public.attempt_drafts enable row level security;

drop policy if exists "users can read own profile" on public.user_profiles;
create policy "users can read own profile"
on public.user_profiles
for select
to authenticated
using (auth.uid() = user_id or public.is_admin());

drop policy if exists "users can create own profile" on public.user_profiles;
create policy "users can create own profile"
on public.user_profiles
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "users can update own profile" on public.user_profiles;
create policy "users can update own profile"
on public.user_profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "users can read own attempts" on public.attempts;
create policy "users can read own attempts"
on public.attempts
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "anyone can submit attempts" on public.attempts;
drop policy if exists "authenticated users can submit own attempts" on public.attempts;
create policy "authenticated users can submit own attempts"
on public.attempts
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "users can read own drafts" on public.attempt_drafts;
create policy "users can read own drafts"
on public.attempt_drafts
for select
to authenticated
using (auth.uid() = user_id or public.is_admin());

drop policy if exists "users can create own drafts" on public.attempt_drafts;
create policy "users can create own drafts"
on public.attempt_drafts
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "users can update own drafts" on public.attempt_drafts;
create policy "users can update own drafts"
on public.attempt_drafts
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "users can delete own drafts" on public.attempt_drafts;
create policy "users can delete own drafts"
on public.attempt_drafts
for delete
to authenticated
using (auth.uid() = user_id or public.is_admin());
