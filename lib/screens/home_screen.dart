// Mengimpor material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';
// Mengimpor widget connection badge indikator status
import '../widgets/connection_badge.dart';
// Mengimpor widget speaker status card
import '../widgets/speaker_status_card.dart';
// Mengimpor widget now playing card pemutar musik
import '../widgets/now_playing_card.dart';
// Mengimpor widget sensor card pembacaan ultrasonik
import '../widgets/sensor_card.dart';
// Mengimpor widget gesture grid panduan kontrol
import '../widgets/gesture_grid.dart';
// Mengimpor layar settings screen
import 'settings_screen.dart';

// Layar utama (Home Screen) aplikasi Future Speaker
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controller animasi fade-in saat pertama kali masuk ke HomeScreen
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Durasi fade-in 600 milidetik dengan kurva easeOut
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // ── Header Bagian Atas (Judul & Tombol Settings) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Future Speaker',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Kontrol Speaker dengan Gesture & Wi-Fi',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol navigasi ke SettingsScreen
                    _buildSettingsButton(context),
                  ],
                ),
              ),

              // ── Badge Indikator Status Koneksi ──
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConnectionBadge(),
                ),
              ),

              // ── Konten Scrollable Kartu-Kartu Utama ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    // Kartu status speaker dan tombol sambung/restart Wi-Fi
                    SpeakerStatusCard(),
                    SizedBox(height: 24),
                    // Label pemutar lagu
                    _SectionLabel('Sedang Diputar'),
                    SizedBox(height: 10),
                    // Kartu pemutar musik aktif
                    NowPlayingCard(),
                    SizedBox(height: 24),
                    // Label pembacaan sensor
                    _SectionLabel('Sensor Gesture HC-SR04'),
                    SizedBox(height: 10),
                    // Kartu monitoring jarak sensor ultrasonik
                    SensorCard(),
                    SizedBox(height: 24),
                    // Label petunjuk gestur
                    _SectionLabel('Petunjuk Kontrol Gesture'),
                    SizedBox(height: 10),
                    // Grid 2x2 informasi gestur tangan
                    GestureGrid(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Membangun tombol ikon gear dengan animasi geser halus menuju SettingsScreen
  Widget _buildSettingsButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, anim, secondaryAnim) => const SettingsScreen(),
              transitionsBuilder: (context, anim, secondaryAnim, child) {
                // Efek transisi bergeser dari kanan ke kiri (SlideTransition)
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surfaceVariant,
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// Widget label judul section yang konsisten
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}
