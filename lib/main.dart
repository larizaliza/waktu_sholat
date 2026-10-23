import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'services/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  // Memuat pengaturan aplikasi.
  final settings = AppSettings();
  await settings.load();

  runApp(WaktuSholatApp(settings: settings));
}

class WaktuSholatApp extends StatelessWidget {
  final AppSettings settings;

  const WaktuSholatApp({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Waktu Sholat',
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF10463B),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F4EC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF082D27),
              foregroundColor: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9BE8C8),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF082D27),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF082D27),
              foregroundColor: Colors.white,
            ),
          ),

          home: HomeScreen(settings: settings),
        );
      },
    );
  }
}