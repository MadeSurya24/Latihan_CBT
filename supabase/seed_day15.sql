-- Seed paket soal dari: SOAL SIMULSI BANK SOAL DAY 15.docx
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- File ini membuat/memperbarui paket: SIMULASI DAY 15
-- Jika paket dengan judul yang sama sudah ada, soal lama pada paket itu akan diganti agar tidak dobel.

with existing_exam as (
  select id
  from public.exams
  where lower(title) = lower('SIMULASI DAY 15')
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
  select 'SIMULASI DAY 15', 'Simulasi Pengetahuan Umum', 120, true
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
    (1, 'Pusat peredaran tata surya adalah ....', '', '{"A":"Bulan","B":"Matahari","C":"Mars","D":"Bintang"}'::jsonb, 'B', true),
    (2, 'Bunga nasional Belanda adalah ....', '', '{"A":"Mawar","B":"Anggrek","C":"Tulip Oranye","D":"Melati"}'::jsonb, 'C', true),
    (3, 'Pohon yang melambangkan hari Natal adalah ....', '', '{"A":"Kelapa","B":"Cemara","C":"Mangga","D":"Jati"}'::jsonb, 'B', true),
    (4, 'Vitamin yang banyak terkandung dalam buah-buahan adalah ....', '', '{"A":"Vitamin A","B":"Vitamin B","C":"Vitamin C","D":"Vitamin D"}'::jsonb, 'C', true),
    (5, 'Mata uang negara Jepang adalah ....', '', '{"A":"Won","B":"Ringgit","C":"Yen","D":"Peso"}'::jsonb, 'C', true),
    (6, 'Ibu kota Rusia adalah ....', '', '{"A":"Tokyo","B":"Moscow","C":"Beijing","D":"Seoul"}'::jsonb, 'B', true),
    (7, 'Nama resmi negara Belanda adalah ....', '', '{"A":"Holland","B":"Netherland","C":"Denmark","D":"Belgia"}'::jsonb, 'B', true),
    (8, 'Penemu radio berasal dari negara ....', '', '{"A":"Jepang","B":"Jerman","C":"Italia","D":"Inggris"}'::jsonb, 'C', true),
    (9, 'Binatang yang bisa hidup di air dan di darat disebut ....', '', '{"A":"Mamalia","B":"Reptil","C":"Amfibi","D":"Herbivora"}'::jsonb, 'C', true),
    (10, 'Tumbuhan berduri yang tumbuh di daerah gurun disebut ....', '', '{"A":"Mawar","B":"Kaktus","C":"Bambu","D":"Pakis"}'::jsonb, 'B', true),
    (11, 'Negara keempat terluas di dunia adalah ....', '', '{"A":"Rusia","B":"Kanada","C":"Cina","D":"Amerika Serikat"}'::jsonb, 'D', true),
    (12, 'Jenis kumbang terbesar adalah ....', '', '{"A":"Badak","B":"Hercules","C":"Goliath","D":"Tanduk"}'::jsonb, 'C', true),
    (13, 'Monumen terkenal di kota Paris adalah ....', '', '{"A":"Big Ben","B":"Menara Pisa","C":"Menara Eiffel","D":"Patung Liberty"}'::jsonb, 'C', true),
    (14, 'Bahan bakar kereta api zaman dahulu adalah ....', '', '{"A":"Solar","B":"Bensin","C":"Batu bara","D":"Gas"}'::jsonb, 'C', true),
    (15, 'Hewan terkecil adalah ....', '', '{"A":"Semut","B":"Amuba","C":"Kutu","D":"Lalat"}'::jsonb, 'B', true),
    (16, 'Satpol PP adalah singkatan dari ....', '', '{"A":"Satuan Polisi Perkotaan","B":"Satuan Polisi Pedesaan","C":"Satuan Polisi Pamong Praja","D":"Satuan Polisi Pemerintah"}'::jsonb, 'C', true),
    (17, 'Kota paling boros listrik di Asia adalah ....', '', '{"A":"Jakarta","B":"Seoul","C":"Tokyo","D":"Bangkok"}'::jsonb, 'C', true),
    (18, 'Julukan Kota Surabaya adalah ....', '', '{"A":"Kota Kembang","B":"Kota Gudeg","C":"Kota Pahlawan","D":"Kota Pelajar"}'::jsonb, 'C', true),
    (19, 'Sumpah yang diucapkan Patih Gajah Mada disebut ....', '', '{"A":"Sumpah Pemuda","B":"Sumpah Palapa","C":"Sumpah Prajurit","D":"Sumpah Setia"}'::jsonb, 'B', true),
    (20, 'Kerajaan Tarumanagara terletak di ....', '', '{"A":"Jawa Timur","B":"Jawa Tengah","C":"Jawa Barat","D":"Bali"}'::jsonb, 'C', true),
    (21, 'Motto TNI AL adalah ....', '', '{"A":"Kartika Eka Paksi","B":"Rastra Sewakottama","C":"Jalesveva Jayamahe","D":"Swa Bhuana Paksa"}'::jsonb, 'C', true),
    (22, 'Arti dari "Rastra Sewakottama" adalah ....', '', '{"A":"Sayap Tanah Air","B":"Abdi Utama bagi Nusantara","C":"Kekuatan dan Kesatuan","D":"Di Laut Kita Jaya"}'::jsonb, 'B', true),
    (23, 'ASEAN adalah singkatan dari ....', '', '{"A":"Association of South East Asia Nation","B":"Asia South East Nation","C":"Association South East Nation","D":"Asia Europe Nation"}'::jsonb, 'A', true),
    (24, 'UNICEF merupakan badan dunia untuk ....', '', '{"A":"Pendidikan","B":"Kesehatan","C":"Anak-anak","D":"Pertanian"}'::jsonb, 'C', true),
    (25, 'WHO adalah organisasi dunia di bidang ....', '', '{"A":"Pendidikan","B":"Kesehatan","C":"Ekonomi","D":"Pertanian"}'::jsonb, 'B', true),
    (26, 'Nama latin gajah adalah ....', '', '{"A":"Bos sundaicus","B":"Elephas indicus","C":"Panthera pardus","D":"Dugong dugong"}'::jsonb, 'B', true),
    (27, 'Nama latin burung merak adalah ....', '', '{"A":"Pavo muticus","B":"Crocodylus novaeguineae","C":"Trugulus","D":"Muntiacus muncak"}'::jsonb, 'A', true),
    (28, 'Kimono adalah pakaian tradisional dari negara ....', '', '{"A":"Cina","B":"Korea","C":"Jepang","D":"India"}'::jsonb, 'C', true),
    (29, 'Hovercraft adalah kendaraan yang bergerak di atas ....', '', '{"A":"Rel","B":"Udara dan air","C":"Jalan raya","D":"Pasir"}'::jsonb, 'B', true),
    (30, 'Life-buoy digunakan sebagai ....', '', '{"A":"Alat komunikasi","B":"Pelampung pengaman","C":"Mesin kapal","D":"Alat menyelam"}'::jsonb, 'B', true),
    (31, 'Pelanggaran tentang orang yang perlu ditolong diatur dalam pasal ....', '', '{"A":"Pasal 351 KUHP","B":"Pasal 531 KUHP","C":"Pasal 245 KUHP","D":"Pasal 400 KUHP"}'::jsonb, 'B', true),
    (32, 'Yang termasuk efek luka bakar adalah ....', '', '{"A":"Efek dingin terhadap kulit","B":"Efek panas terhadap kulit","C":"Efek air terhadap kulit","D":"Efek angin terhadap kulit"}'::jsonb, 'B', true),
    (33, 'Luka bakar tingkat 1 ditandai dengan ....', '', '{"A":"Kulit hangus","B":"Tulang terlihat","C":"Kulit kemerahan","D":"Luka berdarah"}'::jsonb, 'C', true),
    (34, 'Luka bakar tingkat 2 ditandai dengan ....', '', '{"A":"Kulit melepuh dan bengkak","B":"Kulit hangus seluruhnya","C":"Tidak terasa nyeri","D":"Luka hanya kecil"}'::jsonb, 'A', true),
    (35, 'Luka bakar tingkat 3 merupakan luka bakar yang ....', '', '{"A":"Hanya mengenai kulit luar","B":"Kulit terasa dingin","C":"Pembakaran sampai bagian dalam tubuh","D":"Tidak menimbulkan kerusakan"}'::jsonb, 'C', true),
    (36, 'Dua jenis luka berdasarkan tempatnya adalah ....', '', '{"A":"Luka panas dan dingin","B":"Luka ringan dan berat","C":"Luka dalam dan luka luar","D":"Luka kecil dan besar"}'::jsonb, 'C', true),
    (37, 'Obat pengganti tablet norit adalah ....', '', '{"A":"Gula pasir","B":"Garam dapur","C":"Arang dapur halus","D":"Minyak kayu putih"}'::jsonb, 'C', true),
    (38, 'Imunisasi untuk penyakit difteri adalah ....', '', '{"A":"BCG","B":"DPT","C":"Polio","D":"Campak"}'::jsonb, 'B', true),
    (39, 'Pengobatan tradisional dengan cara tusuk jarum disebut ....', '', '{"A":"Refleksi","B":"Hipnoterapi","C":"Akupuntur","D":"Aromaterapi"}'::jsonb, 'C', true),
    (40, 'Pengobatan dengan cara massage disebut juga ....', '', '{"A":"Pijitan","B":"Suntikan","C":"Operasi","D":"Kompres"}'::jsonb, 'A', true),
    (41, 'Buah limau dapat digunakan sebagai obat ....', '', '{"A":"Batuk","B":"Demam","C":"Sakit gigi","D":"Pusing"}'::jsonb, 'B', true),
    (42, 'Air splint disebut juga ....', '', '{"A":"Bantalan air","B":"Bantalan udara","C":"Pelindung tangan","D":"Pembalut luka"}'::jsonb, 'B', true),
    (43, 'Membengkak, kulit membiru, dan nyeri hebat merupakan gejala ....', '', '{"A":"Flu","B":"Luka ringan","C":"Patah tulang","D":"Demam"}'::jsonb, 'C', true),
    (44, 'Obat perangsang bagi orang pingsan adalah ....', '', '{"A":"Alkohol","B":"Cairan amoniak","C":"Air garam","D":"Minyak goreng"}'::jsonb, 'B', true),
    (45, 'Obat-obatan tradisional adalah pengobatan yang menggunakan ....', '', '{"A":"Mesin modern","B":"Bahan kimia","C":"Bahan alami","D":"Alat listrik"}'::jsonb, 'C', true),
    (46, 'Fungsi utama tandu dalam P3K adalah untuk ....', '', '{"A":"Menyimpan obat","B":"Mengangkut korban dengan aman","C":"Mengukur suhu tubuh","D":"Membersihkan luka"}'::jsonb, 'B', true),
    (47, 'Jenis tandu yang biasa digunakan dalam P3K adalah ....', '', '{"A":"Tandu lipat","B":"Tandu besi","C":"Tandu kayu bakar","D":"Tandu plastik kecil"}'::jsonb, 'A', true),
    (48, 'Penyakit menular adalah penyakit yang dapat ....', '', '{"A":"Hilang sendiri","B":"Menyebar ke orang lain","C":"Membuat tubuh tinggi","D":"Menambah berat badan"}'::jsonb, 'B', true),
    (49, 'Pencegahan penularan penyakit dalam P3K dilakukan dengan menggunakan ....', '', '{"A":"Topi","B":"Kacamata hitam","C":"APD seperti sarung tangan","D":"Payung"}'::jsonb, 'C', true),
    (50, 'Gejala penyakit menular dapat berupa ....', '', '{"A":"Demam dan batuk","B":"Rambut panjang","C":"Kulit cerah","D":"Nafsu makan besar"}'::jsonb, 'A', true),
    (51, 'Delapan arah mata angin disebut arah mata angin ....', '', '{"A":"Lengkap","B":"Pokok","C":"Utama","D":"Tambahan"}'::jsonb, 'C', true),
    (52, 'Enam belas arah mata angin disebut arah mata angin ....', '', '{"A":"Lengkap","B":"Pokok","C":"Dasar","D":"Tengah"}'::jsonb, 'A', true),
    (53, 'Kompas tidak boleh didekatkan dengan benda elektronik karena dapat mengganggu ....', '', '{"A":"Peta","B":"Jarum kompas","C":"Skala","D":"Warna kompas"}'::jsonb, 'B', true),
    (54, 'Utara pada kompas disebut juga utara ....', '', '{"A":"Sejati","B":"Timur","C":"Magnet","D":"Barat"}'::jsonb, 'C', true),
    (55, 'Utara yang sebenarnya sesuai poros bumi disebut utara ....', '', '{"A":"Magnet","B":"Sejati","C":"Kompas","D":"Palsu"}'::jsonb, 'B', true),
    (56, 'Selisih antara utara magnet dan utara sejati disebut ....', '', '{"A":"Deviasi","B":"Navigasi","C":"Deklinasi","D":"Orientasi"}'::jsonb, 'C', true),
    (57, 'Pada malam hari arah utara dapat ditentukan dengan melihat bintang ....', '', '{"A":"Sirius","B":"Orion","C":"Polaris","D":"Scorpio"}'::jsonb, 'C', true),
    (58, 'Sudut kompas dihitung searah dengan arah putaran ....', '', '{"A":"Bumi","B":"Jarum jam","C":"Matahari","D":"Angin"}'::jsonb, 'B', true),
    (59, 'Bagian kompas yang berisi angka derajat disebut ....', '', '{"A":"Jarum","B":"Tutup","C":"Skala","D":"Kaca"}'::jsonb, 'C', true),
    (60, 'Membaca arah dengan kompas ke suatu objek disebut ....', '', '{"A":"Menaksir","B":"Mengukur","C":"Membidik","D":"Menggambar"}'::jsonb, 'C', true),
    (61, 'Jarum kompas biasanya berwarna merah pada bagian yang menunjuk ke arah ....', '', '{"A":"Selatan","B":"Timur","C":"Barat","D":"Utara"}'::jsonb, 'D', true),
    (62, 'Kompas pertama kali ditemukan di negara ....', '', '{"A":"Jepang","B":"India","C":"Tiongkok","D":"Mesir"}'::jsonb, 'C', true),
    (63, 'Kegiatan mencari jejak dengan peta dan kompas disebut ....', '', '{"A":"Tracking","B":"Orienteering","C":"Hiking","D":"Camping"}'::jsonb, 'B', true),
    (64, 'Jika kompas menunjukkan 180 derajat, maka kita menghadap ke arah ....', '', '{"A":"Utara","B":"Timur","C":"Barat","D":"Selatan"}'::jsonb, 'D', true),
    (65, 'Huruf N pada kompas merupakan singkatan dari ....', '', '{"A":"North","B":"New","C":"Nether","D":"Normal"}'::jsonb, 'A', true),
    (66, 'Siapa bapak Pramuka Indonesia?', '', '{"A":"Ir. Soekarno","B":"Sri Sultan Hamengkubuwono IX","C":"Ki Hajar Dewantara","D":"Mohammad Hatta"}'::jsonb, 'B', true),
    (67, 'Pramuka merupakan singkatan dari ....', '', '{"A":"Prajurit Muda Karana","B":"Praja Muda Karana","C":"Pemuda Maju Berkarya","D":"Praja Muda Nusantara"}'::jsonb, 'B', true),
    (68, 'Siapa istri Baden Powell?', '', '{"A":"Agnes Baden Powell","B":"Olave St. Clair Soames","C":"Ratu Elizabeth","D":"Lady Diana"}'::jsonb, 'B', true),
    (69, 'Peristiwa yang menjiwai majunya Gerakan Pramuka adalah ....', '', '{"A":"Proklamasi","B":"Sumpah Pemuda","C":"Reformasi","D":"Perang Dunia"}'::jsonb, 'B', true),
    (70, 'Buku "Scouting for Boys" diterbitkan pada tanggal ....', '', '{"A":"15 Januari 1908","B":"22 Februari 1907","C":"14 Agustus 1961","D":"28 Oktober 1928"}'::jsonb, 'A', true),
    (71, 'Urutan tingkatan Pramuka adalah ....', '', '{"A":"Siaga, Penggalang, Penegak, Pandega","B":"Penggalang, Siaga, Penegak, Pandega","C":"Siaga, Penegak, Penggalang, Pandega","D":"Pandega, Penegak, Penggalang, Siaga"}'::jsonb, 'A', true),
    (72, 'Lambang Gerakan Pramuka adalah ....', '', '{"A":"Bintang","B":"Tunas Kelapa","C":"Garuda","D":"Kompas"}'::jsonb, 'B', true),
    (73, 'Motto Gerakan Pramuka adalah ....', '', '{"A":"Sekali Merdeka Tetap Merdeka","B":"Tut Wuri Handayani","C":"Satyaku Kudarmakan, Darmaku Kubaktikan","D":"Bersatu Kita Teguh"}'::jsonb, 'C', true),
    (74, 'Pangkat terakhir Baden Powell adalah ....', '', '{"A":"Mayor","B":"Kolonel","C":"Letnan Jenderal","D":"Kapten"}'::jsonb, 'C', true),
    (75, 'Bahasa Indonesia dari "Scout Promise" adalah ....', '', '{"A":"Dasa Dharma","B":"Tri Satya","C":"Satya Dharma","D":"Janji Pandu"}'::jsonb, 'B', true),
    (76, 'Robert Baden Powell lahir pada tanggal ....', '', '{"A":"14 Agustus 1961","B":"22 Februari 1857","C":"20 Mei 1908","D":"28 Oktober 1928"}'::jsonb, 'B', true),
    (77, 'Panjang tongkat Penggalang adalah ....', '', '{"A":"120 cm","B":"140 cm","C":"160 cm","D":"180 cm"}'::jsonb, 'C', true),
    (78, 'Jambore Dunia pertama diselenggarakan pada tahun ....', '', '{"A":"1910","B":"1920","C":"1930","D":"1945"}'::jsonb, 'B', true),
    (79, 'Jambore Dunia pertama dilaksanakan di ....', '', '{"A":"Paris","B":"Tokyo","C":"London","D":"Jakarta"}'::jsonb, 'C', true),
    (80, 'Siapa pencetus Sistem Among?', '', '{"A":"KH Agus Salim","B":"Soekarno","C":"Ki Hajar Dewantara","D":"Moh. Hatta"}'::jsonb, 'C', true),
    (81, 'Jumlah anggota dalam satu regu Penggalang adalah ....', '', '{"A":"2-4 orang","B":"4-5 orang","C":"6-8 orang","D":"10-12 orang"}'::jsonb, 'C', true),
    (82, 'Sebutan pemimpin regu Penggalang adalah ....', '', '{"A":"Ketua Sangga","B":"Pemimpin Regu","C":"Pradana","D":"Ketua Barung"}'::jsonb, 'B', true),
    (83, 'Kode warna Pramuka Penggalang adalah warna ....', '', '{"A":"Hijau","B":"Biru","C":"Merah","D":"Kuning"}'::jsonb, 'C', true),
    (84, 'TKK dalam Pramuka adalah singkatan dari ....', '', '{"A":"Tanda Kegiatan Khusus","B":"Tanda Kecakapan Khusus","C":"Tanda Keahlian Khusus","D":"Tanda Kemampuan Khusus"}'::jsonb, 'B', true),
    (85, 'Organisasi yang menjadi latar belakang Gerakan Pramuka adalah ....', '', '{"A":"Sarekat Islam","B":"Boedi Oetomo","C":"PNI","D":"Muhammadiyah"}'::jsonb, 'B', true),
    (86, 'Boedi Oetomo didirikan pada tanggal ....', '', '{"A":"20 Mei 1908","B":"28 Oktober 1928","C":"17 Agustus 1945","D":"14 Agustus 1961"}'::jsonb, 'A', true),
    (87, 'Peristiwa Sumpah Pemuda terjadi pada tanggal ....', '', '{"A":"1 Juni 1945","B":"20 Mei 1908","C":"28 Oktober 1928","D":"17 Agustus 1945"}'::jsonb, 'C', true),
    (88, 'Pembina SAKA disebut ....', '', '{"A":"Pradana","B":"Pamong Saka","C":"Pinru","D":"Ketua Regu"}'::jsonb, 'B', true),
    (89, 'Ukuran bendera gugus depan adalah ....', '', '{"A":"50 x 70 cm","B":"60 x 90 cm","C":"80 x 100 cm","D":"100 x 120 cm"}'::jsonb, 'B', true),
    (90, 'Kepanjangan dari JOTA adalah ....', '', '{"A":"Jambore On The Air","B":"Jambore Of The Asia","C":"Join On The Air","D":"Jambore Of The World"}'::jsonb, 'A', true),
    (91, 'Hari Pramuka diperingati setiap tanggal ....', '', '{"A":"17 Agustus","B":"20 Mei","C":"14 Agustus","D":"28 Oktober"}'::jsonb, 'C', true),
    (92, 'Gerakan Pramuka berlandaskan asas ....', '', '{"A":"UUD 1945","B":"Pancasila","C":"Tri Satya","D":"Dasa Dharma"}'::jsonb, 'B', true),
    (93, 'Lagu Gerakan Pramuka adalah ....', '', '{"A":"Indonesia Raya","B":"Hymne Pramuka","C":"Garuda Pancasila","D":"Hari Merdeka"}'::jsonb, 'B', true),
    (94, 'Kepanjangan WOSM adalah ....', '', '{"A":"World Organization of Scout Movement","B":"World Official Scout Member","C":"World Organization Scout Member","D":"World Office Scout Movement"}'::jsonb, 'A', true),
    (95, 'Kepanjangan NIPV adalah ....', '', '{"A":"Nederland Indische Padvinders Vereniging","B":"National Indonesia Pramuka Vereniging","C":"Netherland Indonesia Pandu Vereniging","D":"National International Padvinder Vereniging"}'::jsonb, 'A', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('SIMULASI DAY 15');
select count(*) as jumlah_soal from public.questions where exam_id = (select id from public.exams where lower(title) = lower('SIMULASI DAY 15') order by created_at asc limit 1);
