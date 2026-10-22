// Mengimpor async untuk menjalankan Timer periodik dan Future asynchronous
import 'dart:async';
// Mengimpor foundation untuk ChangeNotifier (state management)
import 'package:flutter/foundation.dart';
// Mengimpor model data aplikasi (Song, SensorReading, DeviceSettings, dll.)
import '../models/models.dart';
// Mengimpor service komunikasi HTTP ke ESP32
import '../services/esp_service.dart';

// Provider utama pengelola state aplikasi: playlist, pemutaran lagu, sensor, dan koneksi Wi-Fi
class SpeakerProvider extends ChangeNotifier {
  // Instance service HTTP untuk berinteraksi dengan ESP32
  final EspService _espService = EspService();

  // ─── Status Koneksi ──────────────────────────────────
  // Status koneksi internal (default: disconnected saat awal dibuka)
  ConnectionState _connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => _connectionState;
  // Getter pembantu untuk mengecek apakah sedang terhubung
  bool get isConnected => _connectionState == ConnectionState.connected;
  // Getter pembantu untuk mengecek apakah sedang proses menghubungkan
  bool get isConnecting => _connectionState == ConnectionState.connecting;
  // Getter pembantu untuk mengecek apakah terputus
  bool get isDisconnected => _connectionState == ConnectionState.disconnected;

  // Penanda boolean apakah ESP32 merespon ping status secara nyata
  bool _isRealEspConnected = false;
  bool get isRealEspConnected => _isRealEspConnected;

  // Penghitung berapa kali polling gagal secara berturut-turut
  int _missedPolls = 0;

  // ─── Pengaturan Perangkat ────────────────────────────
  // Pengaturan perangkat aktif (IP, batas jarak, nama)
  DeviceSettings _settings = DeviceSettings();
  DeviceSettings get settings => _settings;

  // ─── Playlist Lagu (Selaras dengan Firmware ESP32) ───
  // Daftar 8 lagu 8-bit yang tersimpan pada firmware MicroPython ESP32
  final List<Song> _playlist = const [
    Song(
      id: 0,
      title: 'Super Mario',
      artist: 'Koji Kondo',
      notes: [],
      duration: Duration(seconds: 18),
    ),
    Song(
      id: 1,
      title: 'Minecraft',
      artist: 'C418 (Wet Hands)',
      notes: [],
      duration: Duration(seconds: 24),
    ),
    Song(
      id: 2,
      title: 'Tetris',
      artist: 'Korobeiniki',
      notes: [],
      duration: Duration(seconds: 19),
    ),
    Song(
      id: 3,
      title: 'Star Wars',
      artist: 'Imperial March',
      notes: [],
      duration: Duration(seconds: 16),
    ),
    Song(
      id: 4,
      title: 'Pac-Man',
      artist: 'Arcade Theme',
      notes: [],
      duration: Duration(seconds: 14),
    ),
    Song(
      id: 5,
      title: 'Pirates',
      artist: "He's a Pirate",
      notes: [],
      duration: Duration(seconds: 18),
    ),
    Song(
      id: 6,
      title: 'Harry Potter',
      artist: "Hedwig's Theme",
      notes: [],
      duration: Duration(seconds: 19),
    ),
    Song(
      id: 7,
      title: 'Pokemon',
      artist: 'Gotta Catch Em All',
      notes: [],
      duration: Duration(seconds: 18),
    ),
  ];
  List<Song> get playlist => _playlist;

  // ─── State Pemutaran Musik ───────────────────────────
  // Index lagu yang sedang aktif diputar (default: 0 / Super Mario)
  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;
  // Mengambil objek lagu aktif
  Song get currentSong => _playlist[_currentSongIndex];

  // Status apakah musik sedang berjalan atau dijeda
  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  // Posisi detik pemutaran lagu saat ini
  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  // Total durasi lagu aktif
  Duration get totalDuration => currentSong.duration;

