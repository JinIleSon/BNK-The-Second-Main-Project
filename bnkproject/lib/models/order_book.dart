/*
  날짜 : 2025.12.22.
  이름 : 강민철
  내용 : UI에 바로 쓰기 좋은 가공 모델 (호가 10레벨 + 총잔량 + 현재가/등락률)
 */

class OrderBookLevel {
  final int level; // 1..10
  final int? bidPrice;
  final int? bidQty;
  final int? askPrice;
  final int? askQty;

  const OrderBookLevel({
    required this.level,
    this.bidPrice,
    this.bidQty,
    this.askPrice,
    this.askQty,
  });
}

class OrderBookSnapshot {
  final List<OrderBookLevel> levels; // length 10
  final int? totalBidQty; // fid 125
  final int? totalAskQty; // fid 121
  final int? currentPrice; // 6102 or 23 fallback
  final double? changeRate; // 6112 or 201 fallback (%)
  final String sourceType; // "0D" or "0A" or "MERGED"

  const OrderBookSnapshot({
    required this.levels,
    required this.sourceType,
    this.totalBidQty,
    this.totalAskQty,
    this.currentPrice,
    this.changeRate,
  });
}
