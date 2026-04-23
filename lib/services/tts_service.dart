import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _configure();
  }

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _configure() async {
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
