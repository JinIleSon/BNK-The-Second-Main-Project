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

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _CategoryItem(
              label: '맛집',
              icon: Icons.restaurant,
              active: selectedId == 'food',
              onTap: () => onSelect('food'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CategoryItem(
              label: '전통시장',
              icon: Icons.storefront,
              active: selectedId == 'market',
              onTap: () => onSelect('market'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CategoryItem(
              label: '관광지',
              icon: Icons.landscape,
              active: selectedId == 'sight',
              onTap: () => onSelect('sight'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleBg = active ? TravelTheme.boogiMint.withOpacity(0.22) : Colors.white.withOpacity(0.06);
    final circleBorder = active ? TravelTheme.boogiMint.withOpacity(0.55) : Colors.white.withOpacity(0.12);
    final textColor = active ? Colors.white : Colors.white.withOpacity(0.80);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: Border.all(color: circleBorder),
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.white.withOpacity(0.85),
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
