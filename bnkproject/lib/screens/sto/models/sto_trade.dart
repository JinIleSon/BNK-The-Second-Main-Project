enum StoTradeSide { buy, sell }

class StoTrade {
  final String id;
  final String teamId;
  final StoTradeSide side;
  final int qty;
  final int price;
  final int week;
  final DateTime at;

  /// 리포트용(특히 sell)
  final int? avgPriceAtTrade;
  final int? pnl; // sell일 때 (price - avg) * qty

  const StoTrade({
    required this.id,
    required this.teamId,
    required this.side,
    required this.qty,
    required this.price,
    required this.week,
    required this.at,
    this.avgPriceAtTrade,
    this.pnl,
  });
}
