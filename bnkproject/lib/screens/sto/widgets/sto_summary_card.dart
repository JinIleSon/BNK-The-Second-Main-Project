import 'package:flutter/material.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../utils/sto_format.dart';

class StoSummaryCard extends StatelessWidget {
  const StoSummaryCard({super.key, required this.store});

  final StoStore store;

  @override
  Widget build(BuildContext context) {
    final total = store.totalAssets();
    final holding = store.totalHoldingsValue();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoTheme.card,
        borderRadius: BorderRadius.circular(StoTheme.radius),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('총자산', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Week ${store.season.week}/${store.season.maxWeeks}',
                  style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatWon(total),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kv('현금', formatWon(store.cash)),
              const SizedBox(width: 12),
              _kv('보유', formatWon(holding)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StoTheme.card2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
