import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pengaturan pengguna yang disimpan dengan Shared Preferences.
class AppSettings extends ChangeNotifier {
  static const _kCity = 'city';
  static const _kMethod = 'method';
  static const _kDark = 'dark_mode';

  /// Kota yang tersedia (nama sesuai pencarian API).
  static const cities = [
    'Probolinggo',
    'Surabaya',
    'Malang',
    'Jakarta',
    'Bandung',
    'Yogyakarta',
    'Semarang',
    'Denpasar',
    'Medan',
    'Makassar',
  ];

  /// Metode perhitungan (id sesuai API Aladhan).
  static const methods = {
    20: 'Kemenag RI',
    3: 'Muslim World League',
    5: 'Egyptian General Authority',
  };

  String city = 'Probolinggo';
  int method = 20;
  bool isDark = false;

  /// Memuat pengaturan secara asinkron saat aplikasi dibuka.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    city = prefs.getString(_kCity) ?? city;
    method = prefs.getInt(_kMethod) ?? method;
    isDark = prefs.getBool(_kDark) ?? isDark;
    notifyListeners();
  }

  Future<void> setCity(String value) async {
    city = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCity, value);
  }

  Future<void> setMethod(int value) async {
    method = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kMethod, value);
  }

  Future<void> setDark(bool value) async {
    isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, value);
  }
}
