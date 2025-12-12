// lib/models/MypageMain.dart
/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : Mypage 메인 응답 model
 */

import 'Deal.dart';
import 'Pcontract.dart';
import 'Fund.dart';

class MypageMain {
  /// UsersDTO 를 그대로 JSON Map 으로 받음 (필요하면 별도 User 모델로 분리 가능)
  final Map<String, dynamic>? user;
  final List<Deal> dealList;
  final List<Fund> fundList;
  final int balance;
  final List<Pcontract> contractList;
  final List<dynamic> documentList;
  final List<Pcontract> etfList;

  MypageMain({
    required this.user,
    required this.dealList,
    required this.fundList,
    required this.balance,
    required this.contractList,
    required this.documentList,
    required this.etfList,
  });

  factory MypageMain.fromJson(Map<String, dynamic> json) {
    final dealJson = (json['dealList'] as List<dynamic>? ?? const []);
    final fundJson = (json['fundList'] as List<dynamic>? ?? const []);
    final contractJson = (json['contractList'] as List<dynamic>? ?? const []);
    final docJson = (json['documentList'] as List<dynamic>? ?? const []);
    final etfJson = (json['etfList'] as List<dynamic>? ?? const []);

    return MypageMain(
      user: json['user'] as Map<String, dynamic>?,
      dealList: dealJson
          .map((e) => Deal.fromJson(e as Map<String, dynamic>))
          .toList(),
      fundList: fundJson
          .map((e) => Fund.fromJson(e as Map<String, dynamic>))
          .toList(),
      balance: _toInt(json['balance']) ?? 0,
      contractList: contractJson
          .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
          .toList(),
      documentList: docJson, // 지금은 raw JSON 그대로
      etfList: etfJson
          .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'dealList': dealList.map((e) => e.toJson()).toList(),
      'fundList': fundList.map((e) => e.toJson()).toList(),
      'balance': balance,
      'contractList': contractList.map((e) => e.toJson()).toList(),
      'documentList': documentList,
      'etfList': etfList.map((e) => e.toJson()).toList(),
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
