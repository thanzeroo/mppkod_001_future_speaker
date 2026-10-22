// Mengimpor pustaka inti Flutter untuk komponen UI berbasis Material Design
import 'package:flutter/material.dart';
// Mengimpor pustaka services untuk mengakses fitur sistem operasi seperti orientasi dan status bar
import 'package:flutter/services.dart';
// Mengimpor pustaka provider untuk state management reaktif aplikasi
import 'package:provider/provider.dart';
// Mengimpor konfigurasi tema visual kustom (warna, tipografi, card, slider)
import 'theme/app_theme.dart';
// Mengimpor provider pengelola state speaker, koneksi Wi-Fi, dan pembacaan sensor
import 'providers/speaker_provider.dart';
// Mengimpor halaman splash animasi sebagai tampilan pertama saat aplikasi dimuat
import 'screens/splash_screen.dart';

// Fungsi utama (entry point) aplikasi Flutter
void main() {
  // Memastikan framework Flutter dan engine binding siap sepenuhnya sebelum memanggil API platform
  WidgetsFlutterBinding.ensureInitialized();

  // Mengunci orientasi layar perangkat agar tetap dalam posisi tegak (portrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Mengatur gaya bilah status sistem (status bar transparan dengan ikon gelap yang bersih)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Menjalankan widget root utama aplikasi
  runApp(const FutureSpeakerApp());
}

// Widget root aplikasi Future Speaker
class FutureSpeakerApp extends StatelessWidget {
  const FutureSpeakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan SpeakerProvider ke seluruh hierarki widget (state management global)
    return ChangeNotifierProvider(
      // Menginisialisasi instance SpeakerProvider untuk mengelola data speaker secara reaktif
      create: (_) => SpeakerProvider(),
      child: MaterialApp(
        // Judul aplikasi yang tampil pada app switcher perangkat
        title: 'Future Speaker',
        // Menyembunyikan banner "DEBUG" di pojok kanan atas layar
        debugShowCheckedModeBanner: false,
        // Menerapkan tema modern Material 3 yang telah dikustomisasi
        theme: AppTheme.lightTheme,
        // Menentukan halaman awal yang ditampilkan adalah SplashScreen
        home: const SplashScreen(),
      ),
    );
  }
}
