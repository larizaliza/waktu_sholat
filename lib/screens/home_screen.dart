import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/prayer_time.dart';
import '../services/app_settings.dart';
import '../services/prayer_api_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

const Color darkGreen = Color(0xFF082D27);
const Color deepGreen = Color(0xFF10463B);
const Color mintGreen = Color(0xFF9BE8C8);
const Color cream = Color(0xFFF7F4EC);
const Color textDark = Color(0xFF183B34);
const Color mutedText = Color(0xFF73847C);

class HomeScreen extends StatefulWidget {
  final AppSettings settings;

  const HomeScreen({
    super.key,
    required this.settings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerApiService _api = PrayerApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  PrayerTime? _data;
  bool _loading = true;
  bool _fromCache = false;
  String? _error;

  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _load();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final city = widget.settings.city;
    final today = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(today);

    try {
      final result = await _api.fetchPrayerTimes(
        city: city,
        date: today,
        method: widget.settings.method,
      );

      await _db.upsert(result);

      if (!mounted) return;

      setState(() {
        _data = result;
        _fromCache = false;
      });
    } catch (e) {
      try {
        final cached = await _db.getByCityDate(city, dateKey);

        if (!mounted) return;

        setState(() {
          if (cached != null) {
            _data = cached;
            _fromCache = true;
          } else {
            _data = null;
            _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
          }
        });
      } catch (cacheError) {
        if (!mounted) return;

        setState(() {
          _data = null;
          _error = 'Gagal memuat jadwal sholat.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  DateTime _toDateTime(
      String hhmm, {
        int addDays = 0,
      }) {
    final parts = hhmm.split(':');

    return DateTime(
      _now.year,
      _now.month,
      _now.day + addDays,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  MapEntry<String, DateTime> _nextPrayer(PrayerTime prayer) {
    final prayers = <String, String>{
      'Subuh': prayer.fajr,
      'Dzuhur': prayer.dhuhr,
      'Ashar': prayer.asr,
      'Maghrib': prayer.maghrib,
      'Isya': prayer.isha,
    };

    for (final item in prayers.entries) {
      final time = _toDateTime(item.value);

      if (time.isAfter(_now)) {
        return MapEntry(item.key, time);
      }
    }

    return MapEntry(
      'Subuh',
      _toDateTime(prayer.fajr, addDays: 1),
    );
  }

  String _format(Duration duration) {
    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(duration.inHours)}:'
        '${two(duration.inMinutes % 60)}:'
        '${two(duration.inSeconds % 60)}';
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: deepGreen,
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: mintGreen,
        ),
      );
    }

    if (_data == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 130),
          const Icon(
            Icons.cloud_off_rounded,
            color: mintGreen,
            size: 65,
          ),
          const SizedBox(height: 20),
          Text(
            _error ?? 'Data jadwal sholat belum tersedia.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    final prayer = _data!;
    final next = _nextPrayer(prayer);
    final remaining = next.value.difference(_now);

    final dateText = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(_now);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(dateText),
        _buildCountdown(next.key, remaining),
        if (_fromCache) _buildOfflineBanner(prayer),
        _buildSchedule(prayer, next.key),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader(String dateText) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 18,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF153F35),
            Color(0xFF082D27),
            Color(0xFF061F1B),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: mintGreen.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: mintGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu Sholat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Jadwal sholat harian',
                      style: TextStyle(
                        color: Color(0xFFC1D4CC),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _headerButton(
                Icons.history_rounded,
                'Riwayat',
                    () => _open(const HistoryScreen()),
              ),
              const SizedBox(width: 5),
              _headerButton(
                Icons.settings_rounded,
                'Pengaturan',
                    () => _open(
                  SettingsScreen(settings: widget.settings),
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: mintGreen,
                size: 24,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.settings.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: Color(0xFFB6CDC4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
      IconData icon,
      String tooltip,
      VoidCallback onPressed,
      ) {
    return Material(
      color: Colors.white.withOpacity(0.09),
      borderRadius: BorderRadius.circular(13),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }

  Widget _buildCountdown(
      String nextPrayer,
      Duration remaining,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A6553),
            Color(0xFF104438),
            Color(0xFF0B332B),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: mintGreen.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.17),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: mintGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: mintGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menuju sholat berikutnya',
                      style: TextStyle(
                        color: Color(0xFFC7DDD3),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFD7C69A),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'WAKTU TERSISA',
            style: TextStyle(
              color: Color(0xFFC0D8CD),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _format(remaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 43,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 15,
                  color: mintGreen,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Luangkan waktu untuk beribadah',
                    style: TextStyle(
                      color: Color(0xFFE1F1E9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(PrayerTime prayer) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF23463C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: mintGreen.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_done_rounded,
            color: mintGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Data tersimpan ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(prayer.fetchedAt)}',
                  style: const TextStyle(
                    color: Color(0xFFBBD0C6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule(
      PrayerTime prayer,
      String nextPrayer,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(11, 16, 11, 8),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: deepGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Jadwal Sholat',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(_now),
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _row('Subuh', prayer.fajr, Icons.nightlight_round,
              nextPrayer == 'Subuh'),
          _row('Terbit', prayer.sunrise, Icons.wb_twilight_rounded,
              false),
          _row('Dzuhur', prayer.dhuhr, Icons.wb_sunny_rounded,
              nextPrayer == 'Dzuhur'),
          _row('Ashar', prayer.asr, Icons.wb_cloudy_rounded,
              nextPrayer == 'Ashar'),
          _row('Maghrib', prayer.maghrib, Icons.wb_twilight_rounded,
              nextPrayer == 'Maghrib'),
          _row('Isya', prayer.isha, Icons.nights_stay_rounded,
              nextPrayer == 'Isya'),
        ],
      ),
    );
  }

  Widget _row(
      String name,
      String time,
      IconData icon,
      bool highlight,
      ) {
    final bool daytime = [
      'Terbit',
      'Dzuhur',
      'Ashar',
      'Maghrib',
    ].contains(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFD9F0E4)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? const Color(0xFFB4DDC8)
              : const Color(0xFFECEBE4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: highlight
                  ? deepGreen
                  : const Color(0xFFF2F0E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color: highlight
                  ? mintGreen
                  : daytime
                  ? const Color(0xFFE9A14A)
                  : deepGreen,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight:
                highlight ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFC0E6D2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'Berikutnya',
                style: TextStyle(
                  color: deepGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            time,
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight:
              highlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        children: [
          Icon(
            Icons.nightlight_round,
            color: mintGreen,
            size: 24,
          ),
          SizedBox(height: 9),
          Text(
            'Jadikan sholat sebagai prioritas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD5E4DC),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Semoga hari ini penuh berkah.',
            style: TextStyle(
              color: Color(0xFF8EA99D),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}