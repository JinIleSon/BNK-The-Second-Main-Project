import 'package:flutter/material.dart';
import '../travel_theme.dart';

class XpBar extends StatelessWidget {
  final double progress;
  const XpBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: Colors.white.withOpacity(0.10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [TravelTheme.boogiMint, Color(0xFF3BD9F6)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelXpBlock extends StatelessWidget {
  final String levelText;
  final String xpText;
  final double progress;

  const LevelXpBlock({
    super.key,
    required this.levelText,
    required this.xpText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('현재 레벨', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                Text(levelText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                XpBar(progress: progress),
                const SizedBox(height: 4),
                Text(xpText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
