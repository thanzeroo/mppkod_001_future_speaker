// Mengimpor paket material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';

// Widget grid 2x2 yang menampilkan panduan gestur sensor fisik pada Future Speaker
class GestureGrid extends StatelessWidget {
  const GestureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Baris 1: Sensor Kanan 1x Tap & Sensor Kanan 2x Tap
          Row(
            children: [
              // Kolom 1: 1x Tap Kanan -> Putar / Jeda Musik
              const Expanded(
                child: _GestureItem(
                  icon: Icons.pan_tool_alt_rounded,
                  action: 'Sensor Kanan 1x Tap',
                  result: 'Putar / Jeda Musik',
                ),
              ),
              // Garis pemisah vertikal
              Container(
                width: 1,
                height: 72,
                color: AppColors.cardBorder,
              ),
              // Kolom 2: 2x Tap Kanan -> Lagu Berikutnya (Next)
              const Expanded(
                child: _GestureItem(
                  icon: Icons.double_arrow_rounded,
                  action: 'Sensor Kanan 2x Tap',
                  result: 'Lagu Berikutnya',
                ),
              ),
            ],
          ),
          // Garis pemisah horizontal
          Container(
            height: 1,
            color: AppColors.cardBorder,
          ),
          // Baris 2: Sensor Kiri 1x Tap & Aplikasi / Wi-Fi
          Row(
            children: [
              // Kolom 1: Sensor Kiri -> Lagu Sebelumnya (Prev)
              const Expanded(
                child: _GestureItem(
                  icon: Icons.arrow_back_rounded,
                  action: 'Sensor Kiri 1x Tap',
                  result: 'Lagu Sebelumnya',
                ),
              ),
              // Garis pemisah vertikal
              Container(
                width: 1,
                height: 72,
                color: AppColors.cardBorder,
              ),
              // Kolom 2: Kontrol Wi-Fi & Restart
              const Expanded(
                child: _GestureItem(
                  icon: Icons.wifi_rounded,
                  action: 'Aplikasi / Wi-Fi',
                  result: 'Kontrol & Restart',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget representasi item informasi gestur tunggal
class _GestureItem extends StatelessWidget {
  // Ikon penanda jenis aksi gestur
  final IconData icon;
  // Label pemicu aksi gestur
  final String action;
  // Hasil/perintah yang dijalankan sistem
  final String result;

  const _GestureItem({
    required this.icon,
    required this.action,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kotak ikon dengan warna latar biru primer lembut
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          // Teks deskripsi gestur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
