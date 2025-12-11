// lib/models/EtfTrade.dart

class EtfBuy {
  final String pcuid;
  final int pstock;
  final int pprice;
  final int psum;
  final String pname;
  final String pacc;
  final String code;

  EtfBuy({
    required this.pcuid,
    required this.pstock,
    required this.pprice,
    required this.psum,
    required this.pname,
    required this.pacc,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'pcuid': pcuid,
      'pstock': pstock,
      'pprice': pprice,
      'psum': psum,
      'pname': pname,
      'pacc': pacc,
      'code': code,
    };
  }
}

class EtfSell {
  final int psum;
  final String pacc;
  final String pname;
  final String pcuid;
  final String code;

  EtfSell({
    required this.psum,
    required this.pacc,
    required this.pname,
    required this.pcuid,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'psum': psum,
      'pacc': pacc,
      'pname': pname,
      'pcuid': pcuid,
      'code': code,
    };
  }
}

class ApiResult {
  final String result; // "buy" 또는 "sell" 등

  ApiResult({required this.result});

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      result: json['result']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
    };
  }
}
