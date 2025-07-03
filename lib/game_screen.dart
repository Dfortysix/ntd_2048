import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'game_board.dart';
import 'score_box.dart';
import 'list_equality.dart';
import 'fruit_guide.dart';
import 'fireworks_effect.dart';
import 'ad_manager.dart';
import 'banner_ad_widget.dart';
import 'game_state.dart';

class Fruits2048Screen extends StatefulWidget {
  const Fruits2048Screen({super.key});

  @override
  State<Fruits2048Screen> createState() => _Fruits2048ScreenState();
}

class _Fruits2048ScreenState extends State<Fruits2048Screen> {
  static const int gridSize = 4;
  List<List<int>> board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int score = 0;
  int bestScore = 0;
  bool gameOver = false;
  bool gameWon = false;
  bool isMoving = false;
  late SharedPreferences prefs;
  Set<int> _justMergedSet = {};
  
  // Quản lý id duy nhất cho mỗi Tile
  int _nextTileId = 0;
  Map<int, int> _tileIds = {}; // key: i*gridSize+j, value: id
  
  // Lịch sử các bước đi để undo
  List<GameState> _gameHistory = [];
  static const int maxHistorySize = 10; // Giới hạn lịch sử
  
  // Quản lý lượt trợ giúp
  int _freeUndoCount = 1; // 1 lượt miễn phí
  int _paidUndoCount = 0; // Lượt mua bằng quảng cáo
  bool _hasUsedFreeUndo = false; // Đã sử dụng lượt miễn phí chưa
  
  // Audio player cho nhạc nền
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  
  // Audio player cho nhạc chiến thắng
  final AudioPlayer _winAudioPlayer = AudioPlayer();
  
  // Hiệu ứng pháo hoa
  bool _showFireworks = false;
  
  // Quảng cáo xen kẽ được quản lý bởi AdManager
  
  List<Tile> get tiles => _buildTilesFromBoard(board, justMergedSet: _justMergedSet);

  List<Tile> _buildTilesFromBoard(List<List<int>> board, {Set<int>? justMergedSet}) {
    final tiles = <Tile>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        int key = i * gridSize + j;
        if (board[i][j] != 0 && _tileIds.containsKey(key)) {
          tiles.add(Tile(
            id: _tileIds[key]!,
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

  @override
  void initState() {
    super.initState();
    _loadGame();
    _addNewTile();
    _addNewTile();
    _initBackgroundMusic();
    AdManager.loadInterstitialAd();
    AdManager.loadRewardedAd();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _winAudioPlayer.dispose();
    AdManager.dispose();
    super.dispose();
  }

  Future<void> _loadGame() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveGame() async {
    await prefs.setInt('bestScore', bestScore);
  }

  void _saveCurrentState() {
    final currentState = GameState.fromCurrent(
      board: board,
      score: score,
      gameOver: gameOver,
      gameWon: gameWon,
    );
    _gameHistory.add(currentState);
    if (_gameHistory.length > maxHistorySize) {
      _gameHistory.removeAt(0);
    }
  }

  void _performUndo() {
    if (_gameHistory.isNotEmpty) {
      final previousState = _gameHistory.removeLast();
      setState(() {
        board = previousState.boardCopy;
        score = previousState.score;
        gameOver = previousState.gameOver;
        gameWon = previousState.gameWon;
        _justMergedSet.clear();
      });
      if (_showFireworks) {
        setState(() {
          _showFireworks = false;
        });
      }
    }
  }

  void _addNewTile() {
    final empty = <List<int>>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) empty.add([i, j]);
      }
    }
    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      board[pos[0]][pos[1]] = Random().nextDouble() < 0.9 ? 2 : 4;
      _tileIds[pos[0] * gridSize + pos[1]] = _nextTileId++;
    }
  }

  void _resetGame() {
    setState(() {
      board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      score = 0;
      gameOver = false;
      gameWon = false;
      _justMergedSet.clear();
      _tileIds.clear();
      _nextTileId = 0;
    });
    _addNewTile();
    _addNewTile();
    _gameHistory.clear();
    _freeUndoCount = 1;
    _paidUndoCount = 0;
    _hasUsedFreeUndo = false;
    if (AdManager.shouldShowAd()) {
      AdManager.showInterstitialAd();
    }
  }

