// lib/models/Etf.dart
//
// 백엔드 EtfDTO 대응 Flutter 모델

/*
  날짜 : 2025.12.11.
  이름 : 강민철
  내용 : EtfDTO
 */

class Etf {
  final String? pcuid;
  final int? pstock;
  final int? pprice;
  final int? psum;
  final String? pname;
  final String? pacc;

  const Etf({
    this.pcuid,
    this.pstock,
    this.pprice,
    this.psum,
    this.pname,
    this.pacc,
  });

  factory Etf.fromJson(Map<String, dynamic> json) {
    return Etf(
      pcuid: json['pcuid'] as String?,
      pstock: _toInt(json['pstock']),
      pprice: _toInt(json['pprice']),
      psum: _toInt(json['psum']),
      pname: json['pname'] as String?,
      pacc: json['pacc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcuid': pcuid,
      'pstock': pstock,
      'pprice': pprice,
      'psum': psum,
      'pname': pname,
      'pacc': pacc,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
