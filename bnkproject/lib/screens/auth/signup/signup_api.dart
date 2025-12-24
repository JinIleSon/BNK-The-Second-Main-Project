// lib/screens/auth/signup/signup_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupApi {
  final String baseUrl;
  SignupApi(this.baseUrl);

  Future<void> sendVerification({
    required String channel, // "sms" | "email"
    required String target,
  }) async {
    final uri = Uri.parse('$baseUrl/api/verification/send');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'channel': channel, 'target': target}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('sendVerification failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> verifyCode({
    required String channel, // "sms" | "email"
    required String target,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/api/verification/verify');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'channel': channel, 'target': target, 'code': code}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('verifyCode failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> signupPersonal(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/signup/personal');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('signupPersonal failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> signupCompany(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/signup/company');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('signupCompany failed: ${res.statusCode} ${res.body}');
    }
  }
}
