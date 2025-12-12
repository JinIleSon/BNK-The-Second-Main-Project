/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : Mypage 이체/해지 요청 model
 */
// lib/models/MypageTransfer.dart

class TransferRequestModel {
  final int dbalance;
  final String dwho;
  final String myAcc;
  final String yourAcc;

  TransferRequestModel({
    required this.dbalance,
    required this.dwho,
    required this.myAcc,
    required this.yourAcc,
  });

  Map<String, dynamic> toJson() {
    return {
      'dbalance': dbalance,
      'dwho': dwho,
      'myAcc': myAcc,
      'yourAcc': yourAcc,
    };
  }
}

class ProdCancelRequestModel {
  final String pacc;
  final int pbalance;
  final String recvAcc;
  final String pcpid;

  ProdCancelRequestModel({
    required this.pacc,
    required this.pbalance,
    required this.recvAcc,
    required this.pcpid,
  });

  Map<String, dynamic> toJson() {
    return {
      'pacc': pacc,
      'pbalance': pbalance,
      'recvAcc': recvAcc,
      'pcpid': pcpid,
    };
  }
}
