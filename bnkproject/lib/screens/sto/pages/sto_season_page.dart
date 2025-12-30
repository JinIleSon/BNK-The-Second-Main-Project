import 'package:flutter/material.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../widgets/sto_summary_card.dart';
import '../widgets/sto_team_tile.dart';
import '../widgets/sto_trade_sheet.dart';
import 'sto_portfolio_page.dart';
import 'sto_team_detail_page.dart';

class StoSeasonPage extends StatefulWidget {
  const StoSeasonPage({super.key});

  @override
  State<StoSeasonPage> createState() => _StoSeasonPageState();
}

class _StoSeasonPageState extends State<StoSeasonPage> {
  late final StoStore store;

  @override
  void initState() {
    super.initState();
    store = StoStore();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: StoTheme.bgGradient()),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                return Column(
                  children: [
                    _topBar(context),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StoSummaryCard(store: store),
                    ),
                    const SizedBox(height: 10),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        tabs: [
                          Tab(text: '시장'),
                          Tab(text: '포트폴리오'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: TabBarView(
                        children: [
                          _marketTab(),
                          StoPortfolioPage(store: store),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('STO 시즌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const Spacer(),
          if (store.season.isEnded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: StoTheme.gold.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: StoTheme.gold.withOpacity(0.35)),
              ),
              child: const Text('시즌 종료', style: TextStyle(color: StoTheme.gold, fontWeight: FontWeight.w900)),
            )
          else
            OutlinedButton.icon(
              onPressed: store.isLoading ? null : () => store.nextWeek(),
              icon: const Icon(Icons.skip_next),
              label: const Text('다음 주차'),
              style: OutlinedButton.styleFrom(
                foregroundColor: StoTheme.mint,
                side: BorderSide(color: StoTheme.mint.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _marketTab() {
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: store.teams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final team = store.teams[i];
        return StoTeamTile(
          team: team,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StoTeamDetailPage(store: store, teamId: team.id)),
            );
          },
          onBuy: () => _openTrade(teamId: team.id, mode: 'buy'),
          onSell: () => _openTrade(teamId: team.id, mode: 'sell'),
        );
      },
    );
  }

  Future<void> _openTrade({required String teamId, required String mode}) async {
    final team = store.teamById(teamId);
    if (team == null) return;

    final maxQty = mode == 'sell' ? store.holdingQty(teamId) : 9999;

    final qty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoTradeSheet(team: team, mode: mode, maxQty: maxQty),
    );

    if (qty == null || qty <= 0) return;

    final ok = mode == 'buy'
        ? store.buy(teamId: teamId, qty: qty)
        : store.sell(teamId: teamId, qty: qty);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '처리 완료' : '처리 실패(잔액/수량 확인)')),
    );
  }
}
