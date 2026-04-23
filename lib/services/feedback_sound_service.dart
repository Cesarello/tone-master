import 'package:audioplayers/audioplayers.dart';

class FeedbackSoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playCorrect() async {
    await _player.play(AssetSource('success.mp3'));
  }

  Future<void> playWrong() async {
    await _player.play(AssetSource('error.mp3'));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
