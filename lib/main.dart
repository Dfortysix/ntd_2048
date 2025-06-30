import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF776E65),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const Game2048Screen(),
    );
  }
}
