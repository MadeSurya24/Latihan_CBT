-- Seed paket soal dari: soal banksoal last day.docx
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- File ini membuat/memperbarui paket: SIMULASI LAST DAY JUST FRIENDS OR ALWAYS JUST FRIENDS
-- Jika paket dengan judul yang sama sudah ada, soal lama pada paket itu akan diganti agar tidak dobel.

with existing_exam as (
  select id
  from public.exams
  where lower(title) = lower('SIMULASI LAST DAY JUST FRIENDS OR ALWAYS JUST FRIENDS')
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
  select 'SIMULASI LAST DAY JUST FRIENDS OR ALWAYS JUST FRIENDS', 'Simulasi Pengetahuan Umum', 120, true
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
    (1, 'Simpul yang mudah dilepas disebut ....', '', '{"A":"Simpul mati","B":"Simpul hidup","C":"Simpul jangkar","D":"Simpul anyam"}'::jsonb, 'B', true),
    (2, 'Fungsi simpul hidup adalah ....', '', '{"A":"Menyambung kayu","B":"Mengikat tiang","C":"Untuk ikatan yang mudah dibuka kembali","D":"Membuat tandu"}'::jsonb, 'C', true),
    (3, 'Simpul untuk menolong atau mengangkat orang disebut ....', '', '{"A":"Simpul hidup","B":"Simpul pangkal","C":"Simpul kursi","D":"Simpul mati"}'::jsonb, 'C', true),
    (4, 'Fungsi simpul kursi adalah ....', '', '{"A":"Menarik benda berat","B":"Membuat lingkaran tetap untuk penyelamatan","C":"Menyambung dua tongkat","D":"Mengikat tenda"}'::jsonb, 'B', true),
    (5, 'Simpul untuk menyambung dua tali berbeda ukuran disebut ....', '', '{"A":"Simpul pangkal","B":"Simpul hidup","C":"Simpul anyam","D":"Simpul jangkar"}'::jsonb, 'C', true),
    (6, 'Fungsi simpul anyam adalah ....', '', '{"A":"Menyambung dua tali berbeda ukuran","B":"Mengikat hewan","C":"Membuat tiang","D":"Menarik perahu"}'::jsonb, 'A', true),
    (7, 'Jambore Nasional IV dilaksanakan pada tahun ....', '', '{"A":"1980","B":"1982","C":"1986","D":"1991"}'::jsonb, 'C', true),
    (8, 'Jambore Nasional IV dilaksanakan di ....', '', '{"A":"Yogyakarta","B":"Cibubur/Cimanggis, Jakarta","C":"Surabaya","D":"Bandung"}'::jsonb, 'B', true),
    (9, 'Jambore Nasional V dilaksanakan pada tahun ....', '', '{"A":"1986","B":"1988","C":"1990","D":"1991"}'::jsonb, 'D', true),
    (10, 'Sebutan Pramuka di Amerika Serikat adalah ....', '', '{"A":"Scout Kingdom","B":"Boys Scout Union","C":"Boy Scout of America","D":"Scout America Club"}'::jsonb, 'C', true),
    (11, 'Sumpah pandu disebut ....', '', '{"A":"Scout law","B":"Scout promise","C":"Scout movement","D":"Scout motto"}'::jsonb, 'B', true),
    (12, 'Hukum pandu disebut ....', '', '{"A":"Scout law","B":"Scout code","C":"Scout camp","D":"Scout promise"}'::jsonb, 'A', true),
    (13, 'BP bergabung dengan pasukan Hussar ke-13 di India pada tahun ....', '', '{"A":"1870","B":"1876","C":"1880","D":"1888"}'::jsonb, 'B', true),
    (14, 'Dari tahun 1888-1895 BP bertugas di ....', '', '{"A":"Jepang dan Cina","B":"Mesir dan Sudan","C":"India, Afghanistan, Zulu, dan Ashanti","D":"Amerika dan Kanada"}'::jsonb, 'C', true),
    (15, 'BP menjadi letnan jenderal pada tahun ....', '', '{"A":"1899","B":"1901","C":"1908","D":"1910"}'::jsonb, 'C', true),
    (16, 'BP dianugerahi gelar kesatria pada tahun ....', '', '{"A":"1901","B":"1905","C":"1908","D":"1909"}'::jsonb, 'D', true),
    (17, 'Nama kakek BP adalah ....', '', '{"A":"Robert Smyth","B":"William T. Smyth","C":"Henry Smyth","D":"Charles Smyth"}'::jsonb, 'B', true),
    (18, 'Pekerjaan kakek BP adalah ....', '', '{"A":"Dokter kerajaan","B":"Guru militer","C":"Admiral kerajaan Inggris","D":"Penulis"}'::jsonb, 'C', true),
    (19, 'Ayah BP meninggal pada tanggal ....', '', '{"A":"11 Juni 1860","B":"26 Februari 1865","C":"15 Juni 1870","D":"18 Mei 1900"}'::jsonb, 'A', true),
    (20, 'Penulis buku "The Book of Nature" adalah ....', '', '{"A":"Baden Powell","B":"Louis Pasteur","C":"Charles Darwin","D":"Isaac Newton"}'::jsonb, 'C', true),
    (21, 'Judul surat yang ditulis BP kepada ibunya adalah ....', '', '{"A":"My Adventure","B":"What Next","C":"Apa yang harus kukerjakan nanti","D":"My Journey"}'::jsonb, 'C', true),
    (22, 'BP menulis surat untuk ibunya pada tanggal ....', '', '{"A":"11 Juni 1860","B":"26 Februari 1865","C":"13 Oktober 1899","D":"18 Mei 1900"}'::jsonb, 'B', true),
    (23, 'Sebelum masuk Charter House School, BP ingin masuk sekolah ....', '', '{"A":"Oxford dan Cambridge","B":"Rugby dan Eton","C":"Harvard dan Yale","D":"Tokyo dan Kyoto"}'::jsonb, 'B', true),
    (24, 'BP masuk Charter House School pada tahun ....', '', '{"A":"1865","B":"1870","C":"1876","D":"1888"}'::jsonb, 'B', true),
    (25, 'BP bergabung dengan dinas kemiliteran dibantu oleh ....', '', '{"A":"Ayahnya","B":"Kakaknya","C":"Pamannya, Kolonel Henry Smyth","D":"Gurunya"}'::jsonb, 'C', true),
    (26, 'Setelah lulus dari akademi militer, BP ditempatkan di ....', '', '{"A":"Inggris","B":"India","C":"Afrika","D":"Amerika"}'::jsonb, 'B', true),
    (27, 'Pangkat pertama BP adalah ....', '', '{"A":"Kapten","B":"Mayor","C":"Pembantu letnan","D":"Jenderal"}'::jsonb, 'C', true),
    (28, 'Nama teman dekat BP adalah ....', '', '{"A":"Charles Darwin","B":"Kenneth McLaren","C":"William Smyth","D":"Dinuzulu"}'::jsonb, 'B', true),
    (29, 'Kota Mafeking dikepung bangsa Boer selama ....', '', '{"A":"100 hari","B":"150 hari","C":"217 hari","D":"300 hari"}'::jsonb, 'C', true),
    (30, 'Buku yang ditulis BP setelah kembali ke Inggris tahun 1901 berjudul ....', '', '{"A":"Scouting for Boys","B":"Aids to Scouting","C":"Scout Law","D":"Jungle Book"}'::jsonb, 'B', true),
    (31, 'Benua terbesar di dunia adalah ....', '', '{"A":"Afrika","B":"Asia","C":"Amerika","D":"Eropa"}'::jsonb, 'B', true),
    (32, 'Air terjun terbesar berada di ....', '', '{"A":"Venezuela","B":"Brasil","C":"Kanada","D":"India"}'::jsonb, 'B', true),
    (33, 'Air terjun tertinggi di dunia adalah ....', '', '{"A":"Niagara","B":"Victoria","C":"Santo Angel","D":"Yosemite"}'::jsonb, 'C', true),
    (34, 'Gunung tertinggi di dunia adalah ....', '', '{"A":"Kilimanjaro","B":"Everest","C":"Fuji","D":"Elbrus"}'::jsonb, 'B', true),
    (35, 'Gurun terbesar di dunia adalah ....', '', '{"A":"Gurun Sahara","B":"Gurun Gobi","C":"Gurun Arab","D":"Gurun Kalahari"}'::jsonb, 'A', true),
    (36, 'Pulau terbesar di dunia adalah ....', '', '{"A":"Madagaskar","B":"Kalimantan","C":"Greenland","D":"Sumatra"}'::jsonb, 'C', true),
    (37, 'Samudera terbesar di dunia adalah ....', '', '{"A":"Atlantik","B":"Hindia","C":"Arktik","D":"Pasifik"}'::jsonb, 'D', true),
    (38, 'Sungai terpanjang di dunia adalah ....', '', '{"A":"Amazon","B":"Nil","C":"Mississippi","D":"Gangga"}'::jsonb, 'B', true),
    (39, 'Kepulauan terbesar di dunia adalah ....', '', '{"A":"Jepang","B":"Filipina","C":"Indonesia","D":"Maladewa"}'::jsonb, 'C', true),
    (40, 'Matahari adalah ....', '', '{"A":"Planet terbesar","B":"Satelit bumi","C":"Pusat tata surya","D":"Bintang berekor"}'::jsonb, 'C', true),
    (41, 'Planet pertama dalam tata surya adalah ....', '', '{"A":"Venus","B":"Merkurius","C":"Mars","D":"Bumi"}'::jsonb, 'B', true),
    (42, 'Planet terbesar dalam tata surya adalah ....', '', '{"A":"Saturnus","B":"Uranus","C":"Yupiter","D":"Neptunus"}'::jsonb, 'C', true),
    (43, 'Planet yang memiliki cincin adalah ....', '', '{"A":"Venus","B":"Mars","C":"Saturnus","D":"Merkurius"}'::jsonb, 'C', true),
    (44, 'Planet Venus dikenal sebagai ....', '', '{"A":"Planet merah","B":"Planet biru","C":"Bintang pagi","D":"Planet bercincin"}'::jsonb, 'C', true),
    (45, 'Gugusan planet kecil antara Mars dan Yupiter disebut ....', '', '{"A":"Meteor","B":"Asteroid","C":"Komet","D":"Satelit"}'::jsonb, 'B', true),
    (46, 'Bintang berekor disebut ....', '', '{"A":"Meteor","B":"Satelit","C":"Asteroid","D":"Komet"}'::jsonb, 'D', true),
    (47, 'Planet yang dihuni makhluk hidup adalah ....', '', '{"A":"Mars","B":"Venus","C":"Bumi","D":"Jupiter"}'::jsonb, 'C', true),
    (48, 'ABC merupakan singkatan dari ....', '', '{"A":"Australian Broadcasting Commission","B":"American Broadcasting Center","C":"Asia Broadcast Channel","D":"Australia Business Center"}'::jsonb, 'A', true),
    (49, 'AC merupakan singkatan dari ....', '', '{"A":"Active Current","B":"Alternating Current","C":"Automatic Current","D":"Allied Current"}'::jsonb, 'B', true),
    (50, 'AP merupakan singkatan dari ....', '', '{"A":"American Press","B":"Asian Press","C":"Associated Press","D":"Allied Press"}'::jsonb, 'C', true),
    (51, 'AWACS adalah singkatan dari ....', '', '{"A":"Air Warning and Control System","B":"Airborne Warning and Control System","C":"Air Weapon and Communication System","D":"Airborne Weather and Control System"}'::jsonb, 'B', true),
    (52, 'BBC merupakan singkatan dari ....', '', '{"A":"British Broadcasting Corporation","B":"Britain Broadcast Center","C":"British Business Corporation","D":"Broadcast Britain Channel"}'::jsonb, 'A', true),
    (53, 'CBC adalah singkatan dari ....', '', '{"A":"Canadian Broadcasting Corporation","B":"Central Broadcast Company","C":"Canadian Business Center","D":"Central Broadcasting Corporation"}'::jsonb, 'A', true),
    (54, 'CIA merupakan singkatan dari ....', '', '{"A":"Central Intelligence Agency","B":"Central Investigation Agency","C":"Central International Agency","D":"Civil Intelligence Agency"}'::jsonb, 'A', true),
    (55, 'CPU merupakan singkatan dari ....', '', '{"A":"Central Programming Unit","B":"Central Processing Unit","C":"Computer Processing Unit","D":"Computer Program Unit"}'::jsonb, 'B', true),
    (56, 'DIY adalah singkatan dari ....', '', '{"A":"Do It Yourself","B":"Do Your Idea","C":"Design It Yourself","D":"Do It Young"}'::jsonb, 'A', true),
    (57, 'DJ merupakan singkatan dari ....', '', '{"A":"Disk Jump","B":"Disc Jockey","C":"Digital Jockey","D":"Disco Jam"}'::jsonb, 'B', true),
    (58, 'DNA merupakan singkatan dari ....', '', '{"A":"Deoxyribonucleic Acid","B":"Dynamic Nuclear Acid","C":"Double Nuclear Acid","D":"Deoxy Nuclear Acid"}'::jsonb, 'A', true),
    (59, 'EEC/EC merupakan singkatan dari ....', '', '{"A":"Europe Economic Council","B":"European Economic Community","C":"Europe Energy Community","D":"Economic Europe Council"}'::jsonb, 'B', true),
    (60, 'CD pada komputer merupakan singkatan dari ....', '', '{"A":"Compact Data","B":"Compact Disk","C":"Central Disk","D":"Computer Disk"}'::jsonb, 'B', true),
    (61, 'Jumlah darah orang dewasa sekitar ....', '', '{"A":"3 liter","B":"4 liter","C":"5 liter","D":"6,25 liter"}'::jsonb, 'D', true),
    (62, 'Kehilangan darah sebanyak 1,5 liter dapat menyebabkan ....', '', '{"A":"Demam","B":"Collapse","C":"Pingsan ringan","D":"Sesak napas"}'::jsonb, 'B', true),
    (63, 'Kehilangan darah sebanyak 2,25 liter dapat mengakibatkan ....', '', '{"A":"Pusing","B":"Demam","C":"Kematian","D":"Batuk"}'::jsonb, 'C', true),
    (64, 'Tujuan pembalut adalah ....', '', '{"A":"Menambah rasa sakit","B":"Menghentikan pernapasan","C":"Mencegah infeksi pada luka","D":"Membuat luka terbuka"}'::jsonb, 'C', true),
    (65, 'Pembalut segitiga disebut juga ....', '', '{"A":"Band aid","B":"Mitela","C":"Spalk","D":"Splint"}'::jsonb, 'B', true),
    (66, 'Nama lain bidai dalam bahasa Inggris adalah ....', '', '{"A":"Bandage","B":"Splint","C":"Mitela","D":"Fiksasi"}'::jsonb, 'B', true),
    (67, 'Bidai digunakan untuk ....', '', '{"A":"Mengobati batuk","B":"Menahan tulang yang patah","C":"Menurunkan panas","D":"Menghentikan pendarahan hidung"}'::jsonb, 'B', true),
    (68, 'Tujuan pembidaian adalah ....', '', '{"A":"Menambah gerakan tulang","B":"Mengurangi rasa sakit dan mencegah tulang bertambah parah","C":"Mempercepat pendarahan","D":"Membuat luka terbuka"}'::jsonb, 'B', true),
    (69, 'Nama lain pembidaian adalah ....', '', '{"A":"Mitela","B":"Fiksasi","C":"Bandage","D":"Kompres"}'::jsonb, 'B', true),
    (70, 'Nama lain retak tulang selain fisura adalah ....', '', '{"A":"Greenstick","B":"Fracture","C":"Collapse","D":"Splint"}'::jsonb, 'A', true),
    (71, 'Salah satu gejala patah tulang adalah ....', '', '{"A":"Nafsu makan meningkat","B":"Demam ringan tanpa nyeri","C":"Anggota tubuh tidak dapat digerakkan","D":"Kulit memerah normal"}'::jsonb, 'C', true),
    (72, 'Berikut yang termasuk jenis luka adalah ....', '', '{"A":"Luka iris","B":"Luka tidur","C":"Luka dingin","D":"Luka angin"}'::jsonb, 'A', true),
    (73, 'Luka akibat terkena api disebut ....', '', '{"A":"Luka tusuk","B":"Luka iris","C":"Luka bakar","D":"Luka gigitan"}'::jsonb, 'C', true),
    (74, 'Penyebab luka bakar adalah ....', '', '{"A":"Air dan angin","B":"Api dan listrik","C":"Debu dan tanah","D":"Es dan hujan"}'::jsonb, 'B', true),
    (75, 'Warna biru pada tanda obat berarti ....', '', '{"A":"Obat dalam","B":"Obat berbahaya","C":"Obat luar","D":"Obat tidur"}'::jsonb, 'C', true),
    (76, 'Warna merah atau hitam pada tanda obat berarti ....', '', '{"A":"Obat luar","B":"Obat beracun atau berbahaya","C":"Obat batuk","D":"Obat herbal"}'::jsonb, 'B', true),
    (77, 'Darah yang mengalir dari pembuluh nadi berwarna ....', '', '{"A":"Hitam","B":"Biru","C":"Merah muda","D":"Kuning"}'::jsonb, 'C', true),
    (78, 'Obat alami untuk meredakan batuk adalah ....', '', '{"A":"Jahe dan kopi","B":"Jeruk nipis dan kecap","C":"Air garam dan teh","D":"Susu dan madu"}'::jsonb, 'B', true),
    (79, 'Cicendo merupakan rumah sakit spesialis ....', '', '{"A":"Jantung","B":"Anak","C":"Mata","D":"Tulang"}'::jsonb, 'C', true),
    (80, 'Langkah pertama dalam P3K adalah ....', '', '{"A":"Memberi obat","B":"Membalut luka","C":"Evaluasi keamanan dan panggil bantuan medis","D":"Memindahkan korban"}'::jsonb, 'C', true),
    (81, 'Arah 0 derajat pada kompas menunjukkan arah ....', '', '{"A":"Timur","B":"Selatan","C":"Utara","D":"Barat"}'::jsonb, 'C', true),
    (82, 'Arah 135 derajat menunjukkan arah ....', '', '{"A":"Barat daya","B":"Tenggara","C":"Timur laut","D":"Barat laut"}'::jsonb, 'B', true),
    (83, 'Arah 225 derajat menunjukkan arah ....', '', '{"A":"Barat daya","B":"Tenggara","C":"Selatan","D":"Timur"}'::jsonb, 'A', true),
    (84, 'Arah 315 derajat menunjukkan arah ....', '', '{"A":"Timur laut","B":"Barat laut","C":"Barat daya","D":"Selatan"}'::jsonb, 'B', true),
    (85, 'Delapan arah mata angin disebut arah mata angin ....', '', '{"A":"Lengkap","B":"Tambahan","C":"Utama","D":"Khusus"}'::jsonb, 'C', true),
    (86, 'Enam belas arah mata angin disebut arah mata angin ....', '', '{"A":"Lengkap","B":"Pokok","C":"Tengah","D":"Utama"}'::jsonb, 'A', true),
    (87, 'Kompas tidak boleh didekatkan dengan benda elektronik karena dapat mengganggu ....', '', '{"A":"Peta","B":"Jarum kompas","C":"Skala","D":"Arah mata angin"}'::jsonb, 'B', true),
    (88, 'Utara pada kompas disebut juga utara ....', '', '{"A":"Sejati","B":"Peta","C":"Magnet","D":"Angin"}'::jsonb, 'C', true),
    (89, 'Utara yang sebenarnya sesuai poros bumi disebut utara ....', '', '{"A":"Magnet","B":"Sejati","C":"Kompas","D":"Peta"}'::jsonb, 'B', true),
    (90, 'Selisih antara utara magnet dan utara sejati disebut ....', '', '{"A":"Navigasi","B":"Deviasi","C":"Deklinasi","D":"Rotasi"}'::jsonb, 'C', true),
    (91, 'Pada malam hari, arah utara dapat ditentukan dengan melihat bintang ....', '', '{"A":"Orion","B":"Sirius","C":"Polaris","D":"Scorpio"}'::jsonb, 'C', true),
    (92, 'Sudut kompas dihitung searah putaran ....', '', '{"A":"Bumi","B":"Matahari","C":"Jarum jam","D":"Angin"}'::jsonb, 'C', true),
    (93, 'Bagian kompas yang berisi angka derajat disebut ....', '', '{"A":"Jarum","B":"Skala","C":"Visir","D":"Dial"}'::jsonb, 'B', true),
    (94, 'Membaca arah dengan kompas ke suatu objek disebut ....', '', '{"A":"Navigasi","B":"Membidik","C":"Mengukur","D":"Menggambar"}'::jsonb, 'B', true),
    (95, 'Fungsi visir pada kompas bidik adalah untuk ....', '', '{"A":"Menyimpan arah","B":"Mengukur jarak","C":"Membidik sasaran","D":"Menentukan waktu"}'::jsonb, 'C', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('SIMULASI LAST DAY JUST FRIENDS OR ALWAYS JUST FRIENDS');
select count(*) as jumlah_soal from public.questions where exam_id = (select id from public.exams where lower(title) = lower('SIMULASI LAST DAY JUST FRIENDS OR ALWAYS JUST FRIENDS') order by created_at asc limit 1);
