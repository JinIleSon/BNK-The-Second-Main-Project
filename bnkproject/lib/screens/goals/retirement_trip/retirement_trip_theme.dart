import 'package:flutter/material.dart';

/// TravelPage 감성 그대로 가져온 retirement_trip 전용 테마 상수.
/// - 배경: 다크 그라데이션
/// - 카드: 유리(Glass) 느낌
/// - 포인트 컬러: 민트/골드 계열
class RetirementTripTheme {
  // Background gradient
  static const Color bgTop = Color(0xFF070A16);
  static const Color bgBottom = Color(0xFF050816);

  // Accent
  static const Color mint = Color(0xFF34D399);
  static const Color gold = Color(0xFFFBBF24);
  static const Color violet = Color(0xFF818CF8);

  // Text
  static const Color subText = Color(0xFF94A3B8);
  static const Color hintText = Color(0xFFCBD5E1);

  // Borders
  static Color border(double opacity) => Colors.white.withOpacity(opacity);

  static const String heroAsset = 'assets/images/goals/family.png';
}
