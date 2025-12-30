import 'package:flutter/foundation.dart';

import '../models/sto_holding.dart';
import '../models/sto_season.dart';
import '../models/sto_team.dart';
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

  StoSeason season = const StoSeason(week: 1, maxWeeks: 12, status: StoSeasonStatus.ready);

  int cash = 200000; // MVP 시작 현금
  List<StoTeam> teams = const [];

  final Map<String, StoHolding> _holdings = {};
  final List<StoTrade> trades = [];

  Map<String, StoHolding> get holdings => Map.unmodifiable(_holdings);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final loadedTeams = await _repo.fetchInitialTeams();
    teams = loadedTeams;
    season = season.copyWith(status: StoSeasonStatus.running);

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

  void nextWeek() {
    if (season.isEnded) return;

    final next = season.week + 1;
    teams = _engine.nextWeek(teams, next);

    final ended = next >= season.maxWeeks;
    season = season.copyWith(
      week: next,
      status: ended ? StoSeasonStatus.ended : StoSeasonStatus.running,
    );

    notifyListeners();
  }

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

    trades.add(StoTrade(
      id: 'T${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      side: StoTradeSide.buy,
      qty: qty,
      price: t.price,
      week: season.week,
      at: DateTime.now(),
    ));

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

    if (newQty == 0) {
      _holdings.remove(teamId);
    } else {
      _holdings[teamId] = prev.copyWith(qty: newQty);
    }

    cash += revenue;

    trades.add(StoTrade(
      id: 'T${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      side: StoTradeSide.sell,
      qty: qty,
      price: t.price,
      week: season.week,
      at: DateTime.now(),
    ));

    notifyListeners();
    return true;
  }

  Future<void> reset() async {
    cash = 200000;
    _holdings.clear();
    trades.clear();
    season = const StoSeason(week: 1, maxWeeks: 12, status: StoSeasonStatus.ready);
    teams = const [];
    notifyListeners();
    await load();
  }
}
