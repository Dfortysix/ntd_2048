import 'package:flutter/material.dart';
import 'dart:math';

class FireworksEffect extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const FireworksEffect({super.key, this.onComplete});

  @override
  State<FireworksEffect> createState() => _FireworksEffectState();
}

class _FireworksEffectState extends State<FireworksEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Confetti> _confettis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Tạo confetti từ 2 phía (trái và phải)
    _createConfettis();
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _createConfettis() {
    // Confetti từ phía trái
    for (int i = 0; i < 15; i++) {
      _confettis.add(Confetti(
        x: -20, // Bắt đầu từ ngoài màn hình bên trái
        y: 100 + _random.nextDouble() * 600, // Vị trí Y ngẫu nhiên
        color: _getRandomColor(),
        angle: _random.nextDouble() * 60 - 30, // Góc -30 đến 30 độ
        delay: _random.nextDouble() * 0.5,
        size: 8 + _random.nextDouble() * 12, // Kích thước 8-20
        isFromLeft: true,
      ));
    }
    
    // Confetti từ phía phải
    for (int i = 0; i < 15; i++) {
      _confettis.add(Confetti(
        x: 420, // Bắt đầu từ ngoài màn hình bên phải
        y: 100 + _random.nextDouble() * 600, // Vị trí Y ngẫu nhiên
        color: _getRandomColor(),
        angle: 150 + _random.nextDouble() * 60, // Góc 150 đến 210 độ
        delay: _random.nextDouble() * 0.5,
        size: 8 + _random.nextDouble() * 12, // Kích thước 8-20
        isFromLeft: false,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: _confettis.map((confetti) {
            return Positioned(
              left: confetti.x + _getConfettiX(confetti),
              top: confetti.y + _getConfettiY(confetti),
              child: _buildConfetti(confetti),
            );
          }).toList(),
        );
      },
    );
  }

  double _getConfettiX(Confetti confetti) {
    final progress = (_animation.value - confetti.delay).clamp(0.0, 1.0);
    if (progress <= 0) return 0;
    
    const distance = 200.0; // Khoảng cách di chuyển
    final angleRad = confetti.angle * pi / 180;
    return cos(angleRad) * distance * progress;
  }

  double _getConfettiY(Confetti confetti) {
    final progress = (_animation.value - confetti.delay).clamp(0.0, 1.0);
    if (progress <= 0) return 0;
    
    const distance = 200.0; // Khoảng cách di chuyển
    final angleRad = confetti.angle * pi / 180;
    const gravity = 100.0; // Hiệu ứng trọng lực
    
    return sin(angleRad) * distance * progress + gravity * progress * progress;
  }

  Widget _buildConfetti(Confetti confetti) {
    final progress = (_animation.value - confetti.delay).clamp(0.0, 1.0);
    
    if (progress <= 0) return const SizedBox.shrink();
    
    return Transform.rotate(
      angle: progress * 4 * pi, // Xoay confetti
      child: Opacity(
        opacity: progress > 0.8 ? (1.0 - progress) * 5 : 1.0,
        child: Container(
          width: confetti.size,
          height: confetti.size,
          decoration: BoxDecoration(
            color: confetti.color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: confetti.color.withOpacity(0.6),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Confetti {
  final double x;
  final double y;
  final Color color;
  final double angle;
  final double delay;
  final double size;
  final bool isFromLeft;

  Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.angle,
    required this.delay,
    required this.size,
    required this.isFromLeft,
  });
} 