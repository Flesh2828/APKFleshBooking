# Dokumen Spesifikasi UI/UX & Audit Codebase: RoomBook (APKFleshBooking)

Dokumen ini merangkum hasil audit menyeluruh terhadap arsitektur routing, komponen antarmuka (UI/UX), skema database, dan API dari codebase **RoomBook** (mencakup implementasi **Web Next.js** dan **Mobile Flutter**). Dokumen ini disusun sebagai acuan teknis (*baseline context*) untuk kebutuhan perancangan ulang (*redesign*).

---

## 1. User Roles & Access Control

Aplikasi mengidentifikasi 4 tingkatan peran (*role*) pengguna dengan batasan hak akses yang ditegakkan di level antarmuka (kondisional *guard* pada navigasi dan tab) serta level basis data (Supabase Row Level Security / RLS Policy):

| Role | Deskripsi Pengguna | Halaman / Fitur yang Dapat Diakses | Batasan Akses |
| :--- | :--- | :--- | :--- |
| **`ADMIN`** | Pengelola Sarana & Prasarana Kampus / Bagian Logistik | • Semua halaman publik & peminjam<br>• Persetujuan Reservasi (`approvals`)<br>• Kelola Ruangan (`room_management`)<br>• Laporan & Statistik (`reports`)<br>• Audit Trail (`ReservationLog`) | Akses penuh (*Full Control*), termasuk *override* status reservasi dan CRUD master data ruangan. |
| **`DOSEN`** | Tenaga Pendidik / Riset Fakultas | • Dashboard Pengguna<br>• Katalog & Detail Ruangan<br>• Kalender Ketersediaan<br>• Formulir Reservasi Ruangan<br>• Reservasi Saya & Bukti Booking<br>• Dokumentasi Sistem | Terproteksi RLS: Hanya dapat melihat dan membatalkan reservasi miliknya sendiri. Tidak dapat mengakses antrean persetujuan, data master ruangan, dan laporan manajerial. |
| **`MAHASISWA`** | Pengurus Organisasi / Mahasiswa (BEM, Himpunan, UKM) | • Dashboard Pengguna<br>• Katalog & Detail Ruangan<br>• Kalender Ketersediaan<br>• Formulir Reservasi Ruangan<br>• Reservasi Saya & Bukti Booking<br>• Dokumentasi Sistem | Sama seperti Dosen. Terbatas pada kuota peminjaman unit ormawa, membutuhkan persetujuan Admin. |
| **`STAF`** | Tenaga Kependidikan / BAAK / Administrasi Unit | • Dashboard Pengguna<br>• Katalog & Detail Ruangan<br>• Kalender Ketersediaan<br>• Formulir Reservasi Ruangan<br>• Reservasi Saya & Bukti Booking<br>• Dokumentasi Sistem | Sama seperti Dosen & Mahasiswa. Digunakan untuk rapat koordinasi unit dan agenda internal kampus. |

### Mekanisme Penegakan Akses (*Guard Behavior*):
- **Web SPA (`src/app/page.tsx` & `Sidebar.tsx`)**:
  - Menu Admin (`approvals`, `room_management`, `reports`) disembunyikan dari sidebar pengguna non-Admin.
  - Jika pengguna non-Admin memicu *state* tab Admin, `renderActiveView()` secara otomatis mengembalikan tampilan ke `DashboardView`.
  - Terdapat fitur demo **Quick Role Switcher** pada *top navbar* untuk transisi instan antar peran.
- **Mobile Flutter (`MainNavigationScreen.dart` & `approvals_tab.dart`)**:
  - Tab ke-4 pada *Bottom Navigation Bar* bersifat dinamis: menampilkan `ApprovalsTab` jika `currentUser.isAdmin == true`, atau `MyReservationsTab` jika non-Admin.
  - Jika pengguna non-Admin membuka rute/komponen persetujuan, layar menampilkan *Access Denied State* (`Icons.gpp_bad_rounded` dengan pesan "Akses Khusus Administrator").

