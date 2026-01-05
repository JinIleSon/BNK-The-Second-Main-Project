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
    final rewardStyle = TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12);
    final actionTextStyle = TextStyle(
      color: Color.lerp(Colors.white, accent, 0.35),
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    Widget actionButton() {
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onAction,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.30)),
          ),
          alignment: Alignment.center,
          child: Text(
            actionText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: actionTextStyle,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 360;

          final reward = Text(
            rewardText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: rewardStyle,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35)),
              const SizedBox(height: 10),

              // ✅ 진행바 + 진행 텍스트를 같은 줄(Row)로: 모바일에서 더 안정적
              Row(
                children: [
                  Expanded(child: XpBar(progress: progress)),
                  const SizedBox(width: 12),
                  Text(
                    progressText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ✅ 좁은 폭에서는 버튼을 아래로 내려서 깨짐 방지
              if (narrow) ...[
                reward,
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: actionButton()),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: reward),
                    const SizedBox(width: 8),
                    actionButton(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
