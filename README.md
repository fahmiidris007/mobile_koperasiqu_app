# KoperasiQu

<p align="center">
  <strong>Koperasi Digital untuk Masa Depan Anda</strong>
</p>

KoperasiQu adalah aplikasi mobile untuk koperasi digital yang menyediakan layanan simpanan, belanja, dan manajemen profil anggota. Dibangun dengan Flutter menggunakan arsitektur modern dan desain **Liquid Glass** (glassmorphism).

---

## ✨ Fitur

### 🔐 Autentikasi
- Splash screen dengan animasi logo
- Welcome page dengan pengenalan fitur
- Login dengan form glassmorphic
- Registrasi multi-step (Data Pribadi, Info Pekerjaan, Info Keluarga)
- E-KYC verification
- Status pending untuk verifikasi anggota

### 💰 Simpanan
- Dashboard simpanan dengan saldo real-time
- Chart pertumbuhan tabungan (menggunakan fl_chart)
- Deposit (Setor) dengan preset amount dan keterangan
- Withdrawal (Tarik) dengan validasi saldo
- Riwayat transaksi dengan CRUD operations
- Saldo tersinkronisasi di seluruh halaman

### 🛒 Belanja
- Katalog produk dengan filter kategori
- Wishlist dengan penyimpanan Hive (persisten)
  - Toggle dari katalog & halaman detail
  - Halaman wishlist dengan hapus per-item & clear all
- Detail produk dengan rating dan info diskon
- Tombol Beli di WhatsApp — langsung chat admin dengan nama produk terisi otomatis

### 🎯 Dashboard
- Saldo simpanan real-time dari Hive
- Informasi Rekening KoperasiQu dengan atas nama user & salin rekening
- Transaksi terkini (5 item terbaru) + tombol Lihat Semua ke halaman riwayat
- Quick actions: Setor, Tarik
- Ikon notifikasi di header → navigasi ke halaman notifikasi

###  Notifikasi
- Notifikasi dibuat dari data transaksi Hive secara otomatis
- Ditambah notifikasi dummy sistem (Verifikasi Akun, Promo)
- Status baca / belum dibaca (dot indikator + opacity)
- Tombol Tandai Semua Dibaca
- Badge tipe: Transaksi · Sistem · Promo
- Waktu relatif (baru saja, X menit/jam/hari lalu)

### 👤 Profil
- Info anggota dengan avatar inisial nama
- Edit Profil — form nama, HP, email, pekerjaan, pre-fill dari data registrasi
- Keamanan Akun:
  - Security score card dengan progress bar
  - Ubah Password (bottom sheet)
  - Ubah M-PIN 6 digit — flow 2 langkah
  - Toggle Biometrik / Notif Login / Notif Transaksi
  - Kelola Perangkat, Riwayat Login, Nonaktifkan Akun (dengan dialog konfirmasi)
- Akses Notifikasi & Riwayat Transaksi dari menu profil
- Logout dengan dialog konfirmasi

---

## 🏗️ Arsitektur

```
lib/
├── core/
│   ├── router/             # GoRouter navigation + route constants
│   ├── theme/              # Liquid Glass theme & colors
│   ├── services/           # Hive storage (transaksi & wishlist)
│   ├── utils/              # Formatters & validators
│   └── widgets/            # Glass components (GlassContainer, GlassButton, dll)
├── features/
│   ├── auth/               # Authentication feature
│   ├── dashboard/          # Dashboard, notifikasi, main shell
│   ├── savings/            # Simpanan, deposit, withdrawal, history
│   ├── shopping/           # Katalog, wishlist, product detail
│   └── profile/            # Profil, edit profil, keamanan akun
```

Setiap feature mengikuti struktur:
- `data/` — Datasources, models, repositories
- `domain/` — Entities, use cases
- `presentation/` — Pages, providers, widgets

---

## 🛠️ Tech Stack

| Kategori | Library |
|----------|---------|
| State Management | `flutter_riverpod` |
| Navigation | `go_router` |
| Local Database | `hive`, `hive_flutter` |
| Animations | `flutter_animate` |
| Charts | `fl_chart` |
| Deep Links / WhatsApp | `url_launcher` |
| Images | `cached_network_image`, `flutter_svg` |
| Forms | `image_picker` |
| Utilities | `intl`, `uuid`, `equatable` |
| Fonts | `google_fonts` |

---

## 🗺️ Routes

| Path | Halaman |
|------|---------|
| `/` | Splash |
| `/welcome` | Welcome |
| `/login` | Login |
| `/register` | Registrasi (multi-step) |
| `/ekyc` | E-KYC |
| `/pending` | Pending verifikasi |
| `/dashboard` | Dashboard (shell) |
| `/savings` | Halaman Tabungan (shell) |
| `/savings/deposit` | Setor |
| `/savings/withdrawal` | Tarik |
| `/savings/history` | Semua Riwayat Transaksi |
| `/shopping` | Katalog Produk (shell) |
| `/shopping/product/:id` | Detail Produk |
| `/shopping/wishlist` | Wishlist |
| `/profile` | Profil (shell) |
| `/profile/edit` | Edit Profil |
| `/profile/security` | Keamanan Akun |
| `/notifications` | Notifikasi |

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.35.3+
- IDE (VSCode / Android Studio / Xcode untuk iOS)

### Installation

```bash
# Clone repository
git clone https://github.com/ArayaDev/mobile_koperasiqu_app.git

# Masuk ke direktori
cd mobile_koperasiqu_app

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

---

## 🎨 Design System

Aplikasi menggunakan tema **Liquid Glass** dengan:
- Glassmorphism cards dengan backdrop blur
- Gradient backgrounds (Deep Purple → Blue)
- Micro-animations via `flutter_animate`
- Custom bottom navigation: **Beranda · Tabungan · Belanja · Profil**
- Consistent spacing, rounded corners, dan typography (Google Fonts)

---

## 📝 License

MIT License - Lihat [LICENSE](LICENSE) untuk detail.

---

<p align="center">
  Dibuat dengan ❤️ oleh <strong>ArayaDev</strong>
</p>