---

## 2. Complete Page / Screen Inventory

Codebase memiliki dua antarmuka klien yang terhubung ke skema data yang sama:

### A. Web Application (Next.js 14 / React 18 / Tailwind CSS)
*Routing berbasis State Tab (`AppContext.activeTab`) di dalam rute tunggal `src/app/page.tsx` dengan layout responsif (Desktop/Tablet/Mobile).*

| No | Tab Key / Identitas Rute | Nama Layar / Komponen | Role Akses | Tujuan / Deskripsi Singkat |
| :---: | :--- | :--- | :---: | :--- |
| **W01** | `auth` *(unauthenticated)* | **Login & Register View** (`LoginView.tsx`) | Publik / Tamu | Autentikasi dengan Email/Password, simulasi GCP Google SSO, dan registrasi civitas baru. |
| **W02** | `dashboard` | **Dashboard View** (`DashboardView.tsx`) | Semua Role | Ringkasan KPI ruangan, notifikasi antrean pending, agenda terdekat, dan spotlight katalog. |
| **W03** | `catalog` | **Katalog Ruangan** (`RoomsCatalogView.tsx`) | Semua Role | Pencarian dan eksplorasi spesifikasi ruangan, filter gedung, kapasitas, dan fasilitas. |
| **W04** | `availability` | **Kalender Ketersediaan** (`AvailabilityCalendarView.tsx`) | Semua Role | Matriks slot waktu per jam (08:00 - 18:00) per ruangan dan tanggal untuk memantau bentrok. |
| **W05** | `new_booking` | **Formulir Reservasi** (`ReservationFormView.tsx`) | Semua Role | Pengajuan peminjaman ruangan dengan engine validasi bentrok interval & kapasitas *real-time*. |
| **W06** | `my_bookings` | **Reservasi Saya** (`MyReservationsView.tsx`) | Semua Role | Pelacakan status verifikasi (Pending/Approved/Rejected), cetak slip bukti izin, dan pembatalan. |
| **W07** | `approvals` | **Persetujuan Reservasi** (`ApprovalsView.tsx`) | `ADMIN` Only | Antrean verifikasi pengajuan masuk, peninjauan agenda, eksekusi Approve atau Tolak (wajib alasan). |
| **W08** | `room_management` | **Kelola Ruangan** (`RoomManagementView.tsx`) | `ADMIN` Only | Manajemen master data ruangan (CRUD), ubah status operasional (Aktif/Perawatan/Non-aktif). |
| **W09** | `reports` | **Laporan & Statistik** (`ReportsView.tsx`) | `ADMIN` Only | Metrik utilisasi fasilitas, grafik frekuensi ruangan terpopuler, rasio persetujuan, dan rekam audit log. |
| **W10** | `docs` | **Dokumentasi Sistem** (`DocsView.tsx`) | Semua Role | *In-app viewer* untuk dokumen arsitektur, PRD, database, dan panduan API (`docs/*.md`). |

### B. Mobile Application (Flutter / Material 3 Dark Theme)
*Routing menggunakan Named Routes (`/login`, `/main`, `/booking`) dan Bottom Navigation Bar 5-Tab.*

