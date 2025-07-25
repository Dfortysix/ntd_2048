import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
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

  int cherryHelpCount = 1;

  GameStateProvider() {
    // Tự động khởi tạo 2 ô khởi điểm khi Provider được tạo
    addNewTile();
    addNewTile();
    _loadBestScore(); // Load bestScore từ SharedPreferences
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
    return tiles;
  }

  void resetGame() {
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
    }
  }

  void performUndo() {
    if (gameHistory.isNotEmpty) {
      // Kiểm tra và sử dụng lượt undo
      if (freeUndoCount > 0) {
        freeUndoCount--;
        hasUsedFreeUndo = true;
      } else if (paidUndoCount > 0) {
        paidUndoCount--;
      } else {
        // Không có lượt undo nào
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
    }
  }

  void addPaidUndo() {
    paidUndoCount++;
    notifyListeners();
  }

  void addCherryHelp() {
    cherryHelpCount++;
    notifyListeners();
  }

  void useCherryHelp() {
    if (cherryHelpCount > 0) {
      cherryHelpCount--;
      _removeAllCherryTiles();
      notifyListeners();
    }
  }

  // Lưu bestScore vào SharedPreferences
  Future<void> _saveBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bestScore', bestScore);
    } catch (e) {
      // Error handling
    }
  }

  // Cập nhật bestScore và lưu ngay lập tức
  void _updateBestScore(int newScore) {
    if (newScore > bestScore) {
      bestScore = newScore;
      _saveBestScore(); // Lưu ngay lập tức
    }
  }

  // Load bestScore từ SharedPreferences
  Future<void> _loadBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bestScore = prefs.getInt('bestScore') ?? 0;
    } catch (e) {
      // Error handling
    }
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
          _updateBestScore(score);
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
      updateGameState(); // Cập nhật trạng thái game sau khi thêm tile mới
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
          _updateBestScore(score);
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
      updateGameState(); // Cập nhật trạng thái game sau khi thêm tile mới
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
          _updateBestScore(score);
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
      updateGameState(); // Cập nhật trạng thái game sau khi thêm tile mới
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
          _updateBestScore(score);
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
      updateGameState(); // Cập nhật trạng thái game sau khi thêm tile mới
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

  // Cập nhật trạng thái game
  void updateGameState() {
    // Kiểm tra game won
    for (var row in board) {
      for (var value in row) {
        if (value == 2048 && !gameWon) {
          gameWon = true;
          notifyListeners();
          return;
        }
      }
    }
    
    // Kiểm tra game over
    if (!canMove() && !gameOver) {
      gameOver = true;
      notifyListeners();
    }
  }

  // Trợ giúp: Xóa tất cả ô có giá trị 2 (cherry) - chỉ dùng nội bộ
  void _removeAllCherryTiles() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 2) {
          board[i][j] = 0;
          tileIds.remove(i * gridSize + j);
        }
      }
    }
  }
} 