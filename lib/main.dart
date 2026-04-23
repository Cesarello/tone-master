import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_state_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: MaterialApp(
        title: 'Chinese Tone Master',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F)), useMaterial3: true),
        home: const GameScreen(),
      ),
    );
  }
}
