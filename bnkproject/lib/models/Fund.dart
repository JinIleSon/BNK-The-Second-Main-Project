// lib/models/Fund.dart
//
// 백엔드 FundDTO 대응 Flutter 모델
/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : FundDTO
 */

class Fund {
  // 기본 펀드 정보
  final String? fid;
  final String? fname;
  final String? famc;
  final int? frlvl;
  final String? ftype;
  final double? frefpr;
  final String? fsetdt;
  final double? ftc;
  final double? fm1pr;
  final double? fm3pr;
  final double? fm6pr;
  final double? fm12pr;
  final double? facmpr;

  // mypage - 나의 투자용 필드
  final String? pacc;
  final DateTime? pnew;
  final DateTime? pend;
  final int? pbalance;

  // fund_list - 모달 페이지용 필드
  final String? basedt;
  final String? evaltype;
  final String? mgmtcomp;
  final String? grade3y;
  final String? grade5y;
  final String? relatedfund;
  final String? investregion;
  final String? past2023;
  final String? past2024;
  final String? fee1y;
  final String? fee3y;
  final String? startinfo;
  final String? salesfee;
  final String? familysize;
  final String? trustfee;
  final String? aum;
  final String? redeemfee;
  final String? chart1;
  final String? chart2;

  // 추가 필드
  final String? pname;

  const Fund({
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
    this.pacc,
    this.pnew,
    this.pend,
    this.pbalance,
    this.basedt,
    this.evaltype,
    this.mgmtcomp,
    this.grade3y,
    this.grade5y,
    this.relatedfund,
    this.investregion,
    this.past2023,
    this.past2024,
    this.fee1y,
    this.fee3y,
    this.startinfo,
    this.salesfee,
    this.familysize,
    this.trustfee,
    this.aum,
    this.redeemfee,
    this.chart1,
    this.chart2,
    this.pname,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      fid: json['fid'] as String?,
      fname: json['fname'] as String?,
      famc: json['famc'] as String?,
      frlvl: _toInt(json['frlvl']),
      ftype: json['ftype'] as String?,
      frefpr: _toDouble(json['frefpr']),
      fsetdt: json['fsetdt'] as String?,
      ftc: _toDouble(json['ftc']),
      fm1pr: _toDouble(json['fm1pr']),
      fm3pr: _toDouble(json['fm3pr']),
      fm6pr: _toDouble(json['fm6pr']),
      fm12pr: _toDouble(json['fm12pr']),
      facmpr: _toDouble(json['facmpr']),
      pacc: json['pacc'] as String?,
      pnew: _toDateTime(json['pnew']),
      pend: _toDateTime(json['pend']),
      pbalance: _toInt(json['pbalance']),
      basedt: json['basedt'] as String?,
      evaltype: json['evaltype'] as String?,
      mgmtcomp: json['mgmtcomp'] as String?,
      grade3y: json['grade3y'] as String?,
      grade5y: json['grade5y'] as String?,
      relatedfund: json['relatedfund'] as String?,
      investregion: json['investregion'] as String?,
      past2023: json['past2023'] as String?,
      past2024: json['past2024'] as String?,
      fee1y: json['fee1y'] as String?,
      fee3y: json['fee3y'] as String?,
      startinfo: json['startinfo'] as String?,
      salesfee: json['salesfee'] as String?,
      familysize: json['familysize'] as String?,
      trustfee: json['trustfee'] as String?,
      aum: json['aum'] as String?,
      redeemfee: json['redeemfee'] as String?,
      chart1: json['chart1'] as String?,
      chart2: json['chart2'] as String?,
      pname: json['pname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'pacc': pacc,
      'pnew': pnew?.toIso8601String(),
      'pend': pend?.toIso8601String(),
      'pbalance': pbalance,
      'basedt': basedt,
      'evaltype': evaltype,
      'mgmtcomp': mgmtcomp,
      'grade3y': grade3y,
      'grade5y': grade5y,
      'relatedfund': relatedfund,
      'investregion': investregion,
      'past2023': past2023,
      'past2024': past2024,
      'fee1y': fee1y,
      'fee3y': fee3y,
      'startinfo': startinfo,
      'salesfee': salesfee,
      'familysize': familysize,
      'trustfee': trustfee,
      'aum': aum,
      'redeemfee': redeemfee,
      'chart1': chart1,
      'chart2': chart2,
      'pname': pname,
    };
  }
}

// ── helper 함수들 ─────────────────────────────

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
