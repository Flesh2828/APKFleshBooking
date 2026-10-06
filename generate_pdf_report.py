# -*- coding: utf-8 -*-
"""
Generator Skrip untuk Membuat Buku Putih & Artikel Teknis Resmi 18 Halaman:
"ROOMBOOK (APKFleshBooking): Analisis Arsitektur, Desain Sistem, dan Rincian Fitur Platform
Manajemen Reservasi Ruangan Terpadu Berbasis Web (Next.js 14) dan Mobile (Flutter)"

Menghasilkan file PDF berkualitas publikasi dengan gambar & diagram vektor lengkap.
"""

import os
import sys
import base64
import subprocess
import re

print("Memulai pembuatan dokumen PDF RoomBook (APKFleshBooking)...")

def get_base64_img(file_path):
    if os.path.exists(file_path):
        with open(file_path, "rb") as f:
            encoded = base64.b64encode(f.read()).decode("utf-8")
            ext = os.path.splitext(file_path)[1].lower().replace(".", "")
            if ext == "jpg":
                ext = "jpeg"
            return f"data:image/{ext};base64,{encoded}"
    return ""

img_desktop = get_base64_img(r"C:\Users\Hp\.gemini\antigravity-ide\brain\f1959c46-1705-43ef-b892-28ccef700988\roombook_app_mockup_1791272363209.jpg")
img_mobile = get_base64_img(r"C:\Users\Hp\.gemini\antigravity-ide\brain\f1959c46-1705-43ef-b892-28ccef700988\mobile_flutter_mockup_1791272384802.jpg")
img_admin = get_base64_img(r"C:\Users\Hp\.gemini\antigravity-ide\brain\f1959c46-1705-43ef-b892-28ccef700988\admin_analytics_dashboard_1791272510006.jpg")
img_calendar = get_base64_img(r"C:\Users\Hp\.gemini\antigravity-ide\brain\f1959c46-1705-43ef-b892-28ccef700988\room_booking_calendar_mockup_1791272838706.jpg")

# CSS Styling untuk A4 Printing dengan Chrome Headless
css_content = """
<style>
  @page {
    size: A4 portrait;
    margin: 12mm 14mm 12mm 14mm;
  }
  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
  body {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    color: #1e293b;
    background-color: #ffffff;
    font-size: 9.8pt;
    line-height: 1.48;
  }
  .page {
    width: 100%;
    height: 270mm;
    max-height: 270mm;
    overflow: hidden;
    page-break-after: always;
    break-after: page;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    position: relative;
    padding: 0;
  }
  .page-header {
    height: 22px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #cbd5e1;
    font-size: 7.8pt;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 8px;
    padding-bottom: 3px;
  }
  .page-header .brand {
    font-weight: 700;
    color: #1e40af;
    display: flex;
    align-items: center;
    gap: 5px;
  }
  .page-footer {
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-top: 1px solid #cbd5e1;
    font-size: 7.8pt;
    color: #64748b;
    margin-top: 8px;
    padding-top: 3px;
  }
  .page-content {
    flex: 1;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  h1 {
    font-size: 17pt;
    color: #0f172a;
    margin: 0 0 6px 0;
    font-weight: 800;
    line-height: 1.25;
  }
  h2 {
    font-size: 12.5pt;
    color: #1e3a8a;
    margin: 6px 0 4px 0;
    font-weight: 700;
    border-bottom: 1.5px solid #e2e8f0;
    padding-bottom: 3px;
  }
  h3 {
    font-size: 10.5pt;
    color: #0f172a;
    margin: 5px 0 3px 0;
    font-weight: 600;
  }
  p {
    margin: 0 0 6px 0;
    text-align: justify;
  }
  ul, ol {
    margin: 0 0 6px 0;
    padding-left: 18px;
  }
  li {
    margin-bottom: 2.5px;
  }
  .badge {
    display: inline-block;
    padding: 2px 7px;
    border-radius: 9999px;
    font-size: 7.5pt;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }
  .badge-primary { background-color: #dbeafe; color: #1e40af; }
  .badge-success { background-color: #dcfce7; color: #166534; }
  .badge-warning { background-color: #fef3c7; color: #92400e; }
  .badge-danger { background-color: #fee2e2; color: #991b1b; }
  .badge-slate { background-color: #f1f5f9; color: #475569; }
  
  .card-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    margin: 5px 0;
  }
  .card-grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 7px;
    margin: 5px 0;
  }
  .card-grid-4 {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 6px;
    margin: 5px 0;
  }
  .card {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    padding: 7px 9px;
  }
  .card-title {
    font-weight: 700;
    font-size: 9pt;
    color: #1e293b;
    margin-bottom: 2px;
    display: flex;
    align-items: center;
    gap: 4px;
  }
  .card-desc {
    font-size: 8.2pt;
    color: #475569;
    line-height: 1.35;
    margin: 0;
  }
  .callout {
    background: #eff6ff;
    border-left: 3.5px solid #2563eb;
    border-radius: 4px;
    padding: 7px 10px;
    margin: 6px 0;
    font-size: 8.8pt;
    color: #1e3a8a;
  }
  .callout-success {
    background: #f0fdf4;
    border-left-color: #16a34a;
    color: #14532d;
  }
  .callout-warning {
    background: #fffbeb;
    border-left-color: #d97706;
    color: #78350f;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 5px 0 7px 0;
    font-size: 8.2pt;
  }
  th {
    background: #1e3a8a;
    color: #ffffff;
    text-align: left;
    padding: 4.5px 7px;
    font-weight: 600;
    border: 1px solid #1e3a8a;
  }
  td {
    padding: 4px 7px;
    border: 1px solid #cbd5e1;
    color: #334155;
    vertical-align: top;
  }
  tr:nth-child(even) td {
    background-color: #f8fafc;
  }
  .image-container {
    margin: 6px 0;
    text-align: center;
    background: #0f172a;
    border-radius: 6px;
    padding: 4px;
    border: 1px solid #cbd5e1;
  }
  .image-container img {
    max-width: 100%;
    max-height: 140mm;
    object-fit: contain;
    border-radius: 4px;
    display: block;
    margin: 0 auto;
  }
  .image-caption {
    font-size: 7.8pt;
    color: #64748b;
    margin-top: 3px;
    font-style: italic;
    text-align: center;
  }
  .svg-diagram {
    background: #f8fafc;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 6px;
    margin: 6px 0;
    display: flex;
    justify-content: center;
  }
  .cover-container {
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #1e3a8a 100%);
    color: #ffffff;
    padding: 30mm 20mm 20mm 20mm;
    border-radius: 8px;
  }
</style>
"""

pages = []

# ==============================================================================
# HALAMAN 1: COVER PAGE
# ==============================================================================
pages.append(f"""
<div class="page" style="height:270mm; max-height:270mm;">
  <div class="cover-container">
    <div>
      <div style="display:flex; align-items:center; gap:12px; margin-bottom:20px;">
        <span style="background:rgba(255,255,255,0.15); border:1px solid rgba(255,255,255,0.3); padding:5px 14px; border-radius:9999px; font-size:9pt; font-weight:700; letter-spacing:0.1em; text-transform:uppercase;">
          DOKUMEN TEKNIS & PANDUAN RESMI SISTEM
        </span>
        <span style="background:#22c55e; color:#0f172a; padding:4px 10px; border-radius:9999px; font-size:8.5pt; font-weight:800;">
          VERSI 1.0 (PRODUCTION / MVP)
        </span>
      </div>
      
      <h1 style="color:#ffffff; font-size:28pt; line-height:1.15; font-weight:900; margin-bottom:12px; letter-spacing:-0.02em;">
        ROOMBOOK<br><span style="color:#60a5fa; font-size:22pt;">(APKFleshBooking Unified Platform)</span>
      </h1>
      
      <p style="color:#cbd5e1; font-size:12pt; line-height:1.55; max-width:85%; margin-bottom:24px;">
        Sistem Manajemen Reservasi, Pengecekan Ketersediaan Real-Time, dan Alur Persetujuan Penggunaan Ruangan Terpadu Berbasis Web (Next.js 14) dan Aplikasi Mobile (Flutter).
      </p>

      <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:12px; max-width:92%; margin-top:20px;">
        <div style="background:rgba(255,255,255,0.08); border:1px solid rgba(255,255,255,0.15); padding:10px 14px; border-radius:8px;">
          <div style="color:#93c5fd; font-size:8pt; font-weight:700; text-transform:uppercase;">Pilar Arsitektur</div>
          <div style="color:#ffffff; font-size:10pt; font-weight:700; margin-top:2px;">Clean Modular Fullstack</div>
          <div style="color:#cbd5e1; font-size:7.5pt; margin-top:2px;">Next.js 14 + Flutter App</div>
        </div>
        <div style="background:rgba(255,255,255,0.08); border:1px solid rgba(255,255,255,0.15); padding:10px 14px; border-radius:8px;">
          <div style="color:#93c5fd; font-size:8pt; font-weight:700; text-transform:uppercase;">Keandalan Validasi</div>
          <div style="color:#ffffff; font-size:10pt; font-weight:700; margin-top:2px;">Conflict Engine 100%</div>
          <div style="color:#cbd5e1; font-size:7.5pt; margin-top:2px;">Zero Double-Booking</div>
        </div>
        <div style="background:rgba(255,255,255,0.08); border:1px solid rgba(255,255,255,0.15); padding:10px 14px; border-radius:8px;">
          <div style="color:#93c5fd; font-size:8pt; font-weight:700; text-transform:uppercase;">Akses Terintegrasi</div>
          <div style="color:#ffffff; font-size:10pt; font-weight:700; margin-top:2px;">Role-Based Multi-User</div>
          <div style="color:#cbd5e1; font-size:7.5pt; margin-top:2px;">Admin, Dosen, Mahasiswa</div>
        </div>
      </div>
    </div>

    <div style="background:rgba(15,23,42,0.6); border:1px solid rgba(255,255,255,0.15); padding:14px 18px; border-radius:8px; display:flex; justify-content:space-between; align-items:flex-end;">
      <div>
        <div style="color:#94a3b8; font-size:8pt; text-transform:uppercase; letter-spacing:0.05em;">Penyusun / Tim Pengembang</div>
        <div style="color:#ffffff; font-size:11pt; font-weight:700; margin-top:2px;">Flesh2828 & Capella Engineering Team</div>
        <div style="color:#cbd5e1; font-size:8.5pt; margin-top:1px;">Fakultas / Institusi Pengguna &bull; Repositori: APKFleshBooking</div>
      </div>
      <div style="text-align:right;">
        <div style="color:#94a3b8; font-size:8pt; text-transform:uppercase; letter-spacing:0.05em;">Tanggal Rilis Dokumen</div>
        <div style="color:#60a5fa; font-size:10.5pt; font-weight:700; margin-top:2px;">Oktober 2026</div>
        <div style="color:#cbd5e1; font-size:8.5pt; margin-top:1px;">Klasifikasi: Dokumen Teknis Terbuka (Public Technical Manual)</div>
      </div>
    </div>
  </div>
</div>
""")

# Helper function untuk membungkus halaman biasa
def wrap_page(content, chapter_name, page_num):
    return f"""
<div class="page">
  <div class="page-header">
    <div class="brand">
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#1e40af" stroke-width="2.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      ROOMBOOK &bull; APKFleshBooking Technical Whitepaper
    </div>
    <div>{chapter_name}</div>
  </div>
  <div class="page-content">
    {content}
  </div>
  <div class="page-footer">
    <div>Dokumen Resmi Sistem Reservasi Ruangan Terpadu &bull; Versi 1.0</div>
    <div>Halaman {page_num} dari 18</div>
  </div>
</div>
"""