| No | Rute / Nama Tab | File Komponen Flutter | Role Akses | Tujuan / Deskripsi Singkat |
| :---: | :--- | :--- | :---: | :--- |
| **M01** | `/login` | `LoginScreen.dart` | Publik / Tamu | Autentikasi akun Supabase, *role switcher preview*, input kredensial mobile. |
| **M02** | Tab 0: *Beranda* | `home_tab.dart` | Semua Role | *Hero section*, kartu status agenda peminjam, *quick action button*, ringkasan statistik harian. |
| **M03** | Tab 1: *Ruangan* | `rooms_tab.dart` / `room_list_screen.dart` | Semua Role | Daftar kartu ruangan modern dengan indikator kapasitas, fasilitas chip, dan tombol booking langsung. |
| **M04** | Tab 2: *Kalender* | `availability_calendar_screen.dart` | Semua Role | Timeline vertikal slot ketersediaan ruangan harian per jam operasional. |
| **M05** | Tab 3: *Reservasi Saya* | `my_reservations_tab.dart` | Non-Admin | Riwayat peminjaman pengguna terfilter status, slip modal, dan pembatalan reservasi. |
| **M06** | Tab 3: *Persetujuan* | `approvals_tab.dart` | `ADMIN` Only | Antrean pengajuan dengan kartu evaluasi Machine Learning (SVM Recommendation, No-Show risk). |
| **M07** | Tab 4: *Profil* | `profile_tab.dart` | Semua Role | Data identitas civitas, departemen/organisasi, *switch role simulator*, dan aksi Logout. |
| **M08** | `/booking` *(Push Route / FAB)* | `booking_form_screen.dart` | Semua Role | Form multi-tahap pemesanan ruangan terintegrasi file lampiran berkas dan 4 model Machine Learning. |

---

## 3. Per-Page Functional Breakdown

### 3.1 Layar Autentikasi (Login & Register)
* **Tujuan Halaman**: Memverifikasi identitas civitas akademika sebelum masuk ke sistem, mendukung multi-metode autentikasi (Kredensial Email & GCP SSO), serta pendaftaran akun baru.
* **Data yang Ditampilkan**:
  - Kolom input: Email institusi, kata sandi (*toggle show/hide*).
  - Pilihan Quick Demo Accounts: Administrator, Dosen, Mahasiswa (BEM), Staf.
  - Tab Register: Nama lengkap, email, password, role (`MAHASISWA` / `DOSEN` / `STAF`), departemen/program studi, nomor telepon.
  - Modal GCP Workspace: Simulasi login domain kampus `@campus.ac.id`.
* **Aksi / Tombol Pengguna**:
  - Tombol submit `Masuk (Sign In)` & `Daftar Akun Baru`.
  - Tombol `Masuk dengan Akun Google / GCP Workspace`.
  - Tombol *One-Click Quick Fill* untuk akun demo.
  - Tombol *Toggle Visibility* password.
* **State Penting**:
  - *Loading State*: Tombol submit berubah status *disabled* dengan indikator loading 400ms.
  - *Error State*: Alert toast jika password salah atau email tidak terdaftar.
  - *Modal State*: Dialog pop-up simulasi Google Cloud Identity / Workspace.

---

### 3.2 Layar Dashboard / Beranda
* **Tujuan Halaman**: Menyajikan pusat kendali (*command center*) aktivitas peminjaman ruangan harian sesuai peran yang aktif.
* **Data yang Ditampilkan**:
  - **Tampilan Admin**:
    - 4 Kartu KPI: Total Ruangan Aktif, Pengajuan Pending (antrean), Total Reservasi Disetujui, Jadwal Sesi Hari Ini.
    - Seksi "Perlu Persetujuan Segera" (menampilkan 3 antrean teratas: ID, nama pemesan, organisasi, ruangan, jam).
    - Ringkasan aktivitas dan jadwal ruangan terpakai hari ini.
  - **Tampilan Peminjam (Dosen / Mahasiswa / Staf)**:
    - 3 Kartu KPI: Pengajuan Pending Saya, Reservasi Disetujui Saya, Pengajuan Ditolak Saya.
    - Seksi "Jadwal Pemakaian Berikutnya": Menampilkan kartu agenda mendatang yang telah disetujui (Nama ruangan, gedung, tanggal, jam mulai-selesai, tujuan).
    - Spotlight "Katalog Ruangan Populer" dengan foto, kapasitas, dan jam operasional.
* **Aksi / Tombol Pengguna**:
  - Tombol CTA `Ajukan Booking Sekarang` (mengarahkan ke Form Reservasi).
  - Tombol `Cek Kalender Jadwal` (mengarahkan ke Kalender Ketersediaan).
  - Aksi Cepat Admin: Tombol `Setujui Langsung` dan `Tolak` pada kartu antrean dashboard.
  - Tombol `Pesan Ruangan Ini` pada kartu spotlight ruangan.
