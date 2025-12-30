import 'package:flutter/material.dart';
import '../sto_theme.dart';
import '../utils/sto_format.dart';

class StoPriceBadge extends StatelessWidget {
  const StoPriceBadge({super.key, required this.changePct});

  final double changePct;

  @override
  Widget build(BuildContext context) {
    final isUp = changePct >= 0;
    final bg = isUp ? StoTheme.green.withOpacity(0.15) : StoTheme.red.withOpacity(0.15);
    final fg = isUp ? StoTheme.green : StoTheme.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Text(
        formatSignedPercent(changePct),
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