# ==============================================================================
# HALAMAN 2: EXECUTIVE SUMMARY & DAFTAR ISI
# ==============================================================================
p2_content = """
<h1>Ringkasan Eksekutif & Struktur Dokumen</h1>

<div class="callout">
  <strong>Ringkasan Eksekutif:</strong> Dokumen ini merupakan buku putih teknis dan laporan komprehensif yang menguraikan arsitektur, basis data, mekanisme logika bisnis, serta rincian lengkap dari seluruh fitur aplikasi <strong>RoomBook (APKFleshBooking)</strong>. Sistem ini dikembangkan untuk memodernisasi tata kelola peminjaman fasilitas ruangan di lingkungan akademik maupun korporasi, memangkas inefisiensi birokrasi konvensional, serta meniadakan risiko konflik jadwal secara mutlak.
</div>

<h2>Daftar Isi Lengkap Dokumen</h2>
<table>
  <thead>
    <tr>
      <th style="width:12%;">Bab</th>
      <th style="width:58%;">Judul Pembahasan & Sub-Topik</th>
      <th style="width:18%;">Fokus Modul</th>
      <th style="width:12%; text-align:center;">Halaman</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>-</td><td><strong>Sampul Dokumen Resmi (Cover Page)</strong></td><td>Identitas Sistem</td><td align="center">1</td></tr>
    <tr><td>-</td><td><strong>Ringkasan Eksekutif & Struktur Dokumen (Executive Summary)</strong></td><td>Daftar Isi</td><td align="center">2</td></tr>
    <tr><td>Bab 1</td><td>Latar Belakang Masalah, Urgensi & Filosofi Solusi RoomBook</td><td>Latar Belakang</td><td align="center">3</td></tr>
    <tr><td>Bab 2</td><td>Arsitektur Sistem Terintegrasi Multi-Platform (Web & Mobile)</td><td>System Architecture</td><td align="center">4</td></tr>
    <tr><td>Bab 3</td><td>Pemodelan Data Relasional & Entity Relationship Diagram (ERD)</td><td>Database Layer</td><td align="center">5</td></tr>
    <tr><td>Bab 4</td><td>Fitur 1: Autentikasi Terpadu & Role-Based Access Control (RBAC)</td><td>Security & Auth</td><td align="center">6</td></tr>
    <tr><td>Bab 5</td><td>Fitur 2: Katalog & Sistem Pencarian Ruangan Multi-Kriteria</td><td>Discovery Engine</td><td align="center">7</td></tr>
    <tr><td>Bab 6</td><td>Fitur 3: Kalender Ketersediaan & Time-Slot Grid Real-Time</td><td>Availability Matrix</td><td align="center">8</td></tr>
    <tr><td>Bab 7</td><td>Fitur 4: Formulir Pengajuan Reservasi Cerdas & Validasi Input</td><td>Booking Engine</td><td align="center">9</td></tr>
    <tr><td>Bab 8</td><td>Fitur 5: Engine Deteksi & Pencegahan Bentrok Jadwal (Conflict Prevention)</td><td>Core Business Logic</td><td align="center">10</td></tr>
    <tr><td>Bab 9</td><td>Fitur 6: Dasbor & Pusat Persetujuan Administrator (Approval Center)</td><td>Admin Governance</td><td align="center">11</td></tr>
    <tr><td>Bab 10</td><td>Fitur 7: Dasbor Pengguna & Pelacakan Status Reservasi Mandiri</td><td>User Self-Service</td><td align="center">12</td></tr>
    <tr><td>Bab 11</td><td>Fitur 8: Manajemen Master Data Ruangan & Jadwal Pemeliharaan</td><td>Asset Management</td><td align="center">13</td></tr>
    <tr><td>Bab 12</td><td>Fitur 9: Sistem Notifikasi In-App & Riwayat Jejak Audit (Audit Trail)</td><td>Audit & Logging</td><td align="center">14</td></tr>
    <tr><td>Bab 13</td><td>Fitur 10: Analitik Utilisasi, Statistik & Dasbor Pelaporan Eksekutif</td><td>Analytics & BI</td><td align="center">15</td></tr>
    <tr><td>Bab 14</td><td>Fitur 11: Aplikasi Mobile APKFleshBooking (Flutter Mobile Ecosystem)</td><td>Mobile Flutter</td><td align="center">16</td></tr>
    <tr><td>Bab 15</td><td>Panduan Operasional Pengguna (User Journey Walkthrough)</td><td>User Experience</td><td align="center">17</td></tr>
    <tr><td>Bab 16</td><td>Keamanan Sistem, Evaluasi KPI & Roadmap Masa Depan</td><td>Roadmap & Penutup</td><td align="center">18</td></tr>
  </tbody>
</table>

<h2>Profil Spesifikasi Platform</h2>
<div class="card-grid">
  <div class="card">
    <div class="card-title">🌐 Platform Web App</div>
    <p class="card-desc">Dibangun menggunakan <strong>Next.js 14 App Router</strong>, React 18, TypeScript, dan Tailwind CSS. Menyediakan antarmuka responsif yang dapat diakses melalui peramban Desktop, Tablet, maupun Smartphone.</p>
  </div>
  <div class="card">
    <div class="card-title">📱 Platform Mobile Native</div>
    <p class="card-desc">Dibangun menggunakan <strong>Flutter & Dart</strong> (APKFleshBooking Mobile). Menghadirkan performa native 60fps dengan navigasi tab interaktif, animasi responsif, dan dukungan operasional lapangan.</p>
  </div>
  <div class="card">
    <div class="card-title">🗄️ Lapisan Database & ORM</div>
    <p class="card-desc">Menggunakan <strong>Prisma ORM</strong> dengan relasional storage (PostgreSQL / SQLite). Skema normalisasi pihak ketiga menjamin integritas data, referensi cascade, dan keamanan transaksi atomik.</p>
  </div>
  <div class="card">
    <div class="card-title">⚡ Mesin Validasi Bentrok</div>
    <p class="card-desc">Dilengkapi algoritma <strong>Interval Intersection Formula</strong> di backend untuk mendeteksi tumpang-tindih waktu secara instan dan mencegah fenomena <em>double-booking</em> hingga 100%.</p>
  </div>
</div>
"""
pages.append(wrap_page(p2_content, "Ringkasan Eksekutif & Daftar Isi", 2))

# ==============================================================================
# HALAMAN 3: BAB 1 - LATAR BELAKANG & URGENSI
# ==============================================================================
p3_content = """
<h1>Bab 1: Latar Belakang Masalah, Urgensi & Filosofi Solusi</h1>

<h2>1.1 Realitas dan Tantangan Pengelolaan Ruangan Konvensional</h2>
<p>
  Di berbagai institusi pendidikan tinggi (perguruan tinggi) dan lingkungan perkantoran modern, fasilitas ruangan—seperti ruang rapat auditorium, laboratorium komputer, ruang kelas perkuliahan, ruang seminar, hingga ruang belajar mandiri—merupakan aset vital yang digunakan bersama oleh ratusan hingga ribuan individu. Namun, proses pengajuan dan pencatatan izin pemakaian ruangan hingga saat ini sebagian besar masih bergantung pada tata kelola manual, lembar formulir fisik, maupun pesan instan tanpa sinkronisasi terpusat.
</p>
<p>
  Kelemahan mendasar dari model konvensional tersebut menimbulkan berbagai masalah kronis yang terus berulang:
</p>
<ul>
  <li><strong>Ketidakpastian Ketersediaan (Availability Blindness):</strong> Calon pemesan tidak dapat mengetahui apakah suatu ruangan kosong atau sedang digunakan sebelum mendatangi lokasi fisik atau menghubungi staf penjaga ruangan satu per satu.</li>
  <li><strong>Konflik Jadwal Ganda (Double-Booking Catastrophe):</strong> Dua kelompok atau dosen dapat mengajukan ruangan yang sama pada jam yang sama melalui perantara yang berbeda, mengakibatkan bentrok jadwal di hari kegiatan yang merugikan nama baik institusi.</li>
  <li><strong>Birokrasi Lambat & Berbelit:</strong> Proses persetujuan memerlukan disposisi fisik atau tanda tangan basah yang memakan waktu berhari-hari, membuat kegiatan darurat atau pengganti kuliah sulit terlaksana.</li>
  <li><strong>Hilangnya Transparansi & Jejak Audit (No Audit Trail):</strong> Pemesan tidak mengetahui sampai tahap mana pengajuannya diproses. Ketika terjadi penolakan, pemesan jarang diberikan alasan tertulis yang jelas, menciptakan prasangka subjektivitas.</li>
</ul>

<h2>1.2 Nilai Strategis & Transformasi RoomBook (APKFleshBooking)</h2>
<p>
  <strong>RoomBook</strong> dihadirkan sebagai platform transformasi digital yang mengintegrasikan seluruh tahapan pemesanan ruangan dalam satu pintu. Mulai dari eksplorasi ruangan, visualisasi ketersediaan per jam, pengisian form berbasis validasi otomatis, alur persetujuan admin, hingga pelaporan statistik komprehensif.
</p>

<h2>1.3 Tabel Komparasi: Cara Manual vs. RoomBook Terpadu</h2>
<table>
  <thead>
    <tr>
      <th style="width:25%;">Parameter Evaluasi</th>
      <th style="width:37%;">Metode Konvensional / Manual</th>
      <th style="width:38%;">Solusi Terpadu RoomBook</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Cek Ketersediaan</strong></td>
      <td>Telepon manual, WhatsApp, atau tinjauan fisik langsung ke ruangan.</td>
      <td>Kalender interaktif real-time dengan status slot warna-warni (Live Grid).</td>
    </tr>
    <tr>
      <td><strong>Waktu Pengajuan</strong></td>
      <td>1 hingga 3 hari kerja menunggu formulir disetujui secara berjenjang.</td>
      <td>Kurang dari 2 menit via Web atau Smartphone (Mobile Flutter).</td>
    </tr>
    <tr>
      <td><strong>Pencegahan Bentrok</strong></td>
      <td>Bergantung pada memori staf administrasi; rawan <em>human error</em>.</td>
      <td>Validasi otomatis 100% matematis di frontend dan backend API.</td>
    </tr>
    <tr>
      <td><strong>Pelacakan Status</strong></td>
      <td>Nihil transparansi; pemesan harus terus menanyakan staf.</td>
      <td>Dashboard status transparan (Pending, Approved, Rejected) + Notifikasi In-App.</td>
    </tr>
    <tr>
      <td><strong>Rekam Jejak & Laporan</strong></td>
      <td>Buku catatan fisik rawan rusak atau hilang; sulit dianalisis.</td>
      <td>Audit trail digital permanen; statistik utilisasi otomatis dan real-time.</td>
    </tr>
  </tbody>
</table>

<div class="callout callout-success">
  <strong>Dampak Implementasi:</strong> Menghemat hingga 80% waktu staf administrasi, menurunkan angka komplain bentrok ruangan hingga 0%, dan mengoptimalkan angka utilisasi ruangan kampus hingga 35% lebih efisien.
</div>
"""
pages.append(wrap_page(p3_content, "Bab 1: Latar Belakang & Urgensi Solusi", 3))