* **State Penting**:
  - *Empty State*: Jika tidak ada agenda pemakaian mendatang bagi peminjam, atau tidak ada antrean pending bagi admin.
  - *Realtime State*: Banner *animated ping* merah/kuning jika ada reservasi pending baru yang masuk dari perangkat mobile.

---

### 3.3 Layar Katalog Ruangan
* **Tujuan Halaman**: Memfasilitasi pengguna untuk meneliti dan membandingkan fasilitas, spesifikasi teknis, serta daya tampung seluruh ruangan kampus.
* **Data yang Ditampilkan**:
  - Bilah Toolbar Filter: Pencarian teks (*search query*), filter pilihan Gedung (*building dropdown*), filter batas minimal kapasitas (*min capacity*: 20, 50, 100, 200+ orang), fasilitas spesifik.
  - Grid Kartu Ruangan: Foto ruangan, nama ruangan, gedung & lantai, badge kapasitas peserta, badge status operasional (`ACTIVE` / `MAINTENANCE` / `INACTIVE`), jam buka & tutup, daftar badge fasilitas (Proyektor, AC, Sound System, Wi-Fi, dll.), ringkasan deskripsi.
  - Modal Detail Ruangan: Tampilan foto resolusi tinggi, rincian kelengkapan sarana, dan kebijakan pemakaian.
* **Aksi / Tombol Pengguna**:
  - Input teks pencarian *live search*.
  - Pemilihan filter gedung dan kapasitas.
  - Tombol `Reset Filter` (muncul kondisional saat ada filter aktif).
  - Tombol `Lihat Detail / Spesifikasi` (membuka dialog *preview*).
  - Tombol utama `Pesan Ruangan Ini` (mengisi state `selectedRoomForBooking` dan berpindah otomatis ke Form Reservasi).
* **State Penting**:
  - *Empty State*: "Tidak ada ruangan yang cocok" dengan ikon layers dan tombol reset filter.
  - *Status Badge*: Hijau (Siap Dipesan), Kuning (Perawatan/Maintenance), Merah (Non-aktif).

---

### 3.4 Layar Kalender Ketersediaan
* **Tujuan Halaman**: Memberikan transparansi jadwal penggunaan ruangan dalam bentuk matriks jam (*timeslot*) untuk mencegah inisiatif peminjaman yang bentrok.
* **Data yang Ditampilkan**:
  - Pilihan Ruangan aktif (*room selector dropdown/chips*).
  - Pemilih Tanggal (*date navigator* dengan tombol *previous day*, *today*, dan *next day*).
  - Matriks Slot Waktu Per Jam (08:00 sampai 18:00):
    - Status slot: `AVAILABLE` (Tersedia / Bebas), `BOOKED` (Telah Dipesan & Disetujui), `PENDING` (Sedang Ditinjau Admin), `UNAVAILABLE` (Di luar jam operasional ruangan), `MAINTENANCE` (Ruangan dalam perbaikan).
    - Pada slot `BOOKED` / `PENDING`: Menampilkan nama pemesan, organisasi, dan tujuan agenda.
* **Aksi / Tombol Pengguna**:
  - Mengubah pilihan ruangan yang sedang ditinjau.
  - Berpindah tanggal kalender (*Date Picker* HTML / Navigasi Harian).
  - Klik pada slot yang berstatus `AVAILABLE`: Tombol aksi `Pesan Jam Ini` yang langsung mentransfer parameter tanggal dan rentang jam ke formulir reservasi.
* **State Penting**:
  - *Color Coding Slot*:
    - Hijau: Bebas dan dapat dipesan.
    - Biru / Merah Muda: Terisi oleh reservasi disetujui (lengkap dengan info pemesan).
    - Kuning: Slot sedang dalam pengajuan (*pending*).
    - Abu-abu Gelap / Garis Miring: Di luar jam operasional atau *maintenance*.