  bool _moveLeft() {
    bool moved = false;
    _justMergedSet.clear();
    // Lưu lại id cũ
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => _tileIds[i * gridSize + j]));
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
          newRowIds.add(_nextTileId++); // id mới cho merge
          _justMergedSet.add(i * gridSize + newRow.length - 1);
          score += nonZero[col];
          col += 2;
          moved = true;
        } else {
          newRow.add(nonZero[col]);
          newRowIds.add(nonZeroIds[col]);
          col += 1;
        }
      }
      while (newRow.length < gridSize) {
        newRow.add(0);
        newRowIds.add(null);
      }
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] != newRow[j]) {
          board[i][j] = newRow[j];
          moved = true;
        }
        int key = i * gridSize + j;
        if (newRow[j] != 0 && newRowIds[j] != null) {
          _tileIds[key] = newRowIds[j]!;
        } else if (newRow[j] != 0 && newRowIds[j] == null) {
          _tileIds[key] = _nextTileId++;
        } else {
          _tileIds.remove(key);
        }
      }
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    _justMergedSet.clear();
    // Lưu lại id cũ
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => _tileIds[i * gridSize + j]));
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
          newRowIds.add(_nextTileId++); // id mới cho merge
          _justMergedSet.add(i * gridSize + (gridSize - 1 - newRow.length + 1));
          score += nonZero[col];
          col += 2;
          moved = true;
        } else {
          newRow.add(nonZero[col]);
          newRowIds.add(nonZeroIds[col]);
          col += 1;
        }
      }
      while (newRow.length < gridSize) {
        newRow.add(0);
        newRowIds.add(null);
      }
      newRow = newRow.reversed.toList();
      newRowIds = newRowIds.reversed.toList();
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] != newRow[j]) {
          board[i][j] = newRow[j];
          moved = true;
        }
        int key = i * gridSize + j;
        if (newRow[j] != 0 && newRowIds[j] != null) {
          _tileIds[key] = newRowIds[j]!;
        } else if (newRow[j] != 0 && newRowIds[j] == null) {
          _tileIds[key] = _nextTileId++;
        } else {
          _tileIds.remove(key);
        }
      }
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    _justMergedSet.clear();
    // Lưu lại id cũ
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => _tileIds[i * gridSize + j]));
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
          newColIds.add(_nextTileId++); // id mới cho merge
          _justMergedSet.add((newCol.length - 1) * gridSize + j);
          score += col[row];
          row += 2;
          moved = true;
        } else {
          newCol.add(col[row]);
          newColIds.add(colIds[row]);
          row += 1;
        }
      }
      while (newCol.length < gridSize) {
        newCol.add(0);
        newColIds.add(null);
      }
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != newCol[i]) {
          board[i][j] = newCol[i];
          moved = true;
        }
        int key = i * gridSize + j;
        if (newCol[i] != 0 && newColIds[i] != null) {
          _tileIds[key] = newColIds[i]!;
        } else if (newCol[i] != 0 && newColIds[i] == null) {
          _tileIds[key] = _nextTileId++;
        } else {
          _tileIds.remove(key);
        }
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    _justMergedSet.clear();
    // Lưu lại id cũ
    List<List<int?>> oldIds = List.generate(gridSize, (i) => List.generate(gridSize, (j) => _tileIds[i * gridSize + j]));
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
          newColIds.add(_nextTileId++); // id mới cho merge
          _justMergedSet.add((gridSize - 1 - newCol.length + 1) * gridSize + j);
          score += col[row];
          row += 2;
          moved = true;
        } else {
          newCol.add(col[row]);
          newColIds.add(colIds[row]);
          row += 1;
        }
      }
      while (newCol.length < gridSize) {
        newCol.add(0);
        newColIds.add(null);
      }
      newCol = newCol.reversed.toList();
      newColIds = newColIds.reversed.toList();
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != newCol[i]) {
          board[i][j] = newCol[i];
          moved = true;
        }
        int key = i * gridSize + j;
        if (newCol[i] != 0 && newColIds[i] != null) {
          _tileIds[key] = newColIds[i]!;
        } else if (newCol[i] != 0 && newColIds[i] == null) {
          _tileIds[key] = _nextTileId++;
        } else {
          _tileIds.remove(key);
        }
      }
    }
    return moved;
  }

  void _handleMove(bool moved) {
    if (isMoving || !mounted) return;
    if (moved) {
      _saveCurrentState();
      setState(() {
        _addNewTile();
        if (score > bestScore) {
          bestScore = score;
          _saveGame();
        }
      });
      _checkGameState();
      isMoving = true;
      Future.delayed(const Duration(milliseconds: 180), () {
        setState(() {
          _justMergedSet.clear();
        });
        isMoving = false;
      });
    }
  }

  void _checkGameState() {
    for (var row in board) {
      for (var value in row) {
        if (value == 2048 && !gameWon) {
          setState(() => gameWon = true);
          _showWinDialog();
          return;
        }
      }
    }
    if (!_canMove()) {
      setState(() => gameOver = true);
      _showGameOverDialog();
    }
  }

  bool _canMove() {
    for (var row in board) {
      for (var value in row) {
        if (value == 0) return true;
      }
    }
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (i < gridSize - 1 && board[i][j] == board[i + 1][j]) return true;
        if (j < gridSize - 1 && board[i][j] == board[i][j + 1]) return true;
      }
    }
    return false;
  }

  void _showWinDialog() {
    print('🎆 Starting win sequence...'); // Debug
    _stopBackgroundMusic(); // Dừng nhạc nền khi thắng
    _playWinSound(); // Phát nhạc chiến thắng
    setState(() {
      _showFireworks = true; // Hiển thị pháo hoa
      print('🎆 Fireworks set to true'); // Debug
    });
    
    // Tự động tắt pháo hoa sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFireworks = false;
          print('🎆 Fireworks auto-hidden after 3 seconds'); // Debug
        });
      }
    });
  }

  void _showGameOverDialog() {
    _stopBackgroundMusic();
    
    // Hiển thị quảng cáo xen kẽ khi game over
    AdManager.showAdOnGameOver();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🍂 Hết trái cây rồi!'),
        content: Text('Bạn đã thu thập được $score trái cây! 🍎'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Để gradient hiển thị
      appBar: AppBar(
        title: const Text('🍎 Fruits 2048'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleBackgroundMusic,
            icon: Icon(_isMusicPlaying ? Icons.music_note : Icons.music_off),
          ),
          // Nút Undo hoặc xem quảng cáo
          if (_freeUndoCount > 0 || _paidUndoCount > 0)
            IconButton(
              onPressed: _gameHistory.isNotEmpty ? _performUndo : null,
              icon: const Icon(Icons.undo),
              tooltip: 'Quay lại nước đi trước (${_freeUndoCount + _paidUndoCount} lượt còn lại)',
            )
          else
            IconButton(
              onPressed: _gameHistory.isNotEmpty ? _showBuyUndoDialog : null,
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'Xem quảng cáo để nhận lượt trợ giúp',
            ),
          IconButton(onPressed: _resetGame, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          // Lớp dưới: Gradient + pattern emoji trái cây mờ
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB2FF59), // Xanh lá sáng
                  Color(0xFF4CAF50), // Xanh lá đậm
                  Color(0xFF81D4FA), // Xanh dương nhạt
                ],
              ),
            ),
            child: Stack(
              children: [
                // Các emoji trái cây mờ, vị trí cố định đẹp mắt
                Positioned(
                  top: 60, left: 30,
                  child: Opacity(
                    opacity: 0.12,
                    child: Text('🍉', style: TextStyle(fontSize: 80),),
                  ),
                ),
                Positioned(
                  top: 200, right: 40,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text('🍍', style: TextStyle(fontSize: 60),),
                  ),
                ),
                Positioned(
                  bottom: 100, left: 60,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text('🍒', style: TextStyle(fontSize: 50),),
                  ),
                ),
                Positioned(
                  bottom: 40, right: 80,
                  child: Opacity(
                    opacity: 0.09,
                    child: Text('🍇', style: TextStyle(fontSize: 70),),
                  ),
                ),
                Positioned(
                  top: 120, left: 120,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text('🍓', style: TextStyle(fontSize: 60),),
                  ),
                ),
                Positioned(
                  bottom: 180, right: 30,
                  child: Opacity(
                    opacity: 0.09,
                    child: Text('🥭', style: TextStyle(fontSize: 60),),
                  ),
                ),
                Positioned(
                  top: 40, right: 100,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text('🍈', style: TextStyle(fontSize: 60),),
                  ),
                ),
              ],
            ),
          ),
          // Lớp trên: Nội dung game như cũ
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (details) {
                        if (gameOver || isMoving) return;
                        double velocity = details.velocity.pixelsPerSecond.dx;
                        if (velocity.abs() > 300) {
                          if (velocity > 0) {
                            _handleMove(_moveRight());
                          } else {
                            _handleMove(_moveLeft());
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (gameOver || isMoving) return;
                        double velocity = details.velocity.pixelsPerSecond.dy;
                        if (velocity.abs() > 300) {
                          if (velocity > 0) {
                            _handleMove(_moveDown());
                          } else {
                            _handleMove(_moveUp());
                          }
                        }
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ScoreBox('Điểm', score),
                                  ScoreBox('Cao nhất', bestScore),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _freeUndoCount > 0 || _paidUndoCount > 0 
                                          ? const Color(0xFF4CAF50) 
                                          : const Color(0xFFFF9800),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _freeUndoCount > 0 || _paidUndoCount > 0 
                                              ? Icons.undo 
                                              : Icons.play_circle_outline,
                                          color: Colors.white, 
                                          size: 16
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _freeUndoCount > 0 || _paidUndoCount > 0 
                                              ? '${_freeUndoCount + _paidUndoCount}'
                                              : '0',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Hiển thị chi tiết lượt trợ giúp
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_freeUndoCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8BC34A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Miễn phí: $_freeUndoCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (_freeUndoCount > 0 && _paidUndoCount > 0)
                                    const SizedBox(width: 8),
                                  if (_paidUndoCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Quảng cáo: $_paidUndoCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: GameBoard(
                                tiles: tiles,
                                getTileColor: _getTileColor,
                              ),
                            ),
                          ),
                          const FruitGuide(),
                          const Padding(
                            padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 16),
                            child: Text('Vuốt để gộp các trái cây giống nhau 🍎',
                                style: TextStyle(color: Color(0xFF2E7D32))),
                          ),
                        ],
                      ),
                    ),
                    // Hiệu ứng pháo hoa
                    if (_showFireworks)
                      FireworksEffect(
                        onComplete: () {
                          print('🎆 Fireworks effect completed'); // Debug
                          setState(() {
                            _showFireworks = false;
                          });
                        },
                      ),
                  ],
                ),
              ),
              // Quảng cáo biểu ngữ ở dưới cùng
              const BannerAdWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: // 🍒 Cherry
        return const Color(0xFFD32F2F); // Đỏ cherry
      case 4: // 🍓 Dâu tây
        return const Color(0xFFE91E63); // Hồng dâu
      case 8: // 🍇 Nho
        return const Color(0xFF7B1FA2); // Tím nho
      case 16: // 🍊 Quýt
        return const Color(0xFFFFA726); // Cam quýt
      case 32: // 🍎 Táo
        return const Color(0xFFEF5350); // Đỏ táo
      case 64: // 🍐 Lê
        return const Color(0xFFCDDC39); // Vàng xanh lê
      case 128: // 🍑 Đào
        return const Color(0xFFFFB74D); // Cam đào
      case 256: // 🥭 Xoài
        return const Color(0xFFFFD600); // Vàng xoài
      case 512: // 🍍 Dứa
        return const Color(0xFFFFF176); // Vàng dứa
      case 1024: // 🍉 Dưa hấu
        return const Color(0xFF388E3C); // Xanh dưa hấu
      case 2048: // 🍈 Dưa gang
        return const Color(0xFF81C784); // Xanh dưa gang
      case 4096: // 🥥 Dừa
        return const Color(0xFF8D6E63); // Nâu dừa
      case 8192: // 🧺 Giỏ thần kỳ
        return const Color(0xFF7C4DFF); // Tím giỏ thần kỳ
      default:
        return const Color(0xFFC8E6C9); // Màu xanh lá cây nhạt cho ô trống
    }
  }

  Future<void> _initBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/theme.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(0.3);
      await _playBackgroundMusic();
    } catch (e) {
      print('Error initializing background music: $e');
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play();
      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isMusicPlaying = false;
      });
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> _toggleBackgroundMusic() async {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
    if (_isMusicPlaying) {
      await _playBackgroundMusic();
    } else {
      await _stopBackgroundMusic();
    }
  }

  Future<void> _playWinSound() async {
    try {
      await _winAudioPlayer.setAsset('assets/sounds/win.mp3');
      await _winAudioPlayer.setVolume(0.7);
      await _winAudioPlayer.play();
    } catch (e) {
      print('Error playing win sound: $e');
    }
  }

  // Hiển thị dialog mua thêm lượt trợ giúp
  void _showBuyUndoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔄 Thêm lượt trợ giúp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn đã hết lượt trợ giúp!'),
            const SizedBox(height: 8),
            const Text('• 1 lượt miễn phí đã sử dụng'),
            const Text('• Xem quảng cáo để nhận thêm 1 lượt'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quảng cáo sẽ hiển thị trong 15-30 giây',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFF9800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _watchAdForUndo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_outline, size: 16),
                SizedBox(width: 4),
                Text('Xem quảng cáo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xem quảng cáo để nhận lượt trợ giúp
  void _watchAdForUndo() {
    AdManager.showRewardedAd(() {
      // Callback khi xem xong quảng cáo
      setState(() {
        _paidUndoCount++;
      });
      
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Bạn đã nhận thêm 1 lượt trợ giúp!'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
} 