import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/words_data.dart';
import '../models/tone_word.dart';
import '../services/local_words_db.dart';

abstract class WordRepository {
  Future<List<ToneWord>> fetchWords({bool forceRefresh = false});
}

class SupabaseWordRepository implements WordRepository {
  SupabaseWordRepository({LocalWordsDb? localWordsDb}) : _localWordsDb = localWordsDb ?? LocalWordsDb();

  final LocalWordsDb _localWordsDb;

  @override
  Future<List<ToneWord>> fetchWords({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedWords = await _localWordsDb.getWords();
      if (cachedWords.isNotEmpty) return cachedWords;
    }

    try {
      final data = await Supabase.instance.client.from('words').select();
      final fetchedWords = (data as List<dynamic>)
          .map((e) => ToneWord.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);

      if (fetchedWords.isNotEmpty) {
        await _localWordsDb.replaceWords(fetchedWords);
      }

      return fetchedWords;
    } catch (_) {
      final cachedWords = await _localWordsDb.getWords();
      if (cachedWords.isNotEmpty) return cachedWords;
      rethrow;
    }
  }
}

class LocalWordRepository implements WordRepository {
  const LocalWordRepository();

  @override
  Future<List<ToneWord>> fetchWords({bool forceRefresh = false}) async => wordsList;
}