---

### 3.5 Layar Formulir Reservasi Ruangan
* **Tujuan Halaman**: Menjadi pintu masuk pengajuan peminjaman ruangan dengan sistem validasi multi-kriteria otomatis (kapasitas, operasional, dan bentrok jadwal).
* **Data yang Ditampilkan & Kolom Form**:
  - **Pilihan Ruangan**: Dropdown pilihan seluruh ruangan berstatus aktif beserta informasi gedung & kapasitas maksimal.
  - **Identitas Pemesan**: Nama Penanggung Jawab (otomatis terisi dari sesi pengguna) dan Nama Organisasi / Departemen / Unit Kegiatan.
  - **Jadwal Penggunaan**: Tanggal pemakaian (*date picker*), Jam Mulai, dan Jam Selesai (*time picker* format 24 jam).
  - **Rincian Kegiatan**: Estimasi Jumlah Peserta (angka), Tujuan / Agenda Penggunaan (textarea, wajib), Permintaan Fasilitas Tambahan (opsional), Catatan Khusus untuk Administrator (opsional).
  - **Khusus Mobile Flutter (ML Assistant Widgets)**:
    - `MlSmartApprovalBadge` (Evaluasi Support Vector Machine: Rekomendasi Auto-Approve, Manual Review, atau Auto-Reject).
    - `MlEnergyOccupancyCard` (Prediksi Linear Regression: Jam utilisasi mingguan & estimasi konsumsi energi listrik kWh).
    - `MlNoShowBanner` (Prediksi Logistic Regression: Skor probabilitas risiko pembatalan sepihak / mangkir).
    - Komponen upload dokumen lampiran surat izin/proposal (`file_picker`).
* **Aksi / Tombol Pengguna**:
  - Mengubah isian form input.
  - Unggah berkas dokumen pendukung (khusus Flutter).
  - Tombol `Kirim Pengajuan Reservasi` (terkunci / *disabled* jika validasi gagal).
* **State Penting**:
  - **Banner Validasi Real-Time (Dinamis)**:
    - *Success State (Hijau)*: "Jadwal dan kapasitas valid! Slot waktu tersedia dan siap diajukan."
    - *Capacity Conflict State (Kuning/Merah)*: "Jumlah peserta (X) melebihi daya tampung ruangan (Maksimal: Y orang)."
    - *Operational Conflict State (Kuning)*: "Pengajuan harus berada dalam jam operasional ruangan (08:00 - 17:00 WIB)."
    - *Interval Overlap Conflict State (Merah Bounce)*: "Jadwal bentrok dengan reservasi yang telah disetujui: '[Judul Kegiatan]' ([Nama Pemesan])."
  - *Submit State*: Menerbitkan kode unik reservasi (format: `RB-YYYYMM-XXX`), menyelaraskan data ke Supabase Postgres, memunculkan toast notifikasi sukses, dan meredireksi ke tab `Reservasi Saya`.

---

### 3.6 Layar Reservasi Saya & Riwayat
* **Tujuan Halaman**: Wadah bagi peminjam untuk memantau siklus hidup pengajuan, melihat umpan balik admin, membatalkan pengajuan mandiri, dan mengunduh/mencetak izin pemakaian.
* **Data yang Ditampilkan**:
  - Tab Filter Status: `Semua`, `Pending` (Kuning), `Disetujui` (Hijau), `Ditolak` (Merah), `Dibatalkan` (Abu-abu).
  - Input Pencarian: Filter berdasarkan kode reservasi, nama ruangan, atau tujuan kegiatan.
  - Kartu Pengajuan: Kode ID unik, tanggal pengajuan, badge status, nama kegiatan, nama ruangan & gedung, waktu pelaksanaan kegiatan, jumlah peserta.
  - Seksi Alasan Penolakan: Kotak peringatan merah yang memuat alasan resmi penolakan dari admin (diambil dari `ReservationLog`).
