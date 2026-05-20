-- Jalankan file ini jika paket soal tidak bisa dihapus.
-- File ini memastikan relasi paket-soal/nilai punya aturan delete yang benar.

alter table public.questions
drop constraint if exists questions_exam_id_fkey;

alter table public.questions
add constraint questions_exam_id_fkey
foreign key (exam_id)
references public.exams(id)
on delete cascade;

alter table public.attempts
drop constraint if exists attempts_exam_id_fkey;

alter table public.attempts
add constraint attempts_exam_id_fkey
foreign key (exam_id)
references public.exams(id)
on delete set null;

drop policy if exists "admins can update attempts" on public.attempts;
create policy "admins can update attempts"
on public.attempts
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());
