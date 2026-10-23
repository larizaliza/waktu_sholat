/// Model jadwal sholat untuk satu kota pada satu tanggal.
class PrayerTime {
  final int? id;
  final String city;
  final String date; // format yyyy-MM-dd
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateTime fetchedAt;

  PrayerTime({
    this.id,
    required this.city,
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.fetchedAt,
  });

  /// Membuat objek dari respons JSON API Aladhan.
  factory PrayerTime.fromApi(Map<String, dynamic> json,
      {required String city, required String date}) {
    final t = json['data']['timings'] as Map<String, dynamic>;
    // Nilai API bisa berbentuk "04:32 (WIB)", ambil 5 karakter pertama.
    String clean(dynamic v) => v.toString().substring(0, 5);
    return PrayerTime(
      city: city,
      date: date,
      fajr: clean(t['Fajr']),
      sunrise: clean(t['Sunrise']),
      dhuhr: clean(t['Dhuhr']),
      asr: clean(t['Asr']),
      maghrib: clean(t['Maghrib']),
      isha: clean(t['Isha']),
      fetchedAt: DateTime.now(),
    );
  }

  /// Konversi ke Map untuk disimpan ke SQLite.
  Map<String, dynamic> toMap() => {
        'id': id,
        'city': city,
        'date': date,
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'fetched_at': fetchedAt.toIso8601String(),
      };

  /// Konversi dari baris SQLite ke objek.
  factory PrayerTime.fromMap(Map<String, dynamic> m) => PrayerTime(
        id: m['id'] as int?,
        city: m['city'] as String,
        date: m['date'] as String,
        fajr: m['fajr'] as String,
        sunrise: m['sunrise'] as String,
        dhuhr: m['dhuhr'] as String,
        asr: m['asr'] as String,
        maghrib: m['maghrib'] as String,
        isha: m['isha'] as String,
        fetchedAt: DateTime.parse(m['fetched_at'] as String),
      );
}
