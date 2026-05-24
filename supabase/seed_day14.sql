-- Seed paket soal dari: soal simulasi bank soa day 13.docx
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
    (1, 'Apa motto TNI Angkatan Darat (AD)?', '', '{"A":"Jalesveva Jayamahe","B":"Kartika Eka Paksi","C":"Swa Bhuwana Paksa","D":"Rastra Sewakottama"}'::jsonb, 'B', true),
    (2, 'Arti dari “Jalesveva Jayamahe” adalah …', '', '{"A":"Sayap Tanah Air","B":"Di Laut Kita Jaya","C":"Kesatuan dan Kejayaan","D":"Abdi Utama Nusantara"}'::jsonb, 'B', true),
    (3, 'Motto “Swa Bhuwana Paksa” dimiliki oleh …', '', '{"A":"AD","B":"AL","C":"AU","D":"POLRI"}'::jsonb, 'C', true),
    (4, 'Apa arti “Rastra Sewakottama”?', '', '{"A":"Di Laut Kita Jaya","B":"Abdi Utama Bagi Nusantara","C":"Sayap Tanah Air","D":"Kekuatan dan Persatuan"}'::jsonb, 'B', true),
    (5, 'Nama latin Babirusa adalah …', '', '{"A":"Bos sondaicus","B":"Dugong dugong","C":"Babirussa babirussa","D":"Elephas indicus"}'::jsonb, 'C', true),
    (6, 'Nama latin Badak Jawa adalah …', '', '{"A":"Rhinoceros sondaicus","B":"Pavo muticus","C":"Casuarius casuarius","D":"Trugulus"}'::jsonb, 'A', true),
    (7, 'Nama latin Banteng adalah …', '', '{"A":"Bos sondaicus","B":"Phantera pardus","C":"Muntiacus muntjak","D":"Crocodylus novaeguineae"}'::jsonb, 'A', true),
    (8, 'Nama latin Buaya adalah …', '', '{"A":"Pavo muticus","B":"Crocodylus novaeguineae","C":"Elephas indicus","D":"Probosciger aterrimus"}'::jsonb, 'B', true),
    (9, 'Nama latin Burung Merak adalah …', '', '{"A":"Dugong dugong","B":"Pavo muticus","C":"Casuarius casuarius","D":"Trugulus"}'::jsonb, 'B', true),
    (10, 'Nama latin Ikan Duyung adalah …', '', '{"A":"Dugong dugong","B":"Dolphinidae ziphiidae","C":"Phantera pardus","D":"Bos sondaicus"}'::jsonb, 'A', true),
    (11, 'Nama latin Gajah adalah …', '', '{"A":"Elephas indicus","B":"Trugulus","C":"Pavo muticus","D":"Muntiacus muntjak"}'::jsonb, 'A', true),
    (12, 'Nama latin Harimau Jawa adalah …', '', '{"A":"Phantera pardus","B":"Phantera tigris sundaicus","C":"Bos sondaicus","D":"Casuarius casuarius"}'::jsonb, 'B', true),
    (13, 'Nama latin Harimau Sumatera adalah …', '', '{"A":"Phantera tigris sumatranus","B":"Probosciger aterrimus","C":"Dugong dugong","D":"Dolphinidae ziphiidae"}'::jsonb, 'A', true),
    (14, 'Nama latin Kakaktua Raja adalah …', '', '{"A":"Trugulus","B":"Probosciger aterrimus","C":"Pavo muticus","D":"Bos sondaicus"}'::jsonb, 'B', true),
    (15, 'Nama latin Kancil adalah …', '', '{"A":"Trugulus","B":"Elephas indicus","C":"Casuarius casuarius","D":"Muntiacus muntjak"}'::jsonb, 'A', true),
    (16, 'Nama latin Kasuari adalah …', '', '{"A":"Pavo muticus","B":"Casuarius casuarius","C":"Dugong dugong","D":"Bos sondaicus"}'::jsonb, 'B', true),
    (17, 'Nama latin Kijang adalah …', '', '{"A":"Dolphinidae ziphiidae","B":"Trugulus","C":"Muntiacus muntjak","D":"Phantera pardus"}'::jsonb, 'C', true),
    (18, 'Nama latin Lumba-lumba adalah …', '', '{"A":"Dugong dugong","B":"Dolphinidae ziphiidae","C":"Pavo muticus","D":"Bos sondaicus"}'::jsonb, 'B', true),
    (19, 'Nama latin Macan Kumbang adalah …', '', '{"A":"Phantera pardus","B":"Elephas indicus","C":"Trugulus","D":"Casuarius casuarius"}'::jsonb, 'A', true),
    (20, 'Kantor berita Indonesia adalah …', '', '{"A":"AFP","B":"Reuters","C":"Antara","D":"AP"}'::jsonb, 'C', true),
    (21, 'AFP adalah kantor berita dari negara …', '', '{"A":"Inggris","B":"Perancis","C":"Jepang","D":"India"}'::jsonb, 'B', true),
    (22, 'Kantor berita Jepang adalah …', '', '{"A":"Kyodo","B":"PAP","C":"Tass","D":"IRNA"}'::jsonb, 'A', true),
    (23, 'DPA merupakan kantor berita negara …', '', '{"A":"Rusia","B":"India","C":"Jerman","D":"Iran"}'::jsonb, 'C', true),
    (24, 'AP (Associated Press) berasal dari negara …', '', '{"A":"Inggris","B":"Jepang","C":"Amerika Serikat","D":"Malaysia"}'::jsonb, 'C', true),
    (25, 'Kantor berita Malaysia adalah …', '', '{"A":"Bernama","B":"Kyodo","C":"AFP","D":"PAP"}'::jsonb, 'A', true),
    (26, 'PTT adalah kantor berita dari negara …', '', '{"A":"India","B":"Jepang","C":"Rusia","D":"Iran"}'::jsonb, 'A', true),
    (27, 'Reuters berasal dari negara …', '', '{"A":"Jepang","B":"Inggris","C":"Iran","D":"Vietnam"}'::jsonb, 'B', true),
    (28, 'IRNA adalah kantor berita negara …', '', '{"A":"Iran","B":"India","C":"Rusia","D":"Inggris"}'::jsonb, 'A', true),
    (29, 'SIA merupakan singkatan dari …', '', '{"A":"Swiss Air","B":"Singapore Airlines","C":"Scandinavian Airlines","D":"Saudi Airlines"}'::jsonb, 'B', true),
    (30, 'Aero Mexico adalah maskapai penerbangan negara …', '', '{"A":"Italia","B":"Thailand","C":"Meksiko","D":"Tunisia"}'::jsonb, 'C', true),
    (31, 'Ahli tusuk jarum disebut juga …', '', '{"A":"Tabib","B":"Dokter","C":"Sinshe","D":"Bidan"}'::jsonb, 'C', true),
    (32, 'Kepanjangan HIV adalah …', '', '{"A":"Human Immune Virus","B":"Human Immuno Virus","C":"Health Immuno Virus","D":"Human Infection Virus"}'::jsonb, 'B', true),
    (33, 'Penyakit pes disebabkan oleh …', '', '{"A":"Virus","B":"Jamur","C":"Bakteri dan tikus","D":"Nyamuk"}'::jsonb, 'C', true),
    (34, 'Warna putih pada etiket obat menandakan obat untuk …', '', '{"A":"Obat luar","B":"Penyakit dalam","C":"Obat beracun","D":"Luka bakar"}'::jsonb, 'B', true),
    (35, 'Salah satu syarat bidai adalah …', '', '{"A":"Harus lentur","B":"Harus kuat","C":"Harus tajam","D":"Harus pendek"}'::jsonb, 'B', true),
    (36, 'Air splint adalah …', '', '{"A":"Pembalut luka","B":"Alat pernapasan","C":"Bantalan udara","D":"Obat cair"}'::jsonb, 'C', true),
    (37, 'Patah tulang yang menembus kulit disebut …', '', '{"A":"Simple","B":"Retak","C":"Compound","D":"Fisura"}'::jsonb, 'C', true),
    (38, 'Patah tulang tertutup disebut juga …', '', '{"A":"Compound","B":"Simple","C":"Greenstick","D":"Dislokasi"}'::jsonb, 'B', true),
    (39, 'Salah satu penyebab luka bakar adalah …', '', '{"A":"Air hujan","B":"Debu","C":"Api","D":"Angin"}'::jsonb, 'C', true),
    (40, 'Yang termasuk jenis luka adalah …', '', '{"A":"Luka bakar","B":"Flu","C":"Batuk","D":"Pusing"}'::jsonb, 'A', true),
    (41, 'Obat untuk mencuci luka adalah …', '', '{"A":"Sirup","B":"Alkohol","C":"Tablet","D":"Vitamin"}'::jsonb, 'B', true),
    (42, 'Fungsi minyak kayu putih adalah untuk …', '', '{"A":"Mengobati patah tulang","B":"Menghangatkan tubuh","C":"Menambah darah","D":"Mengobati luka dalam"}'::jsonb, 'B', true),
    (43, 'Gejala luka bakar tingkat 2 adalah …', '', '{"A":"Kulit kebiruan","B":"Kulit melepuh","C":"Tidak terasa sakit","D":"Kulit menghitam"}'::jsonb, 'B', true),
    (44, 'Dalam metode ABC, huruf A berarti …', '', '{"A":"Airway","B":"Action","C":"Alert","D":"Accident"}'::jsonb, 'A', true),
    (45, 'Tujuan P3K adalah …', '', '{"A":"Memperparah luka","B":"Mengurangi penderitaan korban","C":"Menambah rasa sakit","D":"Menghambat pernapasan"}'::jsonb, 'B', true),
    (46, 'Nomor gawat darurat Kota Bandung adalah …', '', '{"A":"112","B":"50505","C":"911","D":"119"}'::jsonb, 'B', true),
    (47, 'Pressure bandage artinya …', '', '{"A":"Bebat putar","B":"Pembalut tekan","C":"Pembalut cepat","D":"Kain kasa"}'::jsonb, 'B', true),
    (48, 'Jumlah darah orang dewasa sekitar …', '', '{"A":"2 liter","B":"4 liter","C":"6,25 liter","D":"10 liter"}'::jsonb, 'C', true),
    (49, 'Kehilangan darah sebanyak 1,5 liter dapat menyebabkan …', '', '{"A":"Demam","B":"Collapse","C":"Pingsan ringan","D":"Batuk"}'::jsonb, 'B', true),
    (50, 'Kehilangan darah sebanyak 2,25 liter dapat menyebabkan …', '', '{"A":"Pusing","B":"Demam","C":"Kematian","D":"Sesak napas"}'::jsonb, 'C', true),
    (51, 'Kapan Undang-Undang No. 12 Tahun 2010 tentang Gerakan Pramuka disahkan DPR?', '', '{"A":"14 Agustus 1961","B":"20 Mei 1908","C":"26 Oktober 2010","D":"28 Oktober 1928"}'::jsonb, 'C', true),
    (52, 'Saka Bakti Husada bergerak di bidang …', '', '{"A":"Kelautan","B":"Kehutanan","C":"Kesehatan","D":"Pertanian"}'::jsonb, 'C', true),
    (53, 'Jambore Nasional I dilaksanakan di …', '', '{"A":"Cibubur","B":"Situ Baru/Jagakarsa","C":"Jatinangor","D":"Baturraden"}'::jsonb, 'B', true),
    (54, 'Organisasi yang menjadi latar belakang Gerakan Pramuka adalah …', '', '{"A":"Sarekat Islam","B":"Jong Java","C":"Boedi Oetomo","D":"Muhammadiyah"}'::jsonb, 'C', true),
    (55, 'World Scout Jamboree pertama dilaksanakan di negara …', '', '{"A":"Inggris","B":"Belanda","C":"Jepang","D":"Kanada"}'::jsonb, 'A', true),
    (56, 'Siapa yang mencetuskan nama pandu atau kepanduan?', '', '{"A":"BP","B":"Sri Sultan HB IX","C":"KH Agus Salim","D":"Ki Hajar Dewantara"}'::jsonb, 'C', true),
    (57, 'Raimuna Nasional pertama dilaksanakan pada tahun …', '', '{"A":"1969","B":"1972","C":"1976","D":"1982"}'::jsonb, 'A', true),
    (58, 'Motto Gerakan Pramuka adalah …', '', '{"A":"Tut Wuri Handayani","B":"Satyaku Kudarmakan Darmaku Kubaktikan","C":"Bhinneka Tunggal Ika","D":"Ing Ngarsa Sung Tuladha"}'::jsonb, 'B', true),
    (59, 'Jambore Nasional XI dilaksanakan pada tahun …', '', '{"A":"2016","B":"2018","C":"2020","D":"2022"}'::jsonb, 'D', true),
    (60, 'Pembina SAKA disebut …', '', '{"A":"Andalan","B":"Pembina Gudep","C":"Pamong Saka","D":"Pelatih"}'::jsonb, 'C', true),
    (61, 'Jambore Dunia ke-25 diadakan di negara …', '', '{"A":"Jepang","B":"Korea Selatan","C":"Inggris","D":"Amerika Serikat"}'::jsonb, 'B', true),
    (62, 'Peristiwa Sumpah Pemuda terjadi pada tanggal …', '', '{"A":"20 Mei 1908","B":"17 Agustus 1945","C":"28 Oktober 1928","D":"14 Agustus 1961"}'::jsonb, 'C', true),
    (63, 'Jambore Nasional VII diadakan di …', '', '{"A":"Baturraden","B":"Jakarta","C":"Bandung","D":"Papua"}'::jsonb, 'A', true),
    (64, 'Buku masterpiece karya Baden Powell adalah …', '', '{"A":"Rovering to Success","B":"The Jungle Book","C":"Scouting for Boys","D":"Boys Scout"}'::jsonb, 'C', true),
    (65, '22nd World Scout Jamboree diadakan di negara …', '', '{"A":"Jepang","B":"Swedia","C":"Thailand","D":"Australia"}'::jsonb, 'B', true),
    (66, 'Ukuran bendera gudep adalah …', '', '{"A":"50 × 80 cm","B":"60 × 90 cm","C":"70 × 100 cm","D":"80 × 120 cm"}'::jsonb, 'B', true),
    (67, 'Raimuna Nasional XII dilaksanakan di …', '', '{"A":"Jayapura","B":"Sleman","C":"Jakarta Timur","D":"Bali"}'::jsonb, 'C', true),
    (68, 'Siapa yang membantu BP mendirikan Girl Guide?', '', '{"A":"Agnes dan Olave","B":"Kenneth McLaren","C":"William Debois","D":"Rudy Kipling"}'::jsonb, 'A', true),
    (69, 'Jambore Nasional IX diadakan di …', '', '{"A":"Sumatera Selatan","B":"Jawa Barat","C":"Jakarta","D":"Bali"}'::jsonb, 'A', true),
    (70, 'Kepanjangan WOSM adalah …', '', '{"A":"World Official Scout Movement","B":"World Organization Scout Movement","C":"World Organization of Scout Movement","D":"World Scout Organization Movement"}'::jsonb, 'C', true),
    (71, 'Siapa yang menjadi Pramuka Utama Gerakan Pramuka?', '', '{"A":"Ketua Kwartir Nasional","B":"Presiden Republik Indonesia","C":"Menteri Pendidikan","D":"Ketua Gudep"}'::jsonb, 'B', true),
    (72, '10th World Scout Jamboree dilaksanakan di negara …', '', '{"A":"Jepang","B":"Filipina","C":"Thailand","D":"Yunani"}'::jsonb, 'B', true),
    (73, 'Nama kepanduan saat masa Hindia Belanda adalah …', '', '{"A":"WOSM","B":"NPO","C":"NIPV","D":"BPO"}'::jsonb, 'C', true),
    (74, 'Siapa penemu morse?', '', '{"A":"Thomas Edison","B":"Samuel Finley Breese Morse","C":"Alexander Graham Bell","D":"Isaac Newton"}'::jsonb, 'B', true),
    (75, 'Raimuna Nasional VIII diadakan di …', '', '{"A":"Prambanan, Sleman","B":"Jayapura","C":"Cibubur","D":"Bali"}'::jsonb, 'A', true),
    (76, 'Hari Pramuka diperingati setiap tanggal …', '', '{"A":"2 Mei","B":"20 Mei","C":"14 Agustus","D":"28 Oktober"}'::jsonb, 'C', true),
    (77, 'BP mendapat gelar Lord pada tanggal …', '', '{"A":"22 Februari 1857","B":"6 Agustus 1920","C":"3 Desember 1934","D":"14 Agustus 1961"}'::jsonb, 'B', true),
    (78, 'Jambore Dunia tahun 2027 akan dilaksanakan di kota …', '', '{"A":"Sydney","B":"Saemangeum","C":"Gdańsk","D":"London"}'::jsonb, 'C', true),
    (79, 'Kepanjangan PRAMUKA adalah …', '', '{"A":"Praja Muda Karana","B":"Prajurit Muda Karya","C":"Pemuda Rakyat Mandiri","D":"Praja Mandiri Utama"}'::jsonb, 'A', true),
    (80, 'Landasan idiil Gerakan Pramuka adalah …', '', '{"A":"UUD 1945","B":"Tri Satya","C":"Pancasila","D":"Dasa Dharma"}'::jsonb, 'C', true),
    (81, 'Apa fungsi kompas?', '', '{"A":"Mengukur suhu","B":"Menentukan arah mata angin","C":"Menghitung waktu","D":"Mengukur jarak"}'::jsonb, 'B', true),
    (82, 'Bagian kompas yang menunjukkan arah adalah …', '', '{"A":"Dial","B":"Visir","C":"Jarum magnet","D":"Skala"}'::jsonb, 'C', true),
    (83, 'Penemu kompas pertama kali berasal dari bangsa …', '', '{"A":"Jepang","B":"Inggris","C":"Cina","D":"India"}'::jsonb, 'C', true),
    (84, 'Arah antara selatan dan barat disebut …', '', '{"A":"Tenggara","B":"Barat laut","C":"Barat daya","D":"Timur laut"}'::jsonb, 'C', true),
    (85, 'Timur berada pada derajat …', '', '{"A":"0°","B":"90°","C":"180°","D":"270°"}'::jsonb, 'B', true),
    (86, 'Derajat penuh pada kompas adalah …', '', '{"A":"90°","B":"180°","C":"270°","D":"360°"}'::jsonb, 'D', true),
    (87, 'Kompas harus dijauhkan dari benda yang bersifat …', '', '{"A":"Panas","B":"Tajam","C":"Magnetik","D":"Cair"}'::jsonb, 'C', true),
    (88, 'Sudut yang dihitung searah jarum jam dari arah utara disebut …', '', '{"A":"Navigasi","B":"Azimuth","C":"Deklinasi","D":"Deviasi"}'::jsonb, 'B', true),
    (89, 'Arah 135° menunjukkan arah …', '', '{"A":"Tenggara","B":"Barat daya","C":"Timur laut","D":"Selatan"}'::jsonb, 'A', true),
    (90, 'Selisih antara utara magnet dan utara sejati disebut …', '', '{"A":"Azimuth","B":"Deviasi","C":"Deklinasi","D":"Orientasi"}'::jsonb, 'C', true),
    (91, 'Pada malam hari arah utara dapat ditentukan dengan melihat bintang …', '', '{"A":"Orion","B":"Sirius","C":"Polaris","D":"Scorpio"}'::jsonb, 'C', true),
    (92, 'Kompas harus diletakkan secara … saat digunakan.', '', '{"A":"Miring","B":"Tegak","C":"Datar","D":"Terbalik"}'::jsonb, 'C', true),
    (93, 'Jika kompas menunjukkan 180°, maka arah yang ditunjuk adalah …', '', '{"A":"Utara","B":"Timur","C":"Barat","D":"Selatan"}'::jsonb, 'D', true),
    (94, 'Huruf N pada kompas berarti …', '', '{"A":"North","B":"New","C":"Night","D":"Near"}'::jsonb, 'A', true),
    (95, 'Ilmu untuk menentukan arah dan posisi disebut …', '', '{"A":"Astronomi","B":"Navigasi","C":"Geografi","D":"Biologi"}'::jsonb, 'B', true)
)
insert into public.questions (exam_id, sort_order, text, image, options, answer, active)
select target_exam.id, seed_questions.sort_order, seed_questions.text, seed_questions.image, seed_questions.options, seed_questions.answer, seed_questions.active
from target_exam
cross join seed_questions;

select title, subject, duration_minutes, active from public.exams where lower(title) = lower('SIMULASI DAY 14');
select count(*) as jumlah_soal_day14 from public.questions where exam_id = (select id from public.exams where lower(title) = lower('SIMULASI DAY 14') order by created_at asc limit 1);
