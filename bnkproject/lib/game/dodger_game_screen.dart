import 'package:flutter/material.dart';

class DodgerGameScreen extends StatelessWidget {
  const DodgerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/game/hotteok_dodge.jpg',
            fit: BoxFit.contain, // 전체 보이게(잘림 없음). 꽉 채우려면 BoxFit.cover
          ),
        ),
      ),
    );
  }
}
