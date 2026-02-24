import 'dart:convert';

import 'package:app/features/quran/data/quran_local_store.dart';
import 'package:app/features/quran/domain/quran_ayah.dart';
import 'package:app/features/quran/domain/quran_models.dart';
import 'package:flutter/services.dart';

class QuranRepository {
  QuranRepository(this._localStore);

  final QuranLocalStore _localStore;

  List<QuranSurah>? _cached;

  Future<List<QuranSurah>> loadSurahs() async {
    if (_cached != null) return _cached!;

    final raw = await rootBundle.loadString('assets/quran/quran_full_en.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    _cached = decoded.map((item) {
      final map = (item as Map).cast<String, dynamic>();
      final surahId = (map['id'] as num).toInt();
      final verses = (map['verses'] as List<dynamic>)
          .map((v) {
            final verse = (v as Map).cast<String, dynamic>();
            return QuranVerse(
              surahId: surahId,
              verseId: (verse['id'] as num).toInt(),
              arabic: verse['text'] as String? ?? '',
              english: verse['translation'] as String? ?? '',
            );
          })
          .toList(growable: false);

      return QuranSurah(
        id: surahId,
        arabicName: map['name'] as String? ?? '',
        transliteration: map['transliteration'] as String? ?? '',
        translation: map['translation'] as String? ?? '',
        type: map['type'] as String? ?? '',
        totalVerses: (map['total_verses'] as num?)?.toInt() ?? verses.length,
        verses: verses,
      );
    }).toList(growable: false);

    return _cached!;
  }

  Future<List<QuranAyah>> loadSampleAyahs() async {
    final surahs = await loadSurahs();
    return surahs
        .take(3)
        .expand(
          (s) => s.verses.take(6).map(
                (v) => QuranAyah(
                  surah: s.id,
                  ayah: v.verseId,
                  text: v.arabic,
                ),
              ),
        )
        .toList(growable: false);
  }

  Future<List<QuranSearchResult>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final surahs = await loadSurahs();
    final results = <QuranSearchResult>[];

    for (final surah in surahs) {
      for (final verse in surah.verses) {
        final match = verse.arabic.toLowerCase().contains(q) ||
            verse.english.toLowerCase().contains(q) ||
            '${surah.id}:${verse.verseId}' == q;
        if (!match) continue;

        results.add(
          QuranSearchResult(
            surahId: surah.id,
            surahName: surah.transliteration,
            verseId: verse.verseId,
            arabic: verse.arabic,
            english: verse.english,
          ),
        );

        if (results.length >= 80) {
          return results;
        }
      }
    }

    return results;
  }

  Future<void> addRecentSurah(int surahId) async {
    final existing = _localStore.loadRecentSurahs().where((id) => id != surahId).toList(growable: true);
    existing.insert(0, surahId);
    await _localStore.saveRecentSurahs(existing);
  }

  List<int> loadRecentSurahs() => _localStore.loadRecentSurahs();

  List<QuranBookmark> loadBookmarks() => _localStore.loadBookmarks();

  Future<void> toggleBookmark({required int surahId, required int verseId}) async {
    final bookmarks = _localStore.loadBookmarks().toList(growable: true);
    final index = bookmarks.indexWhere((b) => b.surahId == surahId && b.verseId == verseId);
    if (index >= 0) {
      bookmarks.removeAt(index);
    } else {
      bookmarks.insert(
        0,
        QuranBookmark(surahId: surahId, verseId: verseId, createdAt: DateTime.now()),
      );
    }
    await _localStore.saveBookmarks(bookmarks);
  }

  List<QuranNote> loadNotes() => _localStore.loadNotes();

  Future<void> saveNote({required int surahId, required int verseId, required String text}) async {
    final notes = _localStore.loadNotes().toList(growable: true);
    notes.insert(
      0,
      QuranNote(
        surahId: surahId,
        verseId: verseId,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    await _localStore.saveNotes(notes);
  }
}
