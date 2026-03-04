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
- Wishlist produk dengan penyimpanan Hive (persisten)
  - Toggle wishlist dari katalog & halaman detail
  - Halaman daftar wishlist dengan hapus per-item & clear all
- Detail produk dengan rating dan info diskon
- Tombol **Beli di WhatsApp** — langsung chat ke admin dengan pesan produk terisi otomatis

### 🎯 Dashboard
- Ringkasan simpanan dengan saldo real-time
- Member tier display
- Transaksi terkini (real-time dari Hive)
- Quick actions: Setor, Tarik

### 👤 Profil
- Halaman profil di bottom navigation
- Info anggota, menu pengaturan, pusat bantuan
- Logout dengan konfirmasi dialog

---

## 🏗️ Arsitektur

```
lib/
├── core/
│   ├── router/             # GoRouter navigation
│   ├── theme/              # Liquid Glass theme
│   ├── services/           # Hive storage (transaksi & wishlist)
│   ├── utils/              # Formatters & validators
│   └── widgets/            # Glass components
├── features/
│   ├── auth/               # Authentication feature
│   ├── dashboard/          # Dashboard + main shell
│   ├── savings/            # Simpanan (deposit, withdrawal)
│   ├── shopping/           # Belanja + wishlist
│   └── profile/            # Profil anggota
```

Setiap feature mengikuti struktur:
- `data/` - Datasources, models, repositories
- `domain/` - Entities, use cases
- `presentation/` - Pages, providers, widgets

---

## 🛠️ Tech Stack

| Kategori | Library |
|----------|---------|
| State Management | `flutter_riverpod` |
| Navigation | `go_router` |
| Local Database | `hive`, `hive_flutter` |
| Animations | `flutter_animate` |
| Charts | `fl_chart` |
| Deep Links | `url_launcher` |
| Images | `cached_network_image`, `flutter_svg` |
| Forms | `image_picker` |
| Utilities | `intl`, `uuid`, `equatable` |
| Fonts | `google_fonts` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.35.3
- IDE (VSCode / Android Studio / Xcode (iOS))

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
- Glassmorphism cards dengan blur effect
- Gradient backgrounds (Deep Purple → Blue)
- Animated transitions
- Custom bottom navigation bar: **Beranda · Tabungan · Belanja · Profil**
- Consistent spacing dan typography

---

## 📝 License

MIT License - Lihat [LICENSE](LICENSE) untuk detail.

---

<p align="center">
  Dibuat dengan ❤️ oleh <strong>ArayaDev</strong>
</p>
