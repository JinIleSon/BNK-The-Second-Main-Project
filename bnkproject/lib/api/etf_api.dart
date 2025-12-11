// lib/api/etf_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/EtfMain.dart';
import '../models/EtfOrder.dart';
import '../models/EtfTrade.dart';

class EtfApiClient {
  /// 예: 'http://10.0.2.2:8080/BNK' (에뮬레이터)
  ///     'http://3.39.247.70:8080/BNK' (EC2 배포 서버)
  final String baseUrl;
  final http.Client _client;

  EtfApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> _jsonHeaders() => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  void dispose() {
    _client.close();
  }

  // --------------------------------------------------
  // 1) ETF 메인 데이터
  // GET {baseUrl}/api/etf/main
  // --------------------------------------------------
  Future<EtfMain> fetchEtfMain() async {
    final uri = Uri.parse('$baseUrl/api/etf/main');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        'ETF 메인 데이터 조회 실패: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return EtfMain.fromJson(json);
  }

  // --------------------------------------------------
  // 2) ETF 주문 화면 데이터
  // GET {baseUrl}/api/etf/order?code=...&name=...
  // --------------------------------------------------
  Future<EtfOrder> fetchEtfOrder({
    required String code,
    String? name,
  }) async {
    final query = <String, String>{'code': code};
    if (name != null && name.isNotEmpty) {
      query['name'] = name;
    }

    final uri = Uri.parse('$baseUrl/api/etf/order')
        .replace(queryParameters: query);

    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        'ETF 주문 데이터 조회 실패: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return EtfOrder.fromJson(json);
  }

  // --------------------------------------------------
  // 3) ETF 매수
  // POST {baseUrl}/api/etf/buy
  // Body: EtfBuy -> JSON
  // --------------------------------------------------
  Future<ApiResult> buyEtf(EtfBuy request) async {
    final uri = Uri.parse('$baseUrl/api/etf/buy');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'ETF 매수 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return ApiResult.fromJson(json);
  }

  // --------------------------------------------------
  // 4) ETF 매도
  // POST {baseUrl}/api/etf/sell
  // Body: EtfSell -> JSON
  // --------------------------------------------------
  Future<ApiResult> sellEtf(EtfSell request) async {
    final uri = Uri.parse('$baseUrl/api/etf/sell');
    final resp = await _client.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'ETF 매도 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return ApiResult.fromJson(json);
  }
}