* **Aksi / Tombol Pengguna**:
  - Tombol `Batalkan Pengajuan` (hanya aktif pada reservasi berstatus `PENDING`; memunculkan dialog konfirmasi pengisian alasan pembatalan).
  - Tombol `Cetak Bukti Booking` (hanya aktif jika status `APPROVED`; membuka modal Slip Izin Resmi).
  - Tombol `Ajukan Peminjaman Ruangan Baru` (pada header & *empty state*).
* **State Penting**:
  - *Empty State*: Menampilkan ilustrasi berkas kosong dengan tombol ajakan membuat pengajuan baru.
  - *Modal Slip Reservasi*: Menampilkan kop surat resmi kampus, QR-Code verifikasi, rincian penanggung jawab, jadwal terkonfirmasi, stempel digital "APPROVED", dan tombol cetak (`window.print()`).

---

### 3.7 Layar Persetujuan & Verifikasi (Admin Only)
* **Tujuan Halaman**: Memungkinkan administrator memeriksa kelayakan proposal kegiatan civitas, menganalisis jadwal, dan membuat keputusan formal (Approve / Reject).
* **Data yang Ditampilkan**:
  - Counter Antrean Tab: Menunggu Review (*pending count* dengan animasi *pulse*), Disetujui (*approved count*), Ditolak (*rejected count*), Semua.
  - Tabel Data Pengajuan:
    - Kolom 1: ID Reservasi & Waktu Pengajuan.
    - Kolom 2: Identitas Pemesan & Unit / Departemen.
    - Kolom 3: Ruangan & Jadwal Lengkap.
    - Kolom 4: Agenda / Tujuan & Jumlah Peserta.
    - Kolom 5: Status Badge.
    - Kolom 6: Aksi Cepat (Detail Modal, Setujui Cepat, Tolak).
  - Modal Rincian Verifikasi: Informasi lengkap pemohon, kontak, catatan tambahan, kebutuhan fasilitas, serta riwayat perubahan status (*audit logs*).
* **Aksi / Tombol Pengguna**:
  - Tombol `Setujui (Approve)`: Membuka konfirmasi dialog; mengubah status reservasi menjadi `APPROVED`, mengunci kalender, mencatat log audit, dan mengirimkan notifikasi internal.
  - Tombol `Tolak (Reject)`: Membuka dialog penolakan wajib; admin harus memasukkan alasan penolakan sebelum sistem memproses status `REJECTED`.
  - Filter pencarian nama pemohon, ruangan, atau ID reservasi.
* **State Penting**:
  - *Empty State*: Ikon centang dengan pesan "Semua pengajuan telah ditinjau / tidak ada antrean pending".
  - *Modal Tolak*: Validasi form wajib isi untuk kolom `Alasan Penolakan`.

---

### 3.8 Layar Kelola Ruangan (Admin Only)
* **Tujuan Halaman**: Mengelola master data inventaris fisik fasilitas ruangan kampus.
* **Data yang Ditampilkan**:
  - Daftar Ruangan (Tabel & Kartu): Foto miniatur, nama ruangan, lokasi gedung & nomor lantai, kapasitas peserta, jam operasional, status operasional, dan chip fasilitas.
  - Modal Form Ruangan (Tambah / Edit):
    - Input nama ruangan, gedung, lantai.
    - Input kapasitas maksimum (orang).
    - Input jam operasional buka dan tutup (HH:mm).
    - Input URL foto ruangan.
    - Input daftar fasilitas (dipisahkan tanda koma).
    - Input status operasional (`ACTIVE`, `MAINTENANCE`, `INACTIVE`).
    - Input deskripsi ruangan.
* **Aksi / Tombol Pengguna**:
  - Tombol `Tambah Ruangan Baru` (membuka form modal kosong).
  - Tombol `Edit` pada setiap baris data ruangan.
  - Tombol Cepat Ubah Status: Mengubah langsung ke status `Perawatan (MAINTENANCE)` atau `Aktif (ACTIVE)`.
* **State Penting**:
  - *Form Modal State*: Validasi kelengkapan nama, gedung, dan format jam.

