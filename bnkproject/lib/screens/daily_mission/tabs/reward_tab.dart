import 'package:flutter/material.dart';
import '../travel_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/reward_card.dart';

class RewardTab extends StatelessWidget {
  final void Function(String msg) onSnack;
  final void Function(int idx) onGoTab;

  const RewardTab({
    super.key,
    required this.onSnack,
    required this.onGoTab,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('리워드 보관함', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 1 ? 2.4 : 1.2,
                children: [
                  RewardCard(
                    badge: '포인트',
                    title: '1,200P',
                    titleColor: TravelTheme.boogiGold,
                    desc: '신동백전 전환 가능',
                    buttonText: '신동백전으로 전환',
                    accent: TravelTheme.boogiGold,
                    onTap: () => onSnack('전환 로직 연결하세요.'),
                  ),
                  RewardCard(
                    badge: '금융 리워드',
                    title: '예적금 금리 +0.1%p',
                    titleColor: Colors.white,
                    desc: '30일 내 사용',
                    buttonText: '적용하기',
                    accent: TravelTheme.boogiMint,
                    onTap: () => onSnack('적용 로직 연결하세요.'),
                  ),
                  RewardCard(
                    badge: '한정 아이템',
                    title: '불꽃 부기 스킨',
                    titleColor: Colors.white,
                    desc: '시즌 한정',
                    buttonText: '장착하기',
                    accent: const Color(0xFF818CF8),
                    onTap: () => onGoTab(4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
