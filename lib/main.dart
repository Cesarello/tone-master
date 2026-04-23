import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_state_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const _primaryColor = Color(0xFFAF0000);

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: brightness,
    ).copyWith(primary: _primaryColor, onPrimary: Colors.white);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: MaterialApp(
        title: 'Chinese Tone Master',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const GameScreen(),
      ),
    );
  }
}
