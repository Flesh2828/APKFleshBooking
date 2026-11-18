# DESIGN SYSTEM SPECIFICATION: ROOMBOOK GLASSMORPHISM
**Versi:** 3.2 Production • **Platform Target:** Flutter 3.x (Material 3) & Web Companion  
**Referensi Desain:** Google Stitch Export (`_stitch_ref/`) & Dokumen Audit Teknis (`UI_AUDIT_SPEC.md`)  
**Gaya Desain:** *Refined Frosted Light Glassmorphism with Architectural Mesh Gradient*

---

## 1. Design Philosophy & Architectural Principles

Desain RoomBook mengadopsi estetika **Refined Frosted Light Glassmorphism**. Pendekatan ini menggabungkan keanggunan visual material kaca buram (*frosted glass*), kedalaman spasial berlapis (*specular borders, multi-tier drop shadows*), dan latar belakang kanvas gradien *mesh* arsitektural yang lembut (*architectural soft off-white mesh gradient*).

### Prinsip Utama:
1. **Hierarki Kontras Tinggi & Keterbacaan (*High-Contrast Legibility*)**:
   - Seluruh teks utama menggunakan warna solid charcoal (*Slate 900* `#0F172A`) di atas panel kaca putih semi-transparan (`rgba(255, 255, 255, 0.72)` hingga `0.85`), menjamin kepatuhan WCAG 2.1 AA (rasio kontras > 4.5:1).
2. **Efek Fisika Kaca Nyata (*Real Glass Physics*)**:
   - Pembiasan optik (*backdrop-filter: blur*), pantulan cahaya pada tepian (*specular highlight border* `1px solid rgba(255, 255, 255, 0.90)`), dan bayangan difus (*ambient occlusion shadow*) menciptakan pemisahan visual tanpa membebani kognisi pengguna.
3. **Penyelarasan Multi-Platform (Flutter M3 & Next.js Web)**:
   - Nilai token CSS dipetakan 1:1 ke class Flutter (`Color`, `BoxDecoration`, `BackdropFilter`, `ImageFilter.blur`).

---

## 2. Color Tokens & Glassmorphism Specs

### 2.1 Brand Palette & Foundation Colors

| Token Name | Hex Code | Flutter `Color` | CSS Var / Class | Penggunaan Utama |
| :--- | :--- | :--- | :--- | :--- |
| **Brand Primary (Teal)** | `#0D9488` | `Color(0xFF0D9488)` | `brand.teal` | Warna aksen utama, tombol primer, tab aktif, focus ring. |
| **Brand Dark (Deep Teal)** | `#0F766E` | `Color(0xFF0F766E)` | `brand.tealDark` | Gradien tombol primer, border aksen gelap, header penting. |
| **Brand Light (Mint Teal)** | `#14B8A6` | `Color(0xFF14B8A6)` | `brand.tealLight` | Gradien tombol sekunder, ikon aksen, indikator aktif. |
| **Brand Tint (Mint Glow)** | `#CCFBF1` | `Color(0xFFCCFBF1)` | `brand.mint` | Chip background, badge seleksi, highlight lembut. |
| **Text Primary (Charcoal)** | `#0F172A` | `Color(0xFF0F172A)` | `slateText` / `slate-900` | Judul, heading, teks penting, angka metrik. |
| **Text Secondary (Slate)** | `#334155` | `Color(0xFF334155)` | `slate-700` | Teks isi (*body text*), label form, deskripsi ruangan. |
| **Text Muted (Cool Slate)** | `#64748B` | `Color(0xFF64748B)` | `slate-500` | Subteks waktu, placeholder, tanggal, metadata sekunder. |
| **Border Subtle Neutral** | `#CBD5E1` | `Color(0xFFCBD5E1)` | `slate-300` | Garis pemisah (*divider*), border kartu sekunder non-kaca. |

---

### 2.2 Architectural Canvas & Mesh Gradient

Latar belakang aplikasi tidak menggunakan warna solid putih datar (*flat white*), melainkan gradien arsitektural multi-titik (*multi-point soft mesh gradient*) yang memberikan pendaran cahaya lembut di balik lapisan kaca:

#### CSS Specification:
```css
.mobile-mesh-bg {
  background: 
    radial-gradient(at 0% 0%, #F8FAFC 0px, transparent 50%),
    radial-gradient(at 100% 0%, #E8F2EE 0px, transparent 55%),
    radial-gradient(at 100% 100%, #E3ECF5 0px, transparent 60%),
    radial-gradient(at 0% 100%, #F1F5F9 0px, transparent 50%),
    linear-gradient(168deg, #F3F6FA 0%, #EBF3F8 48%, #E8F2EE 100%);
}
```

#### Flutter Implementation (`LinearGradient` & Ambient Orbs):
```dart
// 1. Base Canvas Mesh Gradient
const BoxDecoration canvasMeshDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3F6FA), // Off-white cool
      Color(0xFFEBF3F8), // Soft sky mist
      Color(0xFFE8F2EE), // Gentle mint whisper
    ],
    stops: [0.0, 0.48, 1.0],
  ),
);

// 2. Ambient Atmosphere Blobs (Diletakkan di dalam Stack di bawah Glass Surface)
Widget buildAmbientOrbs() {
  return Stack(
    children: [
      // Top-Left Teal Orb
      Positioned(
        top: -60,
        left: -40,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF0D9488).withValues(alpha: 0.18),
                Colors.transparent,
              ],
              stops: const [0.0, 0.70],
            ),
          ),
        ),
      ),
      // Mid-Right Sky Orb
      Positioned(
        top: 320,
        right: -50,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF0EA5E9).withValues(alpha: 0.16),
                Colors.transparent,
              ],
              stops: const [0.0, 0.70],
            ),
          ),
        ),
      ),
    ],
  );
}
```

---

### 2.3 Glassmorphism Tiers & Blur Specification

Aplikasi menerapkan 4 tingkatan spesifikasi kaca (*Frosted Glass Tiers*):

| Glass Tier | Opacity (Alpha) | Backdrop Blur (CSS) | Flutter `ImageFilter.blur` | Specular Border | Box Shadow |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Primary Glass Card** (`.glass-card`) | `76%` (`#FFFFFF` with alpha `0.76`) | `blur(18px)` | `sigmaX: 18.0, sigmaY: 18.0` | `1px solid rgba(255, 255, 255, 0.92)` | `0 8px 24px rgba(15, 23, 42, 0.05)` |
| **Tier 2: Glass Input Field** (`.glass-input`) | `65%` (`#FFFFFF` with alpha `0.65`) | `blur(12px)` | `sigmaX: 12.0, sigmaY: 12.0` | `1px solid rgba(255, 255, 255, 0.85)` | `inset 0 2px 4px rgba(15, 23, 42, 0.02)` |
| **Tier 3: Glass Pill / Sub-card** (`.glass-pill-chip`) | `58%` (`#FFFFFF` with alpha `0.58`) | `blur(12px)` | `sigmaX: 12.0, sigmaY: 12.0` | `1px solid rgba(255, 255, 255, 0.80)` | `0 2px 8px rgba(15, 23, 42, 0.03)` |
| **Tier 4: Floating Bottom Dock** (`.glass-dock`) | `85%` (`#FFFFFF` with alpha `0.85`) | `blur(24px)` | `sigmaX: 24.0, sigmaY: 24.0` | `1px solid rgba(255, 255, 255, 0.95)` | `0 12px 40px rgba(15, 23, 42, 0.16)` |

