// lib/models/SessionInfo.dart
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : 세션 정보 model
 */

class SessionInfo {
  final int remainSeconds;

  SessionInfo({required this.remainSeconds});

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      remainSeconds: _toInt(json['remainSeconds']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remainSeconds': remainSeconds,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