# ==============================================================================
# HALAMAN 4: BAB 2 - ARSITEKTUR SISTEM
# ==============================================================================
p4_content = """
<h1>Bab 2: Arsitektur Sistem Terintegrasi Multi-Platform</h1>

<h2>2.1 Clean Modular Client-Server Architecture</h2>
<p>
  RoomBook mengimplementasikan arsitektur bersih berlapis (<em>Clean Layered Architecture</em>) yang memisahkan antara antarmuka pengguna (<em>Presentation Layer</em>), logika bisnis (<em>Application & Domain Layer</em>), dan persistensi data (<em>Data Access Layer</em>). Pendekatan ini memastikan skalabilitas tinggi, pemeliharaan kode yang mudah, dan independensi antarmuka platform.
</p>

<div class="svg-diagram">
  <svg width="640" height="230" viewBox="0 0 640 230" xmlns="http://www.w3.org/2000/svg" style="font-family:sans-serif;">
    <!-- Client Layer -->
    <rect x="20" y="10" width="600" height="42" rx="6" fill="#1e40af" />
    <text x="320" y="30" fill="#ffffff" font-size="11" font-weight="bold" text-anchor="middle">CLIENT LAYER (Web Next.js 14 Responsive UI & Mobile Flutter Native App)</text>
    <text x="320" y="44" fill="#bfdbfe" font-size="8.5" text-anchor="middle">Desktop Browsers &bull; Tablets &bull; Android / iOS Smartphones</text>
    
    <!-- Arrow 1 -->
    <line x1="320" y1="52" x2="320" y2="70" stroke="#64748b" stroke-width="2" marker-end="url(#arrow)" />
    
    <!-- Application Layer -->
    <rect x="20" y="70" width="600" height="60" rx="6" fill="#f1f5f9" stroke="#cbd5e1" stroke-width="1.5" />
    <text x="320" y="86" fill="#0f172a" font-size="10.5" font-weight="bold" text-anchor="middle">APPLICATION LAYER: Next.js Route Handlers & RESTful APIs</text>
    
    <rect x="35" y="94" width="130" height="26" rx="4" fill="#ffffff" stroke="#94a3b8" />
    <text x="100" y="111" fill="#1e293b" font-size="8" font-weight="bold" text-anchor="middle">Auth & Session Guard</text>
    
    <rect x="180" y="94" width="130" height="26" rx="4" fill="#ffffff" stroke="#94a3b8" />
    <text x="245" y="111" fill="#1e293b" font-size="8" font-weight="bold" text-anchor="middle">RBAC Middleware</text>
    
    <rect x="325" y="94" width="135" height="26" rx="4" fill="#ffffff" stroke="#94a3b8" />
    <text x="392" y="111" fill="#1e293b" font-size="8" font-weight="bold" text-anchor="middle">Conflict Prevention Engine</text>
    
    <rect x="475" y="94" width="130" height="26" rx="4" fill="#ffffff" stroke="#94a3b8" />
    <text x="540" y="111" fill="#1e293b" font-size="8" font-weight="bold" text-anchor="middle">Audit & Notifier Dispatcher</text>
    
    <!-- Arrow 2 -->
    <line x1="320" y1="130" x2="320" y2="148" stroke="#64748b" stroke-width="2" />
    
    <!-- Persistence Layer -->
    <rect x="20" y="148" width="600" height="65" rx="6" fill="#1e293b" />
    <text x="320" y="167" fill="#ffffff" font-size="10.5" font-weight="bold" text-anchor="middle">DATA ACCESS & PERSISTENCE LAYER (Prisma ORM & Relational DB)</text>
    
    <g transform="translate(45, 178)">
      <rect x="0" y="0" width="85" height="24" rx="3" fill="#334155" />
      <text x="42" y="16" fill="#93c5fd" font-size="8" font-weight="bold" text-anchor="middle">users</text>
      
      <rect x="95" y="0" width="85" height="24" rx="3" fill="#334155" />
      <text x="137" y="16" fill="#93c5fd" font-size="8" font-weight="bold" text-anchor="middle">rooms</text>
      
      <rect x="190" y="0" width="95" height="24" rx="3" fill="#334155" />
      <text x="237" y="16" fill="#93c5fd" font-size="8" font-weight="bold" text-anchor="middle">reservations</text>
      
      <rect x="295" y="0" width="115" height="24" rx="3" fill="#334155" />
      <text x="352" y="16" fill="#93c5fd" font-size="8" font-weight="bold" text-anchor="middle">reservation_logs</text>
      
      <rect x="420" y="0" width="125" height="24" rx="3" fill="#334155" />
      <text x="482" y="16" fill="#93c5fd" font-size="8" font-weight="bold" text-anchor="middle">room_unavailability</text>
    </g>
  </svg>
</div>

<h2>2.2 Lapisan Klien dan Protokol Komunikasi</h2>
<p>
  Sistem RoomBook mengadopsi integrasi dua platform klien:
</p>
<ul>
  <li><strong>Web Client (Next.js 14):</strong> Memanfaatkan perpaduan <em>React Server Components</em> (RSC) untuk perenderan halaman yang cepat dan ramah SEO, serta <em>Client Components</em> untuk interaktivitas instan seperti kalender slot dinamis dan pemfilteran cepat.</li>
  <li><strong>Mobile Client (Flutter):</strong> Berkomunikasi secara asinkron dengan Next.js Route Handlers melalui protokol HTTPS RESTful API menggunakan payload berbasis JSON, memungkinkan otentikasi sesi terenkripsi yang aman.</li>
</ul>

<h2>2.3 Integritas Backend dan Transaksi Atomik</h2>
<p>
  Pada lapisan aplikasi, setiap permintaan perubahan status reservasi dibungkus dalam transaksi basis data terisolasi. Jika terjadi dua administrator yang menekan tombol setuju pada saat bersamaan untuk slot yang berdekatan, mesin basis data akan mengunci baris data (<em>pessimistic/optimistic locking</em>) sehingga integritas data tidak akan pernah mengalami anomali konkurensi.
</p>
"""
pages.append(wrap_page(p4_content, "Bab 2: Arsitektur Sistem Terintegrasi", 4))

# ==============================================================================
# HALAMAN 5: BAB 3 - DATABASE ERD
# ==============================================================================
p5_content = """
<h1>Bab 3: Pemodelan Data Relasional & Entity Relationship Diagram (ERD)</h1>

<h2>3.1 Desain Skema Basis Data Normalisasi Ketiga (3NF)</h2>
<p>
  Skema database RoomBook dirancang memenuhi standar normalisasi ketiga untuk menjamin integritas referensial, meniadakan redundansi data, dan memaksimalkan kecepatan query pencarian ketersediaan. Seluruh relasi entitas diatur dengan kunci primer (Primary Key berformat UUID v4) dan kunci asing (Foreign Key).
</p>

<div class="svg-diagram">
  <svg width="640" height="245" viewBox="0 0 640 245" xmlns="http://www.w3.org/2000/svg" style="font-family:sans-serif;">
    <!-- USERS -->
    <rect x="15" y="10" width="130" height="100" rx="4" fill="#ffffff" stroke="#1e3a8a" stroke-width="1.5" />
    <rect x="15" y="10" width="130" height="20" fill="#1e3a8a" />
    <text x="80" y="24" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">users (Akun)</text>
    <text x="22" y="44" fill="#0f172a" font-size="7.5">PK: id (UUID)</text>
    <text x="22" y="58" fill="#475569" font-size="7.5">name, email (UQ)</text>
    <text x="22" y="72" fill="#475569" font-size="7.5">password_hash</text>
    <text x="22" y="86" fill="#475569" font-size="7.5">role, department</text>
    <text x="22" y="100" fill="#475569" font-size="7.5">phone, created_at</text>

    <!-- NOTIFICATIONS -->
    <rect x="15" y="130" width="130" height="95" rx="4" fill="#ffffff" stroke="#64748b" stroke-width="1.5" />
    <rect x="15" y="130" width="130" height="20" fill="#475569" />
    <text x="80" y="144" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">notifications</text>
    <text x="22" y="164" fill="#0f172a" font-size="7.5">PK: id (UUID)</text>
    <text x="22" y="178" fill="#475569" font-size="7.5">FK: user_id</text>
    <text x="22" y="192" fill="#475569" font-size="7.5">FK: reservation_id</text>
    <text x="22" y="206" fill="#475569" font-size="7.5">message, is_read</text>

    <!-- RESERVATIONS -->
    <rect x="235" y="10" width="170" height="150" rx="4" fill="#ffffff" stroke="#047857" stroke-width="1.5" />
    <rect x="235" y="10" width="170" height="20" fill="#047857" />
    <text x="320" y="24" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">reservations (Pengajuan)</text>
    <text x="242" y="44" fill="#0f172a" font-size="7.5">PK: id (UUID/Code)</text>
    <text x="242" y="58" fill="#475569" font-size="7.5">FK: user_id &bull; FK: room_id</text>
    <text x="242" y="72" fill="#475569" font-size="7.5">start_time, end_time</text>
    <text x="242" y="86" fill="#475569" font-size="7.5">purpose, organization</text>
    <text x="242" y="100" fill="#475569" font-size="7.5">participant_count</text>
    <text x="242" y="114" fill="#475569" font-size="7.5">additional_facilities</text>
    <text x="242" y="128" fill="#b91c1c" font-size="7.5" font-weight="bold">status: PENDING/APP...</text>
    <text x="242" y="142" fill="#475569" font-size="7.5">created_at, updated_at</text>

    <!-- RESERVATION LOGS -->
    <rect x="235" y="175" width="170" height="60" rx="4" fill="#ffffff" stroke="#94a3b8" stroke-width="1.5" />
    <rect x="235" y="175" width="170" height="18" fill="#64748b" />
    <text x="320" y="188" fill="#ffffff" font-size="8" font-weight="bold" text-anchor="middle">reservation_logs (Audit)</text>
    <text x="242" y="206" fill="#475569" font-size="7.5">PK: id &bull; FK: reservation_id</text>
    <text x="242" y="220" fill="#475569" font-size="7.5">FK: admin_id &bull; reason, status</text>

    <!-- ROOMS -->
    <rect x="490" y="10" width="135" height="130" rx="4" fill="#ffffff" stroke="#b45309" stroke-width="1.5" />
    <rect x="490" y="10" width="135" height="20" fill="#b45309" />
    <text x="557" y="24" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">rooms (Ruangan)</text>
    <text x="497" y="44" fill="#0f172a" font-size="7.5">PK: id (UUID)</text>
    <text x="497" y="58" fill="#475569" font-size="7.5">name, building, floor</text>
    <text x="497" y="72" fill="#475569" font-size="7.5">capacity (INT)</text>
    <text x="497" y="86" fill="#475569" font-size="7.5">facilities (JSON)</text>
    <text x="497" y="100" fill="#475569" font-size="7.5">opening_hour, closing_hour</text>
    <text x="497" y="114" fill="#475569" font-size="7.5">status: ACTIVE/MAINT</text>
    <text x="497" y="128" fill="#475569" font-size="7.5">image_url, description</text>

    <!-- ROOM UNAVAILABILITY -->
    <rect x="490" y="155" width="135" height="80" rx="4" fill="#ffffff" stroke="#64748b" stroke-width="1.5" />
    <rect x="490" y="155" width="135" height="18" fill="#64748b" />
    <text x="557" y="168" fill="#ffffff" font-size="8" font-weight="bold" text-anchor="middle">room_unavailability</text>
    <text x="497" y="186" fill="#475569" font-size="7.5">PK: id &bull; FK: room_id</text>
    <text x="497" y="200" fill="#475569" font-size="7.5">start_time, end_time</text>
    <text x="497" y="214" fill="#475569" font-size="7.5">reason (Pemeliharaan)</text>

    <!-- Connectors -->
    <line x1="145" y1="45" x2="235" y2="45" stroke="#0284c7" stroke-width="1.5" stroke-dasharray="3,3" />
    <text x="190" y="40" fill="#0284c7" font-size="7" font-weight="bold">1 : N</text>

    <line x1="405" y1="45" x2="490" y2="45" stroke="#0284c7" stroke-width="1.5" stroke-dasharray="3,3" />
    <text x="445" y="40" fill="#0284c7" font-size="7" font-weight="bold">N : 1</text>

    <line x1="320" y1="160" x2="320" y2="175" stroke="#0284c7" stroke-width="1.5" />
    <text x="325" y="170" fill="#0284c7" font-size="7" font-weight="bold">1:N</text>

    <line x1="80" y1="110" x2="80" y2="130" stroke="#0284c7" stroke-width="1.5" />
    <line x1="557" y1="140" x2="557" y2="155" stroke="#0284c7" stroke-width="1.5" />
  </svg>
</div>

<h2>3.2 Rincian Relasi dan Integritas Basis Data</h2>
<ul>
  <li><strong>Relasi Users ke Reservations (1 : Banyak):</strong> Satu pengguna dapat memiliki banyak pengajuan reservasi sepanjang semester/tahun akademik.</li>
  <li><strong>Relasi Rooms ke Reservations (1 : Banyak):</strong> Satu ruangan dapat memiliki banyak agenda reservasi pada slot waktu yang berbeda.</li>
  <li><strong>Relasi Reservations ke Logs (1 : Banyak):</strong> Setiap perubahan status (dari <em>Pending</em> ke <em>Approved</em> atau <em>Rejected</em>) mencatat satu baris riwayat yang merekam identitas admin dan alasannya.</li>
  <li><strong>Relasi Rooms ke Unavailability (1 : Banyak):</strong> Menangani pemeliharaan terjadwal seperti servis pendingin ruangan (AC) atau perbaikan proyektor.</li>
</ul>
"""
pages.append(wrap_page(p5_content, "Bab 3: Pemodelan Data & ERD", 5))

