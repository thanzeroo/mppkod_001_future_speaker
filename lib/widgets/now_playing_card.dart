// Mengimpor paket material UI Flutter
import 'package:flutter/material.dart';
// Mengimpor provider untuk membaca dan mengubah status pemutar musik
import 'package:provider/provider.dart';
// Mengimpor SpeakerProvider
import '../providers/speaker_provider.dart';
// Mengimpor token warna tema
import '../theme/app_theme.dart';

// Widget kartu pemutar musik utama (Now Playing Card)
class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data pemutaran musik dari SpeakerProvider
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Informasi Lagu & Tombol Buka Daftar Playlist ──
              Row(
                children: [
                  // Album art ikonik bergradasi biru
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Judul lagu dan nama artis
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Tombol untuk membuka Bottom Sheet daftar lagu
                  IconButton(
                    icon: const Icon(Icons.queue_music_rounded, size: 24),
                    color: AppColors.primary,
                    tooltip: 'Daftar Lagu',
                    onPressed: () => _showPlaylistModal(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Progress Bar & Waktu Berjalan ──
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.sliderInactive,
                      thumbColor: AppColors.primary,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: provider.progress.clamp(0.0, 1.0),
                      // Fungsi seek saat slider digeser pengguna
                      onChanged: (v) => provider.seekTo(v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Waktu detik lagu yang telah diputar
                        Text(
                          provider.currentTimeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Total perkiraan durasi lagu
                        Text(
                          provider.totalTimeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Tombol Pengontrol Pemutaran (Previous, Play/Pause, Next) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Lagu Sebelumnya (Prev)
                  _ControlButton(
                    icon: Icons.skip_previous_rounded,
                    size: 32,
                    onTap: provider.previousSong,
                  ),
                  const SizedBox(width: 28),

                  // Tombol Utama Play / Pause dengan animasi ikon
                  _PlayPauseButton(
                    isPlaying: provider.isPlaying,
                    onTap: provider.togglePlay,
                  ),
                  const SizedBox(width: 28),

                  // Tombol Lagu Berikutnya (Next)
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
                    size: 32,
                    onTap: provider.nextSong,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan modal bottom sheet daftar 8 lagu ESP32
  void _showPlaylistModal(BuildContext context, SpeakerProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle garis penarik modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header modal dan jumlah total lagu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Lagu Future Speaker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${provider.playlist.length} Lagu',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Daftar list lagu
            Expanded(
              child: ListView.separated(
                itemCount: provider.playlist.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: AppColors.cardBorder,
                ),
                itemBuilder: (ctx, index) {
                  final song = provider.playlist[index];
                  final isCurrent = index == provider.currentSongIndex;

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    // Ikon indikator equaliser jika lagu sedang aktif
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCurrent
                            ? Icons.equalizer_rounded
                            : Icons.music_note_rounded,
                        color: isCurrent ? Colors.white : AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w600,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    // Badge label "Diputar" jika lagu ini adalah yang sedang aktif
                    trailing: isCurrent
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Diputar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      // Memilih lagu yang diklik dan menutup modal bottom sheet
                      provider.selectSong(index);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget tombol kontrol bulat untuk Previous dan Next
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: size,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// Widget tombol Play / Pause dengan animasi transisi AnimatedIcon
class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi controller animasi icon Play ke Pause
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  // Mengubah arah animasi saat status isPlaying berubah
  @override
  void didUpdateWidget(_PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: widget.onTap,
        child: Container(
          width: 60,
          height: 60,
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
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            // Ikon animasi perpindahan Play dan Pause
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _controller,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
