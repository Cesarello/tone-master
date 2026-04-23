import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/words_data.dart';
import '../models/tone_word.dart';
import '../services/feedback_sound_service.dart';
import '../services/tts_service.dart';

enum AnswerState { idle, correct, wrong }

class GameStateProvider extends ChangeNotifier {
  GameStateProvider({TtsService? ttsService, FeedbackSoundService? feedbackSoundService})
    : _ttsService = ttsService ?? TtsService(),
      _feedbackSoundService = feedbackSoundService {
    Future.microtask(_autoSpeakIfEnabled);
  }

  final TtsService _ttsService;
  FeedbackSoundService? _feedbackSoundService;
  FeedbackSoundService get feedbackSoundService => _feedbackSoundService ??= FeedbackSoundService();
  final List<ToneWord> _shuffledWords = List.from(wordsList)..shuffle(Random());
  int _currentIndex = 0;
  int _score = 0;
  int _totalAnswered = 0;
  AnswerState _answerState = AnswerState.idle;
  int? _selectedTone;
  bool _isFeedbackSoundEnabled = true;
  bool _isAutoSpeakEnabled = true;

  ToneWord get currentWord => _shuffledWords[_currentIndex % _shuffledWords.length];
  int get score => _score;
  int get totalAnswered => _totalAnswered;
  AnswerState get answerState => _answerState;
  int? get selectedTone => _selectedTone;
  bool get isFinished => _totalAnswered >= _shuffledWords.length;
  bool get isFeedbackSoundEnabled => _isFeedbackSoundEnabled;
  bool get isAutoSpeakEnabled => _isAutoSpeakEnabled;

  Future<void> speakCurrentWord() async {
    await _ttsService.speak(currentWord.character);
  }

  void toggleFeedbackSound() {
    _isFeedbackSoundEnabled = !_isFeedbackSoundEnabled;
    notifyListeners();
  }

  void toggleAutoSpeak() {
    _isAutoSpeakEnabled = !_isAutoSpeakEnabled;
    notifyListeners();

    if (_isAutoSpeakEnabled) {
      _autoSpeakIfEnabled();
    }
  }

  void selectTone(int tone) {
    if (_answerState != AnswerState.idle) return;

    _selectedTone = tone;
    final isCorrect = tone == currentWord.correctTone;

    if (isCorrect) {
      _score++;
      _answerState = AnswerState.correct;
      _playFeedbackSound(isCorrect: true);
    } else {
      _answerState = AnswerState.wrong;
      _playFeedbackSound(isCorrect: false);
    }

    _totalAnswered++;
    notifyListeners();
  }

  void _playFeedbackSound({required bool isCorrect}) {
    if (!_isFeedbackSoundEnabled) return;

    if (isCorrect) {
      feedbackSoundService.playCorrect();
    } else {
      feedbackSoundService.playWrong();
    }
  }

  void nextWord() {
    _ttsService.stop();
    _currentIndex++;
    _answerState = AnswerState.idle;
    _selectedTone = null;
    notifyListeners();
    _autoSpeakIfEnabled();
  }

  void restart() {
    _ttsService.stop();
    _shuffledWords.shuffle(Random());
    _currentIndex = 0;
    _score = 0;
    _totalAnswered = 0;
    _answerState = AnswerState.idle;
    _selectedTone = null;
    notifyListeners();
    _autoSpeakIfEnabled();
  }

  void _autoSpeakIfEnabled() {
    if (!_isAutoSpeakEnabled || isFinished || _answerState != AnswerState.idle) return;
    unawaited(speakCurrentWord());
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}
