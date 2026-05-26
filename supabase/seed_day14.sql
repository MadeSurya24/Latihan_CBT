-- Seed paket soal dari: soal simulasi bank soal day 14.docx
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- File ini membuat/memperbarui paket: SIMULASI DAY 14
-- Jika paket dengan judul yang sama sudah ada, soal lama pada paket itu akan diganti agar tidak dobel.

with existing_exam as (
  select id
  from public.exams
  where lower(title) = lower('SIMULASI DAY 14')
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
  select 'SIMULASI DAY 14', 'Simulasi Pengetahuan Umum', 120, true
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
    (1, 'Metode yang digunakan untuk mengevaluasi kondisi korban disebut metode ....', '', '{"A":"RJP","B":"ABC","C":"CPR","D":"PPGD"}'::jsonb, 'B', true),
    (2, 'Kepanjangan dari PPGD adalah ....', '', '{"A":"Penanganan Pertama Gawat Darurat","B":"Pertolongan Pertama Gawat Darurat","C":"Penyelamatan Pertama Gawat Darurat","D":"Perawatan Pertama Gawat Darurat"}'::jsonb, 'B', true),
    (3, 'Air splint disebut juga ....', '', '{"A":"Kasa steril","B":"Mitela","C":"Bantalan udara","D":"Bebat tekan"}'::jsonb, 'C', true),
    (4, 'Nama lain dari pembidaian adalah ....', '', '{"A":"Sterilisasi","B":"Fiksasi","C":"Evakuasi","D":"Isolasi"}'::jsonb, 'B', true),
    (5, 'Pembalut segitiga disebut juga ....', '', '{"A":"Tourniquet","B":"Splint","C":"Mitela","D":"Band aid"}'::jsonb, 'C', true),
    (6, 'Salah satu tujuan P3K adalah ....', '', '{"A":"Menambah rasa sakit korban","B":"Mencegah infeksi","C":"Membiarkan korban sendiri","D":"Mengabaikan luka kecil"}'::jsonb, 'B', true),
    (7, 'Penyakit cacar dapat menular melalui ....', '', '{"A":"Makanan","B":"Pernapasan dan kontak badan","C":"Gigitan nyamuk","D":"Air kotor"}'::jsonb, 'B', true),
    (8, 'Orang dewasa memiliki jumlah darah sekitar ....', '', '{"A":"2 liter","B":"4 liter","C":"6,25 liter","D":"10 liter"}'::jsonb, 'C', true),
    (9, 'Warna putih pada etiket obat menandakan obat ....', '', '{"A":"Beracun","B":"Luar","C":"Dalam","D":"Suntik"}'::jsonb, 'C', true),
    (10, 'Salah satu gejala luka bakar tingkat 2 adalah ....', '', '{"A":"Kulit membiru","B":"Kulit melepuh","C":"Tulang terlihat","D":"Tidak terasa sakit"}'::jsonb, 'B', true),
    (11, 'Penyebab penyakit pes adalah ....', '', '{"A":"Virus","B":"Jamur","C":"Bakteri dari tikus","D":"Nyamuk"}'::jsonb, 'C', true),
    (12, 'Pembalut tekan disebut juga ....', '', '{"A":"Pressure bandage","B":"Splint","C":"Mitela","D":"Air splint"}'::jsonb, 'A', true),
    (13, 'Rumah sakit Cicendo merupakan rumah sakit spesialis ....', '', '{"A":"Jantung","B":"Anak","C":"Mata","D":"Kulit"}'::jsonb, 'C', true),
    (14, 'Virus yang menyerang kekebalan tubuh manusia adalah ....', '', '{"A":"TBC","B":"HIV","C":"Malaria","D":"Difteri"}'::jsonb, 'B', true),
    (15, 'Jika terjadi pendarahan ringan, tindakan yang benar adalah ....', '', '{"A":"Dibiarkan","B":"Ditiup","C":"Ditekan dengan kain bersih","D":"Diberi air panas"}'::jsonb, 'C', true),
    (16, 'Pengobatan tradisional dengan tusuk jarum disebut ....', '', '{"A":"Pijit","B":"Akupuntur","C":"Herbal","D":"Aromaterapi"}'::jsonb, 'B', true),
    (17, 'Sel darah putih berfungsi untuk ....', '', '{"A":"Membawa oksigen","B":"Membantu pernapasan","C":"Melawan kuman penyakit","D":"Membekukan darah"}'::jsonb, 'C', true),
    (18, 'Menurunnya suhu tubuh akibat cuaca sangat dingin disebut ....', '', '{"A":"Hipertensi","B":"Dislokasi","C":"Hipotermia","D":"Infeksi"}'::jsonb, 'C', true),
    (19, 'Metode napas buatan untuk korban tenggelam adalah metode ....', '', '{"A":"ABC","B":"Heimlich","C":"Hoger Nielsen","D":"Tourniquet"}'::jsonb, 'C', true),
    (20, 'Imunisasi untuk mencegah penyakit difteri adalah ....', '', '{"A":"BCG","B":"Polio","C":"DPT","D":"Campak"}'::jsonb, 'C', true),
    (21, 'Motto TNI Angkatan Laut adalah ....', '', '{"A":"Kartika Eka Paksi","B":"Rastra Sewakottama","C":"Jalesveva Jayamahe","D":"Swa Bhuwana Paksa"}'::jsonb, 'C', true),
    (22, '"Kartika Eka Paksi" merupakan motto dari ....', '', '{"A":"AU","B":"AL","C":"POLRI","D":"AD"}'::jsonb, 'D', true),
    (23, 'Arti dari "Rastra Sewakottama" adalah ....', '', '{"A":"Sayap Tanah Air","B":"Di Laut Kita Jaya","C":"Abdi Utama Bagi Nusantara","D":"Kesatuan dan Kesaktian"}'::jsonb, 'C', true),
    (24, 'Nama latin dari babirusa adalah ....', '', '{"A":"Bos sundaicus","B":"Babirussa babirussa","C":"Panthera pardus","D":"Elephas indicus"}'::jsonb, 'B', true),
    (25, 'Nama latin dari gajah adalah ....', '', '{"A":"Elephas indicus","B":"Dugong dugong","C":"Casuarius casuarius","D":"Trugulus"}'::jsonb, 'A', true),
    (26, 'Nama latin dari harimau Sumatera adalah ....', '', '{"A":"Panthera pardus","B":"Panthera tigris sumatranus","C":"Panthera tigris sundaicus","D":"Rhinoceros sundaicus"}'::jsonb, 'B', true),
    (27, '"Pavo muticus" adalah nama latin dari ....', '', '{"A":"Kasuari","B":"Burung merak","C":"Kijang","D":"Kancil"}'::jsonb, 'B', true),
    (28, 'Nama latin dari buaya adalah ....', '', '{"A":"Crocodylus novaeguineae","B":"Bos sundaicus","C":"Trugulus","D":"Probosciger aterrimus"}'::jsonb, 'A', true),
    (29, 'ASEAN merupakan singkatan dari ....', '', '{"A":"Association of South East Asia Nation","B":"Asian South East Nation","C":"Association South Europe Nation","D":"Asia Education Nation"}'::jsonb, 'A', true),
    (30, 'UNICEF adalah organisasi dunia yang bergerak di bidang ....', '', '{"A":"Buruh internasional","B":"Pendidikan dunia","C":"Anak-anak","D":"Pertanian"}'::jsonb, 'C', true),
    (31, 'WHO merupakan organisasi dunia di bidang ....', '', '{"A":"Pendidikan","B":"Kesehatan","C":"Keuangan","D":"Buruh"}'::jsonb, 'B', true),
    (32, 'Organisasi buruh internasional disebut ....', '', '{"A":"IMF","B":"ILO","C":"FAO","D":"NATO"}'::jsonb, 'B', true),
    (33, 'FAO bergerak di bidang ....', '', '{"A":"Pertahanan","B":"Kesehatan","C":"Pertanian dan pangan","D":"Anak-anak"}'::jsonb, 'C', true),
    (34, 'NATO adalah organisasi ....', '', '{"A":"Kesehatan dunia","B":"Pendidikan dunia","C":"Pertahanan Atlantik Utara","D":"Anak-anak dunia"}'::jsonb, 'C', true),
    (35, 'Huruf Mesir kuno disebut ....', '', '{"A":"Ikon","B":"Hovercraft","C":"Junk","D":"Hieroglyph"}'::jsonb, 'D', true),
    (36, 'Hookah adalah ....', '', '{"A":"Kapal layar","B":"Alat hisap tembakau Indian","C":"Kendaraan air","D":"Simbol tulisan"}'::jsonb, 'B', true),
    (37, 'Hovercraft merupakan ....', '', '{"A":"Perahu layar Cina","B":"Pesawat tempur","C":"Kendaraan air bertenaga angin besar","D":"Kereta api"}'::jsonb, 'C', true),
    (38, 'Kimono adalah pakaian tradisional wanita dari ....', '', '{"A":"Cina","B":"Korea","C":"Jepang","D":"India"}'::jsonb, 'C', true),
    (39, 'Klog adalah ....', '', '{"A":"Pelampung kapal","B":"Sepatu kayu Belanda","C":"Perahu layar","D":"Baju adat"}'::jsonb, 'B', true),
    (40, 'Bintang berekor yang mengitari matahari disebut ....', '', '{"A":"Meteor","B":"Asteroid","C":"Planet","D":"Komet"}'::jsonb, 'D', true),
    (41, 'Life-buoy digunakan sebagai ....', '', '{"A":"Perahu kecil","B":"Pelampung pengaman","C":"Mesin kapal","D":"Ban kendaraan"}'::jsonb, 'B', true),
    (42, 'Kantor berita resmi Indonesia adalah ....', '', '{"A":"Reuters","B":"AFP","C":"Antara","D":"AP"}'::jsonb, 'C', true),
    (43, 'AFP berasal dari negara ....', '', '{"A":"Inggris","B":"Jepang","C":"Perancis","D":"Rusia"}'::jsonb, 'C', true),
    (44, 'Reuters merupakan kantor berita dari ....', '', '{"A":"Inggris","B":"India","C":"Amerika Serikat","D":"Malaysia"}'::jsonb, 'A', true),
    (45, 'Kantor berita Jepang adalah ....', '', '{"A":"Kyodo","B":"Bernama","C":"PAP","D":"IRNA"}'::jsonb, 'A', true),
    (46, 'Bernama adalah kantor berita negara ....', '', '{"A":"India","B":"Malaysia","C":"Iran","D":"Vietnam"}'::jsonb, 'B', true),
    (47, 'PIA merupakan maskapai penerbangan dari ....', '', '{"A":"Pakistan","B":"India","C":"Thailand","D":"Swiss"}'::jsonb, 'A', true),
    (48, 'THAI Airways berasal dari negara ....', '', '{"A":"Singapura","B":"Thailand","C":"Tunisia","D":"Sri Lanka"}'::jsonb, 'B', true),
    (49, 'SIA merupakan singkatan dari ....', '', '{"A":"Singapore International Air","B":"Singapore Airlines","C":"South India Airlines","D":"Scandinavian Airlines"}'::jsonb, 'B', true),
    (50, 'Aeroflot adalah maskapai penerbangan dari ....', '', '{"A":"Rusia","B":"Italia","C":"Swiss","D":"Meksiko"}'::jsonb, 'A', true),
    (51, 'Buku yang ditulis Baden Powell pada tahun 1901 berjudul ....', '', '{"A":"The Jungle Book","B":"Scouting for Boys","C":"Aids to Scouting","D":"Rovering to Success"}'::jsonb, 'C', true),
    (52, 'Pada tahun berapa Baden Powell mendapat undangan dari perkumpulan Boys Brigade?', '', '{"A":"1905","B":"1906","C":"1907","D":"1908"}'::jsonb, 'C', true),
    (53, 'Perkemahan di Pulau Brownsea diikuti oleh ....', '', '{"A":"10 orang","B":"15 orang","C":"20 orang","D":"25 orang"}'::jsonb, 'C', true),
    (54, 'Baden Powell berhenti dari dinas kemiliteran pada tahun ....', '', '{"A":"1908","B":"1910","C":"1912","D":"1920"}'::jsonb, 'B', true),
    (55, 'Pangkat terakhir Baden Powell adalah ....', '', '{"A":"Mayor Jenderal","B":"Kolonel","C":"Letnan Jenderal","D":"Kapten"}'::jsonb, 'C', true),
    (56, 'Baden Powell mulai berkeliling dunia pada tahun ....', '', '{"A":"1910","B":"1911","C":"1912","D":"1913"}'::jsonb, 'C', true),
    (57, 'Baden Powell diangkat sebagai Bapak Pandu Sedunia pada tanggal ....', '', '{"A":"15 Januari 1908","B":"6 Agustus 1920","C":"3 Desember 1934","D":"8 Januari 1941"}'::jsonb, 'B', true),
    (58, 'Baden Powell mengunjungi Batavia (Jakarta) pada tanggal ....', '', '{"A":"6 Agustus 1920","B":"15 Januari 1908","C":"3 Desember 1934","D":"8 Januari 1941"}'::jsonb, 'C', true),
    (59, 'Baden Powell wafat pada tanggal ....', '', '{"A":"8 Januari 1941","B":"6 Agustus 1920","C":"15 Januari 1908","D":"3 Desember 1934"}'::jsonb, 'A', true),
    (60, 'Buku "Scouting for Boys" pertama kali diedarkan pada ....', '', '{"A":"15 Januari 1908","B":"1 Januari 1907","C":"6 Agustus 1920","D":"8 Januari 1941"}'::jsonb, 'A', true),
    (61, 'Kepanduan Siaga didirikan pada tahun ....', '', '{"A":"1908","B":"1910","C":"1912","D":"1916"}'::jsonb, 'D', true),
    (62, 'Buku yang mengilhami kegiatan Siaga adalah ....', '', '{"A":"Aids to Scouting","B":"The Jungle Book","C":"Rovering to Success","D":"Scouting Games"}'::jsonb, 'B', true),
    (63, 'Penulis buku "The Jungle Book" adalah ....', '', '{"A":"Baden Powell","B":"Rudyard Kipling","C":"William McLaren","D":"Horace Cox"}'::jsonb, 'B', true),
    (64, 'Nama anak serigala dalam cerita The Jungle Book adalah ....', '', '{"A":"Bagheera","B":"Baloo","C":"Mowgli","D":"Shere Khan"}'::jsonb, 'C', true),
    (65, 'Bagheera dalam cerita The Jungle Book adalah seekor ....', '', '{"A":"Beruang","B":"Harimau","C":"Serigala","D":"Macan kumbang"}'::jsonb, 'D', true),
    (66, 'Sahabat BP yang memberikan sebidang tanah untuk Gilwell Park adalah ....', '', '{"A":"Rudyard Kipling","B":"William F DeBois McLaren","C":"Horace Cox","D":"Lord Baden"}'::jsonb, 'B', true),
    (67, 'Patung yang ada di Gilwell Park adalah patung ....', '', '{"A":"Elang","B":"Harimau","C":"Singa","D":"Kuda"}'::jsonb, 'C', true),
    (68, 'Gerakan Pramuka menjadi satu-satunya organisasi kepanduan di Indonesia sejak Kepres nomor ....', '', '{"A":"448 Tahun 1961","B":"238 Tahun 1961","C":"174 Tahun 2012","D":"055 Tahun 1982"}'::jsonb, 'B', true),
    (69, 'Skep Panji Gerakan Pramuka adalah nomor ....', '', '{"A":"055 Tahun 1982","B":"448 Tahun 1961","C":"036 Tahun 1979","D":"064 Tahun 2001"}'::jsonb, 'B', true),
    (70, 'Surat keputusan tentang lambang Gerakan Pramuka adalah ....', '', '{"A":"06/KN/72","B":"045/KN/80","C":"132/KN/79","D":"198/KN/2011"}'::jsonb, 'A', true),
    (71, 'Keputusan Kwarnas tentang tanda pengenal adalah nomor ....', '', '{"A":"055 Tahun 1982","B":"036 Tahun 1979","C":"174 Tahun 2012","D":"064 Tahun 2001"}'::jsonb, 'A', true),
    (72, 'Skep tentang tanda pengenal umum adalah ....', '', '{"A":"045/KN/80","B":"059 Tahun 1982","C":"088/KN/74","D":"132/KN/79"}'::jsonb, 'B', true),
    (73, 'SK Kwarnas tentang tanda kecakapan adalah ....', '', '{"A":"174/KN/2012","B":"202/KN/88","C":"088/KN/74 dan 058 Tahun 1982","D":"036/KN/79"}'::jsonb, 'C', true),
    (74, 'SK Kwarnas Nomor 064 Tahun 2001 berisi tentang ....', '', '{"A":"Tanda jabatan","B":"Penarikan diri dari WAGGGS","C":"Tanda pengenal umum","D":"Seragam Pramuka"}'::jsonb, 'B', true),
    (75, 'Skep tentang TKK adalah nomor ....', '', '{"A":"134/KN/76 dan 132 Tahun 1979","B":"055 Tahun 1982","C":"202/KN/88","D":"036/KN/79"}'::jsonb, 'A', true),
    (76, 'Skep seragam Pramuka yang digunakan sekarang adalah ....', '', '{"A":"088/KN/81","B":"174/KN/2012","C":"045/KN/80","D":"132/KN/79"}'::jsonb, 'B', true),
    (77, 'Skep Pramuka Garuda adalah ....', '', '{"A":"045/KN/80 Tahun 1980","B":"036/KN/79 Tahun 1979","C":"202/KN/88 Tahun 1988","D":"198/KN/2011"}'::jsonb, 'A', true),
    (78, 'Jambore Nasional I dilaksanakan di ....', '', '{"A":"Cibubur","B":"Jatinangor","C":"Situ Baru/Jagakarsa","D":"Baturraden"}'::jsonb, 'C', true),
    (79, 'Jambore Nasional VII tahun 2001 dilaksanakan di ....', '', '{"A":"Teluk Gelam","B":"Baturraden","C":"Jatinangor","D":"Cibubur"}'::jsonb, 'B', true),
    (80, 'Jambore Nasional XI tahun 2022 dilaksanakan di ....', '', '{"A":"Buperta Cibubur","B":"Sibolangit","C":"Teluk Gelam","D":"Jatinangor"}'::jsonb, 'A', true),
    (81, 'Apa fungsi utama kompas?', '', '{"A":"Mengukur suhu","B":"Menentukan arah mata angin","C":"Menghitung waktu","D":"Mengukur jarak"}'::jsonb, 'B', true),
    (82, 'Kompas pertama kali ditemukan oleh bangsa ....', '', '{"A":"Jepang","B":"India","C":"Cina","D":"Arab"}'::jsonb, 'C', true),
    (83, 'Bagian kompas yang menunjukkan arah adalah ....', '', '{"A":"Dial","B":"Visir","C":"Jarum magnet","D":"Skala"}'::jsonb, 'C', true),
    (84, 'Arah timur pada kompas berada pada derajat ....', '', '{"A":"0 derajat","B":"90 derajat","C":"180 derajat","D":"270 derajat"}'::jsonb, 'B', true),
    (85, 'Derajat penuh pada kompas adalah ....', '', '{"A":"90 derajat","B":"180 derajat","C":"270 derajat","D":"360 derajat"}'::jsonb, 'D', true),
    (86, 'Arah antara selatan dan barat disebut ....', '', '{"A":"Tenggara","B":"Timur laut","C":"Barat daya","D":"Barat laut"}'::jsonb, 'C', true),
    (87, 'Kompas harus dijauhkan dari benda yang bersifat ....', '', '{"A":"Kayu","B":"Plastik","C":"Magnetik","D":"Kertas"}'::jsonb, 'C', true),
    (88, 'Sudut yang dihitung searah jarum jam dari arah utara disebut ....', '', '{"A":"Deklinasi","B":"Azimuth","C":"Navigasi","D":"Deviasi"}'::jsonb, 'B', true),
    (89, 'Arah 225 derajat menunjukkan arah ....', '', '{"A":"Tenggara","B":"Barat laut","C":"Barat daya","D":"Timur laut"}'::jsonb, 'C', true),
    (90, 'Bagian kompas yang digunakan untuk membidik sasaran disebut ....', '', '{"A":"Visir","B":"Dial","C":"Skala","D":"Pengait"}'::jsonb, 'A', true),
    (91, 'Kompas harus diletakkan secara .... saat digunakan.', '', '{"A":"Tegak","B":"Miring","C":"Datar","D":"Vertikal"}'::jsonb, 'C', true),
    (92, 'Huruf N pada kompas berarti ....', '', '{"A":"North","B":"New","C":"Nether","D":"Night"}'::jsonb, 'A', true),
    (93, 'Jika kompas menunjukkan 180 derajat, maka arah yang ditunjuk adalah ....', '', '{"A":"Utara","B":"Timur","C":"Selatan","D":"Barat"}'::jsonb, 'C', true),
    (94, 'Kegiatan mencari jejak menggunakan peta dan kompas disebut ....', '', '{"A":"Camping","B":"Orienteering","C":"Hiking","D":"Tracking"}'::jsonb, 'B', true),
    (95, 'Pada malam hari, arah utara dapat ditentukan dengan melihat bintang ....', '', '{"A":"Sirius","B":"Polaris","C":"Orion","D":"Vega"}'::jsonb, 'B', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('SIMULASI DAY 14');
select count(*) as jumlah_soal_day14 from public.questions where exam_id = (select id from public.exams where lower(title) = lower('SIMULASI DAY 14') order by created_at asc limit 1);
