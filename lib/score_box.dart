import 'package:flutter/material.dart';

class ScoreBox extends StatelessWidget {
  final String title;
  final int value;

  const ScoreBox(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 