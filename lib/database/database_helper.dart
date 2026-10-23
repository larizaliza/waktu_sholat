import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/prayer_time.dart';

/// Pengelola database SQLite untuk cache jadwal sholat.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _table = 'prayer_times';
  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'waktu_sholat.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city TEXT NOT NULL,
            date TEXT NOT NULL,
            fajr TEXT NOT NULL,
            sunrise TEXT NOT NULL,
            dhuhr TEXT NOT NULL,
            asr TEXT NOT NULL,
            maghrib TEXT NOT NULL,
            isha TEXT NOT NULL,
            fetched_at TEXT NOT NULL,
            UNIQUE(city, date)
          )
        ''');
      },
    );
  }

  /// CREATE / UPDATE: simpan jadwal, timpa jika kota dan tanggal sama.
  Future<void> upsert(PrayerTime p) async {
    final db = await database;
    final map = p.toMap()..remove('id');
    await db.insert(_table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// READ: ambil jadwal berdasarkan kota dan tanggal.
  Future<PrayerTime?> getByCityDate(String city, String date) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'city = ? AND date = ?',
      whereArgs: [city, date],
      limit: 1,
    );
    return rows.isEmpty ? null : PrayerTime.fromMap(rows.first);
  }

  /// READ: ambil seluruh jadwal tersimpan (terbaru lebih dulu).
  Future<List<PrayerTime>> getAll() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'date DESC, city ASC');
    return rows.map(PrayerTime.fromMap).toList();
  }

  /// DELETE: hapus satu jadwal.
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// DELETE: hapus semua jadwal tersimpan.
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_table);
  }
}
