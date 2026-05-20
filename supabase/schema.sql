-- Jalankan file ini di Supabase SQL Editor.
-- Setelah itu buat akun admin di aplikasi, lalu jalankan query penanda admin di bagian bawah file ini.

create extension if not exists pgcrypto;

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_profiles
    where user_id = auth.uid()
  );
$$;

create table if not exists public.exam_settings (
  id int primary key default 1,
  title text not null default 'Soal Simulasi Day 10',
  subject text not null default 'Simulasi Pengetahuan Umum',
  duration_minutes int not null default 120,
  updated_at timestamptz not null default now(),
  constraint one_exam_settings_row check (id = 1)
);

insert into public.exam_settings (id, title, subject, duration_minutes)
values (1, 'Soal Simulasi Day 10', 'Simulasi Pengetahuan Umum', 120)
on conflict (id) do nothing;

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  sort_order int not null,
  text text not null,
  image text not null default '',
  options jsonb not null,
  answer text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists questions_sort_order_key on public.questions(sort_order);

create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  team_name text not null,
  team_number text not null,
  exam_title text not null,
  started_at timestamptz not null,
  finished_at timestamptz not null default now(),
  duration_seconds int not null default 0,
  score int not null default 0,
  correct_count int not null default 0,
  wrong_count int not null default 0,
  unanswered_count int not null default 0,
  total_questions int not null default 0,
  answers jsonb not null default '{}'::jsonb,
  doubtful jsonb not null default '{}'::jsonb,
  question_snapshot jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.admin_profiles enable row level security;
alter table public.exam_settings enable row level security;
alter table public.questions enable row level security;
alter table public.attempts enable row level security;

drop policy if exists "admins can read admin profiles" on public.admin_profiles;
create policy "admins can read admin profiles"
on public.admin_profiles
for select
to authenticated
using (public.is_admin());

drop policy if exists "public can read exam settings" on public.exam_settings;
create policy "public can read exam settings"
on public.exam_settings
for select
to anon, authenticated
using (true);

drop policy if exists "admins can update exam settings" on public.exam_settings;
create policy "admins can update exam settings"
on public.exam_settings
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "public can read active questions" on public.questions;
create policy "public can read active questions"
on public.questions
for select
to anon, authenticated
using (active = true or public.is_admin());

drop policy if exists "admins can insert questions" on public.questions;
create policy "admins can insert questions"
on public.questions
for insert
to authenticated
with check (public.is_admin());

drop policy if exists "admins can update questions" on public.questions;
create policy "admins can update questions"
on public.questions
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "admins can delete questions" on public.questions;
create policy "admins can delete questions"
on public.questions
for delete
to authenticated
using (public.is_admin());

drop policy if exists "anyone can submit attempts" on public.attempts;
create policy "anyone can submit attempts"
on public.attempts
for insert
to anon, authenticated
with check (true);

drop policy if exists "admins can read attempts" on public.attempts;
create policy "admins can read attempts"
on public.attempts
for select
to authenticated
using (public.is_admin());

drop policy if exists "admins can delete attempts" on public.attempts;
create policy "admins can delete attempts"
on public.attempts
for delete
to authenticated
using (public.is_admin());

