# Deployment Guide — RoomBook

**Dokumen:** Build, Configuration, and Production Deployment  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Prasyarat Lingkungan Produksi

- Server berbasis Linux (Ubuntu 22.04 LTS direkomendasikan) atau PaaS seperti Vercel, Railway, atau Coolify.
- Node.js versi 18.17.0+ atau 20.x LTS.
- PostgreSQL database versi 14+ (untuk mode production).
- Reverse Proxy Nginx dengan sertifikat SSL Let's Encrypt (jika self-hosted di VPS).

---

## 2. Variabel Lingkungan (.env)

Buat file `.env.production` pada root folder proyek:

```env
# URL Basis Aplikasi
NEXT_PUBLIC_APP_URL="https://roombook.institusi.ac.id"

# Koneksi Database
DATABASE_URL="postgresql://user:password@localhost:5432/roombook_db?schema=public"

# Kunci Rahasia Sesi / JWT
NEXTAUTH_SECRET="kunci-rahasia-acak-32-karakter-yang-sangat-kuat"
NEXTAUTH_URL="https://roombook.institusi.ac.id"

# Konfigurasi Opsional Institusi
NEXT_PUBLIC_CAMPUS_NAME="Universitas Teknologi Indonesia"
NEXT_PUBLIC_OPERATING_HOURS_START="08:00"
NEXT_PUBLIC_OPERATING_HOURS_END="18:00"
```

---

## 3. Tahapan Build & Menjalankan

### 3.1 Opsi A: Deployment di Vercel (Paling Direkomendasikan)
1. Push repositori ke GitHub / GitLab.
2. Impor proyek ke dashboard Vercel.
3. Masukkan Environment Variables di menu Project Settings.
4. Klik **Deploy**. Vercel akan otomatis mendeteksi konfigurasi Next.js dan mempublikasikannya secara serverless di CDN global.

### 3.2 Opsi B: Deployment di VPS menggunakan PM2 & Node.js
```bash
# 1. Clone repository
git clone https://github.com/institusi/roombook.git
cd roombook

# 2. Instalasi dependensi produksi
npm ci

# 3. Jalankan migrasi basis data
npx prisma migrate deploy

# 4. Generate bundle produksi Next.js
npm run build

# 5. Jalankan aplikasi menggunakan PM2 Process Manager
pm2 start npm --name "roombook" -- start -- -p 3000

# 6. Simpan konfigurasi PM2 agar otomatis jalan saat restart server
pm2 save
pm2 startup
```

---

## 4. Konfigurasi Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name roombook.institusi.ac.id;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name roombook.institusi.ac.id;

    ssl_certificate /etc/letsencrypt/live/roombook.institusi.ac.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/roombook.institusi.ac.id/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
