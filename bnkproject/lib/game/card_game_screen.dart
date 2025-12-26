import 'package:flutter/material.dart';

class CardGameScreen extends StatelessWidget {
  const CardGameScreen({super.key}); // ✅ const 생성자

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/game/card_game.gif',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