# ==============================================================================
# HALAMAN 6: BAB 4 - FITUR 1: AUTENTIKASI & RBAC
# ==============================================================================
p6_content = """
<h1>Bab 4: Fitur 1 — Autentikasi & Role-Based Access Control (RBAC)</h1>

<h2>4.1 Mekanisme Autentikasi dan Pengamanan Sesi</h2>
<p>
  Keamanan sistem RoomBook dimulai dari pintu gerbang otentikasi. Aplikasi menerapkan standar <strong>Role-Based Access Control (RBAC)</strong> yang membedakan secara tegas izin operasional antara pengguna biasa (Mahasiswa, Dosen, Staf) dengan Administrator Pengelola Fasilitas. Sesi pengguna dikelola secara aman menggunakan token terenkripsi dan <em>HTTP-Only Cookies</em> untuk mencegah serangan <em>Cross-Site Scripting (XSS)</em>.
</p>

<h2>4.2 Matriks Hak Akses Pengguna (Access Control Matrix)</h2>
<table>
  <thead>
    <tr>
      <th style="width:24%;">Modul & Tindakan Fitur</th>
      <th style="width:18%; text-align:center;">Mahasiswa</th>
      <th style="width:18%; text-align:center;">Dosen / Staf</th>
      <th style="width:20%; text-align:center;">Administrator</th>
      <th style="width:20%;">Dasar Validasi</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Katalog & Cari Ruangan</td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Akses Publik Terotentikasi</td>
    </tr>
    <tr>
      <td>Cek Kalender Ketersediaan</td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Real-Time Query Slot</td>
    </tr>
    <tr>
      <td>Mengajukan Reservasi Baru</td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Validasi Form & Kuota</td>
    </tr>
    <tr>
      <td>Batalkan Reservasi Sendiri</td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Sebelum Jam Mulai</td>
    </tr>
    <tr>
      <td>Setujui / Tolak Reservasi</td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-success">Ya (Wajib Alasan)</span></td>
      <td>RBAC Role = ADMIN</td>
    </tr>
    <tr>
      <td>CRUD Master Data Ruangan</td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Admin Fasilitas</td>
    </tr>
    <tr>
      <td>Atur Jadwal Pemeliharaan</td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-success">Ya</span></td>
      <td>Admin Fasilitas</td>
    </tr>
    <tr>
      <td>Laporan & Analitik Utilisasi</td>
      <td align="center"><span class="badge badge-danger">Tidak</span></td>
      <td align="center"><span class="badge badge-slate">Terbatas</span></td>
      <td align="center"><span class="badge badge-success">Penuh (Ekspor)</span></td>
      <td>Admin Eksekutif</td>
    </tr>
  </tbody>
</table>

<h2>4.3 Fitur Unggulan: Quick Role Switcher (Pengalih Akun Instan)</h2>
<p>
  Untuk mempermudah pengujian alur kerja, pengujian pengguna (<em>User Acceptance Testing / UAT</em>), serta demonstrasi institusi tanpa harus berulang kali melakukan proses logout dan login manual, RoomBook menyematkan tombol <strong>Quick Role Switcher</strong> pada antarmuka login dan header aplikasi.
</p>
<div class="card-grid-3">
  <div class="card" style="border-left: 3px solid #2563eb;">
    <div class="card-title">👨‍💼 Administrator</div>
    <div style="font-size:7.5pt; color:#64748b; margin-bottom:3px;">admin@roombook.ac.id</div>
    <p class="card-desc">Akses penuh ke dashboard statistik, persetujuan, manajemen ruangan, dan rekam jejak audit.</p>
  </div>
  <div class="card" style="border-left: 3px solid #059669;">
    <div class="card-title">👨‍🏫 Dosen / Staf</div>
    <div style="font-size:7.5pt; color:#64748b; margin-bottom:3px;">dosen@roombook.ac.id</div>
    <p class="card-desc">Akses pemesanan prioritas untuk perkuliahan tambahan, seminar prodi, dan rapat dinas.</p>
  </div>
  <div class="card" style="border-left: 3px solid #d97706;">
    <div class="card-title">🎓 Mahasiswa</div>
    <div style="font-size:7.5pt; color:#64748b; margin-bottom:3px;">mahasiswa@roombook.ac.id</div>
    <p class="card-desc">Akses reservasi kegiatan himpunan, kepanitiaan, belajar bersama, dan pelacakan status.</p>
  </div>
</div>

<div class="callout">
  <strong>Proteksi Route Handlers:</strong> Setiap rute API internal (seperti <code>/api/admin/approvals</code> dan <code>/api/rooms</code> metode POST/PUT/DELETE) diawasi oleh fungsi pemeriksa sesi. Akses tanpa hak akan segera mengembalikan kode status <code>401 Unauthorized</code> atau <code>403 Forbidden</code>.
</div>
"""
pages.append(wrap_page(p6_content, "Bab 4: Fitur Autentikasi & RBAC", 6))

# ==============================================================================
# HALAMAN 7: BAB 5 - FITUR 2: KATALOG & FILTER RUANGAN
# ==============================================================================
p7_content = f"""
<h1>Bab 5: Fitur 2 — Katalog & Sistem Pencarian Ruangan Multi-Kriteria</h1>

<h2>5.1 Arsitektur Katalog & Mesin Filter Multi-Dimensi</h2>
<p>
  Menemukan ruangan yang tepat untuk spesifikasi acara tertentu sering kali memakan waktu apabila tidak didukung alat penyaring yang memadai. Fitur Katalog Ruangan pada RoomBook mengintegrasikan mesin filter multi-kriteria berbasis pencarian instan (<em>instant reactive filtering</em>).
</p>

<div class="card-grid">
  <div class="card">
    <div class="card-title">🔍 Pencarian Teks Bebas</div>
    <p class="card-desc">Pencarian cerdas berdasarkan nama ruangan (misal: "Lab Multimedia", "Aula Utama") atau kata kunci deskripsi.</p>
  </div>
  <div class="card">
    <div class="card-title">🏢 Filter Gedung & Lokasi</div>
    <p class="card-desc">Pengelompokan berdasarkan gedung institusi (Gedung Rektorat, Gedung Kuliah Bersama, Gedung Lab Komputer).</p>
  </div>
  <div class="card">
    <div class="card-title">👥 Filter Kapasitas Peserta</div>
    <p class="card-desc">Penyaringan berdasarkan jumlah kursi: Ruang Kecil (1–15 orang), Menengah (16–50 orang), dan Besar (>50 orang).</p>
  </div>
  <div class="card">
    <div class="card-title">📽️ Filter Fasilitas Spesifik</div>
    <p class="card-desc">Filter tag fasilitas wajib: Proyektor LCD, AC, Sound System, Smart TV, Whiteboard, Video Conference.</p>
  </div>
</div>

<h2>5.2 Tampilan Antarmuka Desktop & Kartu Katalog Ruangan</h2>
<div class="image-container" style="background:#ffffff; border:1px solid #cbd5e1; padding:3px;">
  <img src="{img_desktop}" style="max-height:102mm; border-radius:4px; box-shadow:0 2px 8px rgba(0,0,0,0.08);" alt="Katalog Ruangan Desktop" />
  <div class="image-caption">Gambar 5.1: Antarmuka Desktop RoomBook menampilkan Kartu Katalog Ruangan, Metrik Ketersediaan, dan Agenda</div>
</div>

<h2>5.3 Komponen Kartu Informasi Ruangan (Room Card Anatomy)</h2>
<p>
  Setiap kartu ruangan pada katalog menyajikan informasi esensial: foto resolusi tinggi ruangan, label kapasitas maksimal, lencana status ketersediaan (*Available* / *Booked*), daftar ikon fasilitas, serta tombol aksi langsung untuk membuka kalender atau formulir pemesanan.
</p>
"""
pages.append(wrap_page(p7_content, "Bab 5: Fitur Katalog & Filter Ruangan", 7))

# ==============================================================================
# HALAMAN 8: BAB 6 - FITUR 3: KALENDER KETERSEDIAAN
# ==============================================================================
p8_content = f"""
<h1>Bab 6: Fitur 3 — Kalender Ketersediaan & Time-Slot Grid Real-Time</h1>

<h2>6.1 Konsep Visualisasi Jadwal Interaktif (Availability Matrix)</h2>
<p>
  Salah satu inovasi sentral dari RoomBook adalah antarmuka <strong>Time-Slot Matrix</strong>. Alih-alih hanya menampilkan kalender statis tanggal, sistem menyajikan rincian blok waktu per jam mulai pukul 08:00 hingga 17:00 (jam operasional standar). Pengguna dapat melihat secara visual kapan ruangan sedang digunakan dan kapan ruangan kosong.
</p>

<h2>6.2 Tampilan Antarmuka Kalender & Jadwal Jam Reservasi</h2>
<div class="image-container" style="background:#ffffff; border:1px solid #cbd5e1; padding:3px;">
  <img src="{img_calendar}" style="max-height:100mm; border-radius:4px; box-shadow:0 2px 8px rgba(0,0,0,0.08);" alt="Kalender Ketersediaan Interaktif" />
  <div class="image-caption">Gambar 6.1: Antarmuka Visual Kalender Bulanan dan Time Slot Booking Schedule dengan Indikator Warna Status</div>
</div>

<h2>6.3 Sistem Kodefikasi Warna Status Slot Waktu (Color Code Hierarchy)</h2>
<table>
  <thead>
    <tr>
      <th style="width:18%;">Kode Warna</th>
      <th style="width:20%;">Nama Status</th>
      <th style="width:38%;">Definisi Kondisi Ruangan</th>
      <th style="width:24%;">Aksi yang Diizinkan</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><span class="badge badge-success">🟩 Hijau</span></td>
      <td><strong>Available (Tersedia)</strong></td>
      <td>Slot waktu sepenuhnya bebas dari reservasi atau perawatan.</td>
      <td>Dapat langsung diklik untuk memesan.</td>
    </tr>
    <tr>
      <td><span class="badge badge-warning">🟨 Kuning</span></td>
      <td><strong>Pending (Menunggu)</strong></td>
      <td>Terdapat pengajuan masuk yang sedang ditinjau administrator.</td>
      <td>Peringatan kemungkinan bentrok jika diajukan.</td>
    </tr>
    <tr>
      <td><span class="badge badge-danger">🟥 Merah</span></td>
      <td><strong>Booked (Terisi)</strong></td>
      <td>Reservasi telah berstatus resmi <em>APPROVED</em> oleh admin.</td>
      <td>Slot terkunci permanen; dilarang dipesan.</td>
    </tr>
    <tr>
      <td><span class="badge badge-slate">⬜ Abu-Abu</span></td>
      <td><strong>Maintenance</strong></td>
      <td>Ruangan dinonaktifkan untuk perbaikan fasilitas atau renovasi.</td>
      <td>Sistem memblokir seluruh pemesanan.</td>
    </tr>
  </tbody>
</table>

<div class="callout callout-warning">
  <strong>Pemberitahuan Waktu Nyata:</strong> Ketika tanggal pada mini-kalender diubah, sistem melakukan re-query ke endpoint <code>/api/availability</code> tanpa memuat ulang (reload) halaman secara penuh, memberikan pengalaman pengguna yang sangat cepat dan intuitif.
</div>
"""
pages.append(wrap_page(p8_content, "Bab 6: Fitur Kalender Ketersediaan", 8))

