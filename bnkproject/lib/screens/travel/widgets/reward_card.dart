import 'package:flutter/material.dart';

class RewardCard extends StatelessWidget {
  final String badge;
  final String title;
  final Color titleColor;
  final String desc;
  final String buttonText;
  final Color accent;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.badge,
    required this.title,
    required this.titleColor,
    required this.desc,
    required this.buttonText,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.30)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Color.lerp(Colors.white, accent, 0.35), fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
