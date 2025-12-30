import 'package:flutter/material.dart';

class StoTheme {
  // Toss-ish dark
  static const bgTop = Color(0xFF0B1020);
  static const bgBottom = Color(0xFF0F1730);

  static const mint = Color(0xFF38E1C6);
  static const gold = Color(0xFFFFC93C);

  static const card = Color(0xFF151C33);
  static const card2 = Color(0xFF10162A);

  static const red = Color(0xFFFF5A5F);
  static const green = Color(0xFF2EE59D);

  static const text = Colors.white;
  static const subText = Color(0xFFB8C0D0);

  static const radius = 18.0;

  static LinearGradient bgGradient() => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );
}
