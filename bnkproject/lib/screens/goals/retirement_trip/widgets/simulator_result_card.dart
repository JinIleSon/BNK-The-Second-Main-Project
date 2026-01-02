import 'package:flutter/material.dart';

/// 시뮬레이션 결과 요약 카드.
///
/// 목적:
/// - PlanPage 같은 요약 화면에서 “월 적립/필요 개월/예상일”을 한 장으로 보여주기.
/// - 실제 시뮬레이터 페이지에서도 동일 카드 재사용 가능.
///
/// 원칙:
/// - 데이터는 model/service에서 만들어서 주입.
/// - 이 위젯은 표시만 담당.
class SimulatorResultCard extends StatelessWidget {
  final int monthlyContribution;
  final int monthsNeeded; // -1이면 계산 불가
  final DateTime? expectedDate;

  const SimulatorResultCard({
    super.key,
    required this.monthlyContribution,
    required this.monthsNeeded,
    required this.expectedDate,
  });

  String _fmtDate(DateTime d) => '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  String _fmtWon(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}원';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900);
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54, fontWeight: FontWeight.w600);

    final monthsText = monthsNeeded < 0 ? '계산 불가' : '${monthsNeeded}개월';
    final dateText = expectedDate == null ? '-' : _fmtDate(expectedDate!);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('적립 시뮬레이션', style: titleStyle),
          const SizedBox(height: 10),
          Text('월 적립액: ${_fmtWon(monthlyContribution)}', style: subStyle),
          const SizedBox(height: 6),
          Text('목표 달성까지: $monthsText', style: subStyle),
          const SizedBox(height: 6),
          Text('예상 달성일: $dateText', style: subStyle),
        ],
      ),
    );
  }
}