#### Reusable Flutter Glass Container Widget (`GlassSurface`):
```dart
import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassTier { card, input, pill, dock }

class GlassSurface extends StatelessWidget {
  final Widget child;
  final GlassTier tier;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? customBorder;
  final Color? tintColor;

  const GlassSurface({
    super.key,
    required this.child,
    this.tier = GlassTier.card,
    this.borderRadius,
    this.padding,
    this.customBorder,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    double sigma;
    double opacity;
    double borderOpacity;
    List<BoxShadow> shadows;

    switch (tier) {
      case GlassTier.card:
        sigma = 18.0;
        opacity = 0.76;
        borderOpacity = 0.92;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];
        break;
      case GlassTier.input:
        sigma = 12.0;
        opacity = 0.65;
        borderOpacity = 0.85;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case GlassTier.pill:
        sigma = 12.0;
        opacity = 0.58;
        borderOpacity = 0.80;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case GlassTier.dock:
        sigma = 24.0;
        opacity = 0.85;
        borderOpacity = 0.95;
        shadows = [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ];
        break;
    }

    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final baseColor = tintColor ?? Colors.white;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: opacity),
            borderRadius: effectiveRadius,
            border: customBorder ??
                Border.all(
                  color: Colors.white.withValues(alpha: borderOpacity),
                  width: 1.0,
                ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
```

---

## 3. Semantic Status Colors (Accessibility & Matrix Specs)

Untuk menjamin kontras tinggi dan ramah aksesibilitas (*color-blind friendly*), setiap status dilengkapi dengan **Solid Marker**, **Translucent Glass Surface**, **Border**, dan **High-Contrast Text**:

| Status | Solid Hex | Translucent Glass Tint | Border Token | Dark Text (WCAG AA) | Simbol / Ikon | Makna Domain |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **`AVAILABLE`** | `#10B981` (Emerald 500) | `rgba(16, 185, 129, 0.12)` (`#ECFDF5`) | `#A7F3D0` (`emerald-300`) | `#065F46` (Emerald 800) | `fa-circle-check` | Ruangan kosong, bebas bentrok, siap dipesan. |
| **`BOOKED`** | `#E11D48` (Rose 600) | `rgba(225, 29, 72, 0.10)` (`#FFF1F2`) | `#FECDD3` (`rose-200`) | `#9F1239` (Rose 800) | `fa-lock` | Terverifikasi dan disetujui Sarpras (Slot terkunci). |
| **`PENDING`** | `#D97706` (Amber 600) | `rgba(217, 119, 6, 0.12)` (`#FFFBEB`) | `#FDE68A` (`amber-300`) | `#78350F` (Amber 900) | `fa-hourglass-half` | Pengajuan masuk, sedang ditinjau administrator. |
| **`MAINTENANCE`** | `#64748B` (Cool Slate 500) | `rgba(100, 116, 139, 0.10)` (`#F8FAFC`) | `#CBD5E1` (`slate-300`) | `#1E293B` (Slate 800) | `fa-wrench` | Ruangan ditutup untuk kalibrasi/perbaikan sarpras. |

### Aturan Visual Khusus Matriks Kalender:
1. **Left Indicator Accent Strip**: Setiap kartu slot jadwal wajib memiliki garis solid vertikal di sisi paling kiri setebal `6px` (`Border(left: BorderSide(width: 6.0, color: statusColor))`).
2. **Maintenance Diagonal Stripes**: Slot status pemeliharaan wajib menampilkan pola garis diagonal 45° (*striped pattern*) agar pengguna buta warna langsung dapat mengenali status tanpa bergantung pada warna.
3. **Pill Badging**: Badge status pada kartu dan slot jadwal selalu menyertakan ikon pembeda (Centang untuk Available, Gembok untuk Booked, Jam Pasir untuk Pending, Kunci Pas untuk Maintenance).

---

## 4. Typography, Numerics & Spacing System

### 4.1 Font Family & Weights
- **Font Utama Antarmuka**: `Plus Jakarta Sans`
  - Regular (`FontWeight.w400`): Body text, deskripsi ruangan.
  - Medium (`FontWeight.w500`): Input placeholder, metadata tanggal, nama gedung.
  - SemiBold (`FontWeight.w600`): Label form, teks tombol sekunder, filter chips.
  - Bold (`FontWeight.w700`): Judul kartu, heading seksi, nama pemohon.
  - ExtraBold (`FontWeight.w800`): Angka metrik KPI, judul layar, status badge.
