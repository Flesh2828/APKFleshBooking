# Testing Strategy & Acceptance Criteria — RoomBook

**Dokumen:** Quality Assurance, Test Scenarios, and Verification  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Strategi Pengujian

RoomBook menguji kehandalan sistem melalui beberapa tingkatan:
1. **Unit Testing:** Pengujian fungsi utilitas perhitungan tumpang-tindih rentang waktu (`checkTimeOverlap`), validasi format waktu operasional, dan sanitasi input.
2. **Integration Testing:** Pengujian alur pengiriman formulir reservasi ➔ penyimpanan database ➔ pembaruan status oleh admin ➔ pencatatan audit log ➔ pembuatan notifikasi.
3. **End-to-End (E2E) & User Acceptance Testing (UAT):** Pengujian skenario realistis pengguna dan admin di browser.

---

## 2. Matriks Skenario Pengujian (Acceptance Criteria)

| ID | Fitur | Langkah Pengujian | Hasil yang Diharapkan | Status |
|---|---|---|---|---|
| **TC-01** | Login Role Pengguna | Masukkan akun mahasiswa dan klik login | Pengguna diarahkan ke Dashboard Pengguna; tombol admin tidak muncul | PASS |
| **TC-02** | Login Role Admin | Masukkan akun admin dan klik login | Pengguna diarahkan ke Dashboard Admin dengan statistik dan menu persetujuan | PASS |
| **TC-03** | Cek Ketersediaan | Pilih ruangan dan tanggal di kalender | Menampilkan slot jam kosong dan slot jam yang sudah terisi dengan benar | PASS |
| **TC-04** | Validasi Kapasitas | Input jumlah peserta 60 pada ruangan berkapasitas 40 | Muncul pesan error "Jumlah peserta melebihi kapasitas ruangan (Maks: 40)" | PASS |
| **TC-05** | Validasi Waktu Selesai | Input jam mulai 10:00 dan jam selesai 09:00 | Muncul pesan error "Waktu selesai harus lebih besar dari waktu mulai" | PASS |
| **TC-06** | Validasi Jam Operasional| Input jam mulai 06:00 (buka jam 08:00) | Muncul pesan error "Pengajuan harus berada dalam jam operasional (08:00 - 17:00)" | PASS |
| **TC-07** | Deteksi Bentrok Jadwal | Input slot jam yang beririsan dengan reservasi `APPROVED` | Muncul pesan error bentrok jadwal dan saran memilih slot lain | PASS |
| **TC-08** | Pengajuan Berhasil | Isi formulir valid dan kirim | ID unik terbit (contoh: RB-202609-001), status `PENDING`, muncul di 'Reservasi Saya' | PASS |
| **TC-09** | Persetujuan oleh Admin | Admin membuka antrean, memeriksa detail, klik "Setujui" | Status berubah menjadi `APPROVED`, slot terkunci di kalender, notifikasi masuk ke pemesan | PASS |
| **TC-10** | Penolakan oleh Admin | Admin klik "Tolak", isi alasan penolakan, klik konfirmasi | Status berubah menjadi `REJECTED`, alasan tercatat di log dan dapat dibaca pemesan | PASS |
| **TC-11** | Pembatalan Pengguna | Pengguna membatalkan reservasi pending miliknya | Status berubah menjadi `CANCELLED`, slot dibebaskan | PASS |
| **TC-12** | Tambah Ruangan Baru | Admin mengisi form ruangan baru dan simpan | Ruangan langsung muncul di katalog dan siap dipesan | PASS |

---

## 3. Checklist Responsivitas & Kinerja
- [x] Tampilan Desktop (1920x1080 dan 1366x768): Navigasi nyaman, grid katalog rapi.
- [x] Tampilan Tablet (iPad / 768px): Tampilan layout responsif dan modal proporsional.
- [x] Tampilan Mobile (iPhone / 375px): Menu drawer lancar, formulir nyaman diinput sentuhan jari.
- [x] Waktu muat halaman utama < 2 detik pada koneksi standar.
