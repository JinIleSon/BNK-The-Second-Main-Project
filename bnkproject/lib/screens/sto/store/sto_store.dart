import 'package:flutter/foundation.dart';

import '../models/sto_holding.dart';
import '../models/sto_news_item.dart';
import '../models/sto_season.dart';
import '../models/sto_season_report.dart';
import '../models/sto_team.dart';
import '../models/sto_team_stat.dart';
import '../models/sto_trade.dart';
import '../repo/mock_sto_repo.dart';
import '../repo/sto_repo.dart';
import '../services/sto_price_engine.dart';

class StoStore extends ChangeNotifier {
  StoStore({
    StoRepo? repo,
    StoPriceEngine? priceEngine,
  })  : _repo = repo ?? MockStoRepo(),
        _engine = priceEngine ?? StoPriceEngine();

  final StoRepo _repo;
  final StoPriceEngine _engine;

  bool isLoading = false;

  // 시즌 기본값
  StoSeason season = const StoSeason(week: 1, maxWeeks: 12, status: StoSeasonStatus.ready);

  // 초기 자금
  final int initialCash = 200000;
  int cash = 200000;

  List<StoTeam> teams = const [];

  // 시작가 보관(팀별 시즌 수익률 계산용)
  final Map<String, int> _initialPrice = {};

  // 보유/거래
  final Map<String, StoHolding> _holdings = {};
  final List<StoTrade> trades = [];

  // 승패/순위
  final Map<String, StoTeamStat> _stats = {};

  // 뉴스 피드(더미)
  final List<StoNewsItem> news = [];

  Map<String, StoHolding> get holdings => Map.unmodifiable(_holdings);
  Map<String, StoTeamStat> get stats => Map.unmodifiable(_stats);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final loadedTeams = await _repo.fetchInitialTeams();
    teams = loadedTeams;

    _initialPrice.clear();
    _stats.clear();
    news.clear();

    for (final t in teams) {
      _initialPrice[t.id] = t.price;
      _stats[t.id] = StoTeamStat(teamId: t.id, wins: 0, losses: 0, seasonReturn: 0);
    }

    season = season.copyWith(status: StoSeasonStatus.running);

    // 첫 공지성 뉴스
    news.insert(
      0,
      StoNewsItem(
        id: 'N${DateTime.now().millisecondsSinceEpoch}',
        week: season.week,
        teamId: 'league',
        title: '시즌 개막',
        body: '12주 동안 팀 토큰을 사고팔아 총자산을 최대화하세요.',
        impact: StoNewsImpact.neutral,
        at: DateTime.now(),
      ),
    );

