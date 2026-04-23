import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_state_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const _correctColor = Color(0xFF2E7D32);
  static const _correctContainerColor = Color(0xFFE8F5E9);
  static const _wrongColor = Color(0xFFC62828);
  static const _wrongContainerColor = Color(0xFFFFEBEE);

  static const _toneLabels = ['ˉ', 'ˊ', 'ˇ', 'ˋ'];
  static const _toneSubtitles = ['1° tono', '2° tono', '3° tono', '4° tono'];
  static const _toneColors = [
    Color(0xFF1565C0), // blu - 1° tono
    Color(0xFF2E7D32), // verde - 2° tono
    Color(0xFF6A1B9A), // viola - 3° tono
    Color(0xFFC62828), // rosso - 4° tono
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameStateProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isFinished) {
      return _buildResultScreen(context, provider);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tone Master'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<GameStateProvider>().toggleAutoSpeak(),
            tooltip: provider.isAutoSpeakEnabled
                ? 'Disattiva riproduzione automatica'
                : 'Attiva riproduzione automatica',
            icon: Icon(provider.isAutoSpeakEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded),
          ),
          IconButton(
            onPressed: () => context.read<GameStateProvider>().toggleFeedbackSound(),
            tooltip: provider.isFeedbackSoundEnabled ? 'Disattiva suoni feedback' : 'Attiva suoni feedback',
            icon: Icon(
              provider.isFeedbackSoundEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressBar(context, provider),
            const SizedBox(height: 32),
            _buildWordCard(context, provider),
            const SizedBox(height: 40),
            _buildToneButtons(context, provider),
            const Spacer(),
            if (provider.answerState != AnswerState.idle) _buildNextButton(context, provider),
          ],
        ),
      ),
    );
  }

  void _confirmRestart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nuova sessione?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Verranno selezionati 20 nuovi caratteri casuali e il punteggio verrà azzerato.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Annulla'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.read<GameStateProvider>().restart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ricomincia'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, GameStateProvider provider) {
    final total = provider.totalQuestions;
    final answered = provider.totalAnswered;
    final progress = total == 0 ? 0.0 : answered / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Punteggio: ${provider.score} / $answered',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: () => _confirmRestart(context),
              tooltip: 'Nuova sessione',
              icon: const Icon(Icons.refresh_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${answered + 1} / $total',
          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.75)),
        ),
      ],
    );
  }

  Widget _buildWordCard(BuildContext context, GameStateProvider provider) {
    final word = provider.currentWord;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color? cardColor;
    if (provider.answerState == AnswerState.correct) {
      cardColor = theme.brightness == Brightness.dark ? _correctColor.withValues(alpha: 0.22) : _correctContainerColor;
    } else if (provider.answerState == AnswerState.wrong) {
      cardColor = theme.brightness == Brightness.dark ? _wrongColor.withValues(alpha: 0.22) : _wrongContainerColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton.filledTonal(
              onPressed: provider.speakCurrentWord,
              tooltip: 'Pronuncia la parola',
              icon: const Icon(Icons.volume_up_rounded),
            ),
          ),
          Text(word.character, style: const TextStyle(fontSize: 80, height: 1.0)),
          const SizedBox(height: 4),
          Text(
            word.translation,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          if (provider.answerState == AnswerState.idle)
            Text(
              word.pinyin,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                color: colorScheme.onSurface,
              ),
            )
          else
            _PinyinWithHighlight(
              context: context,
              pinyinWithTone: word.pinyinWithTone,
              highlightColor: provider.answerState == AnswerState.correct ? _correctColor : _wrongColor,
            ),
          const SizedBox(height: 16),
          Visibility(
            visible: provider.answerState == AnswerState.wrong,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(
              'Risposta corretta: ${provider.currentWord.correctTone}° tono',
              style: const TextStyle(color: _wrongColor, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneButtons(BuildContext context, GameStateProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        final tone = index + 1;
        return _ToneButton(
          tone: tone,
          label: _toneLabels[index],
          subtitle: _toneSubtitles[index],
          color: _toneColors[index],
          answerState: provider.answerState,
          selectedTone: provider.selectedTone,
          correctTone: provider.currentWord.correctTone,
          onTap: provider.answerState == AnswerState.idle
              ? () => context.read<GameStateProvider>().selectTone(tone)
              : null,
        );
      }),
    );
  }

  Widget _buildNextButton(BuildContext context, GameStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: () => context.read<GameStateProvider>().nextWord(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Prossima parola →', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, GameStateProvider provider) {
    final percentage = (provider.score / provider.totalAnswered * 100).round();
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Completato!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${provider.score} / ${provider.totalAnswered} corrette ($percentage%)',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                percentage >= 80
                    ? '优秀! Eccellente!'
                    : percentage >= 60
                    ? '不错! Buono!'
                    : '加油! Continua così!',
                style: TextStyle(fontSize: 18, color: Colors.grey[700], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.read<GameStateProvider>().restart(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ricomincia', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinyinWithHighlight extends StatelessWidget {
  final BuildContext context;
  final String pinyinWithTone;
  final Color highlightColor;

  const _PinyinWithHighlight({required this.context, required this.pinyinWithTone, required this.highlightColor});

  static const _toneVowels = 'āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ';

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      letterSpacing: 2,
      color: Theme.of(this.context).colorScheme.onSurface,
    );
    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    for (final char in pinyinWithTone.characters) {
      if (_toneVowels.contains(char)) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString()));
          buffer.clear();
        }
        spans.add(
          TextSpan(
            text: char,
            style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        buffer.write(char);
      }
    }
    if (buffer.isNotEmpty) spans.add(TextSpan(text: buffer.toString()));

    return RichText(
      text: TextSpan(style: base, children: spans),
    );
  }
}

class _ToneButton extends StatelessWidget {
  final int tone;
  final String label;
  final String subtitle;
  final Color color;
  final AnswerState answerState;
  final int? selectedTone;
  final int correctTone;
  final VoidCallback? onTap;

  const _ToneButton({
    required this.tone,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.answerState,
    required this.selectedTone,
    required this.correctTone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color buttonColor = color;
    Color textColor = Colors.white;

    if (answerState != AnswerState.idle) {
      if (tone == correctTone) {
        buttonColor = isDark ? GameScreen._correctColor.withValues(alpha: 0.85) : GameScreen._correctColor;
      } else if (tone == selectedTone) {
        buttonColor = isDark ? GameScreen._wrongColor.withValues(alpha: 0.88) : GameScreen._wrongColor;
      } else {
        buttonColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  label,
                  style: TextStyle(color: textColor, fontSize: 60, fontWeight: FontWeight.w700, height: 1.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
