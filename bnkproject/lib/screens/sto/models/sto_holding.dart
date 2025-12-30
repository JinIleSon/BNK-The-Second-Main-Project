class StoHolding {
  final String teamId;
  final int qty;
  final int avgPrice;

  const StoHolding({
    required this.teamId,
    required this.qty,
    required this.avgPrice,
  });

  StoHolding copyWith({int? qty, int? avgPrice}) {
    return StoHolding(
      teamId: teamId,
      qty: qty ?? this.qty,
      avgPrice: avgPrice ?? this.avgPrice,
    );
  }
}
