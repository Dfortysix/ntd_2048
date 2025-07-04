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
import 'package:provider/provider.dart';
import 'game_state_provider.dart';

class Fruits2048Screen extends StatefulWidget {
  const Fruits2048Screen({super.key});

  @override
  State<Fruits2048Screen> createState() => _Fruits2048ScreenState();
}

class _Fruits2048ScreenState extends State<Fruits2048Screen> {
  static const int gridSize = 4;
  late SharedPreferences prefs;
  
  // Audio player cho nhạc nền
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  
  // Audio player cho nhạc chiến thắng
  final AudioPlayer _winAudioPlayer = AudioPlayer();
  
  // Quảng cáo xen kẽ được quản lý bởi AdManager
  
  @override
  void initState() {
    super.initState();
    // Đảm bảo Provider được khởi tạo trước khi load game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGame();
    });
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
  }

  void _performUndo() {
    final gameState = context.read<GameStateProvider>();
    gameState.performUndo();
  }

  void _handleMove(bool moved) {
    if (moved) {
      final gameState = context.read<GameStateProvider>();
      // Kiểm tra game over và game won
      if (gameState.gameOver) {
        _showGameOverDialog();
      } else if (gameState.gameWon && !gameState.showFireworks) {
        _showWinDialog();
      }
    }
  }

  void _checkGameState() {
    final gameState = context.read<GameStateProvider>();
    for (var row in gameState.board) {
      for (var value in row) {
        if (value == 2048 && !gameState.gameWon) {
          gameState.gameWon = true;
          _showWinDialog();
          return;
        }
      }
    }
    if (!gameState.canMove()) {
      gameState.gameOver = true;
      _showGameOverDialog();
    }
  }



  void _showWinDialog() {
    _stopBackgroundMusic(); // Dừng nhạc nền khi thắng
    _playWinSound(); // Phát nhạc chiến thắng
    context.read<GameStateProvider>().showFireworks = true; // Hiển thị pháo hoa
    
    // Tự động tắt pháo hoa sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<GameStateProvider>().showFireworks = false;
      }
    });
  }

  void _showGameOverDialog() {
    _stopBackgroundMusic();
    
    // Hiển thị quảng cáo xen kẽ khi game over
    AdManager.showAdOnGameOver();
    
    final gameState = context.read<GameStateProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🍂 Hết trái cây rồi!'),
        content: Text('Bạn đã thu thập được ${gameState.score} trái cây! 🍎'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameStateProvider>().resetGame();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
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
          if (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
            IconButton(
              onPressed: gameState.gameHistory.isNotEmpty ? _performUndo : null,
              icon: const Icon(Icons.undo),
              tooltip: 'Quay lại nước đi trước (${gameState.freeUndoCount + gameState.paidUndoCount} lượt còn lại)',
            )
          else
            IconButton(
              onPressed: gameState.gameHistory.isNotEmpty ? _showBuyUndoDialog : null,
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'Xem quảng cáo để nhận lượt trợ giúp',
            ),
          IconButton(
            onPressed: () {
              gameState.resetGame();
            }, 
            icon: const Icon(Icons.refresh)
          ),
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
                        if (gameState.gameOver || gameState.isMoving) return;
                        double velocity = details.velocity.pixelsPerSecond.dx;
                        if (velocity.abs() > 300) {
                          if (velocity > 0) {
                            _handleMove(gameState.moveRight());
                          } else {
                            _handleMove(gameState.moveLeft());
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (gameState.gameOver || gameState.isMoving) return;
                        double velocity = details.velocity.pixelsPerSecond.dy;
                        if (velocity.abs() > 300) {
                          if (velocity > 0) {
                            _handleMove(gameState.moveDown());
                          } else {
                            _handleMove(gameState.moveUp());
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
                                  ScoreBox('Điểm', gameState.score),
                                  ScoreBox('Cao nhất', gameState.bestScore),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0 
                                          ? const Color(0xFF4CAF50) 
                                          : const Color(0xFFFF9800),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0 
                                              ? Icons.undo 
                                              : Icons.play_circle_outline,
                                          color: Colors.white, 
                                          size: 16
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0 
                                              ? '${gameState.freeUndoCount + gameState.paidUndoCount}'
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
                                  if (gameState.freeUndoCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8BC34A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Miễn phí: ${gameState.freeUndoCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (gameState.freeUndoCount > 0 && gameState.paidUndoCount > 0)
                                    const SizedBox(width: 8),
                                  if (gameState.paidUndoCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Quảng cáo: ${gameState.paidUndoCount}',
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
                                tiles: gameState.tiles,
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
                    if (gameState.showFireworks)
                      FireworksEffect(
                        onComplete: () {
                          context.read<GameStateProvider>().showFireworks = false;
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
      // Error handling
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play();
      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isMusicPlaying = false;
      });
    } catch (e) {
      // Error handling
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
      // Error handling
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
      context.read<GameStateProvider>().addPaidUndo();
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