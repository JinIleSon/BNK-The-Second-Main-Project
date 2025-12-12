// lib/models/EtfOrder.dart

/*
  날짜 : 2025.12.11.
  이름 : 강민철
  내용 : ETF 매수/매도 주문을 위한 model
 */

import 'Pcontract.dart';
import 'Etf.dart';
import 'EtfQuote.dart';

class EtfOrder {
  final String code;                 // 종목 코드
  final String stockName;            // 화면에 보여줄 이름 (name 또는 code)
  final String? pcuid;               // 로그인 사용자 id
  final List<Pcontract> accountList; // IRP 계좌 리스트 (보통 1개)
  final Etf? stock;                  // 이미 보유 중인 ETF 정보 (없으면 null)
  final EtfQuote? etfSnap;           // 랭킹 캐시 스냅샷 (없을 수도 있음)

  EtfOrder({
    required this.code,
    required this.stockName,
    this.pcuid,
    required this.accountList,
    this.stock,
    this.etfSnap,
  });

  factory EtfOrder.fromJson(Map<String, dynamic> json) {
    final accountJson = (json['accountList'] as List<dynamic>? ?? const []);
    return EtfOrder(
      code: json['code']?.toString() ?? '',
      stockName: json['stockName']?.toString() ?? '',
      pcuid: json['pcuid']?.toString(),
      accountList: accountJson
          .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
          .toList(),
      stock: json['stock'] != null
          ? Etf.fromJson(json['stock'] as Map<String, dynamic>)
          : null,
      etfSnap: json['etfSnap'] != null
          ? EtfQuote.fromJson(json['etfSnap'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'stockName': stockName,
      'pcuid': pcuid,
      'accountList': accountList.map((e) => e.toJson()).toList(),
      'stock': stock?.toJson(),
      'etfSnap': etfSnap?.toJson(),
    };
  }
}
