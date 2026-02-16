import 'dart:convert';

import 'package:app/features/quran/domain/quran_ayah.dart';
import 'package:flutter/services.dart';

class QuranRepository {
  Future<List<QuranAyah>> loadSampleAyahs() async {
    final raw = await rootBundle.loadString('assets/quran/quran_sample.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    return decoded
        .map(
          (item) => QuranAyah(
            surah: item['surah'] as int,
            ayah: item['ayah'] as int,
            text: item['text'] as String,
          ),
        )
        .toList(growable: false);
  }
}
