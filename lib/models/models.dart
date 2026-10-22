// Model data lagu yang merepresentasikan lagu pada playlist ESP32
class Song {
  // ID unik lagu (0 sampai 7) sesuai urutan playlist di firmware MicroPython
  final int id;
  // Judul lagu (contoh: 'Super Mario', 'Minecraft', dll.)
  final String title;
  // Nama artis atau pencipta lagu
  final String artist;
  // Daftar kumpulan nada (frekuensi dan durasi) untuk lagu ini
  final List<Note> notes;
  // Perkiraan total durasi pemutaran satu putaran melodi lagu
  final Duration duration;

  // Konstruktor konstan untuk membuat objek Song yang immutable (tidak dapat diubah)
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.notes,
    required this.duration,
  });
}

// Representasi satu nada musik tunggal
class Note {
  // Frekuensi nada dalam satuan Hertz (Hz), misal 262 untuk C4, atau 0 untuk jeda nada (REST)
  final int frequency;
  // Durasi nada dibunyikan dalam satuan milidetik (ms)
  final int durationMs;

  // Konstruktor konstan untuk Note
  const Note(this.frequency, this.durationMs);
}

// Enumerasi status koneksi antara aplikasi Flutter dan perangkat ESP32
enum ConnectionState {
  // Berhasil terhubung dan bertukar data dengan ESP32 via Wi-Fi
  connected,
  // Sedang dalam proses mencoba menghubungi IP ESP32
  connecting,
  // Tidak tersambung atau koneksi terputus dari ESP32
  disconnected,
}

// Model data pembacaan sensor ultrasonik HC-SR04
class SensorReading {
  // Jarak yang terukur dalam satuan sentimeter (cm)
  final double distanceCm;
  // Status boolean apakah terdeteksi tangan/objek dalam batas deteksi
  final bool objectDetected;
  // Tipe sensor yang digunakan pada perangkat keras (default: HC-SR04)
  final String sensorType;
  // Waktu saat data sensor ini dicatat/diterima
  final DateTime timestamp;

  // Konstruktor konstan untuk SensorReading
  const SensorReading({
    required this.distanceCm,
    required this.objectDetected,
    this.sensorType = 'HC-SR04',
    required this.timestamp,
  });
}

// Model data konfigurasi pengaturan perangkat Future Speaker
class DeviceSettings {
  // Nama perangkat yang ditampilkan pada UI aplikasi
  String deviceName;
  // Flag aktif/nonaktifnya fitur sensor gestur ultrasonik
  bool sensorEnabled;
  // Tingkat sensitivitas deteksi gestur (1 = Rendah, 2 = Sedang, 3 = Tinggi)
  int sensitivity;
  // Batas ambang jarak deteksi tangan dalam sentimeter (default 15 cm)
  int detectionDistance;
  // Umpan balik audio saat gestur berhasil dikenali
  bool gestureSound;
  // Nama SSID Hotspot Wi-Fi default dari ESP32
  String wifiName;
  // Alamat IP server HTTP ESP32 (Default AP ESP: 192.168.4.1)
  String espIp;
  // Status konektivitas Wi-Fi
  bool wifiConnected;
  // Status kesiapan modul Bluetooth pendukung
  bool bluetoothReady;

  // Konstruktor dengan nilai bawaan (default) yang siap pakai
  DeviceSettings({
    this.deviceName = 'Future Speaker',
    this.sensorEnabled = true,
    this.sensitivity = 3,
    this.detectionDistance = 15,
    this.gestureSound = true,
    this.wifiName = 'FutureSpeaker',
    this.espIp = '192.168.4.1',
    this.wifiConnected = true,
    this.bluetoothReady = true,
  });

  // Method copyWith untuk menduplikasi objek dengan beberapa perubahan nilai tanpa mengubah nilai lainnya
  DeviceSettings copyWith({
    String? deviceName,
    bool? sensorEnabled,
    int? sensitivity,
    int? detectionDistance,
    bool? gestureSound,
    String? wifiName,
    String? espIp,
    bool? wifiConnected,
    bool? bluetoothReady,
  }) {
    return DeviceSettings(
      deviceName: deviceName ?? this.deviceName,
      sensorEnabled: sensorEnabled ?? this.sensorEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      detectionDistance: detectionDistance ?? this.detectionDistance,
      gestureSound: gestureSound ?? this.gestureSound,
      wifiName: wifiName ?? this.wifiName,
      espIp: espIp ?? this.espIp,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      bluetoothReady: bluetoothReady ?? this.bluetoothReady,
    );
  }

  // Getter pembantu untuk menampilkan label teks sensitivitas dalam bahasa Indonesia
  String get sensitivityLabel {
    switch (sensitivity) {
      case 1:
        return 'Rendah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Tinggi';
      default:
        return 'Sedang';
    }
  }
}
