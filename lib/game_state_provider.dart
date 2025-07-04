import 'package:flutter/material.dart';
import 'dart:math';
import 'game_board.dart';
import 'game_state.dart';
import 'ad_manager.dart';

class GameStateProvider extends ChangeNotifier {
  static const int gridSize = 4;
  List<List<int>> board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int score = 0;
  int bestScore = 0;
  bool gameOver = false;
  bool gameWon = false;
  bool isMoving = false;
  Set<int> justMergedSet = {};
  int nextTileId = 0;
  Map<int, int> tileIds = {}; // key: i*gridSize+j, value: id

  // Lịch sử các bước đi để undo
  List<GameState> gameHistory = [];
  static const int maxHistorySize = 10;

  // Quản lý lượt trợ giúp
  int freeUndoCount = 1;
  int paidUndoCount = 0;
  bool hasUsedFreeUndo = false;

  // Hiệu ứng pháo hoa
  bool _showFireworks = false;

  GameStateProvider() {
    // Tự động khởi tạo 2 ô khởi điểm khi Provider được tạo
    print('🎮 GameStateProvider constructor called'); // Debug log
    addNewTile();
    addNewTile();
    print('🎮 Initial tiles added: ${tiles.length}'); // Debug log
    notifyListeners(); // Đảm bảo UI được cập nhật
  }

  set showFireworks(bool value) {
    _showFireworks = value;
    notifyListeners();
  }
  
  bool get showFireworks => _showFireworks;

  List<Tile> get tiles => _buildTilesFromBoard(board, justMergedSet: justMergedSet);

