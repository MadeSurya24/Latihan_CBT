-- Jalankan file ini di Supabase SQL Editor untuk update dari schema lama
-- ke fitur banyak paket soal dan upload gambar.

create extension if not exists pgcrypto;

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text not null default 'Simulasi Pengetahuan Umum',
  duration_minutes int not null default 120,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.exams (title, subject, duration_minutes, active)
select title, subject, duration_minutes, true
from public.exam_settings
where not exists (select 1 from public.exams)
limit 1;

insert into public.exams (title, subject, duration_minutes, active)
select 'Soal Simulasi Day 10', 'Simulasi Pengetahuan Umum', 120, true
where not exists (select 1 from public.exams);

alter table public.questions
add column if not exists exam_id uuid references public.exams(id) on delete cascade;

update public.questions
set exam_id = (select id from public.exams order by created_at asc limit 1)
where exam_id is null;

alter table public.attempts
add column if not exists exam_id uuid references public.exams(id) on delete set null;

drop index if exists public.questions_sort_order_key;
create unique index if not exists questions_exam_sort_order_key
on public.questions(exam_id, sort_order);

alter table public.exams enable row level security;

drop policy if exists "public can read active exams" on public.exams;
create policy "public can read active exams"
on public.exams
for select
to anon, authenticated
using (active = true or public.is_admin());

drop policy if exists "admins can insert exams" on public.exams;
create policy "admins can insert exams"
on public.exams
for insert
to authenticated
with check (public.is_admin());

drop policy if exists "admins can update exams" on public.exams;
create policy "admins can update exams"
on public.exams
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can delete exams" on public.exams;
create policy "admins can delete exams"
on public.exams
for delete
to authenticated
using (public.is_admin());

insert into storage.buckets (id, name, public)
values ('question-images', 'question-images', true)
on conflict (id) do update set public = true;

drop policy if exists "public can read question images" on storage.objects;
create policy "public can read question images"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'question-images');

drop policy if exists "admins can upload question images" on storage.objects;
create policy "admins can upload question images"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'question-images' and public.is_admin());

drop policy if exists "admins can update question images" on storage.objects;
create policy "admins can update question images"
on storage.objects
for update
to authenticated
using (bucket_id = 'question-images' and public.is_admin())
with check (bucket_id = 'question-images' and public.is_admin());

drop policy if exists "admins can delete question images" on storage.objects;
create policy "admins can delete question images"
on storage.objects
for delete
to authenticated
using (bucket_id = 'question-images' and public.is_admin());
