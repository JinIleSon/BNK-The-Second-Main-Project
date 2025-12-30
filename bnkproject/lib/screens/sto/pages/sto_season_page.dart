// pages/sto_season_page.dart
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

  int _tabIndex = 0; // 0: 시장, 1: 순위, 2: 뉴스, 3: 포트폴리오

  // ✅ 요청 경로 고정
  static const String _boogiAsset = 'images/sto/boogi_baseball.png';

  // ✅ 하단 Dock의 "기본" 디자인 높이(버튼/탭 영역). 기기별 bottom inset은 runtime에 더한다.
  static const double _dockBaseHeight = 140.0;

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

  void _goTab(int idx) => setState(() => _tabIndex = idx);

  double _dockHeight(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom; // gesture/nav bar safe area
    return _dockBaseHeight + bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = _dockHeight(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
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

                  // ✅ 상단은 짧게: 요약 카드만 고정
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StoSummaryCard(store: store),
                  ),
                  const SizedBox(height: 10),

                  // ✅ 본문 (탭별 화면)
                  Expanded(
                    child: IndexedStack(
                      index: _tabIndex,
                      children: [
                        _marketTab(bottomPad: bottomPad),
                        _rankTab(bottomPad: bottomPad),
                        _newsTab(bottomPad: bottomPad),
                        Padding(
                          padding: EdgeInsets.only(bottom: bottomPad),
                          child: StoPortfolioPage(store: store),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      // ✅ 엄지 전용: 하단 고정(액션 + 탭)
      bottomNavigationBar: _bottomDock(context),
    );
  }

  // ------------------ 상단(짧게) ------------------
  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.20)),
                color: Colors.white.withOpacity(0.06),
              ),
              child: Image.asset(
                _boogiAsset,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_baseball, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STO 시즌투자',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  store.season.isEnded
                      ? '시즌 종료 · 결과 리포트 확인'
                      : 'Week ${store.season.week} · 모의투자(교육용 데모)',
                  style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ 하단(엄지 전용) ------------------
  Widget _bottomDock(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final height = _dockHeight(context);

    // ✅ SafeArea를 여기서 또 씌우면 padding이 이중으로 먹어서 "과여백" 난다. (정리 끝)
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.10))),
      ),
      child: Column(
        children: [
          // ✅ 액션바: 엄지가 가장 쉽게 누르는 영역 (큰 버튼 2개)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: store.isLoading
                        ? null
                        : (store.season.isEnded ? () => _showEndReport(context) : () => store.nextWeek()),
                    icon: Icon(store.season.isEnded ? Icons.assessment : Icons.skip_next),
                    label: Text(store.season.isEnded ? '결과 보기' : '다음 주차'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: store.season.isEnded ? StoTheme.gold : StoTheme.mint,
                      side: BorderSide(
                        color: (store.season.isEnded ? StoTheme.gold : StoTheme.mint).withOpacity(0.55),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: store.isLoading ? null : () => _openQuickTrade(context),
                    icon: const Icon(Icons.swap_vert),
                    label: const Text('빠른 거래'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoTheme.card,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(color: Colors.white.withOpacity(0.10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ 탭바: 엄지 영역 고정 (큰 터치 타깃)
          Container(
            height: 56,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: StoTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                _ThumbTab(
                  active: _tabIndex == 0,
                  icon: Icons.show_chart,
                  label: '시장',
                  onTap: () => _goTab(0),
                ),
                _ThumbTab(
                  active: _tabIndex == 1,
                  icon: Icons.emoji_events,
                  label: '순위',
                  onTap: () => _goTab(1),
                ),
                _ThumbTab(
                  active: _tabIndex == 2,
                  icon: Icons.feed,
                  label: '뉴스',
                  onTap: () => _goTab(2),
                ),
                _ThumbTab(
                  active: _tabIndex == 3,
                  icon: Icons.account_balance_wallet,
                  label: '포트폴리오',
                  onTap: () => _goTab(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ 시장 ------------------
  Widget _marketTab({required double bottomPad}) {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 16),
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
  Widget _rankTab({required double bottomPad}) {
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

    rows.sort((a, b) {
      final w = b.wins.compareTo(a.wins);
      if (w != 0) return w;
      return b.seasonReturn.compareTo(a.seasonReturn);
    });

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 16),
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
            child: Text(
              '$rank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
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
          Expanded(child: Text(row.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
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
  Widget _newsTab({required double bottomPad}) {
    if (store.isLoading) return const Center(child: CircularProgressIndicator());

    final items = store.news;
    if (items.isEmpty) {
      return Center(child: Text('뉴스 없음', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)));
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _newsCard(context, items[i]),
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
                  Text('$titlePrefix · Week ${n.week}',
                      style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    n.body,
                    style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ 빠른 거래(엄지 전용) ------------------
  Future<void> _openQuickTrade(BuildContext context) async {
    if (store.isLoading) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (ctx, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: StoTheme.bgTop,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('빠른 거래', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text('Week ${store.season.week}',
                            style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: store.teams.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final t = store.teams[i];
                        final holding = store.holdingQty(t.id);
                        final canSell = holding > 0;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: StoTheme.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  color: Colors.white.withOpacity(0.06),
                                  child: Image.asset(
                                    t.logoAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.sports_baseball, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text('보유 $holding주',
                                        style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Future.microtask(() => _openTrade(teamId: t.id, mode: 'buy'));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: StoTheme.mint,
                                    side: BorderSide(color: StoTheme.mint.withOpacity(0.55)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  child: const Text('매수'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: canSell
                                      ? () {
                                    Navigator.pop(ctx);
                                    Future.microtask(() => _openTrade(teamId: t.id, mode: 'sell'));
                                  }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: StoTheme.red,
                                    side: BorderSide(color: StoTheme.red.withOpacity(0.55)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  child: const Text('매도'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  const Text('MVP 팀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${mvp?.name ?? report.mvpTeamId} · ${formatSignedPercent(report.mvpReturn)}'),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  const Text('상위 거래(SELL)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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

class _ThumbTab extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ThumbTab({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? StoTheme.mint.withOpacity(0.18) : Colors.transparent;
    final fg = active ? StoTheme.mint : StoTheme.subText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? StoTheme.mint.withOpacity(0.25) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
