// lib/models/EtfQuote.dart
//
// 백엔드 EtfQuoteDTO 대응 Flutter 모델

class EtfQuote {
  final int? rank;             // 화면용 순위
  final String? code;          // stk_cd
  final String? name;          // stk_nm
  final int? price;            // 현재가 (long -> int)
  final double? changeRate;    // 등락률(%)
  final double? nav;           // 순자산가치
  final double? premiumRate;   // 괴리율(%)
  final String? traceIndexName;

  const EtfQuote({
    this.rank,
    this.code,
    this.name,
    this.price,
    this.changeRate,
    this.nav,
    this.premiumRate,
    this.traceIndexName,
  });

  factory EtfQuote.fromJson(Map<String, dynamic> json) {
    return EtfQuote(
      rank: _toInt(json['rank']),
      code: json['code'] as String?,
      name: json['name'] as String?,
      price: _toInt(json['price']),
      changeRate: _toDouble(json['changeRate']),
      nav: _toDouble(json['nav']),
      premiumRate: _toDouble(json['premiumRate']),
      traceIndexName: json['traceIndexName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'code': code,
      'name': name,
      'price': price,
      'changeRate': changeRate,
      'nav': nav,
      'premiumRate': premiumRate,
      'traceIndexName': traceIndexName,
    };
  }
}

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
