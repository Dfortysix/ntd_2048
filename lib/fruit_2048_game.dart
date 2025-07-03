import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TileComponent extends PositionComponent {
  int value;
  TextComponent? text;
  Paint paint;
  Vector2 targetPosition;

  TileComponent({
    required this.value,
    required Vector2 position,
    required this.targetPosition,
    required this.paint,
  }) : super(position: position, size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    text = TextComponent(
      text: _getEmoji(value),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(text!);
  }

  @override
  void update(double dt) {
    // Animate position to targetPosition
    position += (targetPosition - position) * min(dt * 12, 1.0);
    super.update(dt);
  }

  void updateValue(int newValue) {
    value = newValue;
    text?.text = _getEmoji(value);
  }

  static String _getEmoji(int value) {
    switch (value) {
      case 2: return '🍒';
      case 4: return '🍓';
      case 8: return '🍇';
      case 16: return '🍊';
      case 32: return '🍎';
      case 64: return '🍐';
      case 128: return '🍑';
      case 256: return '🥭';
      case 512: return '🍍';
      case 1024: return '🍉';
      case 2048: return '🍈';
      default: return value.toString();
    }
  }
}

class Fruit2048Game extends FlameGame with PanDetector {
  static const int gridSize = 4;
  late List<List<TileComponent?>> board;
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> bestScore = ValueNotifier<int>(0);

  @override
  Color backgroundColor() => const Color(0xFFB2FF59);

  @override
  Future<void> onLoad() async {
    // Vẽ nền board
    add(
      RectangleComponent(
        position: Vector2(10, 10),
        size: Vector2(300, 300),
        paint: Paint()..color = const Color(0xFF4CAF50),
      ),
    );
    // Vẽ lưới 4x4 bằng các RectangleComponent mỏng
    final double cellSize = 75; // 300 / 4
    final gridStart = Vector2(10, 10);
    final gridPaint = Paint()
      ..color = const Color(0xFFB2FF59);
    // Vẽ các đường dọc
    for (int i = 1; i < gridSize; i++) {
      add(RectangleComponent(
        position: gridStart + Vector2(i * cellSize - 1, 0),
        size: Vector2(2, 300),
        paint: gridPaint,
      ));
    }
    // Vẽ các đường ngang
    for (int i = 1; i < gridSize; i++) {
      add(RectangleComponent(
        position: gridStart + Vector2(0, i * cellSize - 1),
        size: Vector2(300, 2),
        paint: gridPaint,
      ));
    }
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    // Khởi tạo 2 tile đầu tiên
    spawnTile(0, 0, 2);
    spawnTile(1, 1, 2);
  }

  void spawnTile(int row, int col, int value) {
    final pos = Vector2(col * 70 + 20, row * 70 + 20);
    final tile = TileComponent(
      value: value,
      position: pos.clone(),
      targetPosition: pos,
      paint: Paint()..color = Colors.orange,
    );
    add(tile);
    board[row][col] = tile;
  }

  // Xử lý swipe
  @override
  void onPanEnd(DragEndInfo info) {
    final velocity = info.velocity;
    if (velocity.x.abs() > velocity.y.abs()) {
      if (velocity.x > 0) {
        moveRight();
      } else {
        moveLeft();
      }
    } else {
      if (velocity.y > 0) {
        moveDown();
      } else {
        moveUp();
      }
    }
  }

  // Demo: chỉ di chuyển 1 tile, bạn cần thay bằng logic di chuyển/merge thật sự
  void moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      int target = 0;
      int? lastValue;
      TileComponent? lastTile;
      for (int j = 0; j < gridSize; j++) {
        final tile = board[i][j];
        if (tile == null) continue;
        if (lastValue != null && tile.value == lastValue) {
          // Merge
          lastTile!.updateValue(lastTile.value * 2);
          lastTile.targetPosition = Vector2(target * 70 + 20, i * 70 + 20);
          remove(tile);
          board[i][j] = null;
          board[i][target - 1] = lastTile;
          score.value += lastTile.value;
          lastValue = null;
          moved = true;
        } else {
          if (j != target) moved = true;
          tile.targetPosition = Vector2(target * 70 + 20, i * 70 + 20);
          board[i][j] = null;
          board[i][target] = tile;
          lastValue = tile.value;
          lastTile = tile;
          target++;
        }
      }
    }
    if (moved) {
      spawnRandomTile();
      if (!canMove()) {
        // Game over
        overlays.add('GameOver');
      }
    }
  }

  void moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      int target = gridSize - 1;
      int? lastValue;
      TileComponent? lastTile;
      for (int j = gridSize - 1; j >= 0; j--) {
        final tile = board[i][j];
        if (tile == null) continue;
        if (lastValue != null && tile.value == lastValue) {
          lastTile!.updateValue(lastTile.value * 2);
          lastTile.targetPosition = Vector2(target * 70 + 20, i * 70 + 20);
          remove(tile);
          board[i][j] = null;
          board[i][target + 1] = lastTile;
          score.value += lastTile.value;
          lastValue = null;
          moved = true;
        } else {
          if (j != target) moved = true;
          tile.targetPosition = Vector2(target * 70 + 20, i * 70 + 20);
          board[i][j] = null;
          board[i][target] = tile;
          lastValue = tile.value;
          lastTile = tile;
          target--;
        }
      }
    }
    if (moved) {
      spawnRandomTile();
      if (!canMove()) {
        overlays.add('GameOver');
      }
    }
  }

  void moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      int target = 0;
      int? lastValue;
      TileComponent? lastTile;
      for (int i = 0; i < gridSize; i++) {
        final tile = board[i][j];
        if (tile == null) continue;
        if (lastValue != null && tile.value == lastValue) {
          lastTile!.updateValue(lastTile.value * 2);
          lastTile.targetPosition = Vector2(j * 70 + 20, target * 70 + 20);
          remove(tile);
          board[i][j] = null;
          board[target - 1][j] = lastTile;
          score.value += lastTile.value;
          lastValue = null;
          moved = true;
        } else {
          if (i != target) moved = true;
          tile.targetPosition = Vector2(j * 70 + 20, target * 70 + 20);
          board[i][j] = null;
          board[target][j] = tile;
          lastValue = tile.value;
          lastTile = tile;
          target++;
        }
      }
    }
    if (moved) {
      spawnRandomTile();
      if (!canMove()) {
        overlays.add('GameOver');
      }
    }
  }

  void moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      int target = gridSize - 1;
      int? lastValue;
      TileComponent? lastTile;
      for (int i = gridSize - 1; i >= 0; i--) {
        final tile = board[i][j];
        if (tile == null) continue;
        if (lastValue != null && tile.value == lastValue) {
          lastTile!.updateValue(lastTile.value * 2);
          lastTile.targetPosition = Vector2(j * 70 + 20, target * 70 + 20);
          remove(tile);
          board[i][j] = null;
          board[target + 1][j] = lastTile;
          score.value += lastTile.value;
          lastValue = null;
          moved = true;
        } else {
          if (i != target) moved = true;
          tile.targetPosition = Vector2(j * 70 + 20, target * 70 + 20);
          board[i][j] = null;
          board[target][j] = tile;
          lastValue = tile.value;
          lastTile = tile;
          target--;
        }
      }
    }
    if (moved) {
      spawnRandomTile();
      if (!canMove()) {
        overlays.add('GameOver');
      }
    }
  }

  void spawnRandomTile() {
    final empty = <List<int>>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == null) empty.add([i, j]);
      }
    }
    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      spawnTile(pos[0], pos[1], Random().nextDouble() < 0.9 ? 2 : 4);
    }
  }

  bool canMove() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == null) return true;
        if (i < gridSize - 1 && board[i][j]?.value == board[i + 1][j]?.value) return true;
        if (j < gridSize - 1 && board[i][j]?.value == board[i][j + 1]?.value) return true;
      }
    }
    return false;
  }

  void reset() {
    // Xoá toàn bộ tile hiện tại
    for (final row in board) {
      for (final tile in row) {
        if (tile != null) remove(tile);
      }
    }
    board = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score.value = 0;
    // Khởi tạo 2 tile đầu tiên
    spawnTile(0, 0, 2);
    spawnTile(1, 1, 2);
  }
} 