---

### 3.9 Layar Laporan & Statistik (Admin Only)
* **Tujuan Halaman**: Menyediakan visualisasi metrik utilisasi sarana kampus untuk kebutuhan audit pimpinan dan evaluasi operasional sarpras.
* **Data yang Ditampilkan**:
  - 4 Kartu KPI: Total Pengajuan Masuk, Tingkat Persetujuan (*Approval Rate* %), Pengajuan Pending, Pengajuan Ditolak & Dibatalkan.
  - Grafik Distribusi Frekuensi Ruangan: *Horizontal Progress Bar* per ruangan yang diurutkan berdasarkan jumlah pesanan tertinggi.
  - Status Breakdown: Bar persentase distribusi status (*Approved* vs *Pending* vs *Rejected* vs *Cancelled*).
  - Tabel Rekam Audit Sistem (`ReservationLog`): Catatan kronologis tindakan admin, mencakup nama admin penanggung jawab, ID reservasi, status sebelum, status sesudah, catatan/alasan, dan stempel waktu (*timestamp*).
* **Aksi / Tombol Pengguna**:
  - Tombol `Cetak Laporan Lengkap` (memicu fungsi `window.print()` dengan stylesheet ramah cetak dokumen A4).
* **State Penting**:
  - Perhitungan persentase utilisasi dinamis berdasarkan seluruh riwayat database.

---

### 3.10 Layar Dokumentasi Sistem (Docs Viewer)
* **Tujuan Halaman**: Menyediakan repositori dokumentasi pengembangan terintegrasi di dalam aplikasi untuk pengembang, desainer, dan pemangku kepentingan.
* **Data yang Ditampilkan**:
  - Navigasi daftar dokumen: PRD, Architecture, Database Dictionary, UI/UX Guidelines, User Flow, API Documentation, dll.
  - *Reader Pane*: Penampil konten Markdown terformat lengkap dengan tipografi kode, tabel, dan diagram alur.
* **Aksi / Tombol Pengguna**:
  - Memilih dokumen dari daftar menu dokumen.
  - Tombol salin atau lompat antar referensi file.

---

## 4. User Flows

### Flow 1: Alur Peminjam (Pengecekan Ruangan hingga Pengajuan Berhasil)
```text
[1. Login Akun]
   │  Civitas login menggunakan kredensial email atau Google Cloud Platform (GCP) SSO.
   ▼
[2. Beranda / Katalog Ruangan]
   │  Peminjam menjelajahi daftar ruangan atau menerapkan filter (Kapasitas, Gedung).
   ▼
[3. Cek Ketersediaan (Kalender)]
   │  Peminjam memeriksa jadwal pada tanggal yang diinginkan.
   │  Slot hijau menandakan jam kosong; slot merah/biru menandakan ruangan telah terpakai.
   ▼
[4. Isi Formulir Reservasi]
   │  Peminjam mengisi tujuan kegiatan, rentang jam, estimasi peserta, dan fasilitas ekstra.
   │  Sistem memverifikasi:
   │  ├─ Apakah jam dalam rentang buka operasional? (08:00 - 17:00)
   │  ├─ Apakah peserta <= kapasitas ruangan?
   │  └─ Apakah waktu peminjaman tumpang-tindih (overlap) dengan reservasi berstatus APPROVED?
   ▼
[5. Validasi & Submit]
   │  Jika BENTROK  ──> Muncul pesan error merah & saran jam lain; tombol kirim terkunci.
   │  Jika VALID    ──> Tombol aktif; terbit kode tiket (misal: RB-202611-008).
   ▼
[6. Monitoring di 'Reservasi Saya']
   │  Status awal: "PENDING".
   │  Peminjam dapat membatalkan pengajuan selama status masih PENDING.
```

---

