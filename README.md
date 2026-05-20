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

## Catatan histori peserta

Histori peserta saat ini disimpan di `localStorage`, artinya data tersimpan pada browser/perangkat yang digunakan. Jika website dipakai publik dari banyak perangkat, histori setiap perangkat tidak otomatis terkumpul di satu admin pusat.

Untuk histori terpusat dari semua peserta, proyek perlu ditambah backend/database seperti Firebase, Supabase, atau server sendiri.