  List<Tile> _buildTilesFromBoard(List<List<int>> board, {Set<int>? justMergedSet}) {
    final tiles = <Tile>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        int key = i * gridSize + j;
        if (board[i][j] != 0 && tileIds.containsKey(key)) {
          tiles.add(Tile(
            id: tileIds[key]!,
            value: board[i][j],
            row: i,
            col: j,
            justMerged: justMergedSet?.contains(key) ?? false,
          ));
        }
      }
    }
    print('🎮 Built ${tiles.length} tiles from board'); // Debug log
    return tiles;
  }

  void resetGame() {
    print('🔄 Reset game called'); // Debug log
    board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    gameOver = false;
    gameWon = false;
    justMergedSet.clear();
    tileIds.clear();
    nextTileId = 0;
    addNewTile();
    addNewTile();
    gameHistory.clear();
    freeUndoCount = 1;
    paidUndoCount = 0;
    hasUsedFreeUndo = false;
    showFireworks = false;
    notifyListeners();
    
    // Hiển thị quảng cáo khi reset game
    if (AdManager.shouldShowAd()) {
      AdManager.showInterstitialAd();
    }
    print('✅ Reset game completed'); // Debug log
  }

  void addNewTile() {
    final empty = <List<int>>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) empty.add([i, j]);
      }
    }
    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      board[pos[0]][pos[1]] = Random().nextDouble() < 0.9 ? 2 : 4;
      tileIds[pos[0] * gridSize + pos[1]] = nextTileId++;
      print('🎮 Added tile at [${pos[0]}, ${pos[1]}] with value ${board[pos[0]][pos[1]]}'); // Debug log
    }
  }

  void saveCurrentState() {
    // Chỉ lưu nếu có lịch sử hoặc đây là lần đầu
    if (gameHistory.isEmpty || gameHistory.last.score != score) {
      // Lưu trạng thái trước khi merge (justMergedSet rỗng)
      final currentState = GameState.fromCurrent(
        board: board,
        score: score,
        gameOver: gameOver,
        gameWon: gameWon,
        justMergedSet: <int>{}, // Luôn rỗng khi lưu
        tileIds: tileIds,
        nextTileId: nextTileId,
      );
      gameHistory.add(currentState);
      if (gameHistory.length > maxHistorySize) {
        gameHistory.removeAt(0);
      }
      print('💾 Saved game state, history size: ${gameHistory.length}'); // Debug log
    }
  }

  void performUndo() {
    print('🔄 performUndo called - freeUndoCount: $freeUndoCount, paidUndoCount: $paidUndoCount, gameHistory: ${gameHistory.length}'); // Debug log
    if (gameHistory.isNotEmpty) {
      // Kiểm tra và sử dụng lượt undo
      if (freeUndoCount > 0) {
        freeUndoCount--;
        hasUsedFreeUndo = true;
        print('🔄 Used free undo, remaining: $freeUndoCount'); // Debug log
      } else if (paidUndoCount > 0) {
        paidUndoCount--;
        print('🔄 Used paid undo, remaining: $paidUndoCount'); // Debug log
      } else {
        // Không có lượt undo nào
        print('🔄 No undo counts available'); // Debug log
        return;
      }
      
      final previousState = gameHistory.removeLast();
      board = previousState.boardCopy;
      score = previousState.score;
      gameOver = previousState.gameOver;
      gameWon = previousState.gameWon;
      justMergedSet.clear(); // Luôn clear khi undo
      tileIds = Map<int, int>.from(previousState.tileIds);
      nextTileId = previousState.nextTileId;
      showFireworks = false;
      notifyListeners();
      print('🔄 Undo completed successfully'); // Debug log
    } else {
      print('🔄 No game history available'); // Debug log
    }
  }

  void addPaidUndo() {
    paidUndoCount++;
    notifyListeners();
  }

  // Di chuyển sang trái
  bool moveLeft() {
    // Lưu trạng thái trước khi move
    saveCurrentState();
    
    bool moved = false;
    justMergedSet.clear();
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => tileIds[i * gridSize + j]));
    for (int i = 0; i < gridSize; i++) {
      List<int> row = board[i];
      List<int?> rowIds = oldIds[i];
      List<int> nonZero = [];
      List<int?> nonZeroIds = [];
      for (int j = 0; j < gridSize; j++) {
        if (row[j] != 0) {
          nonZero.add(row[j]);
          nonZeroIds.add(rowIds[j]);
        }
      }
      List<int> newRow = [];
      List<int?> newRowIds = [];
      int col = 0;
      while (col < nonZero.length) {
        if (col + 1 < nonZero.length && nonZero[col] == nonZero[col + 1]) {
          newRow.add(nonZero[col] * 2);
          newRowIds.add(nextTileId++);
          justMergedSet.add(i * gridSize + newRow.length - 1);
          score += nonZero[col];
          if (score > bestScore) {
            bestScore = score;
          }
          col += 2;
          moved = true;
        } else {
          newRow.add(nonZero[col]);
          newRowIds.add(nonZeroIds[col]);
          col++;
        }
      }
      while (newRow.length < gridSize) {
        newRow.add(0);
        newRowIds.add(null);
      }
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] != newRow[j]) moved = true;
        board[i][j] = newRow[j];
        if (newRow[j] != 0) {
          tileIds[i * gridSize + j] = newRowIds[j] ?? nextTileId++;
        } else {
          tileIds.remove(i * gridSize + j);
        }
      }
    }
    if (moved) {
      addNewTile();
      notifyListeners();
    }
    return moved;
  }

  // Di chuyển sang phải
  bool moveRight() {
    // Lưu trạng thái trước khi move
    saveCurrentState();
    
    bool moved = false;
    justMergedSet.clear();
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => tileIds[i * gridSize + j]));
    for (int i = 0; i < gridSize; i++) {
      List<int> row = board[i];
      List<int?> rowIds = oldIds[i];
      List<int> nonZero = [];
      List<int?> nonZeroIds = [];
      for (int j = gridSize - 1; j >= 0; j--) {
        if (row[j] != 0) {
          nonZero.add(row[j]);
          nonZeroIds.add(rowIds[j]);
        }
      }
      List<int> newRow = [];
      List<int?> newRowIds = [];
      int col = 0;
      while (col < nonZero.length) {
        if (col + 1 < nonZero.length && nonZero[col] == nonZero[col + 1]) {
          newRow.add(nonZero[col] * 2);
          newRowIds.add(nextTileId++);
          justMergedSet.add(i * gridSize + (gridSize - 1 - newRow.length + 1));
          score += nonZero[col];
          col += 2;
          moved = true;
        } else {
          newRow.add(nonZero[col]);
          newRowIds.add(nonZeroIds[col]);
          col++;
        }
      }
      while (newRow.length < gridSize) {
        newRow.add(0);
        newRowIds.add(null);
      }
      for (int j = 0; j < gridSize; j++) {
        if (board[i][gridSize - 1 - j] != newRow[j]) moved = true;
        board[i][gridSize - 1 - j] = newRow[j];
        if (newRow[j] != 0) {
          tileIds[i * gridSize + (gridSize - 1 - j)] = newRowIds[j] ?? nextTileId++;
        } else {
          tileIds.remove(i * gridSize + (gridSize - 1 - j));
        }
      }
    }
    if (moved) {
      addNewTile();
      notifyListeners();
    }
    return moved;
  }

  // Di chuyển lên
  bool moveUp() {
    // Lưu trạng thái trước khi move
    saveCurrentState();
    
    bool moved = false;
    justMergedSet.clear();
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => tileIds[i * gridSize + j]));
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      List<int?> colIds = [];
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != 0) {
          col.add(board[i][j]);
          colIds.add(oldIds[i][j]);
        }
      }
      List<int> newCol = [];
      List<int?> newColIds = [];
      int row = 0;
      while (row < col.length) {
        if (row + 1 < col.length && col[row] == col[row + 1]) {
          newCol.add(col[row] * 2);
          newColIds.add(nextTileId++);
          justMergedSet.add((newCol.length - 1) * gridSize + j);
          score += col[row];
          row += 2;
          moved = true;
        } else {
          newCol.add(col[row]);
          newColIds.add(colIds[row]);
          row++;
        }
      }
      while (newCol.length < gridSize) {
        newCol.add(0);
        newColIds.add(null);
      }
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != newCol[i]) moved = true;
        board[i][j] = newCol[i];
        if (newCol[i] != 0) {
          tileIds[i * gridSize + j] = newColIds[i] ?? nextTileId++;
        } else {
          tileIds.remove(i * gridSize + j);
        }
      }
    }
    if (moved) {
      addNewTile();
      notifyListeners();
    }
    return moved;
  }

  // Di chuyển xuống
  bool moveDown() {
    // Lưu trạng thái trước khi move
    saveCurrentState();
    
    bool moved = false;
    justMergedSet.clear();
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => tileIds[i * gridSize + j]));
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      List<int?> colIds = [];
      for (int i = gridSize - 1; i >= 0; i--) {
        if (board[i][j] != 0) {
          col.add(board[i][j]);
          colIds.add(oldIds[i][j]);
        }
      }
      List<int> newCol = [];
      List<int?> newColIds = [];
      int row = 0;
      while (row < col.length) {
        if (row + 1 < col.length && col[row] == col[row + 1]) {
          newCol.add(col[row] * 2);
          newColIds.add(nextTileId++);
          justMergedSet.add((gridSize - 1 - newCol.length + 1) * gridSize + j);
          score += col[row];
          row += 2;
          moved = true;
        } else {
          newCol.add(col[row]);
          newColIds.add(colIds[row]);
          row++;
        }
      }
      while (newCol.length < gridSize) {
        newCol.add(0);
        newColIds.add(null);
      }
      for (int i = 0; i < gridSize; i++) {
        if (board[gridSize - 1 - i][j] != newCol[i]) moved = true;
        board[gridSize - 1 - i][j] = newCol[i];
        if (newCol[i] != 0) {
          tileIds[(gridSize - 1 - i) * gridSize + j] = newColIds[i] ?? nextTileId++;
        } else {
          tileIds.remove((gridSize - 1 - i) * gridSize + j);
        }
      }
    }
    if (moved) {
      addNewTile();
      notifyListeners();
    }
    return moved;
  }

  // Kiểm tra có thể di chuyển được không
  bool canMove() {
    // Kiểm tra có ô trống không
    for (var row in board) {
      for (var value in row) {
        if (value == 0) return true;
      }
    }
    // Kiểm tra có thể merge không
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (i < gridSize - 1 && board[i][j] == board[i + 1][j]) return true;
        if (j < gridSize - 1 && board[i][j] == board[i][j + 1]) return true;
      }
    }
    return false;
  }
} 