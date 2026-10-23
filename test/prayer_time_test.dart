import 'package:flutter_test/flutter_test.dart';
import 'package:waktu_sholat/models/prayer_time.dart';

void main() {
  test('PrayerTime.fromApi membersihkan format waktu', () {
    final json = {
      'data': {
        'timings': {
          'Fajr': '04:10 (WIB)',
          'Sunrise': '05:20',
          'Dhuhr': '11:30',
          'Asr': '14:45',
          'Maghrib': '17:35',
          'Isha': '18:45',
        }
      }
    };
    final p = PrayerTime.fromApi(json, city: 'Probolinggo', date: '2026-10-22');
    expect(p.fajr, '04:10');
    expect(p.toMap()['city'], 'Probolinggo');
  });
}
