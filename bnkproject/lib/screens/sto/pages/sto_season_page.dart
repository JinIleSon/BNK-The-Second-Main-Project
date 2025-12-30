import 'package:flutter/material.dart';
import '../models/sto_news_item.dart';
import '../sto_theme.dart';
import '../store/sto_store.dart';
import '../utils/sto_format.dart';
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
  bool _endReportShown = false;

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
      length: 4, // 시장/순위/뉴스/포트폴리오
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: StoTheme.bgGradient()),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                // 시즌 종료 리포트: 1회만 자동 팝업
                if (store.season.isEnded && !_endReportShown) {
                  _endReportShown = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _showEndReport(context);
                  });
                }

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
                          Tab(text: '순위'),
                          Tab(text: '뉴스'),
                          Tab(text: '포트폴리오'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: TabBarView(
                        children: [
                          _marketTab(),
                          _rankTab(),
                          _newsTab(),
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
            OutlinedButton(
              onPressed: () => _showEndReport(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: StoTheme.gold,
                side: BorderSide(color: StoTheme.gold.withOpacity(0.5)),
              ),
              child: const Text('결과 보기'),
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

  // ------------------ 시장 ------------------
  Widget _marketTab() {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());

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

  // ------------------ 순위 ------------------
  Widget _rankTab() {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());

    final rows = store.teams.map((t) {
      final st = store.stats[t.id];
      return _RankRow(
        teamId: t.id,
        name: t.name,
        logo: t.logoAsset,
        wins: st?.wins ?? 0,
        losses: st?.losses ?? 0,
        seasonReturn: st?.seasonReturn ?? 0.0,
      );
    }).toList();

    // 정렬: 승 많은 순 → 시즌수익률 높은 순
    rows.sort((a, b) {
      final w = b.wins.compareTo(a.wins);
      if (w != 0) return w;
      return b.seasonReturn.compareTo(a.seasonReturn);
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: StoTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Text('리그 테이블', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('Week ${store.season.week}', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...rows.asMap().entries.map((e) => _rankTile(context, rank: e.key + 1, row: e.value)),
      ],
    );
  }

  Widget _rankTile(BuildContext context, {required int rank, required _RankRow row}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.white.withOpacity(0.06),
              child: Image.asset(
                row.logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_baseball, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(row.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          Text('${row.wins}-${row.losses}', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w900)),
          const SizedBox(width: 10),
          _retBadge(row.seasonReturn),
        ],
      ),
    );
  }

  Widget _retBadge(double r) {
    final up = r >= 0;
    final bg = (up ? StoTheme.green : StoTheme.red).withOpacity(0.15);
    final fg = up ? StoTheme.green : StoTheme.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Text(
        formatSignedPercent(r),
        style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  // ------------------ 뉴스 ------------------
  Widget _newsTab() {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());

    final items = store.news;
    if (items.isEmpty) {
      return Center(
        child: Text('뉴스 없음', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final n = items[i];
        return _newsCard(context, n);
      },
    );
  }

  Widget _newsCard(BuildContext context, StoNewsItem n) {
    Color color;
    IconData icon;

    switch (n.impact) {
      case StoNewsImpact.bull:
        color = StoTheme.green;
        icon = Icons.trending_up;
        break;
      case StoNewsImpact.bear:
        color = StoTheme.red;
        icon = Icons.trending_down;
        break;
      default:
        color = StoTheme.subText;
        icon = Icons.feed;
        break;
    }

    final team = n.teamId == 'league' ? null : store.teamById(n.teamId);
    final titlePrefix = n.teamId == 'league' ? '리그' : (team?.name ?? '팀');

    return InkWell(
      onTap: team == null
          ? null
          : () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StoTeamDetailPage(store: store, teamId: team.id)),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StoTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$titlePrefix · Week ${n.week}', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(n.body, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ 거래 바텀시트 ------------------
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

    final ok = mode == 'buy' ? store.buy(teamId: teamId, qty: qty) : store.sell(teamId: teamId, qty: qty);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '처리 완료' : '처리 실패(잔액/수량 확인)')),
    );
  }

  // ------------------ 시즌 종료 리포트 ------------------
  void _showEndReport(BuildContext context) {
    final report = store.buildReport();
    final mvp = store.teamById(report.mvpTeamId);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: StoTheme.bgTop,
          title: const Text('시즌 결과 리포트', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: DefaultTextStyle(
              style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('초기자금', formatWon(report.initialCash)),
                  _kv('최종총자산', formatWon(report.finalAssets)),
                  _kv('총 손익', '${report.pnl >= 0 ? '+' : ''}${formatWon(report.pnl)}'),
                  _kv('수익률', formatSignedPercent(report.roi)),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  Text('MVP 팀', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${mvp?.name ?? report.mvpTeamId} · ${formatSignedPercent(report.mvpReturn)}'),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  Text('상위 거래(SELL)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  if (report.topTrades.isEmpty)
                    const Text('해당 없음')
                  else
                    ...report.topTrades.map((t) {
                      final team = store.teamById(t.teamId);
                      final pnl = t.pnl ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${team?.name ?? t.teamId} · ${t.qty}주 · 손익 ${pnl >= 0 ? '+' : ''}${formatWon(pnl)}',
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기', style: TextStyle(color: StoTheme.mint, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(k)),
          const SizedBox(width: 8),
          Expanded(child: Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _RankRow {
  final String teamId;
  final String name;
  final String logo;
  final int wins;
  final int losses;
  final double seasonReturn;

  const _RankRow({
    required this.teamId,
    required this.name,
    required this.logo,
    required this.wins,
    required this.losses,
    required this.seasonReturn,
  });
}
