-- Seed paket soal dari: SOAL SIMULASI BANKS OAL DAY 15 Pt 2.docx
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- File ini membuat/memperbarui paket: SIMULASI DAY 15 PART 2
-- Jika paket dengan judul yang sama sudah ada, soal lama pada paket itu akan diganti agar tidak dobel.

with existing_exam as (
  select id
  from public.exams
  where lower(title) = lower('SIMULASI DAY 15 PART 2')
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
  select 'SIMULASI DAY 15 PART 2', 'Simulasi Pengetahuan Umum', 120, true
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
    (1, 'Kompas termasuk alat navigasi ________.', '', '{"A":"laut","B":"udara","C":"darat","D":"angkasa"}'::jsonb, 'C', true),
    (2, 'Huruf N pada kompas merupakan singkatan dari ________.', '', '{"A":"North","B":"Nether","C":"New","D":"Nation"}'::jsonb, 'A', true),
    (3, 'Huruf E pada kompas berarti ________.', '', '{"A":"Earth","B":"East","C":"End","D":"Eagle"}'::jsonb, 'B', true),
    (4, 'Huruf S pada kompas berarti ________.', '', '{"A":"Side","B":"South","C":"Sea","D":"Sun"}'::jsonb, 'B', true),
    (5, 'Huruf W pada kompas berarti ________.', '', '{"A":"Wind","B":"Wave","C":"West","D":"World"}'::jsonb, 'C', true),
    (6, 'Jika arah yang dituju 90 derajat, maka kita berjalan ke arah ________.', '', '{"A":"Utara","B":"Selatan","C":"Barat","D":"Timur"}'::jsonb, 'D', true),
    (7, 'Ilmu untuk menentukan arah dan posisi disebut ________.', '', '{"A":"komunikasi","B":"navigasi","C":"observasi","D":"koordinasi"}'::jsonb, 'B', true),
    (8, 'Jarum magnet pada kompas selalu menunjuk ke arah ________.', '', '{"A":"Selatan geografis","B":"Barat","C":"Utara magnetis","D":"Timur"}'::jsonb, 'C', true),
    (9, 'Berikut ini arah mata angin utama yang benar adalah ________.', '', '{"A":"Utara, Timur, Selatan, Barat","B":"Timur, Tenggara, Selatan, Barat Daya","C":"Utara, Barat Laut, Timur Laut, Selatan","D":"Barat, Timur Laut, Selatan, Tenggara"}'::jsonb, 'A', true),
    (10, 'Fungsi visir pada kompas bidik adalah untuk ________.', '', '{"A":"menyimpan jarum","B":"membidik sasaran","C":"mengukur suhu","D":"menghitung jarak"}'::jsonb, 'B', true),
    (11, 'Sudut antara arah utara magnetis dengan arah sasaran disebut ________.', '', '{"A":"koordinat","B":"orientasi","C":"azimuth","D":"navigasi"}'::jsonb, 'C', true),
    (12, 'Berapa derajat arah Timur pada kompas?', '', '{"A":"45 derajat","B":"90 derajat","C":"180 derajat","D":"360 derajat"}'::jsonb, 'B', true),
    (13, 'Posisi yang benar saat menggunakan kompas adalah ________.', '', '{"A":"miring","B":"terbalik","C":"horizontal/datar","D":"tegak lurus"}'::jsonb, 'C', true),
    (14, 'Arah antara Selatan dan Barat disebut ________.', '', '{"A":"tenggara","B":"barat laut","C":"timur laut","D":"barat daya"}'::jsonb, 'D', true),
    (15, 'Derajat penuh pada kompas adalah ________.', '', '{"A":"90 derajat","B":"180 derajat","C":"270 derajat","D":"360 derajat"}'::jsonb, 'D', true),
    (16, 'Jambore Nasional I dilaksanakan pada tahun ________.', '', '{"A":"1968","B":"1973","C":"1977","D":"1981"}'::jsonb, 'B', true),
    (17, 'Jambore Nasional II dilaksanakan di ________.', '', '{"A":"Cibubur","B":"Jatinangor","C":"Sibolangit","D":"Baturraden"}'::jsonb, 'C', true),
    (18, 'Jambore Nasional III berlangsung di ________.', '', '{"A":"Jakarta","B":"Bandung","C":"Medan","D":"Banyumas"}'::jsonb, 'A', true),
    (19, 'Jambore Nasional VII dilaksanakan di ________.', '', '{"A":"Teluk Gelam","B":"Baturraden","C":"Jatinangor","D":"Cibubur"}'::jsonb, 'B', true),
    (20, 'Jambore Nasional VIII dilaksanakan di ________.', '', '{"A":"Jawa Tengah","B":"Sumatera Selatan","C":"Jawa Barat","D":"Sumatera Utara"}'::jsonb, 'C', true),
    (21, 'Jambore Nasional IX berlangsung di ________.', '', '{"A":"Cibubur","B":"Teluk Gelam","C":"Sibolangit","D":"Baturraden"}'::jsonb, 'B', true),
    (22, 'Jambore Nasional X dilaksanakan pada tahun ________.', '', '{"A":"2011","B":"2014","C":"2016","D":"2022"}'::jsonb, 'C', true),
    (23, 'Jambore Nasional XI dilaksanakan pada tahun ________.', '', '{"A":"2018","B":"2019","C":"2020","D":"2022"}'::jsonb, 'D', true),
    (24, 'Buku Scouting for Boys pertama kali diedarkan pada tanggal ________.', '', '{"A":"1 Januari 1908","B":"15 Januari 1908","C":"21 Februari 1908","D":"10 November 1908"}'::jsonb, 'B', true),
    (25, 'Penerbit buku Scouting for Boys adalah ________.', '', '{"A":"Gramedia","B":"Erlangga","C":"Horace Cox","D":"Balai Pustaka"}'::jsonb, 'C', true),
    (26, 'Kepanduan siaga didirikan pada tahun ________.', '', '{"A":"1908","B":"1910","C":"1916","D":"1920"}'::jsonb, 'C', true),
    (27, 'Buku yang mengilhami kegiatan siaga adalah ________.', '', '{"A":"Treasure Island","B":"The Jungle Book","C":"Harry Potter","D":"Around the World"}'::jsonb, 'B', true),
    (28, 'Penulis buku The Jungle Book adalah ________.', '', '{"A":"Baden Powell","B":"Robert Stephenson","C":"Rudyard Kipling","D":"William Shakespeare"}'::jsonb, 'C', true),
    (29, 'Nama anak serigala dalam cerita The Jungle Book adalah ________.', '', '{"A":"Tarzan","B":"Simba","C":"Mowgli","D":"Baloo"}'::jsonb, 'C', true),
    (30, 'Bagheera dalam cerita The Jungle Book adalah seekor ________.', '', '{"A":"singa","B":"harimau","C":"macan kumbang","D":"serigala"}'::jsonb, 'C', true),
    (31, 'Sahabat Baden Powell yang memberikan sebidang tanah untuk Gilwell Park adalah ________.', '', '{"A":"Rudyard Kipling","B":"William F DeBois Mc Laren","C":"John Smith","D":"Lord Baden"}'::jsonb, 'B', true),
    (32, 'Patung yang ada di Gilwell Park adalah patung ________.', '', '{"A":"harimau","B":"elang","C":"singa","D":"kuda"}'::jsonb, 'C', true),
    (33, 'Gerakan Pramuka menjadi satu-satunya organisasi kepanduan di Indonesia sejak keluarnya Kepres Nomor ________.', '', '{"A":"174/2012","B":"238/1961","C":"055/1982","D":"198/2011"}'::jsonb, 'B', true),
    (34, 'Skep Panji Gerakan Pramuka bernomor ________.', '', '{"A":"448 Tahun 1961","B":"174 Tahun 2012","C":"059 Tahun 1982","D":"045 Tahun 1980"}'::jsonb, 'A', true),
    (35, 'Surat keputusan Kwartir Nasional tentang lambang Gerakan Pramuka bernomor ________.', '', '{"A":"06/KN/72","B":"202/KN/88","C":"132/KN/79","D":"055 Tahun 1982"}'::jsonb, 'A', true),
    (36, 'Keputusan Kwartir Nasional tentang tanda pengenal bernomor ________.', '', '{"A":"036/KN/79","B":"055 Tahun 1982","C":"064 Tahun 2001","D":"174/KN/2012"}'::jsonb, 'B', true),
    (37, 'Skep tentang tanda pengenal umum adalah ________.', '', '{"A":"202/KN/88","B":"059 Tahun 1982","C":"045/KN/80","D":"198/KN/2011"}'::jsonb, 'B', true),
    (38, 'SK Kwarnas tentang tanda kecakapan adalah ________.', '', '{"A":"088/KN/74 dan 058 Tahun 1982","B":"174/KN/2012","C":"036/KN/79","D":"448 Tahun 1961"}'::jsonb, 'A', true),
    (39, 'SK Kwarnas Nomor 064 Tahun 2001 berisi tentang ________.', '', '{"A":"lambang pramuka","B":"tanda jabatan","C":"penarikan diri dari WAGGGS","D":"tanda kecakapan"}'::jsonb, 'C', true),
    (40, 'Skep tentang TKK adalah ________.', '', '{"A":"055 Tahun 1982","B":"134/KN/76 dan 132 Tahun 1979","C":"174/KN/2012","D":"036/KN/79"}'::jsonb, 'B', true),
    (41, 'Skep tentang baju pramuka dahulu bernomor ________.', '', '{"A":"088/KN/81","B":"202/KN/88","C":"045/KN/80","D":"132/KN/79"}'::jsonb, 'A', true),
    (42, 'Skep baju pramuka yang sekarang bernomor ________.', '', '{"A":"055 Tahun 1982","B":"174/KN/2012","C":"036/KN/79","D":"198/KN/2011"}'::jsonb, 'B', true),
    (43, 'Skep Pramuka Garuda adalah ________.', '', '{"A":"045/KN/80 Tahun 1980","B":"202/KN/88 Tahun 1988","C":"059 Tahun 1982","D":"064 Tahun 2001"}'::jsonb, 'A', true),
    (44, 'Skep Dasa Darma bernomor ________.', '', '{"A":"174/KN/2012","B":"036/KN/79","C":"055 Tahun 1982","D":"448 Tahun 1961"}'::jsonb, 'B', true),
    (45, 'SK SKU terbaru bernomor ________.', '', '{"A":"132/KN/79","B":"202/KN/88","C":"198/KN/2011","D":"064 Tahun 2001"}'::jsonb, 'C', true),
    (46, 'Kerajaan Tarumanagara terletak di ________.', '', '{"A":"Jawa Tengah","B":"Jawa Timur","C":"Jawa Barat","D":"Sumatera Barat"}'::jsonb, 'C', true),
    (47, 'Penemu telepon adalah ________.', '', '{"A":"Thomas Edison","B":"Alexander Graham Bell","C":"Isaac Newton","D":"Charles Darwin"}'::jsonb, 'B', true),
    (48, 'Ilmu yang mempelajari alam semesta disebut ________.', '', '{"A":"Biologi","B":"Geografi","C":"Astronomi","D":"Kimia"}'::jsonb, 'C', true),
    (49, 'Samsung merupakan perusahaan yang berasal dari negara ________.', '', '{"A":"Jepang","B":"China","C":"Korea Selatan","D":"Thailand"}'::jsonb, 'C', true),
    (50, 'Tsunami Aceh tahun 2004 terjadi pada tanggal ________.', '', '{"A":"17 Agustus","B":"26 Desember","C":"1 Januari","D":"10 November"}'::jsonb, 'B', true),
    (51, 'Menara Pisa terletak di negara ________.', '', '{"A":"Spanyol","B":"Italia","C":"Prancis","D":"Yunani"}'::jsonb, 'B', true),
    (52, 'Benua Biru adalah julukan untuk Benua ________.', '', '{"A":"Asia","B":"Afrika","C":"Amerika","D":"Eropa"}'::jsonb, 'D', true),
    (53, 'Presiden pertama Indonesia adalah ________.', '', '{"A":"Soeharto","B":"B. J. Habibie","C":"Ir. Soekarno","D":"Joko Widodo"}'::jsonb, 'C', true),
    (54, 'Ibu kota negara Jepang adalah ________.', '', '{"A":"Osaka","B":"Kyoto","C":"Tokyo","D":"Seoul"}'::jsonb, 'C', true),
    (55, 'Zodiak yang dilambangkan dengan domba adalah ________.', '', '{"A":"Taurus","B":"Aries","C":"Leo","D":"Gemini"}'::jsonb, 'B', true),
    (56, 'Singkatan dari United Nations adalah ________.', '', '{"A":"ASEAN","B":"WHO","C":"PBB","D":"UNICEF"}'::jsonb, 'C', true),
    (57, 'Penulis buku 1984 adalah ________.', '', '{"A":"Tere Liye","B":"George Orwell","C":"William Shakespeare","D":"Charles Dickens"}'::jsonb, 'B', true),
    (58, 'Jumlah provinsi di Indonesia saat ini adalah ________.', '', '{"A":"34","B":"36","C":"38","D":"40"}'::jsonb, 'C', true),
    (59, 'Negara yang memiliki Terusan Suez adalah ________.', '', '{"A":"Mesir","B":"Arab Saudi","C":"India","D":"Turki"}'::jsonb, 'A', true),
    (60, 'Danau terbesar di dunia berdasarkan luas permukaan adalah ________.', '', '{"A":"Danau Toba","B":"Danau Victoria","C":"Danau Superior","D":"Danau Baikal"}'::jsonb, 'C', true),
    (61, 'Pulau Komodo terletak di provinsi ________.', '', '{"A":"Bali","B":"NTT","C":"NTB","D":"Maluku"}'::jsonb, 'B', true),
    (62, 'Penemu lampu pijar adalah ________.', '', '{"A":"Galileo Galilei","B":"Nikola Tesla","C":"Thomas Edison","D":"Albert Einstein"}'::jsonb, 'C', true),
    (63, 'Sungai yang melintasi Mesir adalah Sungai ________.', '', '{"A":"Amazon","B":"Nil","C":"Gangga","D":"Mississippi"}'::jsonb, 'B', true),
    (64, 'Simbol kimia untuk emas adalah ________.', '', '{"A":"Ag","B":"Fe","C":"Au","D":"Hg"}'::jsonb, 'C', true),
    (65, 'Negeri Ginseng adalah julukan bagi negara ________.', '', '{"A":"Jepang","B":"Korea Selatan","C":"China","D":"Mongolia"}'::jsonb, 'B', true),
    (66, 'Kota Bogor dijuluki sebagai Kota ________.', '', '{"A":"Batik","B":"Apel","C":"Hujan","D":"Pelajar"}'::jsonb, 'C', true),
    (67, 'Kitab suci agama Hindu adalah ________.', '', '{"A":"Tripitaka","B":"Al-Qur''an","C":"Weda","D":"Injil"}'::jsonb, 'C', true),
    (68, 'Penulis drama Romeo and Juliet adalah ________.', '', '{"A":"George Orwell","B":"William Shakespeare","C":"Andrea Hirata","D":"Pramoedya Ananta Toer"}'::jsonb, 'B', true),
    (69, 'Gunung tertinggi di dunia adalah ________.', '', '{"A":"Kilimanjaro","B":"Everest","C":"Fuji","D":"Kerinci"}'::jsonb, 'B', true),
    (70, 'Pusat tata surya adalah ________.', '', '{"A":"Bulan","B":"Mars","C":"Matahari","D":"Jupiter"}'::jsonb, 'C', true),
    (71, 'Alat pembayaran resmi untuk biaya pengiriman pos adalah ________.', '', '{"A":"cek","B":"giro","C":"prangko","D":"meterai"}'::jsonb, 'C', true),
    (72, 'Arah jam 9 sama dengan arah ________.', '', '{"A":"Timur","B":"Utara","C":"Selatan","D":"Barat"}'::jsonb, 'D', true),
    (73, 'Mata uang Jepang adalah ________.', '', '{"A":"Won","B":"Yen","C":"Baht","D":"Ringgit"}'::jsonb, 'B', true),
    (74, 'Pohon yang identik dengan perayaan Natal adalah pohon ________.', '', '{"A":"Mangga","B":"Kelapa","C":"Cemara","D":"Jati"}'::jsonb, 'C', true),
    (75, 'Bunga nasional Indonesia yang dijuluki puspa pesona adalah ________.', '', '{"A":"Mawar","B":"Melati","C":"Anggrek Bulan","D":"Tulip"}'::jsonb, 'C', true),
    (76, 'Cabang ilmu kedokteran yang menitikberatkan infeksi dan patogen adalah ________.', '', '{"A":"Neurologi","B":"Kardiologi","C":"Cabang Penyakit Infeksi","D":"Ortopedi"}'::jsonb, 'C', true),
    (77, 'Ilmu biologi yang mempelajari mikroorganisme disebut ________.', '', '{"A":"Zoologi","B":"Mikrobiologi","C":"Botani","D":"Ekologi"}'::jsonb, 'B', true),
    (78, 'Tokoh yang pertama menjelaskan proses fermentasi dan pembuatan vaksin rabies adalah ________.', '', '{"A":"Albert Einstein","B":"Charles Darwin","C":"Louis Pasteur","D":"Isaac Newton"}'::jsonb, 'C', true),
    (79, 'Penyebab penyakit TBC adalah infeksi bakteri ________.', '', '{"A":"Salmonella typhi","B":"Mycobacterium tuberculosis","C":"Bacillus anthracis","D":"Clostridium tetani"}'::jsonb, 'B', true),
    (80, 'Penyakit difteri disebabkan oleh bakteri ________.', '', '{"A":"Corynebacterium diphtheriae","B":"Bordetella pertussis","C":"Yersinia pestis","D":"Mycobacterium leprae"}'::jsonb, 'A', true),
    (81, 'Batuk rejan atau pertusis disebabkan oleh bakteri ________.', '', '{"A":"Bacillus anthracis","B":"Bordetella pertussis","C":"Salmonella typhi","D":"Clostridium botulinum"}'::jsonb, 'B', true),
    (82, 'Penyakit kekakuan otot disebut ________.', '', '{"A":"Polio","B":"Tifus","C":"Tetanus","D":"Hepatitis"}'::jsonb, 'C', true),
    (83, 'Demam tifoid disebabkan oleh bakteri ________.', '', '{"A":"Salmonella typhi","B":"Yersinia pestis","C":"Escherichia coli","D":"Vibrio cholerae"}'::jsonb, 'A', true),
    (84, 'Penyakit kusta disebabkan oleh bakteri ________.', '', '{"A":"Mycobacterium leprae","B":"Bacillus anthracis","C":"Corynebacterium diphtheriae","D":"Clostridium tetani"}'::jsonb, 'A', true),
    (85, 'Penyakit pes atau sampar disebabkan oleh bakteri ________.', '', '{"A":"Salmonella typhi","B":"Yersinia pestis","C":"Bordetella pertussis","D":"Vibrio cholerae"}'::jsonb, 'B', true),
    (86, 'Penyakit antraks disebabkan oleh bakteri ________.', '', '{"A":"Bacillus anthracis","B":"Mycobacterium tuberculosis","C":"Clostridium tetani","D":"Salmonella typhi"}'::jsonb, 'A', true),
    (87, 'Penyakit cacar air disebabkan oleh virus ________.', '', '{"A":"Influenza","B":"Rabies","C":"Varicella-zoster","D":"Ebola"}'::jsonb, 'C', true),
    (88, 'Penyebab penyakit herpes adalah ________.', '', '{"A":"virus influenza","B":"virus herpes simpleks","C":"virus dengue","D":"poliovirus"}'::jsonb, 'B', true),
    (89, 'Penyakit kelumpuhan pada bagian tubuh disebut ________.', '', '{"A":"Tetanus","B":"Polio","C":"Hepatitis","D":"Malaria"}'::jsonb, 'B', true),
    (90, 'Penyebab penyakit flu adalah ________.', '', '{"A":"bakteri","B":"jamur","C":"virus influenza","D":"parasit"}'::jsonb, 'C', true),
    (91, 'Penyakit yang menyebabkan pendarahan di seluruh tubuh pasien disebut ________.', '', '{"A":"Ebola","B":"Polio","C":"Difteri","D":"Kusta"}'::jsonb, 'A', true),
    (92, 'Nama lain penyakit kuning adalah ________.', '', '{"A":"Tetanus","B":"Hepatitis","C":"Malaria","D":"Rabies"}'::jsonb, 'B', true),
    (93, 'Berikut ini yang termasuk penyakit akibat jamur adalah ________.', '', '{"A":"Panu","B":"TBC","C":"Polio","D":"Rabies"}'::jsonb, 'A', true),
    (94, 'Penyakit degeneratif adalah penyakit yang ________.', '', '{"A":"menular melalui udara","B":"disebabkan virus","C":"mengiringi proses penuaan","D":"hanya menyerang anak-anak"}'::jsonb, 'C', true),
    (95, 'Sel-sel otak akan rusak dan mati apabila tidak mendapat oksigen selama ________.', '', '{"A":"1-2 menit","B":"2-3 menit","C":"4-6 menit","D":"10-15 menit"}'::jsonb, 'C', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('SIMULASI DAY 15 PART 2');
select count(*) as jumlah_soal from public.questions where exam_id = (select id from public.exams where lower(title) = lower('SIMULASI DAY 15 PART 2') order by created_at asc limit 1);
