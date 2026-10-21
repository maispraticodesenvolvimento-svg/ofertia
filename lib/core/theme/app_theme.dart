import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary greens
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryDark = Color(0xFF0D3B12);
  static const Color primaryMedium = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySurface = Color(0xFFE8F5E9);
  static const Color primaryBorder = Color(0xFFC8E6C9);

  // Accent
  static const Color accent = Color(0xFF69F0AE);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentAmber = Color(0xFFFFB300);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // States
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFF8F00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // Status chips
  static const Color statusApproved = Color(0xFF2E7D32);
  static const Color statusPending = Color(0xFFFF8F00);
  static const Color statusActive = Color(0xFF1565C0);
  static const Color statusAnalysis = Color(0xFFF57F17);

  // Sidebar
  static const Color sidebarBg = Color(0xFF1B5E20);
  static const Color sidebarActive = Color(0xFF2E7D32);
  static const Color sidebarText = Color(0xFFE8F5E9);
  static const Color sidebarIcon = Color(0xFFA5D6A7);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.grey200),
        ),
        color: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
