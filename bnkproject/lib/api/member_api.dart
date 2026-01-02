// lib/api/member_api.dart
//
// /api/member 관련 로그인/세션/아이디·비번 찾기 API 클라이언트
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : UsersController API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Login.dart';
import '../models/UserProfile.dart';
import '../models/SessionInfo.dart';
import '../models/FindIdPw.dart';
import '../screens/auth/signup/authsession.dart';

const String baseUrl = "http://10.0.2.2:8080/BNK";

class MemberApiClient {

  final String baseUrl;
  final http.Client _client;

  /// 서버에서 내려준 JWT 토큰
  String? token;

  /// 서버 세션 쿠키 (예: 'JSESSIONID=xxxx...')
  String? sessionCookie;

  MemberApiClient({
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
    if (sessionCookie != null && sessionCookie!.isNotEmpty) {
      headers['Cookie'] = sessionCookie!;
    }
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ======================== 로그인 ========================

  Future<LoginResult> login({
    required String mid,
    required String mpw,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/login');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'mid': mid,
        'mpw': mpw,
      }),
    );

    // 로그인 확인용 로그
    print('[LOGIN][RES] status=${resp.statusCode}');
    print('[LOGIN][RES] set-cookie=${resp.headers['set-cookie']}');
    print('[LOGIN][RES] body=${resp.body}');

    // 세션 쿠키 추출 (JSESSIONID)
    final setCookie = resp.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      // 'JSESSIONID=xxx; Path=/BNK; HttpOnly; ...' 에서 앞부분만 사용
      final jsession = setCookie.split(';').firstWhere(
            (s) => s.trim().startsWith('JSESSIONID='),
        orElse: () => setCookie.split(';').first,
      );
      sessionCookie = jsession.trim();
    }

    if (resp.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(resp.body);
      final result = LoginResult.fromJson(json);
      if (result.ok && result.token != null) {
        token = result.token;

        authsession.token = result.token;

      }
      return result;
    } else {
      // 에러 응답도 JSON일 가능성이 높으므로 한 번 시도
      try {
        final Map<String, dynamic> json = jsonDecode(resp.body);
        return LoginResult(
          ok: false,
          message: json['message']?.toString() ??
              '로그인 실패 (status=${resp.statusCode})',
        );
      } catch (_) {
        return LoginResult(
          ok: false,
          message: '로그인 실패 (status=${resp.statusCode})',
        );
      }
    }
  }

  // ======================== 로그아웃 ========================

  Future<bool> logout() async {
    final uri = Uri.parse('$baseUrl/api/member/logout');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
    );

    // 클라이언트 쪽 토큰/세션 제거
    token = null;
    sessionCookie = null;

    if (resp.statusCode == 200) {
      return true;
    }
    return false;
  }

  // ======================== 내 정보 ========================

  Future<MeResult> me() async {
    final uri = Uri.parse('$baseUrl/api/member/me');
    final resp = await _client.get(
      uri,
      headers: _jsonHeaders(),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return MeResult.fromJson(json);
  }

  // ======================== 세션 남은 시간 ========================

  Future<SessionInfo> getSessionRemaining() async {
    final uri = Uri.parse('$baseUrl/api/member/session/remaining');
    final resp = await _client.get(
      uri,
      headers: _jsonHeaders(),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return SessionInfo.fromJson(json);
  }

  // ======================== 세션 연장 ========================

  Future<SessionInfo> extendSession() async {
    final uri = Uri.parse('$baseUrl/api/member/session/extend');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return SessionInfo.fromJson(json);
  }

  // ======================== 아이디 찾기 ========================

  Future<FindIdResult> findIdByPhone({
    required String name,
    required String phone,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/find-id/phone');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
      }),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return FindIdResult.fromJson(json);
  }

  Future<FindIdResult> findIdByEmail({
    required String name,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/find-id/email');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return FindIdResult.fromJson(json);
  }

  // ======================== 비밀번호 찾기(임시비번) ========================

  Future<FindPwResult> findPwByPhone({
    required String mid,
    required String phone,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/find-pw/phone');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'mid': mid,
        'phone': phone,
      }),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return FindPwResult.fromJson(json);
  }

  Future<FindPwResult> findPwByEmail({
    required String mid,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/api/member/find-pw/email');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode({
        'mid': mid,
        'email': email,
      }),
    );

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return FindPwResult.fromJson(json);
  }
}

final MemberApiClient memberApi = MemberApiClient(baseUrl: baseUrl);
