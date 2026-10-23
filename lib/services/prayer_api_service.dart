import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/prayer_time.dart';

/// Layanan untuk mengambil jadwal sholat dari API Aladhan.
class PrayerApiService {
  static const _host = 'api.aladhan.com';

  /// Mengambil jadwal sholat secara asinkron.
  /// Mengembalikan [Future] karena proses jaringan membutuhkan waktu.
  Future<PrayerTime> fetchPrayerTimes({
    required String city,
    required DateTime date,
    required int method,
  }) async {
    final dateParam = DateFormat('dd-MM-yyyy').format(date);
    final uri = Uri.https(_host, '/v1/timingsByCity/$dateParam', {
      'city': city,
      'country': 'Indonesia',
      'method': method.toString(),
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw HttpException('Server mengembalikan kode ${response.statusCode}');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PrayerTime.fromApi(
        json,
        city: city,
        date: DateFormat('yyyy-MM-dd').format(date),
      );
    } on TimeoutException {
      throw Exception('Koneksi timeout. Periksa jaringan internet.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }
}
