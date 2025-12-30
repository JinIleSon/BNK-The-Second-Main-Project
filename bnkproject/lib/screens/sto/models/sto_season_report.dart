import 'sto_trade.dart';

class StoSeasonReport {
  final int initialCash;
  final int finalAssets;
  final int pnl; // final - initial
  final double roi; // pnl / initial
  final String mvpTeamId;
  final double mvpReturn; // 시즌 수익률
  final List<StoTrade> topTrades; // pnl 큰 순

  const StoSeasonReport({
    required this.initialCash,
    required this.finalAssets,
    required this.pnl,
    required this.roi,
    required this.mvpTeamId,
    required this.mvpReturn,
    required this.topTrades,
  });
}
