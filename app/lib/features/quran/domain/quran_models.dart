class QuranVerse {
  const QuranVerse({
    required this.surahId,
    required this.verseId,
    required this.arabic,
    required this.english,
  });

  final int surahId;
  final int verseId;
  final String arabic;
  final String english;
}

class QuranSurah {
  const QuranSurah({
    required this.id,
    required this.arabicName,
    required this.transliteration,
    required this.translation,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  final int id;
  final String arabicName;
  final String transliteration;
  final String translation;
  final String type;
  final int totalVerses;
  final List<QuranVerse> verses;
}

class QuranBookmark {
  const QuranBookmark({
    required this.surahId,
    required this.verseId,
    required this.createdAt,
  });

  final int surahId;
  final int verseId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'verseId': verseId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuranBookmark.fromJson(Map<String, dynamic> json) => QuranBookmark(
        surahId: (json['surahId'] as num).toInt(),
        verseId: (json['verseId'] as num).toInt(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class QuranNote {
  const QuranNote({
    required this.surahId,
    required this.verseId,
    required this.text,
    required this.createdAt,
  });

  final int surahId;
  final int verseId;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'verseId': verseId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuranNote.fromJson(Map<String, dynamic> json) => QuranNote(
        surahId: (json['surahId'] as num).toInt(),
        verseId: (json['verseId'] as num).toInt(),
        text: json['text'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class QuranSearchResult {
  const QuranSearchResult({
    required this.surahId,
    required this.surahName,
    required this.verseId,
    required this.arabic,
    required this.english,
  });

  final int surahId;
  final String surahName;
  final int verseId;
  final String arabic;
  final String english;
}
