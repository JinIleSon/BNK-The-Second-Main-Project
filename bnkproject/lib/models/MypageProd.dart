// lib/models/MypageProd.dart
/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : Mypage 상품 요약 응답 model
 */

import 'Deal.dart';
import 'Pcontract.dart';

class MypageProd {
  final int plus;   // 입금 합계
  final int minus;  // 출금 합계
  final List<Deal> dealList;
  final List<Pcontract> contractList;
  final int balance;

  MypageProd({
    required this.plus,
    required this.minus,
    required this.dealList,
    required this.contractList,
    required this.balance,
  });

  factory MypageProd.fromJson(Map<String, dynamic> json) {
    final dealJson = (json['dealList'] as List<dynamic>? ?? const []);
    final contractJson = (json['contractList'] as List<dynamic>? ?? const []);

    return MypageProd(
      plus: _toInt(json['plus']) ?? 0,
      minus: _toInt(json['minus']) ?? 0,
      dealList: dealJson
          .map((e) => Deal.fromJson(e as Map<String, dynamic>))
          .toList(),
      contractList: contractJson
          .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
          .toList(),
      balance: _toInt(json['balance']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plus': plus,
      'minus': minus,
      'dealList': dealList.map((e) => e.toJson()).toList(),
      'contractList': contractList.map((e) => e.toJson()).toList(),
      'balance': balance,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