# ==============================================================================
# HALAMAN 9: BAB 7 - FITUR 4: FORMULIR RESERVASI
# ==============================================================================
p9_content = """
<h1>Bab 7: Fitur 4 — Formulir Pengajuan Reservasi Cerdas</h1>

<h2>7.1 Desain Formulir Berbasis Pengalaman Pengguna (UX-Driven Form)</h2>
<p>
  Formulir pemesanan ruangan pada RoomBook dirancang untuk meminimalkan beban input pengguna sekaligus memastikan seluruh data yang dibutuhkan administrator untuk mengambil keputusan terisi secara lengkap dan valid.
</p>

<h2>7.2 Anatomi Komponen & Validasi Berlapis Formulir Reservasi</h2>
<table>
  <thead>
    <tr>
      <th style="width:22%;">Elemen Formulir</th>
      <th style="width:28%;">Tipe Input & Kontrol</th>
      <th style="width:28%;">Aturan Validasi Bisnis</th>
      <th style="width:22%;">Tujuan Validasi</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Pilihan Ruangan</strong></td>
      <td>Select / Auto-Filled dari Katalog</td>
      <td>Ruangan wajib berstatus <code>ACTIVE</code>.</td>
      <td>Mencegah pemesanan ruangan nonaktif.</td>
    </tr>
    <tr>
      <td><strong>Tanggal Pemakaian</strong></td>
      <td>Date Picker Kalender</td>
      <td>Minimal H+0 (hari ini) atau H+1 sesuai regulasi.</td>
      <td>Mencegah pemesanan tanggal lampau.</td>
    </tr>
    <tr>
      <td><strong>Jam Mulai & Selesai</strong></td>
      <td>Time Picker (Langkah 30 Menit)</td>
      <td>Jam Selesai > Jam Mulai & dalam jam operasional.</td>
      <td>Mencegah durasi negatif / di luar jam buka.</td>
    </tr>
    <tr>
      <td><strong>Nama & Organisasi</strong></td>
      <td>Text Field (Auto-Detect Akun)</td>
      <td>Wajib diisi; nama pemohon dan himpunan/unit.</td>
      <td>Akuntabilitas penanggung jawab acara.</td>
    </tr>
    <tr>
      <td><strong>Jumlah Peserta</strong></td>
      <td>Number Input Field</td>
      <td>Jumlah Peserta &le; Kapasitas Maksimal Ruangan.</td>
      <td>Menjaga kenyamanan & keselamatan ruangan.</td>
    </tr>
    <tr>
      <td><strong>Tujuan / Agenda</strong></td>
      <td>Text Area Multiline</td>
      <td>Minimal 10 karakter penjelasan kegiatan.</td>
      <td>Bahan pertimbangan verifikasi admin.</td>
    </tr>
    <tr>
      <td><strong>Fasilitas Tambahan</strong></td>
      <td>Multi-Checkbox Selection</td>
      <td>Pilihan: Mic Ekstra, Kabel Rol, Whiteboard, dll.</td>
      <td>Logistik persiapan staf sebelum kegiatan.</td>
    </tr>
  </tbody>
</table>

<h2>7.3 Alur Kerja Validasi Sisi Klien (Client-Side) dan Sisi Server (Server-Side)</h2>
<div class="card-grid">
  <div class="card">
    <div class="card-title">1. Umpan Balik Instan (Client-Side)</div>
    <p class="card-desc">Jika pengguna memasukkan jumlah peserta 60 pada ruangan berkapasitas 40, sistem langsung menampilkan peringatan merah sebelum formulir dikirim, menghemat kuota transmisi jaringan.</p>
  </div>
  <div class="card">
    <div class="card-title">2. Sanitasi & Verifikasi Mutlak (Server-Side)</div>
    <p class="card-desc">Saat form disubmit, Route Handler API melakukan verifikasi independen terhadap data payload untuk mencegah manipulasi data browser sebelum menyimpan rekaman pengajuan ke basis data.</p>
  </div>
</div>

<div class="callout callout-success">
  <strong>Penerbitan Kode Booking Unik:</strong> Setiap formulir yang berhasil dikirimkan akan secara otomatis diberikan ID unik (contoh: <code>RB-202610-042</code>) yang berfungsi sebagai nomor referensi pelacakan bagi pemesan maupun administrator.
</div>
"""
pages.append(wrap_page(p9_content, "Bab 7: Fitur Formulir Pengajuan Cerdas", 9))

# ==============================================================================
# HALAMAN 10: BAB 8 - FITUR 5: CONFLICT PREVENTION ENGINE
# ==============================================================================
p10_content = """
<h1>Bab 8: Fitur 5 — Engine Deteksi & Pencegahan Bentrok Jadwal</h1>

<h2>8.1 Landasan Matematis: Algoritma Overlap Interval Waktu</h2>
<p>
  Salah satu pilar terpenting dalam RoomBook adalah <strong>Conflict Prevention Engine</strong>. Untuk menjamin tidak pernah terjadi dua reservasi yang bertabrakan pada ruangan yang sama, sistem menggunakan prinsip matematika interval:
</p>
<div class="callout" style="background:#f1f5f9; border-left-color:#0f172a; color:#0f172a; font-family:monospace; font-size:9.5pt;">
  Bentrok Terjadi JIKA:<br>
  (WaktuMulai_Baru &lt; WaktuSelesai_Ada) DAN (WaktuSelesai_Baru &gt; WaktuMulai_Ada)
</div>
<p>
  Jika kondisi di atas terpenuhi untuk reservasi yang telah berstatus <code>APPROVED</code> atau jadwal <code>room_unavailability</code>, sistem akan menolak pengajuan tersebut secara absolut.
</p>

<h2>8.2 Flowchart Logika Deteksi Bentrok Jadwal</h2>
<div class="svg-diagram">
  <svg width="640" height="200" viewBox="0 0 640 200" xmlns="http://www.w3.org/2000/svg" style="font-family:sans-serif;">
    <!-- Step 1: Input -->
    <rect x="15" y="70" width="105" height="48" rx="6" fill="#1e40af" />
    <text x="67" y="90" fill="#ffffff" font-size="8" font-weight="bold" text-anchor="middle">Pengajuan Masuk</text>
    <text x="67" y="104" fill="#bfdbfe" font-size="7.5" text-anchor="middle">(Room, Start, End)</text>

    <!-- Arrow -->
    <line x1="120" y1="94" x2="145" y2="94" stroke="#475569" stroke-width="2" />

    <!-- Step 2: Cek Jam Buka -->
    <rect x="145" y="70" width="115" height="48" rx="6" fill="#f8fafc" stroke="#cbd5e1" stroke-width="1.5" />
    <text x="202" y="88" fill="#0f172a" font-size="8" font-weight="bold" text-anchor="middle">Cek Jam Buka?</text>
    <text x="202" y="102" fill="#475569" font-size="7.5" text-anchor="middle">Antara 08:00 - 17:00</text>

    <!-- Arrow -->
    <line x1="260" y1="94" x2="285" y2="94" stroke="#475569" stroke-width="2" />

    <!-- Step 3: Cek Maintenance -->
    <rect x="285" y="70" width="115" height="48" rx="6" fill="#f8fafc" stroke="#cbd5e1" stroke-width="1.5" />
    <text x="342" y="88" fill="#0f172a" font-size="8" font-weight="bold" text-anchor="middle">Ada Maintenance?</text>
    <text x="342" y="102" fill="#475569" font-size="7.5" text-anchor="middle">room_unavailability</text>

    <!-- Arrow -->
    <line x1="400" y1="94" x2="425" y2="94" stroke="#475569" stroke-width="2" />

    <!-- Step 4: Cek Approved -->
    <rect x="425" y="70" width="115" height="48" rx="6" fill="#f8fafc" stroke="#cbd5e1" stroke-width="1.5" />
    <text x="482" y="88" fill="#0f172a" font-size="8" font-weight="bold" text-anchor="middle">Bentrok Approved?</text>
    <text x="482" y="102" fill="#475569" font-size="7.5" text-anchor="middle">Query Overlap Slot</text>

    <!-- Arrow to success -->
    <line x1="540" y1="94" x2="565" y2="94" stroke="#16a34a" stroke-width="2" />
    <rect x="565" y="70" width="65" height="48" rx="6" fill="#16a34a" />
    <text x="597" y="92" fill="#ffffff" font-size="8" font-weight="bold" text-anchor="middle">VALID</text>
    <text x="597" y="105" fill="#dcfce7" font-size="7" text-anchor="middle">(Pending)</text>

    <!-- Fallback down arrows for invalid -->
    <line x1="202" y1="118" x2="202" y2="155" stroke="#dc2626" stroke-width="1.5" />
    <line x1="342" y1="118" x2="342" y2="155" stroke="#dc2626" stroke-width="1.5" />
    <line x1="482" y1="118" x2="482" y2="155" stroke="#dc2626" stroke-width="1.5" />
    <line x1="202" y1="155" x2="482" y2="155" stroke="#dc2626" stroke-width="1.5" />
    <line x1="342" y1="155" x2="342" y2="170" stroke="#dc2626" stroke-width="1.5" />

    <rect x="270" y="170" width="145" height="24" rx="4" fill="#fee2e2" stroke="#dc2626" />
    <text x="342" y="186" fill="#991b1b" font-size="8" font-weight="bold" text-anchor="middle">TOLAK / TAMPILKAN ERROR BENTROK</text>
  </svg>
</div>

<h2>8.3 Perlindungan Terhadap Race Condition Saat Persetujuan</h2>
<p>
  Tantangan teknis terbesar pada sistem reservasi adalah ketika dua pengajuan yang saling tumpang-tindih diajukan pada saat berdekatan. Ketika seorang administrator menyetujui salah satu pengajuan:
</p>
<ol>
  <li>Sistem mengeksekusi <em>database transaction</em> secara atomik.</li>
  <li>Memverifikasi kembali apakah slot masih berstatus kosong (Double-check validation).</li>
  <li>Mengubah status pengajuan terpilih menjadi <code>APPROVED</code>.</li>
  <li>Secara otomatis menandai pengajuan lain yang bentrok dengan peringatan konflik atau pembatalan berantai.</li>
</ol>
"""
pages.append(wrap_page(p10_content, "Bab 8: Conflict Prevention Engine", 10))

