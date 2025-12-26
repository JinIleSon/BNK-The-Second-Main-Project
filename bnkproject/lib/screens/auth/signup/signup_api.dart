// lib/screens/auth/signup/signup_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleResult {
  final bool ok;
  final String message;

  SimpleResult({required this.ok, required this.message});

  factory SimpleResult.fromJson(Map<String, dynamic> json) {
    return SimpleResult(
      ok: json['ok'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class SmsSendResult {
  final bool ok;
  final String message;

  SmsSendResult({required this.ok, required this.message});

  factory SmsSendResult.fromJson(Map<String, dynamic> json) {
    return SmsSendResult(
      ok: json['ok'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class SmsVerifyResult {
  final bool ok;
  final String message;
  final String? verificationToken;

  SmsVerifyResult({required this.ok, required this.message, this.verificationToken});

  factory SmsVerifyResult.fromJson(Map<String, dynamic> json) {
    return SmsVerifyResult(
      ok: json['ok'] == true,
      message: (json['message'] ?? '').toString(),
      verificationToken: json['verificationToken']?.toString(),
    );
  }
}

class SignupApi {
  final String baseUrl;
  SignupApi(this.baseUrl);

  // ✅ SMS 발송: POST /api/verification/sms/send
  Future<SmsSendResult> sendSmsCode(String phoneNumber) async {
    final uri = Uri.parse('$baseUrl/api/verification/sms/send');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return SmsSendResult.fromJson(json);
  }

  // ✅ SMS 검증: POST /api/verification/sms/verify
  Future<SmsVerifyResult> verifySmsCode({
    required String phoneNumber,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/api/verification/sms/verify');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'code': code}),
    );

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return SmsVerifyResult.fromJson(json);
  }

  // ✅ 개인 회원가입: POST /api/member/signup/personal
  Future<SimpleResult> signupPersonal({
    required String mid,
    required String mpw,
    required String mname,
    required String mphone,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/signup/personal');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'mid': mid,
        'mpw': mpw,
        'mname': mname,
        'mphone': mphone,
      }),
    );

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return SimpleResult.fromJson(json);
  }
}
