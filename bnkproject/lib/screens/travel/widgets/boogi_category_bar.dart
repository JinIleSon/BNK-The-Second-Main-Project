import 'package:flutter/material.dart';
import '../travel_theme.dart';
import 'glass_card.dart';

class BoogiCategoryBar extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelect;

  const BoogiCategoryBar({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  // ✅ 6x4 = 24개 슬롯 예시 (필요한 것만 남기고/교체하면 됨)
  static const _cats = <_Cat>[
    _Cat('food', '맛집', Icons.restaurant),
    _Cat('cafe', '카페', Icons.coffee),
    _Cat('bakery', '베이커리', Icons.bakery_dining),
    _Cat('snack', '분식', Icons.ramen_dining),
    _Cat('market', '전통시장', Icons.storefront),
    _Cat('localmart', '동네마트', Icons.shopping_basket),

    _Cat('sight', '관광지', Icons.landscape),
    _Cat('culture', '문화', Icons.museum),
    _Cat('exhibit', '전시', Icons.image),
    _Cat('festival', '축제', Icons.celebration),
    _Cat('experience', '체험', Icons.handyman),
    _Cat('craft', '공방', Icons.brush),

    _Cat('life', '생활', Icons.home_repair_service),
    _Cat('beauty', '미용', Icons.content_cut),
    _Cat('laundry', '세탁/수선', Icons.local_laundry_service),
    _Cat('pet', '반려동물', Icons.pets),
    _Cat('flower', '꽃집', Icons.local_florist),
    _Cat('book', '서점', Icons.menu_book),

    // ✅ BNK 콜라보 축(여기서 스토리 만들면 됨)
    _Cat('dongbaek', '동백전', Icons.card_membership),
    _Cat('bnk_partner', 'BNK제휴', Icons.handshake),
    _Cat('good_shop', '착한가게', Icons.volunteer_activism),
    _Cat('edu', '학원', Icons.school),
    _Cat('sports', '헬스', Icons.fitness_center),
    _Cat('etc', '기타', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 주변 기준 미션 가능한 곳',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          // ✅ 6x4 그리드
          GridView.count(
            primary: false,                 // ✅ 자동 safe-area padding/primary 스크롤 끔
            padding: EdgeInsets.zero,        // ✅ 위쪽 여백 제거
            crossAxisCount: 6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.78,
            children: [
              for (final c in _cats)
                _CategoryItem(
                  label: c.label,
                  icon: c.icon,
                  active: selectedId == c.id,
                  onTap: () => onSelect(c.id),
                  compact: true,
                ),
            ],
          )

        ],
      ),
    );
  }
}

class _Cat {
  final String id;
  final String label;
  final IconData icon;
  const _Cat(this.id, this.label, this.icon);
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  // ✅ 6열 대응: 컴팩트 모드
  final bool compact;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final circleBg = active ? TravelTheme.boogiMint.withOpacity(0.22) : Colors.white.withOpacity(0.06);
    final circleBorder = active ? TravelTheme.boogiMint.withOpacity(0.55) : Colors.white.withOpacity(0.12);
    final textColor = active ? Colors.white : Colors.white.withOpacity(0.80);

    final double iconBox = compact ? 38 : 46;
    final double iconSize = compact ? 18 : 22;
    final double fontSize = compact ? 10 : 12;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: Border.all(color: circleBorder),
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.white.withOpacity(0.85),
                size: iconSize,
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