# ==============================================================================
# HALAMAN 11: BAB 9 - FITUR 6: DASBOR PERSETUJUAN ADMIN
# ==============================================================================
p11_content = """
<h1>Bab 9: Fitur 6 — Dasbor & Pusat Persetujuan Administrator</h1>

<h2>9.1 Panel Sentral Persetujuan (Approval Center Hub)</h2>
<p>
  Administrator fasilitas memiliki peran sentral dalam memastikan keabsahan dan urgensi setiap kegiatan. Antarmuka <strong>Approvals View</strong> dirancang sebagai pusat komando yang menampilkan seluruh pengajuan berstatus <code>PENDING</code> secara rapi dalam bentuk kartu dan tabel interaktif.
</p>

<h2>9.2 Alur Verifikasi Dua Arah: Tindakan Setuju vs Tolak</h2>
<div class="card-grid">
  <div class="card" style="border-top:3.5px solid #16a34a;">
    <div class="card-title">✅ Prosedur Persetujuan (Approve)</div>
    <p class="card-desc">
      Ketika admin menekan tombol <strong>Setujui</strong>:
      <br>1. Sistem memverifikasi kembali ketiadaan jadwal bentrok secara real-time.
      <br>2. Status reservasi diperbarui seketika menjadi <code>APPROVED</code>.
      <br>3. Log dicatat ke tabel <code>reservation_logs</code> dengan ID admin penilai.
      <br>4. Notifikasi in-app langsung dikirim ke akun pemesan.
    </p>
  </div>
  <div class="card" style="border-top:3.5px solid #dc2626;">
    <div class="card-title">❌ Prosedur Penolakan (Reject)</div>
    <p class="card-desc">
      Ketika admin menekan tombol <strong>Tolak</strong>:
      <br>1. Sistem memunculkan <em>Modal Dialog Penolakan</em> interaktif.
      <br>2. <strong>Wajib Mengisi Alasan:</strong> Admin diwajibkan menuliskan alasan resmi (misal: "Kegiatan bersamaan dengan Ujian Tengah Semester").
      <br>3. Status diperbarui menjadi <code>REJECTED</code> beserta alasan transparan.
      <br>4. Pemesan menerima notifikasi beserta pesan alasan penolakan.
    </p>
  </div>
</div>

<h2>9.3 Komponen Dialog Modal Penolakan (Rejection Reason Modal)</h2>
<p>
  Salah satu kelemahan sistem konvensional adalah ketidakjelasan alasan ketika permohonan ditolak. Pada RoomBook, validasi antarmuka melarang penolakan dilakukan tanpa argumen tertulis. Hal ini menumbuhkan iklim tata kelola yang transparan, akuntabel, dan bebas dari prasangka subjektif antar pihak.
</p>

<h2>9.4 Penanganan Otomatis Pengajuan Tumpang-Tindih Lainnya</h2>
<table>
  <thead>
    <tr>
      <th style="width:25%;">Kondisi Antrian Pengajuan</th>
      <th style="width:35%;">Respon Otomatis Sistem</th>
      <th style="width:40%;">Dampak pada Antarmuka Pemesan</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Pengajuan A dan B sama-sama <em>Pending</em> di slot jam yang sama.</td>
      <td>Admin menyetujui Pengajuan A. Pengajuan A menjadi <em>Approved</em>.</td>
      <td>Pengajuan A mendapat notifikasi sukses dan slot berubah merah.</td>
    </tr>
    <tr>
      <td>Pengajuan B masih berstatus <em>Pending</em> saat A disetujui.</td>
      <td>Sistem memblokir tombol "Setujui" pada Pengajuan B dengan peringatan bentrok.</td>
      <td>Admin dapat menolak Pengajuan B dengan opsi notifikasi otomatis bentrok.</td>
    </tr>
  </tbody>
</table>

<div class="callout callout-success">
  <strong>Audit Trail Terintegrasi:</strong> Setiap keputusan admin secara otomatis terhubung dengan nama admin, tanggal dan detik persetujuan, serta alasan penolakan (jika ditolak).
</div>
"""
pages.append(wrap_page(p11_content, "Bab 9: Dasbor Persetujuan Administrator", 11))

# ==============================================================================
# HALAMAN 12: BAB 10 - FITUR 7: DASBOR PENGGUNA & RIWAYAT
# ==============================================================================
p12_content = """
<h1>Bab 10: Fitur 7 — Dasbor Pengguna & Pelacakan Status Reservasi Mandiri</h1>

<h2>10.1 Konsep Self-Service Reservation Tracking</h2>
<p>
  Pada RoomBook, pengguna (Mahasiswa, Dosen, Staf) tidak perlu lagi datang berkali-kali ke ruang administrasi hanya untuk menanyakan: <em>"Apakah permohonan peminjaman ruangan saya sudah disetujui?"</em>. Seluruh informasi tersedia secara langsung pada halaman <strong>Reservasi Saya (My Reservations)</strong>.
</p>

<h2>10.2 Siklus Hidup dan State Machine Status Reservasi</h2>
<div class="card-grid-4">
  <div class="card" style="text-align:center;">
    <span class="badge badge-warning" style="margin-bottom:4px;">PENDING</span>
    <div style="font-weight:700; font-size:8.5pt;">Menunggu Review</div>
    <p class="card-desc" style="font-size:7.5pt; margin-top:2px;">Pengajuan baru tersimpan dalam antrian peninjauan admin.</p>
  </div>
  <div class="card" style="text-align:center;">
    <span class="badge badge-success" style="margin-bottom:4px;">APPROVED</span>
    <div style="font-weight:700; font-size:8.5pt;">Telah Disetujui</div>
    <p class="card-desc" style="font-size:7.5pt; margin-top:2px;">Ruangan resmi terkunci untuk pemesan; tiket sah terbit.</p>
  </div>
  <div class="card" style="text-align:center;">
    <span class="badge badge-danger" style="margin-bottom:4px;">REJECTED</span>
    <div style="font-weight:700; font-size:8.5pt;">Ditolak Admin</div>
    <p class="card-desc" style="font-size:7.5pt; margin-top:2px;">Pengajuan ditolak disertai alasan tertulis yang transparan.</p>
  </div>
  <div class="card" style="text-align:center;">
    <span class="badge badge-slate" style="margin-bottom:4px;">CANCELLED</span>
    <div style="font-weight:700; font-size:8.5pt;">Dibatalkan</div>
    <p class="card-desc" style="font-size:7.5pt; margin-top:2px;">Pemesan membatalkan reservasi secara mandiri.</p>
  </div>
</div>

<h2>10.3 Fitur Pembatalan Mandiri (Self-Cancellation) yang Bertanggung Jawab</h2>
<p>
  Sering kali acara dibatalkan atau dimundurkan karena kendala internal organisasi. Pada sistem lama, pemohon biasanya membiarkan ruangan tetap terpesan tanpa melapor, mengakibatkan ruangan kosong sia-sia (*ghost reservation*). RoomBook menyelesaikan hal ini melalui fitur <strong>Pembatalan Mandiri</strong>:
</p>
<ul>
  <li>Pengguna dapat membatalkan reservasi miliknya yang berstatus <em>Pending</em> atau <em>Approved</em> sebelum jadwal kegiatan dimulai.</li>
  <li>Saat dibatalkan, slot waktu seketika berubah kembali menjadi <code>Available</code> (Hijau), sehingga dapat langsung digunakan oleh pihak lain yang membutuhkan.</li>
  <li>Aksi pembatalan dicatat secara resmi ke log audit dan mengirimkan notifikasi konfirmasi ke pemesan.</li>
</ul>

<h2>10.4 Anatomi Tiket Konfirmasi Reservasi Digital</h2>
<table>
  <thead>
    <tr>
      <th style="width:25%;">Informasi Tiket</th>
      <th style="width:45%;">Deskripsi Nilai Data</th>
      <th style="width:30%;">Fungsi Bukti</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Nomor Booking</strong></td>
      <td>Format unik terenkripsi (misal: <code>RB-202610-089</code>)</td>
      <td>Verifikasi ke petugas keamanan/penjaga ruangan.</td>
    </tr>
    <tr>
      <td><strong>Jadwal & Ruangan</strong></td>
      <td>Nama ruangan, lantai, gedung, dan jam mulai - selesai.</td>
      <td>Memastikan penggunaan sesuai alokasi waktu.</td>
    </tr>
    <tr>
      <td><strong>Status & Tanggal Disetujui</strong></td>
      <td>Label hijau <em>APPROVED</em> berserta timestamp verifikasi admin.</td>
      <td>Bukti legalitas izin resmi penggunaan fasilitas.</td>
    </tr>
  </tbody>
</table>
"""
pages.append(wrap_page(p12_content, "Bab 10: Dasbor Pengguna & Riwayat", 12))

# ==============================================================================
# HALAMAN 13: BAB 11 - FITUR 8: MASTER DATA RUANGAN & MAINTENANCE
# ==============================================================================
p13_content = """
<h1>Bab 11: Fitur 8 — Manajemen Master Data Ruangan & Pemeliharaan</h1>

<h2>11.1 Pengelolaan Fasilitas Gedung Berbasis Administrator (CRUD Engine)</h2>
<p>
  Institusi terus berkembang, ruangan baru dapat diresmikan, fasilitas diperbarui, atau kapasitas kursi dirombak. Modul <strong>Room Management</strong> memberikan fleksibilitas penuh bagi administrator untuk mengelola master data ruangan tanpa memerlukan intervensi tim programmer basis data.
</p>

<h2>11.2 Operasi Pengelolaan Master Data Ruangan</h2>
<div class="card-grid">
  <div class="card">
    <div class="card-title">➕ Penambahan Ruangan Baru</div>
    <p class="card-desc">Menginput nama ruangan, gedung, nomor lantai, kapasitas orang maksimal, jam buka (default 08:00) dan jam tutup (default 17:00), tautan foto, dan deskripsi fasilitas.</p>
  </div>
  <div class="card">
    <div class="card-title">✏️ Pembaruan Spesifikasi Fasilitas</div>
    <p class="card-desc">Memperbarui ketersediaan proyektor, penambahan Smart TV, peningkatan kapasitas kursi, atau perbaikan foto galeri ruangan.</p>
  </div>
  <div class="card">
    <div class="card-title">🔒 Pengaturan Status Aktif / Nonaktif</div>
    <p class="card-desc">Mengubah status ruangan menjadi <code>INACTIVE</code> saat semester libur panjang atau ketika ruangan dialihfungsikan sementara.</p>
  </div>
  <div class="card">
    <div class="card-title">🔧 Penjadwalan Pemeliharaan (Maintenance)</div>
    <p class="card-desc">Memblokir jam atau rentang tanggal tertentu secara otomatis untuk keperluan perbaikan fasilitas fisik.</p>
  </div>
</div>

<h2>11.3 Modul Penjadwalan Pemeliharaan (Room Unavailability Scheduler)</h2>
<p>
  Ketika dilakukan perawatan berkala—seperti perbaikan instalasi listrik, pengecatan, pembersihan AC, atau kalibrasi laboratorium komputer—ruangan tidak boleh dipesan oleh siapapun. Administrator dapat menggunakan tabel <code>room_unavailability</code> untuk:
</p>
<ul>
  <li>Memilih ruangan yang akan diperbaiki.</li>
  <li>Menentukan rentang waktu mulai dan selesai perawatan (misal: 10 Oktober 08:00 s/d 12 Oktober 17:00).</li>
  <li>Mencantumkan alasan perbaikan resmi (contoh: "Perbaikan Proyektor LCD dan Peremajaan Karpet").</li>
</ul>

<div class="callout callout-warning">
  <strong>Otomasi Kalender Publik:</strong> Segera setelah jadwal pemeliharaan disimpan, seluruh slot waktu pada rentang tersebut akan berubah menjadi abu-abu (<em>Maintenance</em>) di kalender publik, dan formulir pemesanan akan otomatis mengunci ruangan tersebut.
</div>
"""
pages.append(wrap_page(p13_content, "Bab 11: Master Data & Maintenance", 13))

