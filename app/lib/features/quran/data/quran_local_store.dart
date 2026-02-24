import 'dart:convert';

import 'package:app/core/storage/app_preferences.dart';
import 'package:app/features/quran/domain/quran_models.dart';

class QuranLocalStore {
  QuranLocalStore(this._preferences);

  final AppPreferences _preferences;

  static const _bookmarksKey = 'quran.bookmarks';
  static const _notesKey = 'quran.notes';
  static const _recentKey = 'quran.recent_surahs';

  List<QuranBookmark> loadBookmarks() {
    final raw = _preferences.getString(_bookmarksKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => QuranBookmark.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveBookmarks(List<QuranBookmark> bookmarks) {
    final raw = jsonEncode(bookmarks.map((e) => e.toJson()).toList(growable: false));
    return _preferences.setString(_bookmarksKey, raw);
  }

  List<QuranNote> loadNotes() {
    final raw = _preferences.getString(_notesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => QuranNote.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveNotes(List<QuranNote> notes) {
    final raw = jsonEncode(notes.map((e) => e.toJson()).toList(growable: false));
    return _preferences.setString(_notesKey, raw);
  }

  List<int> loadRecentSurahs() {
    final raw = _preferences.getString(_recentKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<num>().map((e) => e.toInt()).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveRecentSurahs(List<int> surahIds) {
    final trimmed = surahIds.take(15).toList(growable: false);
    return _preferences.setString(_recentKey, jsonEncode(trimmed));
  }
}