- **Font Monospace & Numerik**: `JetBrains Mono` / `FontVariant.tabularNums`
  - Digunakan untuk: Kode ID Reservasi (`RB-202611-008`), Jam Operasional (`09:00 - 11:00 WIB`), Kapasitas (`120 Kursi`), dan Nilai Prediksi ML (`14.2 kWh`, `94%`).

### 4.2 Type Scale

| Role / Elemen | Ukuran (sp / pt) | Weight | Line Height | Tracking | Flutter `TextStyle` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Screen Title** | `22.0` | `w800` | `1.2` | `-0.02em` | `TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))` |
| **Section Heading** | `17.0` | `w800` | `1.3` | `-0.01em` | `TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))` |
| **Card Title** | `15.0` | `w700` | `1.3` | `0.0` | `TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))` |
| **Body Regular** | `13.0` | `w400` | `1.4` | `0.0` | `TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF334155))` |
| **Body Medium / Input** | `12.5` | `w500` | `1.4` | `0.0` | `TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))` |
| **Subtext / Metadata** | `11.0` | `w500` | `1.3` | `0.0` | `TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))` |
| **Caption / Upper Chip**| `10.0` | `w700` | `1.2` | `+0.03em` | `TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)` |
| **Micro Badge / Counter**| `8.5` | `w800` | `1.0` | `0.0` | `TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800)` |

### 4.3 Border Radius System

| Tingkatan Radius | Nilai Pixel | Penggunaan Komponen |
| :--- | :--- | :--- |
| **Radius XL (Super Round)** | `28px` – `32px` | Floating Bottom Navigation Bar Dock, Modal Bottom Sheet. |
| **Radius LG (Standard Card)**| `20px` – `24px` | Kartu Utama Ruangan, Kartu Jadwal, Kotak Form Induk. |
| **Radius MD (Interactive)** | `14px` – `16px` | Input Field, Tombol Primer / Sekunder, Kartu Slot Jam Kalender. |
| **Radius SM (Micro Chip)** | `8px` – `10px` | Chip Fasilitas, Badge Identitas Role, Kotak Ikon. |
| **Radius Pill (Full Circle)**| `9999px` | Floating Action Button (FAB), Status Pill Badge, Avatar Frame. |

### 4.4 Spacing & Padding Rules
- **Horizontal Screen Margin**: `16.0` pt standar pada seluruh layar.
- **Vertical Spacing antar Seksi**: `16.0` – `20.0` pt.
- **Card Internal Padding**: `14.0` – `16.0` pt.
- **Bottom Navigation Floating Clearance**: Konten paling bawah pada seluruh layar wajib diberi `pb-28` (`padding: EdgeInsets.only(bottom: 100.0)`) agar tidak tertutup oleh Floating Bottom Dock.

---

## 5. Component & Screen Mapping

### 5.1 Floating 5-Tab Bottom Dock + Dynamic Role Switching
Struktur navigasi bawah (*Bottom Navigation*) mengambang di atas konten dengan ketinggian `bottom: 16.0`, margin horizontal `16.0`, berlapisan kaca **Tier 4** (`opacity: 0.85`, `blur: 24.0`).

```
┌──────────────────────────────────────────────────────────────┐
│  [Tab 0]      [Tab 1]        ( + )       [Tab 3]     [Tab 4] │
│  Beranda      Ruangan       Center       Kalender   Dinamis* │
│                              FAB                             │
└──────────────────────────────────────────────────────────────┘
* Tab 4 Dinamis:
  - Admin Role    : [Persetujuan] (Icon clipboard-check + Badge counter antrean)
  - Non-Admin Role: [Reservasi Saya] (Icon clock-rotate-left + Badge pending)
```

- **Center Floating Action Button (FAB)**:
  - Posisi: Mengambang di tengah, menjorok ke atas setinggi `-20px`.
  - Dimensi: Diameter `50px` x `50px` lingkaran penuh (`shape: BoxShape.circle`).
  - Latar Belakang: Gradien Brand Teal (`from: Color(0xFF0F766E), to: Color(0xFF0D9488)`).
  - Border: Ring ganda (`border: 2px solid white`, `boxShadow: 0 8px 20px rgba(13, 148, 136, 0.40)`).
  - Aksi: Membuka layar pengajuan reservasi (`/booking`).

