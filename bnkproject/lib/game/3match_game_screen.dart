import 'package:flutter/material.dart';

class Match3GameScreen extends StatelessWidget {
  const Match3GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/game/match3_finance2.png',
            fit: BoxFit.contain, // ✅ 전체 보이게, 잘림 없음
          ),
        ),
      ),
    );
  }
}
