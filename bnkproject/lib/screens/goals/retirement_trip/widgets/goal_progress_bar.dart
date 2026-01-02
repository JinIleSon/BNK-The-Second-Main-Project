import 'package:flutter/material.dart';

/// 목표 달성률 ProgressBar 위젯.
///
/// 목적:
/// - goal 진행률 표시 UI를 재사용 가능한 컴포넌트로 분리.
/// - 페이지에서는 숫자(0~1)만 넘기고, 표현은 여기서 통일.
///
/// 원칙:
/// - 계산(달성률 산정)은 model/service에서 끝내고,
/// - 이 위젯은 “표시”에만 집중한다.
class GoalProgressBar extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final String leftLabel;
  final String rightLabel;

  const GoalProgressBar({
    super.key,
    required this.progress,
    required this.leftLabel,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress < 0 ? 0.0 : (progress > 1 ? 1.0 : progress);
    final percent = (p * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                leftLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: p,
            minHeight: 10,
            backgroundColor: Colors.white12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                rightLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
