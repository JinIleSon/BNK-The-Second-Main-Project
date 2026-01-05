import 'package:flutter/material.dart';
import '../travel_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/mission_progress_card.dart';

class MissionTab extends StatelessWidget {
  final void Function(int idx) onGoTab;

  const MissionTab({super.key, required this.onGoTab});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '미션 보드',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 1;

              final cards = [
                MissionProgressCard(
                  category: '일일 미션',
                  title: '신동백전 결제 1회',
                  desc: '5,000원 이상 결제 시 XP 적립',
                  progress: 0.30,
                  progressText: '1/3 진행',
                  rewardText: '+10 XP · +50P',
                  actionText: '가맹점 찾기',
                  accent: TravelTheme.boogiMint,
                  onAction: () => onGoTab(2),
                ),
                MissionProgressCard(
                  category: '주간 챌린지',
                  title: '맛집 3곳 투어',
                  desc: '부산관광공사 인증 맛집',
                  progress: 0.66,
                  progressText: '2/3 진행',
                  rewardText: '+50 XP · +200P',
                  actionText: '코스 보기',
                  accent: TravelTheme.boogiMint,
                  onAction: () => onGoTab(2),
                ),
                MissionProgressCard(
                  category: '시즌 이벤트',
                  title: '부산불꽃축제 미션',
                  desc: '해운대/광안리 상권 소비',
                  progress: 0.00,
                  progressText: '0/5 진행',
                  rewardText: '+200 XP · +1,000P · 한정 스킨',
                  actionText: '참여하기',
                  accent: TravelTheme.boogiGold,
                  onAction: () => onGoTab(2),
                ),
              ];

              // ✅ 1열에서는 GridView 금지 (모바일 폰트/폭에서 깨짐 방지)
              if (cols == 1) {
                return Column(
                  children: [
                    cards[0],
                    const SizedBox(height: 12),
                    cards[1],
                    const SizedBox(height: 12),
                    cards[2],
                  ],
                );
              }

              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: cards,
              );
            },
          ),
        ],
      ),
    );
  }
}
