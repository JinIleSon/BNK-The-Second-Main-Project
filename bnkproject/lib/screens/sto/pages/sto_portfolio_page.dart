import 'package:flutter/material.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../utils/sto_format.dart';

class StoPortfolioPage extends StatelessWidget {
  const StoPortfolioPage({super.key, required this.store});

  final StoStore store;

  @override
  Widget build(BuildContext context) {
    final items = store.holdings.values.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        const SizedBox(height: 6),
        _card(
          title: '현금',
          value: formatWon(store.cash),
          trailing: TextButton(
            onPressed: () => store.reset(),
            child: const Text('리셋'),
          ),
        ),
        const SizedBox(height: 10),
        _card(title: '보유 평가금', value: formatWon(store.totalHoldingsValue())),
        const SizedBox(height: 10),
        _card(title: '총자산', value: formatWon(store.totalAssets())),
        const SizedBox(height: 14),

        Text('보유 종목', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),

        if (items.isEmpty)
          _empty('보유 종목이 없습니다. 시장에서 매수하세요.')
        else
          ...items.map((h) {
            final t = store.teamById(h.teamId);
            if (t == null) return const SizedBox.shrink();

            final now = t.price * h.qty;
            final cost = h.avgPrice * h.qty;
            final pnl = now - cost;
            final pct = cost == 0 ? 0.0 : pnl / cost;

            final isUp = pnl >= 0;
            final color = isUp ? StoTheme.green : StoTheme.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: StoTheme.card,
                borderRadius: BorderRadius.circular(StoTheme.radius),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('${h.qty}주 · 평단 ${formatWon(h.avgPrice)}',
                            style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatWon(now), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        '${pnl >= 0 ? '+' : ''}${formatWon(pnl)} (${formatSignedPercent(pct)})',
                        style: TextStyle(color: color, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _card({required String title, required String value, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoTheme.card,
        borderRadius: BorderRadius.circular(StoTheme.radius),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoTheme.card,
        borderRadius: BorderRadius.circular(StoTheme.radius),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Text(text, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
    );
  }
}