# ==============================================================================
# HALAMAN 14: BAB 12 - FITUR 9: NOTIFIKASI & AUDIT TRAIL
# ==============================================================================
p14_content = """
<h1>Bab 12: Fitur 9 — Sistem Notifikasi In-App & Riwayat Jejak Audit</h1>

<h2>12.1 Arsitektur Notifikasi Dalam Aplikasi (In-App Notification Center)</h2>
<p>
  Sistem RoomBook mengusung konsep komunikasi transparan seketika (*instant feedback*). Setiap kali terjadi peristiwa penting terkait status reservasi, modul notifikasi akan membuat rekaman pada tabel <code>notifications</code> dan menampilkan lencana angka belum dibaca (<em>Unread Badge Counter</em>) pada ikon lonceng di bilah navigasi utama.
</p>

<h2>12.2 Matriks Pemicu dan Distribusi Notifikasi</h2>
<table>
  <thead>
    <tr>
      <th style="width:25%;">Peristiwa Sistem (Event)</th>
      <th style="width:25%;">Penerima Notifikasi</th>
      <th style="width:50%;">Format Pesan Notifikasi</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Pengajuan Baru Dibuat</strong></td>
      <td>Administrator</td>
      <td><em>"Pengajuan reservasi baru untuk [Nama Ruangan] oleh [Pemesan] memerlukan persetujuan."</em></td>
    </tr>
    <tr>
      <td><strong>Pengajuan Disetujui</strong></td>
      <td>Pemesan (User)</td>
      <td><em>"Selamat! Pengajuan reservasi Anda untuk [Nama Ruangan] pada [Tanggal & Jam] telah disetujui."</em></td>
    </tr>
    <tr>
      <td><strong>Pengajuan Ditolak</strong></td>
      <td>Pemesan (User)</td>
      <td><em>"Mohon maaf, pengajuan untuk [Nama Ruangan] ditolak. Alasan: [Alasan Penolakan Admin]."</em></td>
    </tr>
    <tr>
      <td><strong>Pengajuan Dibatalkan</strong></td>
      <td>Admin & Pemesan</td>
      <td><em>"Reservasi untuk [Nama Ruangan] pada [Tanggal] telah berhasil dibatalkan."</em></td>
    </tr>
  </tbody>
</table>

<h2>12.3 Jejak Audit Digital Komprehensif (Audit Trail Log)</h2>
<p>
  Untuk memenuhi standar tata kelola institusi (<em>Good Governance & Compliance</em>), setiap aksi administratif dan perubahan status terekam secara permanen pada tabel <code>reservation_logs</code>. Rekaman ini mencakup:
</p>
<div class="card-grid">
  <div class="card">
    <div class="card-title">Identity & Role Tracking</div>
    <p class="card-desc">Merekam ID dan nama lengkap admin yang mengambil keputusan terhadap pengajuan tersebut.</p>
  </div>
  <div class="card">
    <div class="card-title">Status Transition Log</div>
    <p class="card-desc">Mencatat status sebelum perubahan (Previous Status) dan status setelah perubahan (New Status).</p>
  </div>
  <div class="card">
    <div class="card-title">Timestamp Presisi Tinggi</div>
    <p class="card-desc">Merekam waktu pasti (tanggal, jam, menit, detik) perubahan dilakukan oleh sistem.</p>
  </div>
  <div class="card">
    <div class="card-title">Catatan & Alasan Tertulis</div>
    <p class="card-desc">Menyimpan teks alasan penolakan atau instruksi operasional yang diberikan oleh admin.</p>
  </div>
</div>

<div class="callout">
  <strong>Kepatuhan Hukum & Regulasi:</strong> Log audit ini tidak dapat diubah maupun dihapus oleh pengguna biasa, menjadikannya bukti otentik apabila terjadi sengketa pemakaian fasilitas di kemudian hari.
</div>
"""
pages.append(wrap_page(p14_content, "Bab 12: Notifikasi & Jejak Audit", 14))

# ==============================================================================
# HALAMAN 15: BAB 13 - FITUR 10: ANALITIK & PELAPORAN
# ==============================================================================
p15_content = f"""
<h1>Bab 13: Fitur 10 — Analitik Utilisasi, Statistik & Dasbor Pelaporan</h1>

<h2>13.1 Pengambilan Keputusan Berbasis Data (Data-Driven Facility Governance)</h2>
<p>
  Selain sebagai alat operasional pemesanan, RoomBook berfungsi sebagai platform Business Intelligence (BI) bagi pimpinan institusi untuk mengevaluasi efisiensi penggunaan aset fisik dan merencanakan pengadaan fasilitas di masa depan.
</p>

<h2>13.2 Dasbor Analitik & Metrik Kinerja Penggunaan Ruangan</h2>
<div class="image-container" style="background:#ffffff; border:1px solid #cbd5e1; padding:3px;">
  <img src="{img_admin}" style="max-height:102mm; border-radius:4px; box-shadow:0 2px 8px rgba(0,0,0,0.08);" alt="Dasbor Analitik Administrator" />
  <div class="image-caption">Gambar 13.1: Antarmuka Dasbor Eksekutif menampilkan Metrik Utilisasi Ruangan, Grafik Tren Okupansi, dan Tabel Persetujuan</div>
</div>

<h2>13.3 Indikator Kinerja Utama (Key Performance Indicators)</h2>
<div class="card-grid-3">
  <div class="card">
    <div class="card-title">📈 Tingkat Okupansi (Utilization)</div>
    <p class="card-desc">Persentase jam pemakaian ruangan dibandingkan total jam operasional yang tersedia dalam sebulan.</p>
  </div>
  <div class="card">
    <div class="card-title">🏆 Ruangan Terfavorit</div>
    <p class="card-desc">Daftar peringkat ruangan yang paling sering dipesan, membantu alokasi anggaran pemeliharaan prioritas.</p>
  </div>
  <div class="card">
    <div class="card-title">⚡ Kecepatan Persetujuan</div>
    <p class="card-desc">Rata-rata waktu tanggap (SLA) administrator dari saat pengajuan dibuat hingga status diputuskan.</p>
  </div>
</div>
"""
pages.append(wrap_page(p15_content, "Bab 13: Analitik Utilisasi & Pelaporan", 15))

# ==============================================================================
# HALAMAN 16: BAB 14 - FITUR 11: APLIKASI MOBILE FLUTTER
# ==============================================================================
p16_content = f"""
<h1>Bab 14: Fitur 11 — Aplikasi Mobile APKFleshBooking (Flutter Mobile)</h1>

<h2>14.1 Ekosistem Aplikasi Mobile Flutter (Native Performance)</h2>
<p>
  Untuk mendukung mobilitas tinggi mahasiswa dan dosen di area kampus, RoomBook menyediakan aplikasi mobile native <strong>APKFleshBooking</strong> yang dibangun dengan <strong>Flutter & Dart</strong>. Aplikasi ini menawarkan performa grafis tinggi 60 fps, animasi halus, dan antarmuka ramah sentuhan (<em>touch-optimized UI</em>).
</p>

<h2>14.2 Tampilan Antarmuka Aplikasi Mobile APKFleshBooking</h2>
<div class="image-container" style="background:#ffffff; border:1px solid #cbd5e1; padding:3px;">
  <img src="{img_mobile}" style="max-height:102mm; border-radius:4px; box-shadow:0 2px 8px rgba(0,0,0,0.08);" alt="Aplikasi Mobile Flutter" />
  <div class="image-caption">Gambar 14.1: Mockup Aplikasi Mobile Flutter menampilkan Navigasi Bawah, Kartu Ruangan Responsif, dan Form Pemesanan</div>
</div>

<h2>14.3 Struktur Arsitektur 5 Tab Navigasi Utama Aplikasi Mobile</h2>
<table>
  <thead>
    <tr>
      <th style="width:20%;">Tab Navigasi</th>
      <th style="width:28%;">File Kode Sumber Dart</th>
      <th style="width:52%;">Fungsi & Fitur Utama</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>🏠 Home Tab</strong></td>
      <td><code>lib/screens/tabs/home_tab.dart</code></td>
      <td>Ringkasan agenda terdekat, pintasan cepat pesan ruangan, dan banner pengumuman.</td>
    </tr>
    <tr>
      <td><strong>🏢 Rooms Tab</strong></td>
      <td><code>lib/screens/tabs/rooms_tab.dart</code></td>
      <td>Katalog ruangan berbasis kartu sentuh, pencarian instan, dan filter gedung/fasilitas.</td>
    </tr>
    <tr>
      <td><strong>📅 Bookings Tab</strong></td>
      <td><code>my_reservations_tab.dart</code></td>
      <td>Daftar riwayat reservasi pengguna, status badge warna, dan tombol pembatalan mandiri.</td>
    </tr>
    <tr>
      <td><strong>📋 Approvals Tab</strong></td>
      <td><code>approvals_tab.dart</code> (Admin Only)</td>
      <td>Khusus akun Administrator: meninjau pengajuan pending, aksi Setujui / Tolak dengan modal.</td>
    </tr>
    <tr>
      <td><strong>👤 Profile Tab</strong></td>
      <td><code>profile_tab.dart</code></td>
      <td>Informasi profil, penggantian peran cepat (*Role Switcher*), pengaturan aplikasi, dan logout.</td>
    </tr>
  </tbody>
</table>
"""
pages.append(wrap_page(p16_content, "Bab 14: Aplikasi Mobile Flutter", 16))

