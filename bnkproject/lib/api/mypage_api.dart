// lib/api/mypage_api.dart
//
// /api/mypage/editList, /api/mypage/editSell, /api/mypage/editBuy
// 를 호출하는 Flutter용 클라이언트.
//
// ⚠ 이 API들은 Spring에서 Principal(로그인 사용자)을 요구하므로
//    세션 쿠키(JSESSIONID)가 필요하다.
//    로그인 후 받은 쿠키 값을 [sessionCookie] 에 넣어줘야 한다.

/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : mypage 기능(edit) API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Pcontract.dart';
import '../models/EditRequest.dart';
import '../models/MypageMain.dart';
import '../models/MypageProd.dart';
import '../models/MypageTransfer.dart';

class MypageApiClient {
  /// 예:
  ///   - PC에서 dart run 테스트: 'http://localhost:8080/BNK'
  ///   - 에뮬레이터에서 앱 실행: 'http://10.0.2.2:8080/BNK'
  ///   - EC2 배포: 'http://3.39.247.70:8080/BNK'
  final String baseUrl;

  /// 세션 쿠키 (예: 'JSESSIONID=xxxx...; Path=/BNK; HttpOnly')
  /// 실제로는 'JSESSIONID=...' 한 줄만 있어도 됨.
  String? sessionCookie;

  String? token;

  final http.Client _client;

  MypageApiClient({
    required this.baseUrl,
    this.sessionCookie,
    this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

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

  void dispose() {
    _client.close();
  }

  // --------------------------------------------------
  // 1) 변경 상품 목록 조회
  //    GET {baseUrl}/api/mypage/editList
  //    Response: List<PcontractDTO>
  // --------------------------------------------------
  Future<List<Pcontract>> fetchEditList() async {
    final uri = Uri.parse('$baseUrl/api/mypage/editList');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '변경 상품 목록 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(resp.body);
    return jsonList
        .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --------------------------------------------------
  // 2) 변경 상품 매도
  //    POST {baseUrl}/api/mypage/editSell
  //    Body : EditRequestDTO(JSON)
  //    Response: true / false (Boolean)
  // --------------------------------------------------
  Future<bool> editSell(EditRequest request) async {
    final uri = Uri.parse('$baseUrl/api/mypage/editSell');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        '변경 상품 매도 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is bool) return decoded;

    // 혹시 JSON이 { "success": true } 이런 식으로 바뀌면 여기서 처리
    if (decoded is Map && decoded['success'] is bool) {
      return decoded['success'] as bool;
    }

    throw Exception('예상치 못한 응답 형식: ${resp.body}');
  }

  // --------------------------------------------------
  // 3) 변경 상품 매수
  //    POST {baseUrl}/api/mypage/editBuy
  //    Body : EditRequestDTO(JSON)
  //    Response: true / false (Boolean)
  // --------------------------------------------------
  Future<bool> editBuy(EditRequest request) async {
    final uri = Uri.parse('$baseUrl/api/mypage/editBuy');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        '변경 상품 매수 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is bool) return decoded;

    if (decoded is Map && decoded['success'] is bool) {
      return decoded['success'] as bool;
    }

    throw Exception('예상치 못한 응답 형식: ${resp.body}');
  }

  // ---------------------------------------------
  // 1) 마이페이지 메인 데이터
  // GET {baseUrl}/api/mypage/main
  // ---------------------------------------------
  Future<MypageMain> fetchMypageMain() async {
    final uri = Uri.parse('$baseUrl/api/mypage/main');
    final resp = await _client.get(uri, headers: _jsonHeaders());
    // 디버그 로그
    print('[MYPAGE][REQ] cookie=$sessionCookie');
    print('[MYPAGE][REQ] token=${token != null ? "YES" : "NO"}');

    if (resp.statusCode != 200) {
      throw Exception(
        '마이페이지 메인 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return MypageMain.fromJson(json);
  }

  // ---------------------------------------------
  // 2) 마이페이지 상품 요약
  // GET {baseUrl}/api/mypage/prod
  // ---------------------------------------------
  Future<MypageProd> fetchMypageProd() async {
    final uri = Uri.parse('$baseUrl/api/mypage/prod');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '마이페이지 상품 요약 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return MypageProd.fromJson(json);
  }

  // ---------------------------------------------
  // 3) 계좌이체
  // POST {baseUrl}/api/mypage/transfer
  // ---------------------------------------------
  Future<bool> transfer(TransferRequestModel request) async {
    final uri = Uri.parse('$baseUrl/api/mypage/transfer');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        '계좌이체 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is bool) return decoded;
    if (decoded is Map && decoded['success'] is bool) {
      return decoded['success'] as bool;
    }
    throw Exception('예상치 못한 응답 형식: ${resp.body}');
  }

  // ---------------------------------------------
  // 4) 해지 대상 상품 목록
  // GET {baseUrl}/api/mypage/prodCancel
  // ---------------------------------------------
  Future<List<Pcontract>> fetchProdCancelList() async {
    final uri = Uri.parse('$baseUrl/api/mypage/prodCancel');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '해지 대상 상품 목록 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(resp.body);
    return jsonList
        .map((e) => Pcontract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------
  // 5) 상품 해지 처리
  // POST {baseUrl}/api/mypage/prodCancel
  // ---------------------------------------------
  Future<bool> prodCancel(ProdCancelRequestModel request) async {
    final uri = Uri.parse('$baseUrl/api/mypage/prodCancel');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        '상품 해지 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is bool) return decoded;
    if (decoded is Map && decoded['success'] is bool) {
      return decoded['success'] as bool;
    }
    throw Exception('예상치 못한 응답 형식: ${resp.body}');
  }
}
