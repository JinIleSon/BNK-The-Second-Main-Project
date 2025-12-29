import 'package:flutter/material.dart';

class Match3GameScreen extends StatelessWidget {
  const Match3GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/game/match3_finance.gif',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
