import 'package:flutter/material.dart';
import '../models/sto_team.dart';
import '../sto_theme.dart';
import '../utils/sto_format.dart';

class StoTradeSheet extends StatefulWidget {
  const StoTradeSheet({
    super.key,
    required this.team,
    required this.mode, // 'buy' | 'sell'
    required this.maxQty,
  });

  final StoTeam team;
  final String mode;
  final int maxQty;

  @override
  State<StoTradeSheet> createState() => _StoTradeSheetState();
}

class _StoTradeSheetState extends State<StoTradeSheet> {
  int qty = 1;

  @override
  void initState() {
    super.initState();
    qty = widget.maxQty <= 0 ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.mode == 'buy';
    final canTrade = isBuy ? qty > 0 : (qty > 0 && qty <= widget.maxQty);
    final total = widget.team.price * qty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StoTheme.bgTop,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isBuy ? '매수' : '매도',
                  style: TextStyle(color: isBuy ? StoTheme.mint : StoTheme.gold, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const Spacer(),
                Text(widget.team.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),

            _row('현재가', formatWon(widget.team.price)),
            const SizedBox(height: 6),
            _row('가능수량', isBuy ? '—' : '${widget.maxQty}주'),
            const SizedBox(height: 12),

            Row(
              children: [
                _stepBtn('-', () => setState(() => qty = (qty - 1).clamp(0, 9999))),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: StoTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text('$qty 주', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                _stepBtn('+', () => setState(() => qty = (qty + 1).clamp(0, 9999))),
              ],
            ),

            const SizedBox(height: 12),
            _row('예상금액', formatWon(total)),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: canTrade ? () => Navigator.pop(context, qty) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBuy ? StoTheme.mint : StoTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isBuy ? '매수 실행' : '매도 실행', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      children: [
        Text(k, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _stepBtn(String t, VoidCallback onPressed) {
    return SizedBox(
      width: 44,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }
}
