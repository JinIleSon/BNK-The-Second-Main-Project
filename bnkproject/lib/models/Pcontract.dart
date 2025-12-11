// lib/models/Pcontract.dart
//
// 백엔드 PcontractDTO 대응 Flutter 모델

class Pcontract {
  // 기본 계약 정보
  final String? pcuid;
  final String? pcpid;
  final String? pccptp;
  final String? pccprd;
  final String? pcwcat;
  final String? pcwdac;
  final int? pcmdps;
  final int? pcgamn;
  final String? pcatapp;
  final int? pcatdt;
  final String? pcatac;
  final String? pccns;
  final String? pcntcs;
  final String? pcnapw;
  final String? pacc;
  final DateTime? pnew;
  final DateTime? pend;
  final int? pbalance;

  // 추가 컬럼 - 손진일
  final String? pname;
  final String? ptype;
  final double? phirate;
  final double? pbirate;

  // 추가 컬럼 - 손진일 (회원 정보)
  final String? mname;
  final String? mphone;
  final String? pwtpi;

  // 추가 컬럼 - 강민철
  final double? pcwtpi;
  final String? type;

  // 추가 컬럼 - 펀드 계좌용
  final String? fid;
  final String? fname;
  final String? famc;
  final String? frlvl;
  final String? ftype;
  final String? frefpr;
  final String? fsetdt;
  final String? ftc;
  final String? fm1pr;
  final String? fm3pr;
  final String? fm6pr;
  final String? fm12pr;
  final String? facmpr;

  // 추가 컬럼 - ETF 조회용
  final int? pstock; // 보유 수량
  final int? pprice; // 매수 단가
  final int? psum;   // 평가/매수 금액
  final String? code;

  const Pcontract({
    this.pcuid,
    this.pcpid,
    this.pccptp,
    this.pccprd,
    this.pcwcat,
    this.pcwdac,
    this.pcmdps,
    this.pcgamn,
    this.pcatapp,
    this.pcatdt,
    this.pcatac,
    this.pccns,
    this.pcntcs,
    this.pcnapw,
    this.pacc,
    this.pnew,
    this.pend,
    this.pbalance,
    this.pname,
    this.ptype,
    this.phirate,
    this.pbirate,
    this.mname,
    this.mphone,
    this.pwtpi,
    this.pcwtpi,
    this.type,
    this.fid,
    this.fname,
    this.famc,
    this.frlvl,
    this.ftype,
    this.frefpr,
    this.fsetdt,
    this.ftc,
    this.fm1pr,
    this.fm3pr,
    this.fm6pr,
    this.fm12pr,
    this.facmpr,
    this.pstock,
    this.pprice,
    this.psum,
    this.code,
  });

  factory Pcontract.fromJson(Map<String, dynamic> json) {
    return Pcontract(
      pcuid: json['pcuid'] as String?,
      pcpid: json['pcpid'] as String?,
      pccptp: json['pccptp'] as String?,
      pccprd: json['pccprd'] as String?,
      pcwcat: json['pcwcat'] as String?,
      pcwdac: json['pcwdac'] as String?,
      pcmdps: _toInt(json['pcmdps']),
      pcgamn: _toInt(json['pcgamn']),
      pcatapp: json['pcatapp'] as String?,
      pcatdt: _toInt(json['pcatdt']),
      pcatac: json['pcatac'] as String?,
      pccns: json['pccns'] as String?,
      pcntcs: json['pcntcs'] as String?,
      pcnapw: json['pcnapw'] as String?,
      pacc: json['pacc'] as String?,
      pnew: _toDateTime(json['pnew']),
      pend: _toDateTime(json['pend']),
      pbalance: _toInt(json['pbalance']),
      pname: json['pname'] as String?,
      ptype: json['ptype'] as String?,
      phirate: _toDouble(json['phirate']),
      pbirate: _toDouble(json['pbirate']),
      mname: json['mname'] as String?,
      mphone: json['mphone'] as String?,
      pwtpi: json['pwtpi'] as String?,
      pcwtpi: _toDouble(json['pcwtpi']),
      type: json['type'] as String?,
      fid: json['fid'] as String?,
      fname: json['fname'] as String?,
      famc: json['famc'] as String?,
      frlvl: json['frlvl'] as String?,
      ftype: json['ftype'] as String?,
      frefpr: json['frefpr'] as String?,
      fsetdt: json['fsetdt'] as String?,
      ftc: json['ftc'] as String?,
      fm1pr: json['fm1pr'] as String?,
      fm3pr: json['fm3pr'] as String?,
      fm6pr: json['fm6pr'] as String?,
      fm12pr: json['fm12pr'] as String?,
      facmpr: json['facmpr'] as String?,
      pstock: _toInt(json['pstock']),
      pprice: _toInt(json['pprice']),
      psum: _toInt(json['psum']),
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcuid': pcuid,
      'pcpid': pcpid,
      'pccptp': pccptp,
      'pccprd': pccprd,
      'pcwcat': pcwcat,
      'pcwdac': pcwdac,
      'pcmdps': pcmdps,
      'pcgamn': pcgamn,
      'pcatapp': pcatapp,
      'pcatdt': pcatdt,
      'pcatac': pcatac,
      'pccns': pccns,
      'pcntcs': pcntcs,
      'pcnapw': pcnapw,
      'pacc': pacc,
      'pnew': pnew?.toIso8601String(),
      'pend': pend?.toIso8601String(),
      'pbalance': pbalance,
      'pname': pname,
      'ptype': ptype,
      'phirate': phirate,
      'pbirate': pbirate,
      'mname': mname,
      'mphone': mphone,
      'pwtpi': pwtpi,
      'pcwtpi': pcwtpi,
      'type': type,
      'fid': fid,
      'fname': fname,
      'famc': famc,
      'frlvl': frlvl,
      'ftype': ftype,
      'frefpr': frefpr,
      'fsetdt': fsetdt,
      'ftc': ftc,
      'fm1pr': fm1pr,
      'fm3pr': fm3pr,
      'fm6pr': fm6pr,
      'fm12pr': fm12pr,
      'facmpr': facmpr,
      'pstock': pstock,
      'pprice': pprice,
      'psum': psum,
      'code': code,
    };
  }
}

// ───────────────── helper 함수들 ─────────────────

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

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
