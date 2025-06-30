import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  final List<List<int>> board;
  final Color Function(int) getTileColor;

  const GameBoard({super.key, required this.board, required this.getTileColor});

  @override
  Widget build(BuildContext context) {
    const int gridSize = 4;
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IgnorePointer(
        child: GridView.builder(
          itemCount: gridSize * gridSize,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            int row = index ~/ gridSize;
            int col = index % gridSize;
            int val = board[row][col];
            return Container(
              decoration: BoxDecoration(
                color: getTileColor(val),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: val == 0
                    ? const SizedBox.shrink()
                    : Text(
                        '$val',
                        style: TextStyle(
                          color: val <= 4
                              ? const Color(0xFF776E65)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: val >= 1000 ? 22 : 26,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
} 