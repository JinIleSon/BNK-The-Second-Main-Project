import 'package:flutter/material.dart';
import 'xp.dart';

class MissionProgressCard extends StatelessWidget {
  final String category;
  final String title;
  final String desc;
  final double progress;
  final String progressText;
  final String rewardText;
  final String actionText;
  final Color accent;
  final VoidCallback onAction;

  const MissionProgressCard({
    super.key,
    required this.category,
    required this.title,
    required this.desc,
    required this.progress,
    required this.progressText,
    required this.rewardText,
    required this.actionText,
    required this.accent,
    required this.onAction,
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
          Text(category, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35)),
          const SizedBox(height: 10),
          XpBar(progress: progress),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(progressText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  rewardText,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.30)),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: Color.lerp(Colors.white, accent, 0.35),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