insert into public.questions (sort_order, text, image, options, answer, active)
values
  (1, 'Stasiun radio ABC berasal dari negara …', '', '{"A":"Inggris","B":"Jepang","C":"Australia","D":"Amerika Serikat"}'::jsonb, 'C', true),
  (2, 'Kepanjangan BBC adalah …', '', '{"A":"British Broadcasting Corporation","B":"Broadcast Britain Center","C":"British Broad Center","D":"Broadcasting British Company"}'::jsonb, 'A', true),
  (3, 'NHK merupakan stasiun radio terkenal dari negara …', '', '{"A":"Cina","B":"Jepang","C":"Korea","D":"India"}'::jsonb, 'B', true),
  (4, 'VOA adalah singkatan dari …', '', '{"A":"Voice of Asia","B":"Voice of America","C":"Voice of Australia","D":"Voice of Africa"}'::jsonb, 'B', true),
  (5, 'Lagu kebangsaan Amerika Serikat adalah …', '', '{"A":"Kimigayo","B":"Advance Australia Fair","C":"The Stars Spangled Banner","D":"Fratelli d’Italia"}'::jsonb, 'C', true),
  (6, 'Lagu kebangsaan Jepang berjudul …', '', '{"A":"Kimigayo","B":"Maame","C":"Wilhelmus","D":"Negaraku"}'::jsonb, 'A', true),
  (7, 'Lagu kebangsaan Malaysia adalah …', '', '{"A":"Negaraku","B":"Oom Hemmect","C":"Maame","D":"Wilhelmus"}'::jsonb, 'A', true),
  (8, '“God Save The Queen” merupakan lagu kebangsaan negara …', '', '{"A":"Jerman","B":"Inggris","C":"Belgia","D":"India"}'::jsonb, 'B', true),
  (9, 'Lagu kebangsaan Belanda adalah …', '', '{"A":"Wilhelmus","B":"Kimigayo","C":"Fratelli d’Italia","D":"Duke Patria"}'::jsonb, 'A', true),
  (10, 'Maskapai penerbangan Garuda Indonesia termasuk penerbangan …', '', '{"A":"Asing","B":"Domestik","C":"Regional","D":"Charter"}'::jsonb, 'B', true),
  (11, 'MAS adalah maskapai penerbangan dari negara …', '', '{"A":"Mesir","B":"Malaysia","C":"Jepang","D":"India"}'::jsonb, 'B', true),
  (12, 'JAL merupakan singkatan dari …', '', '{"A":"Japan Air Lines","B":"Java Air Lines","C":"Jakarta Airlines","D":"Japan Aviation Limited"}'::jsonb, 'A', true),
  (13, 'Lufthansa adalah maskapai penerbangan dari negara …', '', '{"A":"Italia","B":"Inggris","C":"Jerman","D":"Belgia"}'::jsonb, 'C', true),
  (14, 'Cathay Pacific berasal dari negara …', '', '{"A":"Hongkong","B":"India","C":"Korea Selatan","D":"Pakistan"}'::jsonb, 'A', true),
  (15, 'Singapore Airlines disingkat …', '', '{"A":"SAS","B":"SIA","C":"SAA","D":"CSA"}'::jsonb, 'B', true),
  (16, 'Kantor berita resmi Indonesia adalah …', '', '{"A":"Reuters","B":"AFP","C":"Antara","D":"Bernama"}'::jsonb, 'C', true),
  (17, 'AFP berasal dari negara …', '', '{"A":"Inggris","B":"Amerika Serikat","C":"Prancis","D":"Jepang"}'::jsonb, 'C', true),
  (18, 'Reuters merupakan kantor berita dari negara …', '', '{"A":"Inggris","B":"Rusia","C":"India","D":"Iran"}'::jsonb, 'A', true),
  (19, 'Bernama adalah kantor berita negara …', '', '{"A":"Thailand","B":"Malaysia","C":"Vietnam","D":"India"}'::jsonb, 'B', true),
  (20, 'AP adalah singkatan dari …', '', '{"A":"Asian Press","B":"Associated Press","C":"American Publisher","D":"Agency Press"}'::jsonb, 'B', true),
  (21, 'Motto TNI AD adalah …', '', '{"A":"Jalesveva Jayamahe","B":"Swa Bhuwana Paksa","C":"Kartika Eka Paksi","D":"Rastra Sewakottama"}'::jsonb, 'C', true),
  (22, '“Di Laut Kita Jaya” merupakan arti dari motto …', '', '{"A":"Kartika Eka Paksi","B":"Rastra Sewakottama","C":"Swa Bhuwana Paksa","D":"Jalesveva Jayamahe"}'::jsonb, 'D', true),
  (23, 'Motto POLRI adalah …', '', '{"A":"Rastra Sewakottama","B":"Kartika Eka Paksi","C":"Swa Bhuwana Paksa","D":"Jalesveva Jayamahe"}'::jsonb, 'A', true),
  (24, 'Nama latin gajah adalah …', '', '{"A":"Bos sundaicus","B":"Elephas indicus","C":"Crocodylus novaeguineae","D":"Dugong dugong"}'::jsonb, 'B', true),
  (25, 'Babirusa memiliki nama latin …', '', '{"A":"Babirussa babirussa","B":"Panthera pardus","C":"Pavo muticus","D":"Trugulus"}'::jsonb, 'A', true),
  (26, 'Nama latin harimau Sumatera adalah …', '', '{"A":"Panthera pardus","B":"Panthera tigris sundaicus","C":"Panthera tigris sumatranus","D":"Elephas indicus"}'::jsonb, 'C', true),
  (27, 'Dugong dugong adalah nama latin dari hewan …', '', '{"A":"Gajah","B":"Lumba-lumba","C":"Ikan duyung","D":"Buaya"}'::jsonb, 'C', true),
  (28, 'Nama latin burung merak adalah …', '', '{"A":"Pavo muticus","B":"Casuarius casuarius","C":"Muntiacus muntjak","D":"Probosciger aterrimus"}'::jsonb, 'A', true),
  (29, 'Nama latin kasuari adalah …', '', '{"A":"Crocodylus novaeguineae","B":"Casuarius casuarius","C":"Dugong dugong","D":"Panthera pardus"}'::jsonb, 'B', true),
  (30, 'Panthera pardus merupakan nama latin dari …', '', '{"A":"Harimau Jawa","B":"Kijang","C":"Macan kumbang","D":"Kakaktua Raja"}'::jsonb, 'C', true),
  (31, 'Raja Dinuzulu meninggal pada tahun …', '', '{"A":"1910","B":"1911","C":"1912","D":"1913"}'::jsonb, 'D', true),
  (32, 'Buku yang ditulis BP setelah kembali ke Inggris tahun 1901 berjudul …', '', '{"A":"Scouting for Boys","B":"Aids to Scouting","C":"The Jungle Book","D":"Rovering to Success"}'::jsonb, 'B', true),
  (33, 'BP mendapat undangan dari perkumpulan Boys Brigade pada tahun …', '', '{"A":"1905","B":"1906","C":"1907","D":"1908"}'::jsonb, 'C', true),
  (34, 'Perkemahan di Pulau Brownsea diikuti oleh …', '', '{"A":"15 orang","B":"18 orang","C":"20 orang","D":"25 orang"}'::jsonb, 'C', true),
  (35, 'BP berhenti dari dinas kemiliteran pada tahun …', '', '{"A":"1908","B":"1909","C":"1910","D":"1911"}'::jsonb, 'C', true),
  (36, 'Pangkat terakhir Baden Powell adalah …', '', '{"A":"Mayor Jenderal","B":"Letnan Jenderal","C":"Kolonel","D":"Marsekal"}'::jsonb, 'B', true),
  (37, 'BP memulai perjalanan berkeliling dunia pada tahun …', '', '{"A":"1910","B":"1911","C":"1912","D":"1913"}'::jsonb, 'C', true),
  (38, 'Baden Powell diangkat sebagai Chief Scout of the World pada tanggal …', '', '{"A":"6 Agustus 1920","B":"16 Agustus 1920","C":"8 Januari 1941","D":"3 Desember 1934"}'::jsonb, 'A', true),
  (39, 'BP mengunjungi Batavia (Jakarta) pada tanggal …', '', '{"A":"1 Januari 1934","B":"3 Desember 1934","C":"6 Agustus 1934","D":"8 Januari 1935"}'::jsonb, 'B', true),
  (40, 'Baden Powell wafat pada tanggal …', '', '{"A":"8 Januari 1941","B":"6 Agustus 1920","C":"3 Desember 1934","D":"15 Januari 1908"}'::jsonb, 'A', true),
  (41, 'Buku Scouting for Boys pertama kali diedarkan pada tanggal …', '', '{"A":"1 Januari 1908","B":"15 Januari 1908","C":"10 Februari 1908","D":"20 Januari 1908"}'::jsonb, 'B', true),
  (42, 'Penerbit buku Scouting for Boys adalah …', '', '{"A":"Oxford Press","B":"Gramedia","C":"Horace Cox","D":"Cambridge Press"}'::jsonb, 'C', true),
  (43, 'Kepanduan siaga didirikan pada tahun …', '', '{"A":"1914","B":"1915","C":"1916","D":"1917"}'::jsonb, 'C', true),
  (44, 'Buku yang mengilhami kegiatan siaga adalah …', '', '{"A":"Scouting for Boys","B":"The Jungle Book","C":"Aids to Scouting","D":"Rovering to Success"}'::jsonb, 'B', true),
  (45, 'Penulis buku The Jungle Book adalah …', '', '{"A":"Baden Powell","B":"William McLaren","C":"Rudyard Kipling","D":"John Thurman"}'::jsonb, 'C', true),
  (46, 'Nama anak serigala dalam cerita The Jungle Book adalah …', '', '{"A":"Simba","B":"Tarzan","C":"Mowgli","D":"Bagheera"}'::jsonb, 'C', true),
  (47, 'Bagheera dan Baloo dalam cerita The Jungle Book adalah …', '', '{"A":"Singa dan harimau","B":"Macan kumbang dan beruang","C":"Serigala dan rubah","D":"Beruang dan gajah"}'::jsonb, 'B', true),
  (48, 'Sahabat BP yang memberikan sebidang tanah adalah …', '', '{"A":"Rudyard Kipling","B":"John Thurman","C":"William F DeBois McLaren","D":"Lord Baden"}'::jsonb, 'C', true),
  (49, 'Patung yang ada di Gilwell Park adalah patung …', '', '{"A":"Harimau","B":"Elang","C":"Singa","D":"Kuda"}'::jsonb, 'C', true),
  (50, 'Gerakan Pramuka menjadi satu-satunya organisasi kepanduan sejak Kepres nomor …', '', '{"A":"238/1961","B":"448/1961","C":"055/1982","D":"174/2012"}'::jsonb, 'A', true),
  (51, 'Skep Panji Gerakan Pramuka adalah nomor …', '', '{"A":"036 tahun 1979","B":"448 tahun 1961","C":"174 tahun 2012","D":"064 tahun 2001"}'::jsonb, 'B', true),
  (52, 'Surat keputusan Kwartir Nasional tentang lambang Gerakan Pramuka adalah …', '', '{"A":"06/KN/72","B":"045/KN/80","C":"055/1982","D":"132/KN/79"}'::jsonb, 'A', true),
  (53, 'Keputusan Kwarnas tentang tanda pengenal bernomor …', '', '{"A":"202/KN/88","B":"055 tahun 1982","C":"064 tahun 2001","D":"174/KN/2012"}'::jsonb, 'B', true),
  (54, 'Skep tentang tanda pengenal umum adalah …', '', '{"A":"059 Tahun 1982","B":"088 Tahun 1982","C":"045 Tahun 1980","D":"036 Tahun 1979"}'::jsonb, 'A', true),
  (55, 'SK Kwarnas tentang tanda kecakapan adalah …', '', '{"A":"055/1982 dan 036/1979","B":"088/KN/74 dan 058 tahun 1982","C":"202/KN/88 dan 045/1980","D":"174/2012 dan 132/1979"}'::jsonb, 'B', true),
  (56, 'SK Kwarnas nomor 064 tahun 2001 berisi tentang …', '', '{"A":"Seragam pramuka","B":"Lambang pramuka","C":"Penarikan diri dari WAGGGS","D":"Tanda jabatan"}'::jsonb, 'C', true),
  (57, 'Skep tentang TKK adalah nomor …', '', '{"A":"132/KN/79 dan 134/KN/76","B":"055/1982 dan 058/1982","C":"036/1979 dan 045/1980","D":"174/2012 dan 202/1988"}'::jsonb, 'A', true),
  (58, 'Skep tentang baju pramuka dahulu adalah …', '', '{"A":"045/KN/80","B":"088/KN/81","C":"202/KN/88","D":"174/KN/2012"}'::jsonb, 'B', true),
  (59, 'Skep baju pramuka yang sekarang adalah …', '', '{"A":"174/KN/2012","B":"036/KN/79","C":"055/1982","D":"064/2001"}'::jsonb, 'A', true),
  (60, 'Skep SKU terbaru adalah …', '', '{"A":"045/KN/80","B":"198/KN/2011","C":"132/KN/79","D":"202/KN/88"}'::jsonb, 'B', true),
  (61, 'Obat merah seperti mercurochrome atau betadine digunakan untuk …', '', '{"A":"Obat sakit perut","B":"Obat malaria","C":"Obat luka baru yang ringan","D":"Obat mata"}'::jsonb, 'C', true),
  (62, 'Yodium tinctur digunakan untuk …', '', '{"A":"Luka berat atau lama","B":"Sakit kepala","C":"Luka bakar","D":"Penyakit malaria"}'::jsonb, 'A', true),
  (63, 'Fungsi perbalse atau salep adalah untuk …', '', '{"A":"Obat mata","B":"Obat luka lama","C":"Obat pusing","D":"Obat batuk"}'::jsonb, 'B', true),
  (64, 'Amonia liquida digunakan untuk …', '', '{"A":"Mengobati luka bakar","B":"Membersihkan mata","C":"Perangsang bagi orang pingsan","D":"Mengobati demam"}'::jsonb, 'C', true),
  (65, 'Larutan burowi berfungsi sebagai …', '', '{"A":"Obat sakit perut","B":"Pembersih luka","C":"Obat malaria","D":"Penghangat tubuh"}'::jsonb, 'B', true),
  (66, 'Boorwater dapat digunakan untuk …', '', '{"A":"Obat malaria","B":"Pengering luka","C":"Pembersih luka dan mata","D":"Obat pingsan"}'::jsonb, 'C', true),
  (67, 'Zulfazincie digunakan sebagai …', '', '{"A":"Obat luka","B":"Obat mata","C":"Obat batuk","D":"Obat pusing"}'::jsonb, 'B', true),
  (68, 'Tablet norit digunakan untuk …', '', '{"A":"Penyakit malaria","B":"Sakit kepala","C":"Keracunan dan sakit perut","D":"Obat luka"}'::jsonb, 'C', true),
  (69, 'Tablet kina digunakan untuk penyakit …', '', '{"A":"Campak","B":"Malaria","C":"TBC","D":"Tetanus"}'::jsonb, 'B', true),
  (70, 'Paracetamol digunakan untuk mengatasi …', '', '{"A":"Demam","B":"Luka bakar","C":"Keracunan","D":"Pingsan"}'::jsonb, 'A', true),
  (71, 'Arang dapur dapat digunakan sebagai pengganti …', '', '{"A":"Yodium","B":"Paracetamol","C":"Tablet norit","D":"Boorwater"}'::jsonb, 'C', true),
  (72, 'Daun babadotan yang ditumbuk dapat digunakan sebagai pengganti …', '', '{"A":"Obat merah","B":"Tablet kina","C":"Zulfazincie","D":"Amoniak"}'::jsonb, 'A', true),
  (73, 'Lena (collapse/kolaps) disebabkan oleh …', '', '{"A":"Kekurangan oksigen","B":"Keracunan makanan","C":"Infeksi mata","D":"Penyakit malaria"}'::jsonb, 'A', true),
  (74, 'Gugat (shock) terjadi akibat …', '', '{"A":"Terlalu banyak makan","B":"Peristiwa yang mengejutkan","C":"Kekurangan vitamin","D":"Penyakit kulit"}'::jsonb, 'B', true),
  (75, 'Pernapasan buatan adalah usaha agar …', '', '{"A":"Jantung bekerja kembali","B":"Mata dapat melihat kembali","C":"Paru-paru dapat bekerja kembali","D":"Tubuh menjadi hangat"}'::jsonb, 'C', true),
  (76, 'Metode pernapasan buatan yang paling cepat dan efektif adalah …', '', '{"A":"Howard","B":"Schapter","C":"Mulut ke mulut","D":"Laborde"}'::jsonb, 'C', true),
  (77, 'Metode Hoger Nielsen disarankan untuk korban …', '', '{"A":"Tenggelam","B":"Keracunan","C":"Luka bakar","D":"Pingsan"}'::jsonb, 'A', true),
  (78, 'Pendarahan luar adalah …', '', '{"A":"Darah keluar di dalam tubuh","B":"Darah keluar dari tubuh","C":"Darah berhenti mengalir","D":"Darah membeku"}'::jsonb, 'B', true),
  (79, 'Darah dari pembuluh nadi berwarna …', '', '{"A":"Merah tua","B":"Hitam","C":"Merah muda","D":"Kuning"}'::jsonb, 'C', true),
  (80, 'Immunisasi artinya …', '', '{"A":"Membersihkan darah","B":"Menyuntikkan antigen untuk kekebalan","C":"Mengobati luka","D":"Mengobati demam"}'::jsonb, 'B', true),
  (81, 'Kompas adalah alat untuk …', '', '{"A":"Menggambar peta","B":"Menentukan arah mata angin","C":"Mengukur suhu","D":"Menghitung jarak"}'::jsonb, 'B', true),
  (82, 'Penemu kompas pertama kali adalah bangsa …', '', '{"A":"Arab","B":"Jepang","C":"Cina","D":"India"}'::jsonb, 'C', true),
  (83, 'Bagian kompas yang menunjukkan arah adalah …', '', '{"A":"Dial","B":"Visir","C":"Jarum magnet","D":"Kaca pembesar"}'::jsonb, 'C', true),
  (84, 'Sudut yang dihitung searah jarum jam dari arah utara disebut …', '', '{"A":"Navigasi","B":"Azimuth","C":"Orientasi","D":"Koordinat"}'::jsonb, 'B', true),
  (85, 'Timur berada pada derajat …', '', '{"A":"45°","B":"90°","C":"180°","D":"360°"}'::jsonb, 'B', true),
  (86, 'Arah antara selatan dan barat disebut …', '', '{"A":"Barat laut","B":"Tenggara","C":"Barat daya","D":"Timur laut"}'::jsonb, 'C', true),
  (87, 'Kompas yang sering digunakan dalam kegiatan pramuka dan orienteering adalah …', '', '{"A":"Kompas Geologi","B":"Kompas Digital","C":"Kompas Bidik","D":"Kompas Gyro"}'::jsonb, 'C', true),
  (88, 'Simbol pada peta untuk sungai atau kali adalah …', '', '{"A":"Garis berkelok","B":"Lingkaran","C":"Kotak","D":"Segitiga"}'::jsonb, 'A', true),
  (89, 'Tanda medan berbentuk pohon kelapa menunjukkan …', '', '{"A":"Hutan jati","B":"Kebun kelapa","C":"Sawah","D":"Semak"}'::jsonb, 'B', true),
  (90, 'Simbol huruf “L” pada tanda medan berarti …', '', '{"A":"Ladang","B":"Laut","C":"Lapangan","D":"Lembah"}'::jsonb, 'A', true),
  (91, 'Tanda medan berbentuk kotak dengan tanda bulan sabit menunjukkan …', '', '{"A":"Gereja","B":"Pura","C":"Kelenteng","D":"Mesjid"}'::jsonb, 'D', true),
  (92, 'Simbol tanda medan untuk danau berbentuk …', '', '{"A":"Garis lurus","B":"Gelombang","C":"Area tertutup tidak beraturan","D":"Segitiga"}'::jsonb, 'C', true),
  (93, 'Tanda jejak dengan tanda silang besar (X) berarti …', '', '{"A":"Air bersih","B":"Ikuti jalan ini","C":"Jangan dilewati","D":"Bahaya"}'::jsonb, 'D', true),
  (94, 'Tanda jejak berbentuk hati berarti …', '', '{"A":"Bahaya","B":"Air buruk","C":"Keadaan buruk","D":"Kembali"}'::jsonb, 'C', true),
  (95, 'Tanda jejak berbentuk lingkaran dengan panah berarti …', '', '{"A":"Air bersih","B":"Kembali","C":"Bahaya","D":"Perkemahan"}'::jsonb, 'B', true),
  (96, 'Pecahkan sandi pada gambar berikut.', '/images/questions/sandi-01.jpeg', '{"A":"MANDALA SAPARUA","B":"MANAGALA SAPARUA","C":"MANGGALA SAPARUA","D":"MANAGALA SAPUTRA","E":"MANDALA SAMUDRA"}'::jsonb, 'B', true),
  (97, 'Pecahkan sandi pada gambar berikut.', '/images/questions/sandi-02.jpeg', '{"A":"BATAS MONAS RAKIT","B":"BATAS MONAS RAKYAT","C":"BATAK MONAS RAKIT","D":"BATAS MANAS RAKIT","E":"BATAS MONAS RAKSA"}'::jsonb, 'A', true),
  (98, 'Pecahkan sandi pada gambar berikut.', '/images/questions/sandi-03.jpeg', '{"A":"HILANG SERIBU","B":"HILANG SEFIBU","C":"HILANG SEBUAH","D":"HIDANG SEFIBU","E":"HILANG SEFIRA"}'::jsonb, 'B', true),
  (99, 'Pecahkan sandi pada gambar berikut.', '/images/questions/sandi-04.jpeg', '{"A":"SAHABAT SETIA","B":"SAHABAT SEHATI","C":"SAHABAT SEJATI","D":"SAHABAT SEJARAH","E":"SAHABAT SEJUTA"}'::jsonb, 'C', true),
  (100, 'Pecahkan sandi pada gambar berikut.', '/images/questions/sandi-05.jpeg', '{"A":"MONARKI ABSOLUT","B":"MONARKI ABSURD","C":"MONARKI ABSOLUS","D":"MONARSI ABSOLUT","E":"MONARKI ABSOLUTE"}'::jsonb, 'A', true)
on conflict (sort_order) do nothing;

-- Cara menandai akun sebagai admin:
-- 1. Buat akun admin dari halaman Admin di website.
-- 2. Di Supabase Dashboard buka Authentication > Users, copy User UID akun admin.
-- 3. Jalankan query ini dengan mengganti USER_UID_DARI_SUPABASE dan email admin:
-- insert into public.admin_profiles (user_id, email)
-- values ('USER_UID_DARI_SUPABASE', 'admin@email.com')
-- on conflict (user_id) do nothing;
