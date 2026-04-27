import 'package:flutter/foundation.dart';

import '../models/tone_word.dart';
import '../repositories/word_repository.dart';

enum WordsLoadState { idle, loading, loaded, error }

class WordsProvider extends ChangeNotifier {
  WordsProvider({required WordRepository repository}) : _repository = repository {
    _loadWords();
  }

  final WordRepository _repository;
  List<ToneWord> _words = const [];
  WordsLoadState _state = WordsLoadState.idle;
  String? _error;

  List<ToneWord> get words => _words;
  WordsLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == WordsLoadState.loading;
  bool get hasError => _state == WordsLoadState.error;

  Future<void> _loadWords({bool forceRefresh = false}) async {
    _state = WordsLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _words = await _repository.fetchWords(forceRefresh: forceRefresh);
      _state = WordsLoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = WordsLoadState.error;
    }

    notifyListeners();
  }

  Future<void> refresh() => _loadWords(forceRefresh: true);
}
