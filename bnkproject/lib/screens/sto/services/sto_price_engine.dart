import 'dart:math';
import '../models/sto_price_point.dart';
import '../models/sto_team.dart';

class StoPriceEngine {
  final Random _rng;

  StoPriceEngine({int seed = 42}) : _rng = Random(seed);

  List<StoTeam> nextWeek(List<StoTeam> teams, int nextWeek) {
    return teams.map((t) {
      final prev = t.price;

      // 최소 룰: -8% ~ +8% 변동, 가격 최소 1,000원 바닥
      final pct = (_rng.nextDouble() * 0.16) - 0.08;
      final next = (prev * (1 + pct)).round().clamp(1000, 999999999);

      final nextHistory = List<StoPricePoint>.from(t.history)
        ..add(StoPricePoint(week: nextWeek, price: next));

      return t.copyWith(
        price: next,
        changePct: prev == 0 ? 0 : (next - prev) / prev,
        history: nextHistory,
      );
    }).toList();
  }
}
