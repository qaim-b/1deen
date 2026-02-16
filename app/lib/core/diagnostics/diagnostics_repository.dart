import 'dart:convert';

import 'package:app/core/diagnostics/diagnostic_event.dart';
import 'package:app/core/storage/app_preferences.dart';

class DiagnosticsRepository {
  DiagnosticsRepository(this._preferences);

  static const _eventsKey = 'diagnostics.events';
  static const _maxEvents = 120;

  final AppPreferences _preferences;

  List<DiagnosticEvent> loadEvents() {
    final raw = _preferences.getString(_eventsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map(DiagnosticEvent.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> append(DiagnosticEvent event) async {
    final current = loadEvents().toList(growable: true);
    current.insert(0, event);
    if (current.length > _maxEvents) {
      current.removeRange(_maxEvents, current.length);
    }

    final payload = jsonEncode(current.map((e) => e.toJson()).toList(growable: false));
    await _preferences.setString(_eventsKey, payload);
  }

  Future<void> clear() async {
    await _preferences.setString(_eventsKey, '[]');
  }
}
