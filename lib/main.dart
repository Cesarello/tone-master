import 'package:chinese_tones/data/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/supabase_utils.dart';
import 'providers/game_state_provider.dart';
import 'providers/words_provider.dart';
import 'repositories/word_repository.dart';
import 'screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseUtils.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WordsProvider>(create: (_) => WordsProvider(repository: SupabaseWordRepository())),
        ChangeNotifierProxyProvider<WordsProvider, GameStateProvider>(
          create: (_) => GameStateProvider(),
          update: (_, wordsProvider, gameState) {
            if (wordsProvider.state == WordsLoadState.loaded) {
              gameState?.updateWords(wordsProvider.words);
            }
            return gameState ?? GameStateProvider(words: wordsProvider.words);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Chinese Tone Master',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const GameScreen(),
      ),
    );
  }
}
