import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 카테고리 탭 위젯
 */

class ChipItem {
  final String label;
  final String? iconUrl;
  const ChipItem(this.label, {this.iconUrl});
}

class CategoryTab extends StatelessWidget {
  final List<ChipItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool circleStyle;

  const CategoryTab({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.circleStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: circleStyle ? 86 : 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final it = items[i];
          final selected = i == selectedIndex;

          if (circleStyle) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: selected ? Colors.white24 : Colors.white10,
                        backgroundImage: it.iconUrl != null ? NetworkImage(it.iconUrl!) : null,
                      ),
                      if (i < 2) // 빨간 점 느낌(하드코딩)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF05060A), width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    it.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ChoiceChip(
            selected: selected,
            onSelected: (_) => onTap(i),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (it.iconUrl != null) ...[
                  CircleAvatar(radius: 10, backgroundImage: NetworkImage(it.iconUrl!)),
                  const SizedBox(width: 8),
                ] else if (i == 0) ...[
                  const Icon(Icons.grid_view_rounded, size: 16),
                  const SizedBox(width: 8),
                ],
                Text(it.label),
              ],
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            backgroundColor: Colors.white10,
            selectedColor: Colors.white12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          );
        },
      ),
    );
  }
}
