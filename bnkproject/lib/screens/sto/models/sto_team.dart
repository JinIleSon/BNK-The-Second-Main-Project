import 'sto_price_point.dart';

class StoTeam {
  final String id;
  final String name;
  final String logoAsset; // optional
  final int price;
  final double changePct; // vs prev week
  final List<StoPricePoint> history;

  const StoTeam({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.price,
    required this.changePct,
    required this.history,
  });

  StoTeam copyWith({
    int? price,
    double? changePct,
    List<StoPricePoint>? history,
  }) {
    return StoTeam(
      id: id,
      name: name,
      logoAsset: logoAsset,
      price: price ?? this.price,
      changePct: changePct ?? this.changePct,
      history: history ?? this.history,
    );
  }
}
