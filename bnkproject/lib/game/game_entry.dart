import 'package:flutter/material.dart';

import 'dodger_game_screen.dart';
import '3match_game_screen.dart';
import 'card_game_screen.dart'; // ✅ 추가

class GameEntryPage extends StatelessWidget {
  const GameEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final card = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('게임'),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _Header(),
          const SizedBox(height: 14),

          // 1) 3매치 금융교육
          _GameCard(
            cardColor: card,
            title: '3매치 금융교육',
            subtitle: 'Match-3 · 금융 개념 학습',
            assetImagePath: 'assets/game/match3_finance.png',
            badgeText: 'PLAY',
            onPlay: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const Match3GameScreen()),
              );
            },
          ),

          const SizedBox(height: 12),

          // 2) 장애물(씨앗호떡) 피하기
          _GameCard(
            cardColor: card,
            title: '장애물(씨앗호떡) 피하기',
            subtitle: 'Dodge · Survival',
            assetImagePath: 'assets/game/hotteok_dodge.jpg',
            badgeText: 'PLAY',
            onPlay: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const DodgerGameScreen()),
              );
            },
          ),

          const SizedBox(height: 12),

          // 3) 동백전 카드게임
          _GameCard(
            cardColor: card,
            title: '동백전 카드게임',
            subtitle: '혜택 조합 · 리워드 최적화',
            assetImagePath: 'assets/game/card_game.gif',
            badgeText: 'PLAY',
            onPlay: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const CardGameScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
    );
    final sub = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white60,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('미니게임', style: title),
        const SizedBox(height: 6),
        Text('가볍게 즐기고 리워드도 챙기세요.', style: sub),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final Color cardColor;
  final String title;
  final String subtitle;
  final String assetImagePath;
  final String? badgeText;
  final VoidCallback onPlay;

  const _GameCard({
    required this.cardColor,
    required this.title,
    required this.subtitle,
    required this.assetImagePath,
    required this.onPlay,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
    );
    final s = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white60,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      assetImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, size: 42, color: Colors.white38),
                      ),
                    ),
                    if (badgeText != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _Badge(text: badgeText!),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: t),
                        const SizedBox(height: 4),
                        Text(subtitle, style: s),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('플레이'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
