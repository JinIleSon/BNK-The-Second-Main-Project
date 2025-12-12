// lib/models/StockRank.dart
//
// 백엔드 StockRankDTO 대응 Flutter 모델

/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : StockRankDTO
 */

class StockRank {
  final int rank;          // now_rank
  final String code;       // stk_cd
  final String name;       // stk_nm
  final int price;         // cur_prc
  final double changeRate; // flu_rt (%)
  final int amount;        // trde_prica

  StockRank({
    required this.rank,
    required this.code,
    required this.name,
    required this.price,
    required this.changeRate,
    required this.amount,
  });

  factory StockRank.fromJson(Map<String, dynamic> json) {
    return StockRank(
      rank: _toInt(json['rank']) ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _toInt(json['price']) ?? 0,
      changeRate: _toDouble(json['changeRate']) ?? 0.0,
      amount: _toInt(json['amount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'code': code,
      'name': name,
      'price': price,
      'changeRate': changeRate,
      'amount': amount,
    };
  }
}

// 숫자 파싱 헬퍼
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
