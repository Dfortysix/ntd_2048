import 'package:flame/game.dart';
import 'fruit_2048_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: Fruit2048Game(),
      overlayBuilderMap: {
        'MainUI': (context, game) => MyGameOverlay(game: game as Fruit2048Game),
      },
      initialActiveOverlays: const ['MainUI'],
    ),
  );
}

class MyGameOverlay extends StatelessWidget {
  final Fruit2048Game game;
  const MyGameOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App bar custom
        Container(
          color: const Color(0xFF4CAF50),
          padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.apple, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Fruits 2048', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => game.reset(), icon: const Icon(Icons.refresh, color: Colors.white)),
            ],
          ),
        ),
        // Box điểm, điểm cao nhất
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (context, value, _) => _scoreBox('Điểm', value),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder<int>(
                valueListenable: game.bestScore,
                builder: (context, value, _) => _scoreBox('Cao nhất', value),
              ),
            ],
          ),
        ),
        // Spacer để board Flame nằm phía dưới overlay này
        const Spacer(),
        // Hướng dẫn, text, v.v.
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('Vuốt để gộp các trái cây giống nhau 🍎', style: TextStyle(color: Color(0xFF2E7D32))),
        ),
      ],
    );
  }

  Widget _scoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
