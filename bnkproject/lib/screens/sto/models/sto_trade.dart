enum StoTradeSide { buy, sell }

class StoTrade {
  final String id;
  final String teamId;
  final StoTradeSide side;
  final int qty;
  final int price;
  final int week;
  final DateTime at;

  const StoTrade({
    required this.id,
    required this.teamId,
    required this.side,
    required this.qty,
    required this.price,
    required this.week,
    required this.at,
  });
}
