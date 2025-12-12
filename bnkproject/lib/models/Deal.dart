// lib/models/Deal.dart
//
// 백엔드 DealDTO 대응 Flutter 모델

/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : DealDTO
 */

class Deal {
  /// 거래 id (DB 자동 증가)
  final int? did;

  /// 회원 id (mid)
  final String mid;

  /// 거래 후 잔액 (dbalance)
  final int dbalance;

  /// 누구에게/어떤 거래인지 (dwho)
  final String dwho;

  /// 거래 일시 (ddate, CreationTimestamp)
  final DateTime? ddate;

  Deal({
    this.did,
    required this.mid,
    required this.dbalance,
    required this.dwho,
    this.ddate,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      did: _toInt(json['did']),
      mid: json['mid']?.toString() ?? '',
      dbalance: _toInt(json['dbalance']) ?? 0,
      dwho: json['dwho']?.toString() ?? '',
      ddate: _toDateTime(json['ddate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'mid': mid,
      'dbalance': dbalance,
      'dwho': dwho,
      'ddate': ddate?.toIso8601String(),
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

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
