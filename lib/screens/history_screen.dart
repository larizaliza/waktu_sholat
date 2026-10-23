import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/prayer_time.dart';

/// Menampilkan jadwal yang tersimpan di SQLite, dapat dihapus pengguna.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = DatabaseHelper.instance;
  late Future<List<PrayerTime>> _future;

  @override
  void initState() {
    super.initState();
    _future = _db.getAll();
  }

  void _reload() => setState(() => _future = _db.getAll());

  Future<void> _deleteOne(PrayerTime p) async {
    await _db.delete(p.id!);
    _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jadwal ${p.city} (${p.date}) dihapus')),
    );
  }

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua?'),
        content: const Text('Seluruh jadwal tersimpan akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      await _db.deleteAll();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Tersimpan'),
        actions: [
          IconButton(
            tooltip: 'Hapus semua',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _deleteAll,
          ),
        ],
      ),
      body: FutureBuilder<List<PrayerTime>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada jadwal tersimpan'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final p = items[i];
              return Dismissible(
                key: ValueKey(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteOne(p),
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text('${p.city} • ${p.date}'),
                  subtitle: Text(
                    'Subuh ${p.fajr} | Dzuhur ${p.dhuhr} | Ashar ${p.asr}\n'
                    'Maghrib ${p.maghrib} | Isya ${p.isha}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteOne(p),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
