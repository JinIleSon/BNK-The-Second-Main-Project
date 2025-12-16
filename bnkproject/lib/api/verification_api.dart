// lib/api/verification_api.dart
//
// /api/verification 관련 이메일·SMS 인증 API 클라이언트
//
// - POST /api/verification/email/send
// - POST /api/verification/email/verify
// - POST /api/verification/sms/send
// - POST /api/verification/sms/verify
//
// 사용 예:
//   final api = VerificationApiClient(baseUrl: 'http://10.0.2.2:8080/BNK');
//   final emailRes = await api.sendEmailCode('test@example.com');
//   final smsRes = await api.sendSmsCode('010-1234-5678');
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : VerificationController API (세션 쿠키 유지 버전)
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationApiClient {
  /// 예:
  ///  - 로컬: 'http://localhost:8080/BNK'
  ///  - 에뮬레이터: 'http://10.0.2.2:8080/BNK'
  ///  - EC2: 'http://3.39.247.70:8080/BNK'
  final String baseUrl;
  final http.Client _client;

  /// 서버에서 내려온 세션 쿠키 (예: "JSESSIONID=xxxx...")
  String? sessionCookie;

  VerificationApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Map<String, String> _jsonHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    // 🔥 세션 쿠키가 있으면 Cookie 헤더에 붙여서 같은 세션 유지
    if (sessionCookie != null && sessionCookie!.isNotEmpty) {
      headers['Cookie'] = sessionCookie!;
    }
    return headers;
  }

  // ---------------------------------------------------------------------------
  // 1) 이메일 인증번호 전송
  //    POST {baseUrl}/api/verification/email/send
  //    Body: { "email": "..." }
  //    Response: { "send": true/false, "error"?: "..." }
  // ---------------------------------------------------------------------------
  Future<EmailSendResult> sendEmailCode(String email) async {
    final uri = Uri.parse('$baseUrl/api/verification/email/send');

    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email}),
    );

    // 🔥 서버에서 내려온 JSESSIONID 쿠키 저장
    final setCookie = resp.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      // 예: "JSESSIONID=ABCDEF...; Path=/BNK; HttpOnly; ..."
      final parts = setCookie.split(';');
      // JSESSIONID 로 시작하는 부분을 찾음
      final jsessionPart = parts.firstWhere(
            (p) => p.trim().startsWith('JSESSIONID='),
        orElse: () => parts.first,
      );
      sessionCookie = jsessionPart.trim();
      // 이제부터 verifyEmailCode, SMS 관련 요청에서도 같은 세션 사용
    }

    try {
      final Map<String, dynamic> json = jsonDecode(resp.body);
      final send = json['send'] == true;
      final error = json['error']?.toString();
      return EmailSendResult(send: send, error: error);
    } catch (_) {
      // 응답이 JSON 형식이 아닐 때 대비
      if (resp.statusCode == 200) {
        return EmailSendResult(send: true, error: null);
      } else {
        return EmailSendResult(
          send: false,
          error: '이메일 전송 실패 (status=${resp.statusCode})',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 2) 이메일 인증번호 검증
  //    POST {baseUrl}/api/verification/email/verify
  //    Body: { "code": "..." }
  //    Response: { "matched": true/false }
  // ---------------------------------------------------------------------------
  Future<EmailVerifyResult> verifyEmailCode(String code) async {
    final uri = Uri.parse('$baseUrl/api/verification/email/verify');

    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(), // ← 여기서 Cookie: JSESSIONID=... 포함
      body: jsonEncode({'code': code}),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    final matched = json['matched'] == true;
    return EmailVerifyResult(matched: matched);
  }

  // ---------------------------------------------------------------------------
  // 3) SMS 인증번호 전송
  //    POST {baseUrl}/api/verification/sms/send
  //    Body: { "phoneNumber": "010-...." }
  //    Response (성공): { "ok": true,  "message": "인증번호 전송 완료" }
  //            (실패): { "ok": false, "message": "..." }
  // ---------------------------------------------------------------------------
  Future<SmsSendResult> sendSmsCode(String phoneNumber) async {
    final uri = Uri.parse('$baseUrl/api/verification/sms/send');

    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    final ok = json['ok'] == true;
    final message = json['message']?.toString() ?? '';
    return SmsSendResult(ok: ok, message: message);
  }

  // ---------------------------------------------------------------------------
  // 4) SMS 인증번호 검증
  //    POST {baseUrl}/api/verification/sms/verify
  //    Body: { "phoneNumber": "010-....", "code": "123456" }
  //    Response (성공):
  //      { "ok": true, "message": "인증 성공", "verificationToken": "..." }
  //            (실패):
  //      { "ok": false, "message": "..." }
  // ---------------------------------------------------------------------------
  Future<SmsVerifyResult> verifySmsCode({
    required String phoneNumber,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/api/verification/sms/verify');

    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'code': code,
      }),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    final ok = json['ok'] == true;
    final message = json['message']?.toString() ?? '';
    final verificationToken = json['verificationToken']?.toString();

    return SmsVerifyResult(
      ok: ok,
      message: message,
      verificationToken: verificationToken,
    );
  }
}

// ==================== 결과 모델들 ====================

class EmailSendResult {
  final bool send;
  final String? error;

  EmailSendResult({
    required this.send,
    this.error,
  });
}

class EmailVerifyResult {
  final bool matched;

  EmailVerifyResult({required this.matched});
}

class SmsSendResult {
  final bool ok;
  final String message;

  SmsSendResult({
    required this.ok,
    required this.message,
  });
}

class SmsVerifyResult {
  final bool ok;
  final String message;
  final String? verificationToken;

  SmsVerifyResult({
    required this.ok,
    required this.message,
    this.verificationToken,
  });
}
