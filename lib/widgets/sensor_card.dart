// Mengimpor paket material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor provider untuk membaca data sensor secara reaktif
import 'package:provider/provider.dart';
// Mengimpor SpeakerProvider
import '../providers/speaker_provider.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';

// Widget kartu pemantau jarak real-time dari dual sensor ultrasonik HC-SR04
class SensorCard extends StatelessWidget {
  const SensorCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data pembacaan sensor dari SpeakerProvider
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final reading = provider.sensorReading;
        final connected = provider.isConnected;
        // Tangan terdeteksi hanya valid jika objek ada dan ESP32 dalam status tersambung
        final detected = reading.objectDetected && connected;

        // Kontainer kartu dengan border animasi yang menyala saat tangan terdeteksi
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // Border menjadi biru saat gestur tangan aktif, atau netral saat diam
              color: detected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              // Ikon telapak tangan gestur dengan latar belakang adaptif
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: detected
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.pan_tool_alt_outlined,
                  color: detected ? AppColors.primary : AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Bagian teks informasi status sensor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris status teks dan titik indikator hijau/abu-abu
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: detected
                                ? AppColors.online
                                : AppColors.offline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          detected
                              ? 'Tangan Terdeteksi'
                              : 'Menunggu Gesture',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: detected
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Menampilkan angka jarak riil dalam satuan cm
                    Text(
                      reading.distanceCm < 100
                          ? '${reading.distanceCm.toStringAsFixed(1)} cm · Dual HC-SR04'
                          : 'Jangkauan bebas · Dual HC-SR04',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Keterangan petunjuk aksi sensor
                    Text(
                      detected
                          ? 'Tangan siap memberi perintah gesture'
                          : 'Sensor kiri (Prev) & kanan (Play/Next)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
