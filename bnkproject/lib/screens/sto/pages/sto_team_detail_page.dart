import 'package:flutter/material.dart';
import '../models/sto_team.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../utils/sto_format.dart';
import '../widgets/sto_price_badge.dart';
import '../widgets/sto_trade_sheet.dart';

class StoTeamDetailPage extends StatelessWidget {
  const StoTeamDetailPage({super.key, required this.store, required this.teamId});

  final StoStore store;
  final String teamId;

  @override
  Widget build(BuildContext context) {
    final StoTeam? team = store.teamById(teamId);
    if (team == null) {
      return const Scaffold(body: Center(child: Text('팀 정보를 찾을 수 없음')));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: StoTheme.bgGradient()),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(team.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: StoTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('현재가', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(formatWon(team.price),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                          ],
                        ),
                      ),
                      StoPriceBadge(changePct: team.changePct),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text('가격 히스토리', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: StoTheme.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: ListView.builder(
                      itemCount: team.history.length,
                      itemBuilder: (_, i) {
                        final p = team.history[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text('Week ${p.week}', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(formatWon(p.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _tradeBtn(context, team, 'buy', '매수', StoTheme.mint)),
                    const SizedBox(width: 10),
                    Expanded(child: _tradeBtn(context, team, 'sell', '매도', StoTheme.gold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tradeBtn(BuildContext context, StoTeam team, String mode, String text, Color color) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          final maxQty = mode == 'sell' ? store.holdingQty(team.id) : 9999;
          final qty = await showModalBottomSheet<int>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => StoTradeSheet(team: team, mode: mode, maxQty: maxQty),
          );
          if (qty == null || qty <= 0) return;

          final ok = mode == 'buy' ? store.buy(teamId: team.id, qty: qty) : store.sell(teamId: team.id, qty: qty);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? '처리 완료' : '처리 실패(잔액/수량 확인)')));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
