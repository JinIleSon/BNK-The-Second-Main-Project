// lib/models/EditRequest.dart
//
// 백엔드 EditRequestDTO 대응 Flutter 모델
//  - pacc: 계좌번호
//  - sellTypes: 각 상품별 매도 타입 리스트
//  - products: 각 상품의 Pcontract 정보
//  - totalAmount: 총 매도금액(입금될 금액)

/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : EditRequestDTO
 */

import 'Pcontract.dart';

class EditRequest {
  final String pacc;
  final List<String> sellTypes;
  final List<Pcontract> products;
  final int totalAmount; // Java Long ↔ Dart int

  EditRequest({
    required this.pacc,
    required this.sellTypes,
    required this.products,
    required this.totalAmount,
  });

  factory EditRequest.fromJson(Map<String, dynamic> json) {
    final sellTypeList = (json['sellTypes'] as List<dynamic>? ?? const []);
    final productList = (json['products'] as List<dynamic>? ?? const []);

    return EditRequest(
      pacc: json['pacc']?.toString() ?? '',
      sellTypes: sellTypeList.map((e) => e.toString()).toList(),
      products: productList
          .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: _toInt(json['totalAmount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pacc': pacc,
      'sellTypes': sellTypes,
      'products': products.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}

// ── helper ──────────────────────────────────────────────

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
