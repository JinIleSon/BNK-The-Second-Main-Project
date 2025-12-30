import 'package:flutter/material.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../utils/sto_format.dart';

class StoPortfolioPage extends StatelessWidget {
  const StoPortfolioPage({
    super.key,
    required this.store,
    this.extraBottomPadding = 0, // ✅ 부모가 필요하면 추가로 넣는 여백
  });

  final StoStore store;

  /// ✅ 하단 고정 UI를 Stack으로 덮는 구조인 화면에서만,
  /// 부모가 실제 하단바 높이만큼을 넘겨줘서 마지막 아이템이 가리지 않게 한다.
  /// (Scaffold bottomNavigationBar/bottomSheet로 이미 공간을 빼면 0 유지)
  final double extraBottomPadding;

  @override
  Widget build(BuildContext context) {
    final items = store.holdings.values.toList();

    // ✅ 기본 여백만 유지: 과도한 빈 공간 방지
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const baseGap = 12.0;
    final bottomPadding = safeBottom + baseGap + extraBottomPadding;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
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
                  _logo(t.logoAsset),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          '${h.qty}주 · 평단 ${formatWon(h.avgPrice)}',
                          style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700),
                        ),
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

  Widget _logo(String? assetPath) {
    const size = 34.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: (assetPath == null || assetPath.isEmpty)
            ? Icon(Icons.shield, color: StoTheme.subText, size: 18)
            : Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.shield, color: StoTheme.subText, size: 18),
        ),
      ),
    );
  }
}
