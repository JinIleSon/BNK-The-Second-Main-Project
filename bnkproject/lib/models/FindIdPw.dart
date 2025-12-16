// lib/models/FindIdPw.dart
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : 아이디/비밀번호 찾기 결과 model
 */

class FindIdResult {
  final bool ok;
  final String? mid;
  final String? message;

  FindIdResult({
    required this.ok,
    this.mid,
    this.message,
  });

  factory FindIdResult.fromJson(Map<String, dynamic> json) {
    return FindIdResult(
      ok: json['ok'] == true,
      mid: json['mid']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class FindPwResult {
  final bool ok;
  final String? tempPw;
  final String? message;

  FindPwResult({
    required this.ok,
    this.tempPw,
    this.message,
  });

  factory FindPwResult.fromJson(Map<String, dynamic> json) {
    return FindPwResult(
      ok: json['ok'] == true,
      tempPw: json['tempPw']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
