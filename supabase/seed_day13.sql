-- Seed paket soal dari: Soal simulasi bank soal day 12.docx
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- File ini membuat/memperbarui paket: soal simulasi bank soal day 13
-- Versi ini tidak memakai DECLARE/DO agar lebih aman ditempel ke SQL Editor.
-- Jika paket dengan judul yang sama sudah ada, soal lama pada paket itu akan diganti agar tidak dobel.

with existing_exam as (
  select id
  from public.exams
  where lower(title) = lower('soal simulasi bank soal day 13')
  order by created_at asc
  limit 1
),
updated_exam as (
  update public.exams
  set subject = 'Simulasi Pengetahuan Umum',
      duration_minutes = 120,
      active = true,
      updated_at = now()
  where id in (select id from existing_exam)
  returning id
),
inserted_exam as (
  insert into public.exams (title, subject, duration_minutes, active)
  select 'soal simulasi bank soal day 13', 'Simulasi Pengetahuan Umum', 120, true
  where not exists (select 1 from existing_exam)
  returning id
),
target_exam as (
  select id from updated_exam
  union all
  select id from inserted_exam
  limit 1
),
deleted_questions as (
  delete from public.questions
  where exam_id in (select id from target_exam)
  returning id
),
seed_questions (sort_order, text, image, options, answer, active) as (
  values
    (1, 'Alat untuk menetapkan atau mencari arah mata angin disebut …', '', '{"A":"Teropong","B":"Kompas","C":"Peta","D":"Jam"}'::jsonb, 'B', true),
    (2, 'Bagian kompas yang berfungsi menunjukkan arah adalah …', '', '{"A":"Dial","B":"Visir","C":"Jarum magnet","D":"Kaca pembesar"}'::jsonb, 'C', true),
    (3, 'Bangsa yang pertama kali menemukan kompas adalah …', '', '{"A":"Jepang","B":"India","C":"Yunani","D":"Cina"}'::jsonb, 'D', true),
    (4, 'Arah timur pada kompas berada pada derajat …', '', '{"A":"45°","B":"90°","C":"180°","D":"270°"}'::jsonb, 'B', true),
    (5, 'Derajat penuh pada kompas adalah …', '', '{"A":"180°","B":"270°","C":"360°","D":"720°"}'::jsonb, 'C', true),
    (6, 'Arah antara selatan dan barat disebut …', '', '{"A":"Tenggara","B":"Barat laut","C":"Timur laut","D":"Barat daya"}'::jsonb, 'D', true),
    (7, 'Kompas harus dijauhkan dari benda yang bersifat …', '', '{"A":"Lunak","B":"Panas","C":"Magnetis","D":"Ringan"}'::jsonb, 'C', true),
    (8, 'Sudut yang dihitung searah jarum jam dari arah utara disebut …', '', '{"A":"Navigasi","B":"Azimuth","C":"Dial","D":"Deklinasi"}'::jsonb, 'B', true),
    (9, 'Jika kompas menunjukkan 180°, maka arah yang ditunjuk adalah …', '', '{"A":"Utara","B":"Timur","C":"Selatan","D":"Barat"}'::jsonb, 'C', true),
    (10, 'Bagian kompas yang berisi angka derajat disebut …', '', '{"A":"Skala","B":"Jarum","C":"Visir","D":"Penggantung"}'::jsonb, 'A', true),
    (11, 'Pada malam hari arah utara dapat ditentukan dengan melihat bintang …', '', '{"A":"Sirius","B":"Polaris","C":"Orion","D":"Mars"}'::jsonb, 'B', true),
    (12, 'Kompas yang sering digunakan dalam kegiatan pramuka adalah …', '', '{"A":"Kompas digital","B":"Kompas geologi","C":"Kompas bidik","D":"Kompas gyro"}'::jsonb, 'C', true),
    (13, 'Jika arah yang dituju 315°, maka arah tersebut adalah …', '', '{"A":"Barat daya","B":"Tenggara","C":"Timur laut","D":"Barat laut"}'::jsonb, 'D', true),
    (14, 'Ilmu untuk menentukan arah dan posisi disebut …', '', '{"A":"Biologi","B":"Navigasi","C":"Astronomi","D":"Geografi"}'::jsonb, 'B', true),
    (15, 'Posisi yang benar saat menggunakan kompas adalah …', '', '{"A":"Tegak","B":"Miring","C":"Horizontal/datar","D":"Terbalik"}'::jsonb, 'C', true),
    (16, 'Pada tahun 1897 Baden Powell mendapat penghargaan …', '', '{"A":"Scout Medal","B":"Metabele Campaign","C":"Victoria Cross","D":"Golden Arrow"}'::jsonb, 'B', true),
    (17, 'Pada tahun 1900 BP menerima penghargaan …', '', '{"A":"Order of Merit","B":"Companion Order of the Bath","C":"Scout Hero Medal","D":"King Medal"}'::jsonb, 'B', true),
    (18, 'Nama kepanduan pada masa Hindia Belanda adalah …', '', '{"A":"NPO","B":"WOSM","C":"NIPV","D":"WAGGGS"}'::jsonb, 'C', true),
    (19, 'Sebelum menjadi NIPV, organisasi kepanduan Belanda bernama …', '', '{"A":"NPO","B":"PPO","C":"BSA","D":"WOSM"}'::jsonb, 'A', true),
    (20, 'Satuan Karya Bahari diatur dalam SK nomor … tahun 2011.', '', '{"A":"154","B":"155","C":"158","D":"160"}'::jsonb, 'C', true),
    (21, 'Satuan Karya Bakti Husada diatur dalam SK nomor … tahun 2011.', '', '{"A":"154","B":"158","C":"238","D":"448"}'::jsonb, 'A', true),
    (22, 'Sebutan Pramuka di Singapura adalah …', '', '{"A":"Boy Scout of America","B":"Singapore Scout Association","C":"Bharat Scout","D":"Pengakap Malaysia"}'::jsonb, 'B', true),
    (23, 'Nama “pandu” atau “kepanduan” dicetuskan oleh …', '', '{"A":"Ki Hajar Dewantara","B":"KH. Agus Salim","C":"Baden Powell","D":"Ernest Thompson"}'::jsonb, 'B', true),
    (24, 'Ki Hajar Dewantara lahir pada tanggal …', '', '{"A":"20 Mei 1908","B":"2 Mei 1889","C":"14 Agustus 1961","D":"12 April 1888"}'::jsonb, 'B', true),
    (25, 'Kantor pusat biro kepanduan dunia berada di …', '', '{"A":"London","B":"New York","C":"Jenewa","D":"Tokyo"}'::jsonb, 'C', true),
    (26, 'Lagu perang pandu suku Zulu berjudul …', '', '{"A":"Scout Law","B":"Eengonyama","C":"Mafeking","D":"Impeesa"}'::jsonb, 'B', true),
    (27, 'Pertemuan besar untuk Pramuka Penggalang disebut …', '', '{"A":"Raimuna","B":"Wirakarya","C":"Jambore","D":"Muspanitera"}'::jsonb, 'C', true),
    (28, 'Pertemuan untuk Pramuka Penegak disebut …', '', '{"A":"Raimuna","B":"LT","C":"Dianpinru","D":"Pesta Siaga"}'::jsonb, 'A', true),
    (29, 'Saka yang bergerak di bidang kelautan adalah …', '', '{"A":"Saka Bhayangkara","B":"Saka Wira Kartika","C":"Saka Bahari","D":"Saka Husada"}'::jsonb, 'C', true),
    (30, 'Motto pandu adalah …', '', '{"A":"Always Ready","B":"Be Prepared","C":"Scout Spirit","D":"One Scout"}'::jsonb, 'B', true),
    (31, 'Perang Dunia II berlangsung pada tahun …', '', '{"A":"1914–1918","B":"1920–1925","C":"1939–1945","D":"1945–1950"}'::jsonb, 'C', true),
    (32, 'Cub Scout berarti …', '', '{"A":"Penggalang","B":"Penegak","C":"Siaga","D":"Pandega"}'::jsonb, 'C', true),
    (33, 'Boy Scout berarti …', '', '{"A":"Penegak","B":"Penggalang","C":"Siaga","D":"Pandega"}'::jsonb, 'B', true),
    (34, 'Rover Scout berarti …', '', '{"A":"Penegak","B":"Siaga","C":"Penggalang","D":"Pandega"}'::jsonb, 'A', true),
    (35, 'Dua organisasi besar kepanduan dunia adalah …', '', '{"A":"ASEAN dan UNICEF","B":"WOSM dan WAGGGS","C":"WHO dan UNESCO","D":"FIFA dan IOC"}'::jsonb, 'B', true),
    (36, 'Kepanjangan WOSM adalah …', '', '{"A":"World Organization of Scout Members","B":"World Organization of the Scout Movement","C":"World Scout Organization Movement","D":"World Scout Official Movement"}'::jsonb, 'B', true),
    (37, 'Kepanjangan WAGGGS adalah …', '', '{"A":"World Association of Girl Guides and Girl Scouts","B":"World Girl Scout Group","C":"Women Association Guide Group","D":"World Guide Scout Society"}'::jsonb, 'A', true),
    (38, 'Istilah kepanduan di Malaysia disebut …', '', '{"A":"Scout Malaysia","B":"Persekutuan Pengakap Malaysia","C":"Bharat Scout","D":"Scout Filipina"}'::jsonb, 'B', true),
    (39, 'Sebutan Pramuka di Amerika Serikat adalah …', '', '{"A":"Bharat Scout","B":"Scout Singapore","C":"Boy Scout of America","D":"Kapatiran Scout"}'::jsonb, 'C', true),
    (40, 'Sumpah pandu disebut …', '', '{"A":"Scout Law","B":"Scout Promise","C":"Scout Oath","D":"Scout Motto"}'::jsonb, 'B', true),
    (41, 'Hukum pandu disebut …', '', '{"A":"Scout Law","B":"Scout Promise","C":"Scout Motto","D":"Scout Skill"}'::jsonb, 'A', true),
    (42, 'BP mengadakan perkemahan di Pulau Brownsea pada tahun …', '', '{"A":"1905","B":"1906","C":"1907","D":"1908"}'::jsonb, 'C', true),
    (43, 'BP mendapatkan julukan IMPEESA dari suku …', '', '{"A":"Maya","B":"Viking","C":"Zulu","D":"Sparta"}'::jsonb, 'C', true),
    (44, 'Arti IMPEESA adalah …', '', '{"A":"Harimau pemberani","B":"Serigala yang tidak pernah tidur","C":"Penjaga hutan","D":"Singa perkasa"}'::jsonb, 'B', true),
    (45, 'Kota Mafeking dikepung bangsa Boer selama …', '', '{"A":"100 hari","B":"150 hari","C":"217 hari","D":"300 hari"}'::jsonb, 'C', true),
    (46, 'Cara memeriksa kesadaran korban adalah …', '', '{"A":"Menekan kaki korban","B":"Memberi minuman","C":"Panggil dan raba bahu","D":"Menidurkan korban"}'::jsonb, 'C', true),
    (47, 'Langkah awal mengatasi patah tulang adalah …', '', '{"A":"Mengurut bagian patah","B":"Stabilkan dengan perban","C":"Memberikan makanan","D":"Memindahkan korban"}'::jsonb, 'B', true),
    (48, 'Tindakan tepat untuk korban pingsan adalah …', '', '{"A":"Membiarkan korban duduk","B":"Memberikan kopi","C":"Buka jalan napas dan posisi miring","D":"Mengguncang tubuh korban"}'::jsonb, 'C', true),
    (49, 'Kain pembalut segitiga disebut juga …', '', '{"A":"Kasa","B":"Mitela","C":"Tandu","D":"Spalk"}'::jsonb, 'B', true),
    (50, 'Pembidaian disebut juga …', '', '{"A":"Faksasi","B":"Evakuasi","C":"Resusitasi","D":"Akupuntur"}'::jsonb, 'A', true),
    (51, 'Penyakit malaria jenis Quartana disebabkan oleh Plasmodium …', '', '{"A":"Falciparum","B":"Vivax","C":"Malariae","D":"Ovale"}'::jsonb, 'C', true),
    (52, 'Bakteri tifus menyerang sistem …', '', '{"A":"Pernapasan","B":"Pencernaan","C":"Peredaran darah","D":"Saraf"}'::jsonb, 'B', true),
    (53, 'Untuk obat dalam, kotak P3K diberi warna …', '', '{"A":"Merah","B":"Hijau","C":"Putih","D":"Kuning"}'::jsonb, 'C', true),
    (54, 'Metode napas buatan untuk korban tenggelam adalah metode …', '', '{"A":"Mouth to Mouth","B":"Heimlich","C":"Hoger Nielsen","D":"CPR"}'::jsonb, 'C', true),
    (55, 'Obat penyakit malaria adalah …', '', '{"A":"Paracetamol","B":"Pil kina","C":"Amoxicillin","D":"Antasida"}'::jsonb, 'B', true),
    (56, 'Bebat putar untuk menahan pendarahan besar disebut …', '', '{"A":"Kasa","B":"Mitela","C":"Tourniquet","D":"Spalk"}'::jsonb, 'C', true),
    (57, 'Menurunnya suhu tubuh akibat cuaca sangat dingin disebut …', '', '{"A":"Dehidrasi","B":"Hipotermia","C":"Dislokasi","D":"Demam"}'::jsonb, 'B', true),
    (58, 'Kain tipis dan lembut untuk pembalut luka disebut …', '', '{"A":"Kasa steril","B":"Kapas","C":"Mitela","D":"Tandu"}'::jsonb, 'A', true),
    (59, 'Posisi tulang pada sendi yang tidak pada tempat semestinya disebut …', '', '{"A":"Fraktur","B":"Dislokasi","C":"Hipotermia","D":"Infeksi"}'::jsonb, 'B', true),
    (60, 'Virus yang menyerang kekebalan tubuh manusia adalah …', '', '{"A":"Influenza","B":"HIV","C":"TBC","D":"Malaria"}'::jsonb, 'B', true),
    (61, 'Pengobatan tradisional dengan cara tusuk jarum disebut …', '', '{"A":"Akupresur","B":"Akupuntur","C":"Massage","D":"Refleksi"}'::jsonb, 'B', true),
    (62, 'Air splint disebut juga …', '', '{"A":"Bantalan udara","B":"Pembalut luka","C":"Perban elastis","D":"Kasa steril"}'::jsonb, 'A', true),
    (63, 'Obat perangsang bagi orang pingsan adalah …', '', '{"A":"Alkohol","B":"Cairan amoniak","C":"Yodium","D":"Kina"}'::jsonb, 'B', true),
    (64, 'Alat untuk mengangkut korban cedera disebut …', '', '{"A":"Spalk","B":"Mitela","C":"Tandu","D":"Kasa"}'::jsonb, 'C', true),
    (65, 'Prinsip utama dalam P3K adalah …', '', '{"A":"Cepat dan tepat","B":"Hidupkan, bantu, laporkan","C":"Selamatkan korban","D":"Evakuasi cepat"}'::jsonb, 'B', true),
    (66, 'Patung Sphinx kebanyakan terdapat di negara …', '', '{"A":"Yunani","B":"Italia","C":"Mesir","D":"India"}'::jsonb, 'C', true),
    (67, 'Ibu kota Provinsi Banten adalah …', '', '{"A":"Tangerang","B":"Cilegon","C":"Serang","D":"Pandeglang"}'::jsonb, 'C', true),
    (68, 'Gunung tertinggi di dunia adalah …', '', '{"A":"Kilimanjaro","B":"Everest","C":"Fuji","D":"Himalaya"}'::jsonb, 'B', true),
    (69, 'Motto pendidikan “Tut Wuri Handayani” berasal dari …', '', '{"A":"WHO","B":"P dan K","C":"ASEAN","D":"UNICEF"}'::jsonb, 'B', true),
    (70, 'Kepanjangan WHO adalah …', '', '{"A":"World Health Organization","B":"World Human Organization","C":"World Healthy Official","D":"World Hospital Organization"}'::jsonb, 'A', true),
    (71, 'Pusat peredaran tata surya adalah …', '', '{"A":"Bulan","B":"Mars","C":"Matahari","D":"Bumi"}'::jsonb, 'C', true),
    (72, 'Bunga nasional Belanda adalah …', '', '{"A":"Mawar","B":"Sakura","C":"Tulip Oranye","D":"Melati"}'::jsonb, 'C', true),
    (73, 'Pohon yang melambangkan hari Natal adalah pohon …', '', '{"A":"Mangga","B":"Cemara","C":"Kelapa","D":"Beringin"}'::jsonb, 'B', true),
    (74, 'Vitamin yang banyak terkandung dalam buah-buahan adalah vitamin …', '', '{"A":"A","B":"B","C":"C","D":"D"}'::jsonb, 'C', true),
    (75, 'Mata uang negara Jepang adalah …', '', '{"A":"Won","B":"Yen","C":"Ringgit","D":"Yuan"}'::jsonb, 'B', true),
    (76, 'Ibu kota Rusia adalah …', '', '{"A":"Beijing","B":"Seoul","C":"Moscow","D":"Tokyo"}'::jsonb, 'C', true),
    (77, 'Nama resmi negara Belanda adalah …', '', '{"A":"Holland","B":"Netherland","C":"Dutchland","D":"Belgia"}'::jsonb, 'B', true),
    (78, 'Penemu radio berasal dari negara …', '', '{"A":"Jerman","B":"Inggris","C":"Italia","D":"Jepang"}'::jsonb, 'C', true),
    (79, 'Binatang yang dapat hidup di air dan di darat disebut …', '', '{"A":"Mamalia","B":"Reptil","C":"Amfibi","D":"Herbivora"}'::jsonb, 'C', true),
    (80, 'Tumbuhan berduri yang tumbuh di daerah gurun disebut …', '', '{"A":"Mawar","B":"Kaktus","C":"Cemara","D":"Teratai"}'::jsonb, 'B', true),
    (81, 'Negara keempat terluas di dunia adalah …', '', '{"A":"Rusia","B":"Kanada","C":"China","D":"Amerika Serikat"}'::jsonb, 'D', true),
    (82, 'Monumen terkenal di kota Paris adalah …', '', '{"A":"Big Ben","B":"Menara Eiffel","C":"Colosseum","D":"Patung Liberty"}'::jsonb, 'B', true),
    (83, 'Bahan bakar kereta api zaman dahulu adalah …', '', '{"A":"Minyak tanah","B":"Batu bara","C":"Solar","D":"Gas"}'::jsonb, 'B', true),
    (84, 'Satpol PP adalah singkatan dari …', '', '{"A":"Satuan Polisi Perkotaan","B":"Satuan Polisi Pamong Praja","C":"Satuan Pengamanan Publik","D":"Polisi Pemerintah Pusat"}'::jsonb, 'B', true),
    (85, 'Julukan Kota Surabaya adalah …', '', '{"A":"Kota Kembang","B":"Kota Pelajar","C":"Kota Pahlawan","D":"Kota Hujan"}'::jsonb, 'C', true),
    (86, 'Sumpah yang diucapkan Patih Gajah Mada disebut …', '', '{"A":"Sumpah Pemuda","B":"Sumpah Setia","C":"Sumpah Palapa","D":"Sumpah Prajurit"}'::jsonb, 'C', true),
    (87, 'Kerajaan Tarumanagara terletak di …', '', '{"A":"Jawa Tengah","B":"Jawa Barat","C":"Sumatera","D":"Kalimantan"}'::jsonb, 'B', true),
    (88, 'Penemu telepon adalah …', '', '{"A":"Thomas Edison","B":"Isaac Newton","C":"Alexander Graham Bell","D":"Galileo Galilei"}'::jsonb, 'C', true),
    (89, 'Ilmu yang mempelajari alam semesta disebut …', '', '{"A":"Geologi","B":"Biologi","C":"Astronomi","D":"Ekonomi"}'::jsonb, 'C', true),
    (90, 'Samsung adalah perusahaan yang berasal dari negara …', '', '{"A":"Jepang","B":"China","C":"Korea Selatan","D":"Amerika"}'::jsonb, 'C', true),
    (91, 'Tsunami Aceh terjadi pada tanggal …', '', '{"A":"17 Agustus","B":"26 Desember","C":"10 November","D":"1 Juni"}'::jsonb, 'B', true),
    (92, 'Menara Pisa terletak di negara …', '', '{"A":"Prancis","B":"Italia","C":"Inggris","D":"Belanda"}'::jsonb, 'B', true),
    (93, 'Presiden pertama Indonesia adalah …', '', '{"A":"Soeharto","B":"B.J. Habibie","C":"Ir. Soekarno","D":"Joko Widodo"}'::jsonb, 'C', true),
    (94, 'Bunga nasional yang dijuluki puspa pesona adalah …', '', '{"A":"Mawar","B":"Anggrek Bulan","C":"Melati","D":"Tulip"}'::jsonb, 'B', true),
    (95, 'Negara pertama yang mengakui kedaulatan Republik Indonesia adalah …', '', '{"A":"Jepang","B":"Belanda","C":"Mesir","D":"Amerika Serikat"}'::jsonb, 'C', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('soal simulasi bank soal day 13');
select count(*) as jumlah_soal_day13 from public.questions where exam_id = (select id from public.exams where lower(title) = lower('soal simulasi bank soal day 13') order by created_at asc limit 1);