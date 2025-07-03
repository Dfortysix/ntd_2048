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
            _AnimatedTile(
              key: ValueKey(tile.id),
              tile: tile,
              tileSize: tileSize,
              getTileColor: getTileColor,
            ),
        ],
      ),
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  final Tile tile;
  final double tileSize;
  final Color Function(int) getTileColor;
  const _AnimatedTile({Key? key, required this.tile, required this.tileSize, required this.getTileColor}) : super(key: key);

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      left: widget.tile.col * (widget.tileSize + 6) + 8,
      top: widget.tile.row * (widget.tileSize + 6) + 8,
      child: RepaintBoundary(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: widget.tile.justMerged
              ? TweenAnimationBuilder<double>(
                  key: ValueKey('merge_${widget.tile.id}_${widget.tile.value}'),
                  tween: Tween<double>(begin: 1.25, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: _tileContent(),
                )
              : Container(
                  key: ValueKey('tile_${widget.tile.id}_${widget.tile.value}'),
                  child: _tileContent(),
                ),
        ),
      ),
    );
  }

  Widget _tileContent() {
    return Container(
      width: widget.tileSize,
      height: widget.tileSize,
      decoration: BoxDecoration(
        color: widget.getTileColor(widget.tile.value),
        borderRadius: BorderRadius.circular(4),
        border: widget.tile.value >= 1024
            ? Border.all(color: Colors.amberAccent, width: 3)
            : null,
      ),
      child: Center(
        child: Text(
          FruitTile.getDisplayText(widget.tile.value),
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
    );
  }
} 