---

### 5.2 Glass KPI Cards Row
Menampilkan 3 kartu ringkasan status horizontal (`Grid(3 cols, gap: 10.0)`):
- **Pending Card**: Nilai numerik warna Amber (`#B45309`), pill status `Review`, dot pendaran Amber.
- **Disetujui Card**: Nilai numerik warna Emerald (`#047857`), pill status `Siap`, dot pendaran Emerald.
- **Ditolak Card**: Nilai numerik warna Slate (`#475569`), pill status `Nihil`, dot pendaran Slate.

---

### 5.3 Glass Room Card (Katalog Ruangan)
- **Image Header (`height: 140px`)**:
  - Foto ruangan dengan sudut membulat `16px`.
  - Gradient scrim bawah: `from: Colors.black.withOpacity(0.6) to: Colors.transparent`.
  - **Top-Left Badge**: Status Operasional (`ACTIVE` = Emerald `#10B981`, `MAINTENANCE` = Slate `#64748B`).
  - **Bottom Overlay**: Nama Gedung & Lantai di kiri; Chip kapasitas peserta (`fa-users 120 Kursi`) di kanan.
- **Card Body**:
  - Judul Ruangan (`15sp`, Bold, `#0F172A`).
  - Jam Operasional (`fa-clock 08:00 - 17:00 WIB`, font monospace tabular).
  - Chip Fasilitas (`GlassSurface(tier: GlassTier.pill)`): Menampilkan ikon spesifik (Proyektor, AC, Wi-Fi 6).
  - **Action Row**: Tombol `Pesan Ruangan Ini` (Gradien Teal) dan tombol ikon kalender ketersediaan.

---

### 5.4 Hourly Availability Calendar Matrix
- **Room Selector & Date Strip**:
  - Dropdown kaca pemilih ruangan dengan ikon miniatur gedung dan kapasitas.
  - Bilah tanggal horizontal (*3-Day Quick Strip*) dengan tombol hari sebelumnya dan hari berikutnya.
- **Slot Card Visuals**:
  - Tinggi slot terisi / tersedia: proporsional terhadap rentang jam.
  - Garis aksen kiri setebal `6px` sesuai warna semantik.
  - Menampilkan ID Reservasi, Judul Kegiatan, Nama Pemohon, dan Unit Organisasi.
  - Slot `AVAILABLE`: Border *dashed* Emerald (`#34D399`), tombol `Pesan Jam Ini` satu kali klik (*1-Tap Booking*).
  - Slot `MAINTENANCE`: Pola garis arsir diagonal 45° (*striped background pattern*).

---

### 5.5 Booking Form & Progressive Conflict Validation
Formulir reservasi ruangan diintegrasikan dengan validasi bertahap (*Progressive Validation*):
- **Ruangan Terpilih**: Card preview kaca ringkas di bagian paling atas.
- **Input Jam & Tanggal**: Form input kaca dengan ikon kalender dan waktu.
- **Progressive Conflict Banner (Dinamis)**:
  - Jika terjadi bentrok waktu dengan reservasi `APPROVED`, form **tidak hanya menampilkan error**, tetapi memunculkan kotak rekomendasi cerdas (*Alternative Slot Suggestion*):
  ```
  ⚠️ Interval Bentrok Terdeteksi (1 Jam)
  Slot 10:00 - 11:00 telah dibooking oleh "Gladi Bersih DPM".
  Saran slot alternatif terdekat (1-Tap pilih):
  [✓ 11:00 - 13:00 (Tersedia)]   [✓ 14:00 - 16:00 (Tersedia)]
  ```
- **Lampiran Dokumen (`file_picker`)**:
  - Kotak dashed kaca (*Teal border*) menampilkan nama berkas, ukuran, dan ikon PDF/Word.

---

### 5.6 Tiga Widget Machine Learning (Decision Intelligence)

Tiga kartu analitik prediktif kaca disematkan pada Form Booking (Mobile M08) dan Kartu Antrean Persetujuan Admin (Mobile M06):

