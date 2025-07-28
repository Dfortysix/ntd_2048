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
import 'settings_screen.dart';
import 'localization_helper.dart';

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
  
  // Audio player cho nhạc merge
  final AudioPlayer _mergeAudioPlayer = AudioPlayer();
  
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
    _mergeAudioPlayer.dispose();
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
      if (gameState.justMergedSet.isNotEmpty) {
        _playMergeSound();
      }
      // Kiểm tra game over và game won
      _checkGameState();
      
      // Kiểm tra và hiển thị dialog tương ứng
      if (gameState.gameOver) {
        _showGameOverDialog();
      } else if (gameState.gameWon && !gameState.showFireworks) {
        _showWinDialog();
      }
    }
  }

  void _checkGameState() {
    final gameState = context.read<GameStateProvider>();
    gameState.updateGameState();
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
    
    final gameState = context.read<GameStateProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocalizationHelper.getLocalizedString(context, 'gameOver')),
        content: Text(LocalizationHelper.gameOverMessage(context, gameState.score)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameStateProvider>().resetGame();
            },
            child: Text(LocalizationHelper.getLocalizedString(context, 'playAgain')),
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
        title: Text(LocalizationHelper.getLocalizedString(context, 'appTitle')),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleBackgroundMusic,
            icon: Icon(_isMusicPlaying ? Icons.music_note : Icons.music_off),
          ),
          IconButton(
            onPressed: () {
              gameState.resetGame();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
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
                                  ScoreBox(LocalizationHelper.getLocalizedString(context, 'score'), gameState.score),
                                  ScoreBox(LocalizationHelper.getLocalizedString(context, 'bestScore'), gameState.bestScore),
                                  // Nhóm trợ giúp (undo/quảng cáo + xóa cherry)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
                                            ? (gameState.gameHistory.isNotEmpty ? _performUndo : null)
                                            : (gameState.gameHistory.isNotEmpty ? _showBuyUndoDialog : null),
                                        icon: Icon(
                                          (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
                                              ? Icons.undo
                                              : Icons.play_circle_outline,
                                          color: _helpIconColor(gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0),
                                        ),
                                        tooltip: (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
                                            ? LocalizationHelper.undoHelpTooltip(context, gameState.freeUndoCount + gameState.paidUndoCount)
                                            : LocalizationHelper.getLocalizedString(context, 'watchAdForHelp'),
                                        splashColor: (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
                                            ? null
                                            : Colors.orangeAccent,
                                        highlightColor: (gameState.freeUndoCount > 0 || gameState.paidUndoCount > 0)
                                            ? null
                                            : Colors.orange.withOpacity(0.2),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          final provider = context.read<GameStateProvider>();
                                          if (provider.cherryHelpCount > 0) {
                                            provider.useCherryHelp();
                                          } else {
                                            _showBuyCherryHelpDialog();
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete_sweep,
                                          color: _cherryHelpIconColor(context.read<GameStateProvider>().cherryHelpCount > 0),
                                        ),
                                        tooltip: LocalizationHelper.getLocalizedString(context, 'removeCherryHelpTooltip'),
                                        splashColor: context.read<GameStateProvider>().cherryHelpCount > 0
                                            ? null
                                            : Colors.orangeAccent,
                                        highlightColor: context.read<GameStateProvider>().cherryHelpCount > 0
                                            ? null
                                            : Colors.orange.withOpacity(0.2),
                                      ),
                                    ],
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
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 16),
                            child: Text(LocalizationHelper.getLocalizedString(context, 'swipeToMerge'),
                                style: const TextStyle(color: Color(0xFF2E7D32))),
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

  Color _helpIconColor(bool hasHelp) {
    return hasHelp ? Colors.white : Colors.orange;
  }

  Color _cherryHelpIconColor(bool hasCherry) {
    return hasCherry ? Colors.white : Colors.orange;
  }

  Future<void> _initBackgroundMusic() async {
    prefs = await SharedPreferences.getInstance();
    bool? isMusicOn = prefs.getBool('isMusicOn');
    _isMusicPlaying = isMusicOn ?? true; // Mặc định là bật nhạc nếu chưa có dữ liệu

    await _audioPlayer.setAsset('assets/sounds/theme.mp3');
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setVolume(0.3);

    if (_isMusicPlaying) {
      await _audioPlayer.play();
    }
    setState(() {}); // Cập nhật UI
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
    _isMusicPlaying = !_isMusicPlaying;
    await prefs.setBool('isMusicOn', _isMusicPlaying);
    setState(() {});
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

  Future<void> _playMergeSound() async {
    if (!_isMusicPlaying) return;
    try {
      await _mergeAudioPlayer.setAsset('assets/sounds/merge.wav');
      await _mergeAudioPlayer.setVolume(0.7);
      await _mergeAudioPlayer.play();
    } catch (e) {
      // Error handling
    }
  }

  // Hiển thị dialog mua thêm lượt trợ giúp
  void _showBuyUndoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationHelper.getLocalizedString(context, 'addHelpMove')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalizationHelper.getLocalizedString(context, 'addHelpMoveMessage')),
            const SizedBox(height: 8),
            Text(LocalizationHelper.getLocalizedString(context, 'freeMoveUsed')),
            Text(LocalizationHelper.getLocalizedString(context, 'watchAdForMove')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocalizationHelper.getLocalizedString(context, 'adInfo'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFF9800)),
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
            child: Text(LocalizationHelper.getLocalizedString(context, 'cancel')),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline, size: 16),
                const SizedBox(width: 4),
                Text(LocalizationHelper.getLocalizedString(context, 'watchAd')),
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
        SnackBar(
          content: Text(LocalizationHelper.getLocalizedString(context, 'helpMoveAdded')),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Hiển thị dialog mua thêm lượt xóa cherry (giống undo)
  void _showBuyCherryHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationHelper.getLocalizedString(context, 'addCherryHelp')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalizationHelper.getLocalizedString(context, 'addCherryHelpMessage')),
            const SizedBox(height: 8),
            Text(LocalizationHelper.getLocalizedString(context, 'watchAdForCherry')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocalizationHelper.getLocalizedString(context, 'adInfo'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFF9800)),
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
            child: Text(LocalizationHelper.getLocalizedString(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _watchAdForCherryHelp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline, size: 16),
                const SizedBox(width: 4),
                Text(LocalizationHelper.getLocalizedString(context, 'watchAd')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xem quảng cáo để nhận lượt xóa cherry
  void _watchAdForCherryHelp() {
    AdManager.showRewardedAd(() {
      context.read<GameStateProvider>().addCherryHelp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationHelper.getLocalizedString(context, 'cherryHelpAdded')),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
} 