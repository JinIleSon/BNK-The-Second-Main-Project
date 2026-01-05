import 'package:flutter/material.dart';
import '../travel_theme.dart';
import '../widgets/badge_card.dart';
import '../widgets/buttons.dart';
import '../widgets/glass_card.dart';
import '../widgets/xp.dart';

class BoogiTab extends StatelessWidget {
  final void Function(String msg) onSnack;

  const BoogiTab({super.key, required this.onSnack});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('내 부기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TravelTheme.boogiMint.withOpacity(0.18),
                            border: Border.all(color: TravelTheme.boogiMint.withOpacity(0.35), width: 2),
                          ),
                        ),
                        Image.asset('assets/images/daily_mission.png', width: 70, height: 70, fit: BoxFit.contain),
                        Positioned(
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withOpacity(0.10)),
                            ),
                            child: const Text('Lv.3 상인 부기', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const XpBar(progress: 0.62),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('XP 312 / 500', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SolidButton(
                      text: '스킨 변경',
                      accent: TravelTheme.boogiMint,
                      onTap: () => onSnack('스킨 변경 연결하세요.'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GhostButton(
                      text: '배지 보기',
                      onTap: () => onSnack('배지 상세 연결하세요.'),
                    ),
                  ),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('획득 배지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: twoCol ? 2 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.75,
                children: const [
                  BadgeCard(title: '시장 상인 배지', desc: '전통시장 결제 10회'),
                  BadgeCard(title: '관광 마스터', desc: '관광 미션 5회 완료'),
                  BadgeCard(title: '금융 리더', desc: '금융상품 3개 연동'),
                  BadgeCard(title: '불꽃 부기 스킨', desc: '시즌 이벤트 보상', locked: true),
                ],
              ),
            ],
          );

          if (twoCol) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                Expanded(child: right),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(height: 16),
              right,
            ],
          );
        },
      ),
    );
  }
}
