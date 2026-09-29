# Contributing Guidelines — RoomBook

Terima kasih atas minat Anda untuk berkontribusi pada pengembangan aplikasi **RoomBook**!  
Dokumen ini memuat panduan gaya kode, alur kerja Git, dan standar kualitas.

---

## 1. Alur Kerja Git (Git Workflow)

1. **Fork & Clone:** Clone repository ke lingkungan lokal Anda.
2. **Branching Strategy:**
   - `main`: Branch produksi yang selalu stabil.
   - `develop`: Branch integrasi pengembangan aktif.
   - `feature/nama-fitur`: Branch untuk fitur baru (contoh: `feature/export-excel-report`).
   - `bugfix/nama-bug`: Branch untuk perbaikan issue (contoh: `bugfix/conflict-timezone`).
3. **Commit Messages:** Gunakan format Conventional Commits:
   - `feat: tambah filter fasilitas ruangan pada katalog`
   - `fix: perbaiki validasi bentrok jadwal saat persetujuan admin`
   - `docs: perbarui spesifikasi endpoint API`
   - `style: perbaiki padding dan kontras warna pada mobile view`

---

## 2. Standar Koding (Coding Standards)

- **TypeScript Strict Mode:** Selalu berikan tipe eksplisit pada props, payload API, dan state. Hindari penggunaan tipe `any`.
- **Komponen React:**
  - Gunakan fungsional komponen dengan hooks (`useState`, `useEffect`, `useMemo`).
  - Pecah komponen besar menjadi komponen kecil dan gunakan Server Components jika tidak memerlukan interaksi klien.
- **Styling:**
  - Gunakan class utility Tailwind CSS.
  - Hindari inline style kecuali untuk nilai dinamis yang dihitung saat runtime.
- **Validasi Input:** Selalu lakukan validasi ganda (frontend untuk UX, backend untuk keamanan).

---

## 3. Pull Request (PR) Checklist
Sebelum mengajukan Pull Request, pastikan:
- [ ] Kode berhasil di-build tanpa error (`npm run build`).
- [ ] Linter tidak menghasilkan warning kritis (`npm run lint`).
- [ ] Fitur telah diuji responsivitasnya pada ukuran layar desktop dan mobile.
- [ ] Dokumentasi terkait diperbarui jika terdapat perubahan skema data atau rute API.
