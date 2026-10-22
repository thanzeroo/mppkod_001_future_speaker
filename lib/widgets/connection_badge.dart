// Mengimpor paket material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor provider untuk membaca state SpeakerProvider
import 'package:provider/provider.dart';
// Mengimpor SpeakerProvider
import '../providers/speaker_provider.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';

// Widget badge pil dinamis yang menampilkan status konektivitas Wi-Fi ke ESP32
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengonsumsi state dari SpeakerProvider secara reaktif
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final connected = provider.isConnected;
        final isConnecting = provider.isConnecting;

        // Kontainer dengan animasi transisi warna latar belakang saat status berubah
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            // Warna latar biru lembut saat terhubung, atau abu-abu slate saat terputus
            color: connected ? AppColors.connectedBg : AppColors.disconnectedBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titik berkedip (pulsing dot) indikator status aktif
              _PulseDot(
                color: isConnecting
                    ? AppColors.warning
                    : (connected ? AppColors.online : AppColors.error),
              ),
              const SizedBox(width: 8),
              // Animasi pergantian teks halus
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isConnecting
                      ? 'Menghubungkan...'
                      : (connected ? 'Terhubung (Wi-Fi ESP)' : 'Belum Terhubung'),
                  key: ValueKey('${connected}_$isConnecting'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: connected
                        ? AppColors.connectedText
                        : AppColors.disconnectedText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget internal untuk animasi titik berdenyut (pulsing dot)
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Mengontrol durasi denyutan 1.5 detik berulang bolak-balik (repeat reverse)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    // Interpolasi opasitas dari 0.5 ke 1.0 dengan kurva halus
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Membebaskan controller animasi dari memori
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Mengatur opasitas dinamis mengikuti nilai animasi
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
