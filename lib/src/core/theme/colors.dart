import 'package:flutter/material.dart';

/// Color palette for KoperasiQu — Elegant Light Green theme
class AppColors {
  AppColors._();

  // Primary brand colors — Emerald Green
  static const Color primary = Color(0xFF1B8A5A);       // emerald green
  static const Color primaryLight = Color(0xFF34C27A);  // lighter emerald
  static const Color primaryDark = Color(0xFF0F5C3A);   // deep forest green

  // Solid background colors (light green palette)
  static const Color background = Color(0xFFF0FAF5);    // hijau muda cerah utama
  static const Color backgroundAlt = Color(0xFFE6F5EE); // sedikit lebih dalam
  static const Color surface = Color(0xFFFFFFFF);        // card / surface
  static const Color surfaceVariant = Color(0xFFF5FBF7); // subtle surface

  // Accent colors
  static const Color accent = Color(0xFF2BAE76);         // medium emerald
  static const Color accentLight = Color(0xFFB7E5D0);    // pale mint accent
  static const Color gold = Color(0xFFD4A853);           // elegant gold accent

  // Glass effect colors (for cards on light bg)
  static const Color glassWhite = Color(0xCCFFFFFF);     // 80% white
  static const Color glassBorder = Color(0x661B8A5A);    // 40% primary
  static const Color glassHighlight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);

  // Text colors (dark for light background)
  static const Color textPrimary = Color(0xFF0F3D2A);   // deep forest green
  static const Color textSecondary = Color(0xFF4A7A62); // muted green-grey
  static const Color textMuted = Color(0xFF8AABA0);     // lighter muted
  static const Color textOnPrimary = Colors.white;       // text on primary button

  // Transaction colors
  static const Color income = Color(0xFF059669);
  static const Color expense = Color(0xFFDC2626);

  // Gradient presets — tetap untuk komponen tertentu (header card, buttons)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Tidak lagi digunakan sebagai background layar, tapi tersedia sbg fallback
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAlt],
  );

  /// Background layar sekarang solid — ini alias untuk kompatibilitas
  static const LinearGradient liquidGlassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAlt],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0FAF5)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );

  /// Solid background warna utama (hijau muda cerah)
  static const Color solidBackground = background;

  // ── Backward-compatibility aliases ──────────────────────────────────────
  // File-file lama menggunakan AppColors.teal dan AppColors.purple.
  // Daripada mengubah semua file sekaligus, alias ini memetakan ke warna baru
  // yang harmonis dengan palet hijau elegan.
  @Deprecated('Gunakan AppColors.accent sebagai gantinya')
  static const Color teal = accent;           // emerald medium ≈ teal lama
  @Deprecated('Gunakan AppColors.primaryDark sebagai gantinya')
  static const Color purple = primaryDark;    // deep forest green ≈ purple lama
  @Deprecated('Gunakan AppColors.primaryDark sebagai gantinya')
  static const Color deepBlue = primaryDark;
}
