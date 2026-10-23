import 'package:flutter/material.dart';

import '../services/app_settings.dart';

/// Halaman pengaturan; nilai disimpan dengan Shared Preferences.
class SettingsScreen extends StatelessWidget {
  final AppSettings settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Kota'),
            DropdownButton<String>(
              isExpanded: true,
              value: settings.city,
              items: AppSettings.cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) settings.setCity(v);
              },
            ),
            const SizedBox(height: 16),
            const Text('Metode perhitungan'),
            DropdownButton<int>(
              isExpanded: true,
              value: settings.method,
              items: AppSettings.methods.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) settings.setMethod(v);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode gelap'),
              value: settings.isDark,
              onChanged: settings.setDark,
            ),
          ],
        ),
      ),
    );
  }
}
