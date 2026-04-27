class ToneWord {
  final String pinyin;
  final String pinyinWithTone;
  final String character;
  final int correctTone;
  final String translation;

  const ToneWord({
    required this.pinyin,
    required this.pinyinWithTone,
    required this.character,
    required this.correctTone,
    required this.translation,
  });

  factory ToneWord.fromJson(Map<String, dynamic> json) {
    return ToneWord(
      pinyin: json['pinyin'] as String,
      pinyinWithTone: json['pinyin_with_tone'] as String,
      character: json['character'] as String,
      correctTone: json['correct_tone'] as int,
      translation: json['translation'] as String,
    );
  }
}
