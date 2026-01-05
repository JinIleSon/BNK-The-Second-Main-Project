// screens/daily_mission/widgets/quick_card.dart
import 'package:flutter/material.dart';
import 'glass_card.dart';

class QuickCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final String desc;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  const QuickCard({
    super.key,
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.desc,
    required this.buttonText,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ 핵심: 내용만큼만 높이
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                badgeText,
                style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12), // ✅ Spacer 대신 고정 여백
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: buttonColor.withOpacity(0.35)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.lerp(Colors.white, buttonColor, 0.35),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
