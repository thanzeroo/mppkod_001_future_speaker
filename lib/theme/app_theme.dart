// Mengimpor material untuk komponen UI dan warna Flutter
import 'package:flutter/material.dart';
// Mengimpor services untuk kustomisasi overlay status bar
import 'package:flutter/services.dart';

// Palet warna terpusat (Design System Tokens) untuk konsistensi visual di seluruh aplikasi
class AppColors {
  // Palet Warna Primer - Biru modern vibrant
  static const Color primary = Color(0xFF1E60FF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF174BC4);
  static const Color primarySurface = Color(0xFFEEF4FF);
  static const Color primarySurfaceLight = Color(0xFFF5F8FF);

  // Aksen - Cyan elektrik & biru langit lembut
  static const Color accent = Color(0xFF00C6FF);
  static const Color accentSoft = Color(0xFFBAE6FD);

  // Warna Latar Belakang & Permukaan Kartu
  static const Color background = Color(0xFFF3F7FC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEAF1FA);

  // Tipografi Warna Teks Berjenjang
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  // Warna Indikator Status (Harmonis & Tenang)
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFF64748B);

  // Badge Status Koneksi
  static const Color connectedBg = Color(0xFFE0F2FE);
  static const Color connectedText = Color(0xFF0369A1);
  static const Color disconnectedBg = Color(0xFFF1F5F9);
  static const Color disconnectedText = Color(0xFF475569);

  // Slider Pemutar Musik
  static const Color sliderActive = Color(0xFF1E60FF);
  static const Color sliderInactive = Color(0xFFD6E4FF);

  // Border Garis Kartu
  static const Color cardBorder = Color(0xFFE2EBF6);

  // Tombol Putuskan Koneksi
  static const Color disconnectBg = Color(0xFFF8FAFC);
  static const Color disconnectText = Color(0xFF475569);
  static const Color disconnectBorder = Color(0xFFCBD5E1);

  // Tombol Toggle Switch
  static const Color toggleActive = Color(0xFF1E60FF);
  static const Color toggleInactive = Color(0xFFCBD5E1);
}

// Konfigurasi Tema Global Material Design 3
class AppTheme {
  // Getter tema terang (light theme)
  static ThemeData get lightTheme {
    return ThemeData(
      // Mengaktifkan spesifikasi desain Material 3
      useMaterial3: true,
      // Menggunakan font modern 'Inter'
      fontFamily: 'Inter',
      // Brightness terang
      brightness: Brightness.light,
      // Warna background scaffold default
      scaffoldBackgroundColor: AppColors.background,
      // Skema warna komponen UI
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      // Pengaturan AppBar bersih tanpa bayangan (flat modern)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      // Pengaturan Card sudut membulat 16px dengan garis border halus
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // Pengaturan Slider pemutar musik
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sliderActive,
        inactiveTrackColor: AppColors.sliderInactive,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      // Pengaturan tombol ElevatedButton dengan sudut membulat 14px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