    isLoading = false;
    notifyListeners();
  }

  StoTeam? teamById(String id) {
    try {
      return teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  int holdingQty(String teamId) => _holdings[teamId]?.qty ?? 0;

  int totalHoldingsValue() {
    int sum = 0;
    for (final h in _holdings.values) {
      final t = teamById(h.teamId);
      if (t != null) sum += t.price * h.qty;
    }
    return sum;
  }

  int totalAssets() => cash + totalHoldingsValue();

  // -----------------------
  // 라운드 진행(주차)
  // -----------------------
  void nextWeek() {
    if (season.isEnded) return;

    final next = season.week + 1;
    teams = _engine.nextWeek(teams, next);

    // 승패 업데이트: 이번 주 등락률 기준 상위 절반 = win, 하위 절반 = loss
    final sorted = [...teams]..sort((a, b) => b.changePct.compareTo(a.changePct));
    final half = (sorted.length / 2).floor();

    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      final prevStat = _stats[t.id] ?? StoTeamStat(teamId: t.id, wins: 0, losses: 0, seasonReturn: 0);

      final isWin = i < half;
      final newWins = prevStat.wins + (isWin ? 1 : 0);
      final newLosses = prevStat.losses + (isWin ? 0 : 1);

      final init = _initialPrice[t.id] ?? t.price;
      final seasonRet = init == 0 ? 0.0 : (t.price - init) / init;

      _stats[t.id] = prevStat.copyWith(wins: newWins, losses: newLosses, seasonReturn: seasonRet);
    }

    // 더미 뉴스 생성 (상위 2 + 하위 2 + 리그요약)
    _pushWeeklyNews(sorted, next);

    final ended = next >= season.maxWeeks;
    season = season.copyWith(
      week: next,
      status: ended ? StoSeasonStatus.ended : StoSeasonStatus.running,
    );

    notifyListeners();
  }

  void _pushWeeklyNews(List<StoTeam> sorted, int week) {
    final now = DateTime.now();

    if (sorted.isEmpty) return;

    final top = sorted.take(2).toList();
    final bottom = sorted.reversed.take(2).toList();

    news.insert(
      0,
      StoNewsItem(
        id: 'N${now.microsecondsSinceEpoch}L',
        week: week,
        teamId: 'league',
        title: '리그 주간 요약',
        body: 'Week $week: 상위권 강세, 하위권 변동성 확대. 시장 심리 주의.',
        impact: StoNewsImpact.neutral,
        at: now,
      ),
    );

    for (final t in top) {
      news.insert(
        0,
        StoNewsItem(
          id: 'N${now.microsecondsSinceEpoch}${t.id}T',
          week: week,
          teamId: t.id,
          title: '${t.name} 상승 모멘텀',
          body: '호재성 루머 확산. 수급 유입으로 단기 강세.',
          impact: StoNewsImpact.bull,
          at: now,
        ),
      );
    }

    for (final t in bottom) {
      news.insert(
        0,
        StoNewsItem(
          id: 'N${now.microsecondsSinceEpoch}${t.id}B',
          week: week,
          teamId: t.id,
          title: '${t.name} 악재 이슈',
          body: '불확실성 확대. 단기 조정 가능성.',
          impact: StoNewsImpact.bear,
          at: now,
        ),
      );
    }
  }

  // -----------------------
  // 매수/매도
  // -----------------------
  bool buy({required String teamId, required int qty}) {
    if (qty <= 0) return false;
    final t = teamById(teamId);
    if (t == null) return false;

    final cost = t.price * qty;
    if (cash < cost) return false;

    final prev = _holdings[teamId];
    final prevQty = prev?.qty ?? 0;
    final prevAvg = prev?.avgPrice ?? 0;

    final newQty = prevQty + qty;
    final newAvg = prevQty == 0 ? t.price : (((prevAvg * prevQty) + (t.price * qty)) / newQty).round();

    _holdings[teamId] = StoHolding(teamId: teamId, qty: newQty, avgPrice: newAvg);
    cash -= cost;

    trades.add(
      StoTrade(
        id: 'T${DateTime.now().millisecondsSinceEpoch}',
        teamId: teamId,
        side: StoTradeSide.buy,
        qty: qty,
        price: t.price,
        week: season.week,
        at: DateTime.now(),
        avgPriceAtTrade: newAvg,
        pnl: null,
      ),
    );

    notifyListeners();
    return true;
  }

  bool sell({required String teamId, required int qty}) {
    if (qty <= 0) return false;
    final t = teamById(teamId);
    if (t == null) return false;

    final prev = _holdings[teamId];
    if (prev == null || prev.qty < qty) return false;

    final revenue = t.price * qty;
    final newQty = prev.qty - qty;

    // 리포트용 pnl 계산(보유 평단 기준)
    final avg = prev.avgPrice;
    final pnl = (t.price - avg) * qty;

    if (newQty == 0) {
      _holdings.remove(teamId);
    } else {
      _holdings[teamId] = prev.copyWith(qty: newQty);
    }

    cash += revenue;

    trades.add(
      StoTrade(
        id: 'T${DateTime.now().millisecondsSinceEpoch}',
        teamId: teamId,
        side: StoTradeSide.sell,
        qty: qty,
        price: t.price,
        week: season.week,
        at: DateTime.now(),
        avgPriceAtTrade: avg,
        pnl: pnl,
      ),
    );

    notifyListeners();
    return true;
  }

  // -----------------------
  // 시즌 리포트
  // -----------------------
  StoSeasonReport buildReport() {
    final finalAssets = totalAssets();
    final pnl = finalAssets - initialCash;
    final roi = initialCash == 0 ? 0.0 : pnl / initialCash;

    // MVP: 시즌 수익률 가장 높은 팀
    String mvpId = teams.isEmpty ? 'unknown' : teams.first.id;
    double bestRet = -999;

    for (final t in teams) {
      final init = _initialPrice[t.id] ?? t.price;
      final r = init == 0 ? 0.0 : (t.price - init) / init;
      if (r > bestRet) {
        bestRet = r;
        mvpId = t.id;
      }
    }

    // 상위 거래: pnl 기준(SELL만)
    final sells = trades.where((e) => e.side == StoTradeSide.sell && e.pnl != null).toList()
      ..sort((a, b) => (b.pnl!.abs()).compareTo(a.pnl!.abs()));

    final topTrades = sells.take(5).toList();

    return StoSeasonReport(
      initialCash: initialCash,
      finalAssets: finalAssets,
      pnl: pnl,
      roi: roi,
      mvpTeamId: mvpId,
      mvpReturn: bestRet,
      topTrades: topTrades,
    );
  }

  Future<void> reset() async {
    cash = initialCash;
    _holdings.clear();
    trades.clear();
    season = const StoSeason(week: 1, maxWeeks: 12, status: StoSeasonStatus.ready);
    teams = const [];
    _initialPrice.clear();
    _stats.clear();
    news.clear();
    notifyListeners();
    await load();
  }
}
