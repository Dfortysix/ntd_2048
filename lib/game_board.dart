import 'package:flutter/material.dart';
import 'fruit_tile.dart';

class Tile {
  final int id;
  final int value;
  final int row;
  final int col;
  final bool justMerged;
  const Tile({required this.id, required this.value, required this.row, required this.col, this.justMerged = false});
}

class GameBoard extends StatelessWidget {
  final List<Tile> tiles;
  final Color Function(int) getTileColor;
  final int gridSize;
  const GameBoard({super.key, required this.tiles, required this.getTileColor, this.gridSize = 4});

  @override
  Widget build(BuildContext context) {
    const double tileSize = 320 / 4 - 6; // 320 là kích thước board, 6 là spacing
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Nền lưới
          for (int r = 0; r < gridSize; r++)
            for (int c = 0; c < gridSize; c++)
              Positioned(
                left: c * (tileSize + 6) + 8,
                top: r * (tileSize + 6) + 8,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: getTileColor(0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          // Các tile động
          for (final tile in tiles.where((t) => t.value > 0))
            AnimatedPositioned(
              key: ValueKey(tile.id),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              left: tile.col * (tileSize + 6) + 8,
              top: tile.row * (tileSize + 6) + 8,
              child: AnimatedScale(
                scale: tile.justMerged ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: getTileColor(tile.value),
                    borderRadius: BorderRadius.circular(4),
                    border: tile.value >= 1024
                        ? Border.all(color: Colors.amberAccent, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      FruitTile.getDisplayText(tile.value),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 