### Flow 2: Alur Administrator (Verifikasi, Persetujuan, dan Notifikasi)
```text
[1. Notifikasi Pengajuan Masuk]
   │  Admin menerima indikator antrean baru di Navbar, Dashboard, atau Tab Persetujuan.
   ▼
[2. Buka Menu Persetujuan (/approvals)]
   │  Admin melihat daftar antrean terurut berdasarkan waktu pengajuan terbaru.
   ▼
[3. Tinjau Rincian Permohonan]
   │  Admin membuka modal detail: memeriksa urgensi kegiatan, identitas unit,
   │  dan rekomendasi Machine Learning (Auto-Approve / Manual Review / Risiko No-Show).
   ▼
[4. Pengambilan Keputusan]
   ├────────────────────────────────────────┬────────────────────────────────────────┐
   ▼                                        ▼                                        ▼
[PILIHAN A: SETUJUI]                     [PILIHAN B: TOLAK]                       [PILIHAN C: CANCEL]
• Klik tombol "Setujui".                 • Klik tombol "Tolak".                   • Terjadi pembatalan
• Konfirmasi dialog.                     • Wajib isi "Alasan Penolakan".            oleh peminjam mandiri.
• Status: "APPROVED".                    • Status: "REJECTED".                    • Status: "CANCELLED".
• Kalender publik terkunci.              • Slot jadwal tetap bebas.               • Slot jadwal kembali
• Kirim notifikasi sukses.               • Kirim notifikasi penolakan               bebas.
• Catat di ReservationLog.               • Catat alasan di ReservationLog.
   │                                        │                                        │
   └────────────────────────────────────────┴────────────────────────────────────────┘
                                            ▼
[5. Pemutakhiran Sisi Pengguna (Realtime)]
   Peminjam melihat status terupdate di tab 'Reservasi Saya'.
   Jika APPROVED, tombol "Cetak Bukti Booking" aktif dan siap dibawa ke petugas lokasi.
```

---

### Flow 3: Alur Sinkronisasi Multi-Platform (Web <-> Supabase <-> Mobile)
```text
[Pengguna di Mobile Flutter]
   │  Mengisi booking form + upload proposal berkas lampiran.
   ▼
[Supabase PostgreSQL & Edge Functions]
   │  Data masuk ke tabel `reservations` dengan trigger RLS.
   │  Edge function menjalankan inferensi klasifikasi teks & prediksi risiko no-show.
   │  Supabase Realtime Broadcast memancarkan event `INSERT` / `UPDATE`.
   ▼
[Web Admin Next.js]
   │  Listener `roombook_realtime_reservations` menangkap payload secara instan.
   │  Muncul toast mengambang: "Pemesanan baru dari mobile: '[Tujuan Agenda]'".
   │  Angka antrean badge persetujuan bertambah otomatis tanpa refresh halaman.
```

---

## 5. Ringkasan Kebutuhan Desain Ulang (*Redesign Takeaways*)

1. **Konsistensi Navigasi Antar Platform**:
   - Web menggunakan model navigasi *Sidebar + Tab State*, sedangkan Mobile menggunakan *5-Tab Bottom Navigation Bar*. Struktur penamaan menu dan hierarki informasi (*Information Architecture*) harus diselaraskan.
2. **Keterbacaan Matriks Kalender**:
   - Pada layar kalender ketersediaan, pembedaan visual antara status `AVAILABLE`, `BOOKED`, `PENDING`, dan `MAINTENANCE` memerlukan rasio kontras warna yang lebih tegas dan ramah aksesibilitas (*color-blind friendly*).
3. **Penyatuan Komponen Machine Learning**:
   - Fitur prediksi ML (kategori otomatis, prediksi beban energi listrik kWh, dan skor risiko mangkir) yang saat ini sudah aktif di mobile perlu dihadirkan juga di dasbor web admin dalam bentuk kartu analitik visual (*smart badge & energy widget*).
4. **Alur Validasi yang Bersahabat (*Progressive Validation*)**:
   - Error bentrok jadwal perlu memberikan visualisasi slot waktu terdekat yang tersedia (*alternative slot suggestion*), bukan sekadar menolak input pengguna.
