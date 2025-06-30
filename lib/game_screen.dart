import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'game_board.dart';
import 'score_box.dart';
import 'list_equality.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  static const int gridSize = 4;
  List<List<int>> board =
      List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int score = 0;
  int bestScore = 0;
  bool gameOver = false;
  bool gameWon = false;
  bool isMoving = false;
  late SharedPreferences prefs;
  
  // Audio player cho nhạc nền
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _loadGame();
    _addNewTile();
    _addNewTile();
    _initBackgroundMusic();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
    }
  }

  void _resetGame() {
    setState(() {
      board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      score = 0;
      gameOver = false;
      gameWon = false;
    });
    _addNewTile();
    _addNewTile();
  }

  bool _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = board[i].where((e) => e != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j];
          row.removeAt(j + 1);
        }
      }
      List<int> newRow = row + List.filled(gridSize - row.length, 0);
      if (!ListEquality().equals(board[i], newRow)) {
        board[i] = newRow;
        moved = true;
      }
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> row = board[i].where((e) => e != 0).toList();
      for (int j = row.length - 1; j > 0; j--) {
        if (row[j] == row[j - 1]) {
          row[j] *= 2;
          score += row[j];
          row.removeAt(j - 1);
        }
      }
      List<int> newRow = List.filled(gridSize - row.length, 0) + row;
      if (!ListEquality().equals(board[i], newRow)) {
        board[i] = newRow;
        moved = true;
      }
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != 0) col.add(board[i][j]);
      }
      for (int i = 0; i < col.length - 1; i++) {
        if (col[i] == col[i + 1]) {
          col[i] *= 2;
          score += col[i];
          col.removeAt(i + 1);
        }
      }
      List<int> newCol = col + List.filled(gridSize - col.length, 0);
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != newCol[i]) {
          board[i][j] = newCol[i];
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int j = 0; j < gridSize; j++) {
      List<int> col = [];
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != 0) col.add(board[i][j]);
      }
      for (int i = col.length - 1; i > 0; i--) {
        if (col[i] == col[i - 1]) {
          col[i] *= 2;
          score += col[i];
          col.removeAt(i - 1);
        }
      }
      List<int> newCol = List.filled(gridSize - col.length, 0) + col;
      for (int i = 0; i < gridSize; i++) {
        if (board[i][j] != newCol[i]) {
          board[i][j] = newCol[i];
          moved = true;
        }
      }
    }
    return moved;
  }

  void _handleMove(bool moved) {
    if (isMoving || !mounted) return;
    if (moved) {
      setState(() {
        _addNewTile();
        if (score > bestScore) {
          bestScore = score;
          _saveGame();
        }
      });
      _checkGameState();
      isMoving = true;
      Future.delayed(const Duration(milliseconds: 150), () {
        isMoving = false;
      });
    }
  }

  void _checkGameState() {
    for (var row in board) {
      if (row.contains(2048) && !gameWon) {
        setState(() => gameWon = true);
        _showWinDialog();
        return;
      }
    }
    if (!_canMove()) {
      setState(() => gameOver = true);
      _showGameOverDialog();
    }
  }

  bool _canMove() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) return true;
        if (i < gridSize - 1 && board[i][j] == board[i + 1][j]) return true;
        if (j < gridSize - 1 && board[i][j] == board[i][j + 1]) return true;
      }
    }
    return false;
  }

  void _showWinDialog() {
    _stopBackgroundMusic();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Chúc mừng!'),
        content: const Text('Bạn đã đạt đến 2048!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Chơi lại')),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    _stopBackgroundMusic();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Điểm số của bạn: $score'),
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
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        title: const Text('2048'),
        actions: [
          IconButton(
            onPressed: _toggleBackgroundMusic,
            icon: Icon(_isMusicPlaying ? Icons.music_note : Icons.music_off),
          ),
          IconButton(onPressed: _resetGame, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: GestureDetector(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ScoreBox('Điểm', score),
                ScoreBox('Cao nhất', bestScore),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: GameBoard(
                  board: board,
                  getTileColor: _getTileColor,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Vuốt để di chuyển các ô',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFFCDC1B4);
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
} 