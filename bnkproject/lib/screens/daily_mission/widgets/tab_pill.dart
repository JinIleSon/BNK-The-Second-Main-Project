import 'package:flutter/material.dart';
import '../travel_theme.dart';

class TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const TabPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? TravelTheme.boogiMint.withOpacity(0.15) : Colors.transparent;
    final border = active ? TravelTheme.boogiMint : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border.withOpacity(active ? 0.65 : 0)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
