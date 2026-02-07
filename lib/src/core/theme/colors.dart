import 'package:flutter/material.dart';

/// Color palette for KoperasiQu "Liquid Glass" theme
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF136DEC);
  static const Color primaryLight = Color(0xFF4F9DFF);
  static const Color primaryDark = Color(0xFF0A4BA8);

  // Gradient colors for backgrounds
  static const Color gradientStart = Color(0xFF1A4B8C);
  static const Color gradientMiddle = Color(0xFF2D6B9E);
  static const Color gradientEnd = Color(0xFF4A2C82);

  static const Color teal = Color(0xFF19A1E6);
  static const Color purple = Color(0xFF7C3AED);
  static const Color deepBlue = Color(0xFF0F172A);

  // Glass effect colors
  static const Color glassWhite = Color(0x26FFFFFF); // 15% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassHighlight = Color(0x4DFFFFFF); // 30% white

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF); // 50% white

  // Transaction colors
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, teal],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF2D1B4E)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient liquidGlassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A8A), Color(0xFF0891B2), Color(0xFF7C3AED)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x1AFFFFFF)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, teal],
  );
}
