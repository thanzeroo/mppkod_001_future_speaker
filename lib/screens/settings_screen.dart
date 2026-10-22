// Mengimpor material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor provider untuk membaca dan mengubah konfigurasi DeviceSettings
import 'package:provider/provider.dart';
// Mengimpor SpeakerProvider
import '../providers/speaker_provider.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';
// Mengimpor layar DisconnectedScreen saat user menekan putuskan koneksi
import 'disconnected_screen.dart';

// Layar pengaturan (Settings Screen) untuk konfigurasi IP, sensitivitas sensor, dan profil speaker
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Mendengarkan data DeviceSettings dari SpeakerProvider
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final s = provider.settings;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header Pengaturan & Tombol Kembali ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      // Tombol panah kembali ke HomeScreen
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        color: AppColors.textPrimary,
                      ),
                      const Expanded(
                        child: Text(
                          'Pengaturan Future Speaker',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Daftar Pilihan Pengaturan (Scrollable) ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Kartu identitas perangkat & status koneksi aktif
                      _DeviceCard(
                        name: s.deviceName,
                        isConnected: provider.isConnected,
                        ip: s.espIp,
                      ),
                      const SizedBox(height: 24),

                      // ── Bagian Koneksi Jaringan Wi-Fi ──
                      _sectionTitle('Koneksi Jaringan Wi-Fi'),
                      const SizedBox(height: 12),
                      // Item ubah IP ESP32
                      _SettingsItem(
                        icon: Icons.wifi,
                        iconColor: AppColors.primary,
                        title: 'IP ESP32 Wi-Fi',
                        subtitle: s.espIp,
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onTap: () => _showIpDialog(context, provider),
                      ),
                      const SizedBox(height: 8),
                      // Item restart koneksi
                      _SettingsItem(
                        icon: Icons.sync_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'Restart Koneksi',
                        subtitle: 'Hubungkan ulang & reset transmisi',
                        trailing: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onTap: () async {
                          // Menjalankan restart connection ke ESP32
                          await provider.restartConnection();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Koneksi berhasil di-restart!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: AppColors.primaryDark,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Bagian Sensor Gestur Ultrasonik HC-SR04 ──
                      _sectionTitle('Sensor Gesture HC-SR04'),
                      const SizedBox(height: 12),
                      // Toggle aktif/nonaktif sensor
                      _SettingsItem(
                        icon: Icons.pan_tool_alt_outlined,
                        iconColor: AppColors.primary,
                        title: 'Sensor Gesture',
                        subtitle:
                            'HC-SR04 · ${s.sensorEnabled ? "Aktif" : "Nonaktif"}',
                        trailing: _ToggleSwitch(
                          value: s.sensorEnabled,
                          onChanged: (v) => provider.setSensorEnabled(v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Slider tingkat sensitivitas (Rendah, Sedang, Tinggi)
                      _SliderItem(
                        title: 'Sensitivitas',
                        valueLabel: s.sensitivityLabel,
                        value: s.sensitivity.toDouble(),
                        min: 1,
                        max: 3,
                        divisions: 2,
                        onChanged: (v) => provider.setSensitivity(v.round()),
                      ),
                      const SizedBox(height: 8),
                      // Slider batas jarak deteksi tangan (2-20 cm)
                      _SliderItem(
                        title: 'Jarak Deteksi',
                        valueLabel: '${s.detectionDistance} cm',
                        subtitle: '2–20 cm batas tangan',
                        value: s.detectionDistance.toDouble(),
                        min: 2,
                        max: 20,
                        divisions: 18,
                        onChanged: (v) =>
                            provider.setDetectionDistance(v.round()),
                      ),
                      const SizedBox(height: 24),

                      // ── Bagian Feedback Audio ──
                      _sectionTitle('Feedback'),
                      const SizedBox(height: 12),
                      // Toggle bunyi konfirmasi gestur
                      _SettingsItem(
                        icon: Icons.notifications_active_outlined,
                        iconColor: AppColors.primary,
                        title: 'Bunyi Konfirmasi Gesture',
                        subtitle: 'Bunyi singkat saat gesture terdeteksi',
                        trailing: _ToggleSwitch(
                          value: s.gestureSound,
                          onChanged: (v) => provider.setGestureSound(v),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Bagian Profil Perangkat ──
                      _sectionTitle('Perangkat'),
                      const SizedBox(height: 12),
                      // Item ganti nama perangkat speaker
                      _SettingsItem(
                        icon: Icons.edit_outlined,
                        iconColor: AppColors.primary,
                        title: 'Nama Perangkat',
                        subtitle: s.deviceName,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 22,
                        ),
                        onTap: () => _showDeviceNameDialog(context, provider),
                      ),
                      const SizedBox(height: 32),

                      // ── Tombol Putuskan Koneksi ──
                      _DisconnectButton(
                        onTap: () => _handleDisconnect(context, provider),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Label pemisah kategori pengaturan
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  // Dialog pop-up ubah alamat IP Wi-Fi
  void _showIpDialog(BuildContext context, SpeakerProvider provider) {
    final controller = TextEditingController(text: provider.settings.espIp);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Alamat IP Wi-Fi ESP32',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alamat IP yang tertera di Thonny (Default Hotspot ESP: 192.168.4.1)',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                provider.setEspIp(newIp);
                provider.connect(newIp);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan & Sambung'),
          ),
        ],
      ),
    );
  }

  // Dialog pop-up ganti nama perangkat speaker
  void _showDeviceNameDialog(BuildContext context, SpeakerProvider provider) {
    final controller =
        TextEditingController(text: provider.settings.deviceName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nama Perangkat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                provider.setDeviceName(name);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Memutuskan koneksi dan mengarahkan navigasi ke DisconnectedScreen
  void _handleDisconnect(BuildContext ctx, SpeakerProvider provider) {
    provider.disconnect();
    Navigator.of(ctx).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DisconnectedScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }
}

// ═══════════════════════════════════════════════════════
// Komponen Widget Internal Layar Settings
// ═══════════════════════════════════════════════════════

// Widget kartu preview informasi perangkat
class _DeviceCard extends StatelessWidget {
  final String name;
  final bool isConnected;
  final String ip;

  const _DeviceCard({
    required this.name,
    required this.isConnected,
    required this.ip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Ikon speaker dalam kotak biru muda
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.speaker_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Nama perangkat dan alamat IP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ESP32 · $ip',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Badge status terhubung / terputus
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isConnected ? AppColors.connectedBg : AppColors.disconnectedBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? AppColors.online : AppColors.error,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? 'Terhubung' : 'Terputus',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isConnected
                        ? AppColors.connectedText
                        : AppColors.disconnectedText,
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

// Widget baris item pengaturan standar (icon, title, subtitle, trailing action)
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// Widget slider pengaturan bertahap (sensitivitas dan jarak deteksi)
class _SliderItem extends StatelessWidget {
  final String title;
  final String valueLabel;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderItem({
    required this.title,
    required this.valueLabel,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                valueLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: AppColors.sliderActive,
              inactiveTrackColor: AppColors.sliderInactive,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget tombol toggle switch animasi kustom
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? AppColors.toggleActive : AppColors.toggleInactive,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget tombol putuskan koneksi berwarna slate bersih
class _DisconnectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DisconnectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.disconnectBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.disconnectBorder),
          ),
          child: const Center(
            child: Text(
              'Putuskan Koneksi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.disconnectText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