  // Menghitung progress persentase pemutaran (0.0 sampai 1.0) untuk slider
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0;
    return (_currentPosition.inMilliseconds / totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  // String format waktu berjalan "MM:SS"
  String get currentTimeStr => _formatDuration(_currentPosition);
  // String format total durasi "MM:SS"
  String get totalTimeStr => _formatDuration(totalDuration);

  // ─── State Sensor Ultrasonik ─────────────────────────
  // Data jarak dan status deteksi tangan terkini
  SensorReading _sensorReading = SensorReading(
    distanceCm: 999,
    objectDetected: false,
    timestamp: DateTime.now(),
  );
  SensorReading get sensorReading => _sensorReading;

  // ─── Timer Sinkronisasi & Posisi Lagu ────────────────
  // Timer untuk memajukan detik posisi lagu
  Timer? _playbackTimer;
  // Timer untuk meminta status ke ESP32 secara periodik
  Timer? _syncTimer;

  // Konstruktor: Memulai timer pemutaran dan timer sinkronisasi, serta langsung mem-probe ESP
  SpeakerProvider() {
    _startPlaybackTimer();
    _startSyncTimer();
    // Memeriksa keberadaan ESP32 saat aplikasi baru saja dibuka
    probeEsp();
  }

  // Membersihkan timer dan client HTTP saat provider dihancurkan
  @override
  void dispose() {
    _playbackTimer?.cancel();
    _syncTimer?.cancel();
    _espService.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  // Kontrol Pemutaran Musik (Optimistic Update)
  // ═══════════════════════════════════════════════════

  // Mengubah status Play / Pause musik
  Future<void> togglePlay() async {
    // Memperbarui state lokal terlebih dahulu secara instan agar UI responsif
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _playbackTimer?.cancel();
    }
    notifyListeners();

    // Mengirim perintah HTTP ke ESP32 jika terhubung
    if (_isRealEspConnected) {
      final res = await _espService.togglePlay(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  // Beralih ke lagu berikutnya
  Future<void> nextSong() async {
    _currentSongIndex = (_currentSongIndex + 1) % _playlist.length;
    _currentPosition = Duration.zero;
    if (_isPlaying) {
      _startPlaybackTimer();
    }
    notifyListeners();

    if (_isRealEspConnected) {
      final res = await _espService.next(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  // Beralih ke lagu sebelumnya
  Future<void> previousSong() async {
    _currentSongIndex =
        (_currentSongIndex - 1 + _playlist.length) % _playlist.length;
    _currentPosition = Duration.zero;
    if (_isPlaying) {
      _startPlaybackTimer();
    }
    notifyListeners();

    if (_isRealEspConnected) {
      final res = await _espService.prev(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  // Memilih lagu tertentu berdasarkan nomor index di playlist
  Future<void> selectSong(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentSongIndex = index;
      _currentPosition = Duration.zero;
      _isPlaying = true;
      _startPlaybackTimer();
      notifyListeners();

      if (_isRealEspConnected) {
        final res = await _espService.selectSong(_settings.espIp, index);
        if (res != null) _applyEspStatus(res);
      }
    }
  }

  // Menggeser posisi pemutaran lagu (seek) menggunakan slider
  void seekTo(double fraction) {
    _currentPosition = Duration(
      milliseconds: (totalDuration.inMilliseconds * fraction).round(),
    );
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Manajemen Koneksi Wi-Fi ke ESP32
  // ═══════════════════════════════════════════════════

  // Menguji keberadaan ESP32 secara senyap di background
  Future<bool> probeEsp() async {
    final status = await _espService.getStatus(_settings.espIp);
    if (status != null) {
      _missedPolls = 0;
      _isRealEspConnected = true;
      _connectionState = ConnectionState.connected;
      _applyEspStatus(status);
      notifyListeners();
      return true;
    } else {
      if (_isRealEspConnected) {
        _isRealEspConnected = false;
        _connectionState = ConnectionState.disconnected;
        notifyListeners();
      }
      return false;
    }
  }

  // Memulai proses koneksi manual ke ESP32 via Wi-Fi
  Future<bool> connect([String? newIp]) async {
    if (newIp != null && newIp.trim().isNotEmpty) {
      _settings = _settings.copyWith(espIp: newIp.trim());
    }

    _connectionState = ConnectionState.connecting;
    notifyListeners();

    final status = await _espService.getStatus(_settings.espIp);
    if (status != null) {
      _missedPolls = 0;
      _isRealEspConnected = true;
      _connectionState = ConnectionState.connected;
      _applyEspStatus(status);
      _startPlaybackTimer();
      notifyListeners();
      return true;
    } else {
      _missedPolls = 0;
      _isRealEspConnected = false;
      _connectionState = ConnectionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  // Merestart pemutaran musik di ESP32 dan menyambungkan kembali koneksi
  Future<bool> restartConnection() async {
    _connectionState = ConnectionState.connecting;
    notifyListeners();

    if (_isRealEspConnected) {
      await _espService.restart(_settings.espIp);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    final ok = await connect();
    return ok;
  }

  // Memutuskan koneksi secara manual dari ESP32
  Future<void> disconnect() async {
    _connectionState = ConnectionState.disconnected;
    _isPlaying = false;
    _isRealEspConnected = false;
    _playbackTimer?.cancel();
    _sensorReading = SensorReading(
      distanceCm: 999,
      objectDetected: false,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Manajemen Pengaturan (Settings)
  // ═══════════════════════════════════════════════════

  // Memperbarui seluruh konfigurasi pengaturan perangkat
  void updateSettings(DeviceSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // Mengubah nama tampilan speaker
  void setDeviceName(String name) {
    _settings = _settings.copyWith(deviceName: name);
    notifyListeners();
  }

  // Mengubah alamat IP tujuan ESP32
  void setEspIp(String ip) {
    _settings = _settings.copyWith(espIp: ip.trim());
    notifyListeners();
  }

  // Mengaktifkan atau menonaktifkan fitur sensor gestur
  void setSensorEnabled(bool enabled) {
    _settings = _settings.copyWith(sensorEnabled: enabled);
    if (!enabled) {
      _sensorReading = SensorReading(
        distanceCm: 999,
        objectDetected: false,
        timestamp: DateTime.now(),
      );
    }
    notifyListeners();
  }

  // Mengatur tingkat sensitivitas deteksi gestur
  void setSensitivity(int value) {
    _settings = _settings.copyWith(sensitivity: value);
    notifyListeners();
  }

  // Mengatur ambang batas jarak deteksi sensor (cm)
  void setDetectionDistance(int value) {
    _settings = _settings.copyWith(detectionDistance: value);
    notifyListeners();
  }

  // Mengatur bunyi konfirmasi gestur
  void setGestureSound(bool value) {
    _settings = _settings.copyWith(gestureSound: value);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Sinkronisasi Data & Realtime Timers
  // ═══════════════════════════════════════════════════

  // Menerapkan data status JSON yang diterima dari ESP32 ke state aplikasi Flutter
  void _applyEspStatus(Map<String, dynamic> status) {
    final bool espPlaying = status['playing'] == true;
    final int? espSongIndex = status['song_index'] as int?;
    final num? kiri = status['kiri'] as num?;
    final num? kanan = status['kanan'] as num?;

    // Menyesuaikan status playing jika berbeda dengan data ESP32
    if (espPlaying != _isPlaying) {
      _isPlaying = espPlaying;
    }
    // Menyesuaikan nomor lagu jika ESP32 berpindah lagu lewat gestur fisik
    if (espSongIndex != null &&
        espSongIndex >= 0 &&
        espSongIndex < _playlist.length &&
        espSongIndex != _currentSongIndex) {
      _currentSongIndex = espSongIndex;
      _currentPosition = Duration.zero;
    }

    // Memproses pembacaan dual sensor ultrasonik HC-SR04
    final double distKanan = kanan?.toDouble() ?? 999.0;
    final double distKiri = kiri?.toDouble() ?? 999.0;
    // Mengambil jarak terdekat dari kedua sensor
    final double activeDist = distKanan < distKiri ? distKanan : distKiri;
    final bool detected = activeDist < _settings.detectionDistance;

    // Memperbarui model pembacaan sensor
    _sensorReading = SensorReading(
      distanceCm: activeDist > 200 ? 999.0 : activeDist,
      objectDetected: detected,
      timestamp: DateTime.now(),
    );

    // Memberitahu semua widget pendengar agar UI segera dirender ulang
    notifyListeners();
  }

  // Timer periodik setiap 1000ms untuk meminta status terbaru dari ESP32 (Polling)
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) async {
      // Jika sedang proses connecting manual, jangan tumpuk dengan auto-sync
      if (isConnecting) return;

      final status = await _espService.getStatus(_settings.espIp);
      if (status != null) {
        _missedPolls = 0;
        if (!_isRealEspConnected || _connectionState != ConnectionState.connected) {
          _isRealEspConnected = true;
          _connectionState = ConnectionState.connected;
          _startPlaybackTimer();
        }
        _applyEspStatus(status);
      } else {
        if (_isRealEspConnected) {
          _missedPolls++;
          // Jika gagal 3 kali berturut-turut (~3 detik), tandai status terputus
          if (_missedPolls >= 3) {
            _isRealEspConnected = false;
            _connectionState = ConnectionState.disconnected;
            notifyListeners();
          }
        }
      }
    });
  }

  // Timer periodik setiap 1 detik untuk memajukan progres lagu
  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      _currentPosition += const Duration(seconds: 1);
      // Jika durasi lagu habis, otomatis lompat ke lagu berikutnya
      if (_currentPosition >= totalDuration) {
        nextSong();
      }
      notifyListeners();
    });
  }

  // Memformat objek Duration menjadi teks representasi "MM:SS"
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
