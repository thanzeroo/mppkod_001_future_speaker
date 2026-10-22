// Mengimpor async untuk menangani operasi asynchronous (Future, Duration, Timeout)
import 'dart:async';
// Mengimpor pustaka convert untuk encode/decode format JSON
import 'dart:convert';
// Mengimpor package http untuk mengirim HTTP GET/POST request ke ESP32
import 'package:http/http.dart' as http;

// Layanan perantara komunikasi jaringan antara aplikasi Flutter dan HTTP REST API ESP32
class EspService {
  // Instance http client yang dapat digunakan kembali untuk performa koneksi yang efisien
  final http.Client _client = http.Client();

  // Mengambil status terkini ESP32 (apakah memutar lagu, index lagu, serta jarak sensor)
  Future<Map<String, dynamic>?> getStatus(String ip) async {
    return _sendRequest(ip, '/api/status');
  }

  // Mengirim perintah Toggle Play / Pause ke ESP32
  Future<Map<String, dynamic>?> togglePlay(String ip) async {
    return _sendRequest(ip, '/api/toggle');
  }

  // Mengirim perintah Play (putar) lagu ke ESP32
  Future<Map<String, dynamic>?> play(String ip) async {
    return _sendRequest(ip, '/api/play');
  }

  // Mengirim perintah Pause (jeda) lagu ke ESP32
  Future<Map<String, dynamic>?> pause(String ip) async {
    return _sendRequest(ip, '/api/pause');
  }

  // Mengirim perintah beralih ke lagu berikutnya (Next Song)
  Future<Map<String, dynamic>?> next(String ip) async {
    return _sendRequest(ip, '/api/next');
  }

  // Mengirim perintah beralih ke lagu sebelumnya (Previous Song)
  Future<Map<String, dynamic>?> prev(String ip) async {
    return _sendRequest(ip, '/api/prev');
  }

  // Mengirim perintah memilih lagu spesifik berdasarkan ID/index daftar lagu
  Future<Map<String, dynamic>?> selectSong(String ip, int index) async {
    return _sendRequest(ip, '/api/select?id=$index');
  }

  // Mengirim perintah reset dan memutar ulang lagu dari awal (Lagu 0 / Super Mario)
  Future<Map<String, dynamic>?> restart(String ip) async {
    return _sendRequest(ip, '/api/restart');
  }

  // Fungsi pembantu terpusat untuk mengirim request HTTP GET dan mem-parsing respon JSON
  Future<Map<String, dynamic>?> _sendRequest(String ip, String path) async {
    // Membersihkan format IP dari spasi berlebih atau prefix protokol jika user mengetikkannya
    final cleanIp = ip.trim().replaceAll('http://', '').replaceAll('/', '');
    // Membangun URL lengkap yang valid
    final uri = Uri.parse('http://$cleanIp$path');

    try {
      // Mengirim request GET dengan batas waktu timeout 2500 milidetik agar UI tidak macet
      final response = await _client.get(uri).timeout(
            const Duration(milliseconds: 2500),
          );

      // Memeriksa jika status HTTP adalah 200 OK
      if (response.statusCode == 200) {
        final body = response.body;
        // Memastikan body respon tidak kosong
        if (body.isNotEmpty) {
          // Mendekode string JSON menjadi Map objek Dart
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      }
      return null;
    } catch (e) {
      // Menangkap error jika perangkat offline, timeout jaringan, atau socket terputus
      return null;
    }
  }

  // Menutup client http saat service dibersihkan untuk menghindari memory leak
  void dispose() {
    _client.close();
  }
}
