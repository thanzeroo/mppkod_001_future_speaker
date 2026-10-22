// Mengimpor async untuk menjalankan timer durasi splash screen
import 'dart:async';
// Mengimpor material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';
// Mengimpor halaman utama HomeScreen tujuan navigasi
import 'home_screen.dart';

// Layar pembuka (Splash Screen) dengan animasi logo berdenyut dan progress bar
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk animasi denyut (pulse) logo
  late AnimationController _pulseController;
  // Controller untuk animasi fade-in saat pertama kali muncul
  late AnimationController _fadeController;
  // Nilai skala pembesaran/pengecilan logo
  late Animation<double> _scaleAnimation;
  // Nilai opasitas fade-in
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi animasi denyutan berulang (1800ms repeat reverse)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    // Interpolasi skala logo dari 0.94 ke 1.06
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Inisialisasi animasi fade-in layar selama 900ms
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Memulai animasi fade-in
    _fadeController.forward();

    // 3. Berpindah ke HomeScreen setelah jeda 2200 milidetik
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        // Mengganti rute dengan efek transisi FadeTransition halus
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, anim, secondaryAnim) => const HomeScreen(),
            transitionsBuilder: (context, anim, secondaryAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  // Membersihkan kedua controller animasi saat widget dibuang dari pohon widget
  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Efek fade-in untuk seluruh konten splash screen
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Animasi Logo Future Speaker ──
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cincin luar lingkaran tipis
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                        ),
                        // Ikon speaker di dalam lingkaran
                        const Icon(
                          Icons.speaker_group_rounded,
                          size: 58,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Judul Aplikasi ──
                const Text(
                  'FUTURE SPEAKER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subjudul Tagline ──
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Smart Gesture & Wi-Fi Audio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Indikator Loading Bar ──
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppColors.sliderInactive,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menyiapkan sistem...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