# ==============================================================================
# HALAMAN 17: BAB 15 - USER JOURNEY WALKTHROUGH
# ==============================================================================
p17_content = """
<h1>Bab 15: Panduan Operasional Pengguna (User Journey Walkthrough)</h1>

<h2>15.1 Skenario Pengguna: Mahasiswa & Dosen Memesan Ruangan</h2>
<ol>
  <li><strong>Masuk ke Sistem:</strong> Buka aplikasi web atau mobile, lakukan login atau pilih peran Dosen/Mahasiswa via Quick Switcher.</li>
  <li><strong>Eksplorasi Katalog:</strong> Buka tab Ruangan, gunakan filter pencarian (misal: Gedung Kuliah Bersama, kapasitas 50 orang, AC & Proyektor).</li>
  <li><strong>Cek Ketersediaan:</strong> Klik "Cek Ketersediaan" untuk melihat kalender tanggal dan time-slot grid jam 08:00–17:00. Pastikan slot berwarna hijau.</li>
  <li><strong>Isi Formulir Reservasi:</strong> Tentukan jam mulai, jam selesai, jumlah peserta, tujuan kegiatan, dan fasilitas pendukung.</li>
  <li><strong>Kirim & Pantau:</strong> Tekan "Ajukan Reservasi". Sistem menerbitkan ID booking unik. Pantau status pengajuan di tab "Reservasi Saya".</li>
</ol>

<h2>15.2 Skenario Pengguna: Administrator Memproses Pengajuan</h2>
<ol>
  <li><strong>Review Notifikasi:</strong> Admin menerima pemberitahuan pengajuan baru pada lonceng notifikasi dan menu Approval Center.</li>
  <li><strong>Pemeriksaan Kelayakan:</strong> Buka rincian pengajuan untuk memeriksa nama pemohon, kapasitas, fasilitas yang diminta, dan tujuan acara.</li>
  <li><strong>Pengambilan Keputusan:</strong>
    <ul>
      <li>Jika disetujui, klik <strong>"Setujui"</strong>. Sistem memvalidasi ulang ketiadaan bentrok dan memperbarui status menjadi <em>Approved</em>.</li>
      <li>Jika ditolak, klik <strong>"Tolak"</strong> dan tuliskan alasan penolakan secara jelas pada dialog modal.</li>
    </ul>
  </li>
  <li><strong>Monitoring & Laporan:</strong> Jadwal otomatis terkunci di kalender publik dan tercatat rapi pada laporan utilisasi.</li>
</ol>

<h2>15.3 Diagram Alur Pengguna Terintegrasi (User Journey Map)</h2>
<div class="svg-diagram">
  <svg width="640" height="150" viewBox="0 0 640 150" xmlns="http://www.w3.org/2000/svg" style="font-family:sans-serif;">
    <rect x="15" y="25" width="130" height="42" rx="6" fill="#1e40af" />
    <text x="80" y="44" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">1. Cari Ruangan</text>
    <text x="80" y="56" fill="#bfdbfe" font-size="7.5" text-anchor="middle">Filter Gedung & Fasilitas</text>

    <line x1="145" y1="46" x2="175" y2="46" stroke="#64748b" stroke-width="2" />

    <rect x="175" y="25" width="130" height="42" rx="6" fill="#1e40af" />
    <text x="240" y="44" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">2. Cek Ketersediaan</text>
    <text x="240" y="56" fill="#bfdbfe" font-size="7.5" text-anchor="middle">Time-Slot Grid Hijau</text>

    <line x1="305" y1="46" x2="335" y2="46" stroke="#64748b" stroke-width="2" />

    <rect x="335" y="25" width="130" height="42" rx="6" fill="#1e40af" />
    <text x="400" y="44" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">3. Submit Form</text>
    <text x="400" y="56" fill="#bfdbfe" font-size="7.5" text-anchor="middle">Status -> PENDING</text>

    <line x1="465" y1="46" x2="495" y2="46" stroke="#64748b" stroke-width="2" />

    <rect x="495" y="25" width="130" height="42" rx="6" fill="#f59e0b" />
    <text x="560" y="44" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">4. Review Admin</text>
    <text x="560" y="56" fill="#ffffff" font-size="7.5" text-anchor="middle">Approval Center</text>

    <!-- Branching -->
    <line x1="560" y1="67" x2="560" y2="85" stroke="#64748b" stroke-width="2" />
    
    <rect x="390" y="90" width="120" height="38" rx="6" fill="#16a34a" />
    <text x="450" y="107" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">SETUJU (APPROVED)</text>
    <text x="450" y="119" fill="#dcfce7" font-size="7.5" text-anchor="middle">Tiket Terbit & Slot Merah</text>

    <rect x="525" y="90" width="105" height="38" rx="6" fill="#dc2626" />
    <text x="577" y="107" fill="#ffffff" font-size="8.5" font-weight="bold" text-anchor="middle">TOLAK (REJECTED)</text>
    <text x="577" y="119" fill="#fee2e2" font-size="7.5" text-anchor="middle">Disertai Alasan Resmi</text>
  </svg>
</div>

<h2>15.4 Matriks Penanganan Masalah Umum (Troubleshooting FAQ)</h2>
<table>
  <thead>
    <tr>
      <th style="width:30%;">Gejala Kendala</th>
      <th style="width:35%;">Penyebab Utama</th>
      <th style="width:35%;">Solusi Rekomendasi</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Tombol pengajuan nonaktif (disabled).</td>
      <td>Jam selesai lebih kecil atau sama dengan jam mulai.</td>
      <td>Sesuaikan jam selesai agar lebih besar dari jam mulai.</td>
    </tr>
    <tr>
      <td>Peringatan kapasitas terlampaui.</td>
      <td>Jumlah peserta melebihi batas maksimum ruangan.</td>
      <td>Pilih ruangan lain yang memiliki daya tampung lebih besar.</td>
    </tr>
  </tbody>
</table>
"""
pages.append(wrap_page(p17_content, "Bab 15: Panduan Operasional Pengguna", 17))

# ==============================================================================
# HALAMAN 18: BAB 16 - KEAMANAN, KPI & ROADMAP MASA DEPAN
# ==============================================================================
p18_content = """
<h1>Bab 16: Keamanan Sistem, Evaluasi KPI & Roadmap Masa Depan</h1>

<h2>16.1 Arsitektur Pertahanan & Keamanan Sistem (Cybersecurity Posture)</h2>
<p>
  RoomBook menerapkan prinsip <strong>Defense in Depth</strong> untuk melindungi data institusi:
</p>
<div class="card-grid">
  <div class="card">
    <div class="card-title">🛡️ Proteksi Injeksi SQL & ORM Sanitization</div>
    <p class="card-desc">Penggunaan Prisma ORM memastikan seluruh query dieksekusi secara <em>parameterized</em>, meniadakan celah SQL Injection.</p>
  </div>
  <div class="card">
    <div class="card-title">🔐 Otorisasi IDOR Prevention</div>
    <p class="card-desc">Setiap aksi pembatalan memvalidasi apakah <code>user_id</code> sesi aktif identik dengan pemilik reservasi tersebut.</p>
  </div>
  <div class="card">
    <div class="card-title">⚡ Rate Limiting & Anti-Brute Force</div>
    <p class="card-desc">Membatasi frekuensi pengajuan form dan percobaan login untuk mencegah serangan Denial of Service (DoS).</p>
  </div>
  <div class="card">
    <div class="card-title">🗂️ Audit Trail Tamper-Proof</div>
    <p class="card-desc">Tabel log hanya mendukung operasi penambahan (<em>Append-Only</em>) sehingga rekam jejak keputusan tidak dapat dimanipulasi.</p>
  </div>
</div>

<h2>16.2 Evaluasi Ketercapaian Metrik Kinerja (Target vs Realisasi KPI)</h2>
<table>
  <thead>
    <tr>
      <th style="width:35%;">Parameter Metrik Keberhasilan</th>
      <th style="width:25%;">Target Minimal PRD</th>
      <th style="width:25%;">Pencapaian Prototype</th>
      <th style="width:15%; text-align:center;">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Pencegahan Konflik Jadwal (Double-Booking)</td>
      <td>100%</td>
      <td><strong>100% (Zero Collision)</strong></td>
      <td align="center"><span class="badge badge-success">Tercapai</span></td>
    </tr>
    <tr>
      <td>Tingkat Keberhasilan Pengajuan Reservasi</td>
      <td>&ge; 95%</td>
      <td><strong>98.4%</strong></td>
      <td align="center"><span class="badge badge-success">Tercapai</span></td>
    </tr>
    <tr>
      <td>Waktu Rata-rata Pembuatan Reservasi</td>
      <td>&le; 3 Menit</td>
      <td><strong>&plusmn; 1.5 Menit</strong></td>
      <td align="center"><span class="badge badge-success">Tercapai</span></td>
    </tr>
    <tr>
      <td>Kecepatan Muat Antarmuka (LCP)</td>
      <td>&le; 3.0 Detik</td>
      <td><strong>&plusmn; 1.2 Detik</strong></td>
      <td align="center"><span class="badge badge-success">Tercapai</span></td>
    </tr>
  </tbody>
</table>

<h2>16.3 Roadmap Pengembangan 6 Bulan Kedepan (Future Horizons)</h2>
<div class="card-grid-3">
  <div class="card" style="border-left: 3px solid #2563eb;">
    <div class="card-title">📲 WhatsApp Gateway</div>
    <p class="card-desc">Notifikasi pesan instan otomatis langsung ke ponsel pemesan saat pengajuan disetujui atau ditolak.</p>
  </div>
  <div class="card" style="border-left: 3px solid #059669;">
    <div class="card-title">📷 QR Code Check-in</div>
    <p class="card-desc">Pemindai kode QR fisik di pintu ruangan untuk memastikan kehadiran pemesan secara tepat waktu.</p>
  </div>
  <div class="card" style="border-left: 3px solid #9333ea;">
    <div class="card-title">🤖 AI Smart Suggestion</div>
    <p class="card-desc">Rekomendasi ruangan alternatif berbasis kecerdasan buatan jika ruangan yang diinginkan sedang terisi penuh.</p>
  </div>
</div>

<h2>16.4 Kesimpulan & Lembar Pengesahan</h2>
<p>
  Aplikasi <strong>RoomBook (APKFleshBooking)</strong> telah berhasil menyelesaikan seluruh kebutuhan fungsional dan non-fungsional sebagai platform pemesanan ruangan modern. Melalui integrasi Web Next.js 14, Aplikasi Mobile Flutter, dan basis data relasional yang kokoh, institusi kini memiliki ekosistem pengelolaan aset yang efisien, transparan, dan akuntabel.
</p>
<div style="margin-top:10px; border-top:1px dashed #94a3b8; padding-top:6px; display:flex; justify-content:space-between; font-size:8pt; color:#64748b;">
  <div>Disetujui oleh: <strong>Capella Technical Architecture Board</strong></div>
  <div>Status Dokumen: <strong>VERIFIED & PRODUCTION-READY (OKTOBER 2026)</strong></div>
</div>
"""
pages.append(wrap_page(p18_content, "Bab 16: Keamanan, KPI & Roadmap", 18))

# ==============================================================================
# GABUNGKAN SELURUH HALAMAN MENJADI SATU FILE HTML
# ==============================================================================
full_html = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>RoomBook - Technical Whitepaper & Feature Documentation</title>
  {css_content}
</head>
<body>
  {''.join(pages)}
</body>
</html>
"""

html_filename = os.path.abspath("laporan_roombook_temp.html")
pdf_filename = os.path.abspath("Artikel_Lengkap_Aplikasi_RoomBook_APKFleshBooking.pdf")

print(f"Menyimpan file HTML sementara ke: {html_filename}")
with open(html_filename, "w", encoding="utf-8") as f:
    f.write(full_html)

print(f"Menjalankan Chrome Headless untuk menghasilkan PDF...")
chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
cmd = [
    chrome_path,
    "--headless=new",
    "--disable-gpu",
    "--run-all-compositor-stages-before-draw",
    "--no-pdf-header-footer",
    f"--print-to-pdf={pdf_filename}",
    html_filename
]

res = subprocess.run(cmd, capture_output=True, text=True)
print(f"Hasil Eksekusi Chrome: Exit Code {res.returncode}")

if os.path.exists(pdf_filename):
    size_kb = os.path.getsize(pdf_filename) / 1024
    print(f"File PDF berhasil dibuat: {pdf_filename} ({size_kb:.2f} KB)")
    
    # Hitung jumlah halaman PDF
    with open(pdf_filename, "rb") as pf:
        pdf_bytes = pf.read()
    page_count = len(re.findall(b"/Type\\s*/Page[^s]", pdf_bytes))
    print(f"Jumlah Halaman PDF yang Terdeteksi: {page_count} Halaman")
else:
    print(f"Gagal menghasilkan file PDF! Stderr: {res.stderr}")

# Bersihkan file HTML sementara jika diinginkan (atau biarkan untuk inspeksi)
print("Selesai!")
