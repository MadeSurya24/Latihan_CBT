# CBT Simulasi Bank Soal

Website CBT simulasi bank soal berbasis React, Vite, dan Tailwind CSS.

## Menjalankan di komputer sendiri

```bash
npm install
npm run dev
```

Buka URL yang muncul di terminal, biasanya:

```text
http://localhost:5173/
```

Jika Vite memakai port lain, gunakan URL yang tertulis pada bagian `Local`.

## Diakses perangkat lain dalam satu WiFi

Jalankan:

```bash
npm run dev
```

Lalu buka URL `Network` yang muncul di terminal, misalnya:

```text
http://192.168.1.5:5174/
```

Komputer yang menjalankan server harus tetap menyala, dan perangkat lain harus berada di jaringan WiFi yang sama.

## Deploy agar bisa diakses publik

Build proyek:

```bash
npm run build
```

Upload folder proyek ini ke layanan hosting statis seperti Vercel, Netlify, Cloudflare Pages, GitHub Pages, atau hosting lain yang mendukung React/Vite.

Pengaturan umum:

- Build command: `npm run build`
- Output directory: `dist`
- Install command: `npm install`

File `vercel.json` dan `public/_redirects` sudah disiapkan agar aplikasi tetap aman jika dibuka sebagai single page app.

## Supabase untuk admin dan nilai terpusat

Aplikasi mendukung mode Supabase agar admin bisa CRUD soal dan melihat nilai semua regu.

1. Buka Supabase project.
2. Masuk ke SQL Editor.
3. Jalankan seluruh isi file `supabase/schema.sql`.
4. Jalankan aplikasi, buka mode Admin, lalu buat akun admin.
5. Buka Supabase Authentication > Users, copy UID akun admin.
6. Jalankan query penanda admin yang ada di bagian bawah `supabase/schema.sql`.

Environment variable yang perlu dipasang di Vercel:

```text
VITE_SUPABASE_URL=https://wxescpzqnlknqwxwuurg.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_zmatfjIqyNJqcEgTMuYgSg_LPxj1nja
```

Setelah environment variable dipasang, redeploy project di Vercel.

## Catatan histori regu

Jika Supabase aktif, hasil regu tersimpan ke database dan bisa dilihat admin. Jika Supabase belum aktif atau schema belum dijalankan, aplikasi memakai data lokal sebagai fallback.

Fallback lokal memakai `localStorage`, artinya data hanya tersimpan pada browser/perangkat yang digunakan.