#### 1. `MlSmartApprovalBadge` (Support Vector Machine / SVM)
- **Tujuan**: Memberikan rekomendasi kelayakan persetujuan instan berdasarkan riwayat data kepatuhan proposal.
- **Visual Spec**:
  - Container kaca ber-border kiri solid `4px` warna Brand Teal (`#0D9488`).
  - Ikon: `fa-brain` / `ph-sparkle` dengan background bulat pudar teal.
  - Tag Hasil: `94% Auto-Approve Match` (badge hijau) atau `Manual Review Required` (badge amber).
  - Keterangan: *"Pola kegiatan ormawa resmi memenuhi kepatuhan sarpras kampus."*

#### 2. `MlEnergyOccupancyCard` (Linear Regression)
- **Tujuan**: Menghitung estimasi beban konsumsi energi listrik (kWh) pendingin ruangan (AC) dan pencahayaan serta proyeksi utilisasi mingguan.
- **Visual Spec**:
  - Container kaca ber-border kiri solid `4px` warna Emerald (`#10B981`).
  - Ikon: `fa-bolt` warna hijau emerald.
  - Tag Metrik: `~14.2 kWh (Optimal)` font monospace.
  - Keterangan: *"AC & pencahayaan terukur efisien • Utilisasi mingguan ruangan 78% optimal."*

#### 3. `MlNoShowBanner` (Logistic Regression)
- **Tujuan**: Memprediksi risiko kemungkinan peminjam mangkir / tidak hadir (*No-Show Risk Probability*).
- **Visual Spec**:
  - Container kaca ber-border kiri solid `4px` warna Indigo (`#6366F1`).
  - Ikon: `fa-chart-line` warna indigo.
  - Tag Metrik: `4.1% (Risiko Sangat Rendah)` jika score < 0.50, atau `Tinggi (> 50%)` jika pemohon memiliki riwayat pembatalan mendadak.
  - Keterangan: *"Track record pemohon: 99.1% pemakaian tepat waktu."*

---

### 5.7 Admin Approvals Tab (Mobile Screen M06)
- **Header Khusus Admin**: Badge `ADMIN SARPRAS PORTAL`, indikator live counter antrean dengan animasi pendaran (*pulsing dot*).
- **Segmented Filter Tabs**: `Semua`, `Menunggu (3)`, `Disetujui (14)`, `Ditolak (2)`.
- **Approval Card Detail**:
  - Rincian pemesan, nama kegiatan, kapasitas, waktu pemakaian.
  - Widget rangkuman evaluasi ML (Skor SVM Auto-Approve & No-Show Risk).
  - **Dual Action Button Bar**:
    - Tombol `Tolak (Reject)`: Latar putih kaca, border merah rose, teks rose (`#BE123C`). Membuka dialog wajib alasan penolakan.
    - Tombol `Setujui (Approve)`: Latar gradien Teal (`#0D9488`), teks putih, bayangan aksen teal.

---

## 6. Implementation Checklist for Mobile Flutter

Saat mengimplementasikan ke `mobile_flutter/lib/`:
- [ ] Ganti tema dasar gelap (`darkTheme`) di `mobile_flutter/lib/theme/app_theme.dart` menjadi `AppTheme.frostedLightTheme` mengacu pada token di atas.
- [ ] Tambahkan font `Plus Jakarta Sans` dan `JetBrains Mono` di `pubspec.yaml`.
- [ ] Buat widget dasar `GlassSurface` di `mobile_flutter/lib/widgets/glass_surface.dart`.
- [ ] Implementasikan `MainNavigationScreen` dengan 5-tab floating dock dan center FAB.
- [ ] Perbarui `booking_form_screen.dart` dengan *Progressive Conflict Validation* dan 3 kartu ML.
- [ ] Perbarui `availability_calendar_screen.dart` dengan strip indikator warna semantik 6px dan *striped pattern* maintenance.
- [ ] Perbarui `approvals_tab.dart` dengan kartu verifikasi kaca dan tombol aksi dual-button.
