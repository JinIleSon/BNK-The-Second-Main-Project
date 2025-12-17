// lib/api/stock_rank_api.dart
//
// GET /api/ranks 를 호출해서 실시간 종목 랭킹(List<StockRank>)을 가져오는 클라이언트

/*
  날짜 : 2025.12.12.
  이름 : 강민철
  내용 : 키움 랭크 API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/StockRank.dart';

class StockRankApiClient {
  /// 예:
  ///   에뮬레이터: 'http://10.0.2.2:8080/BNK'
  ///   로컬에서 dart run: 'http://localhost:8080/BNK'
  ///   EC2: 'http://3.39.247.70:8080/BNK'
  final String baseUrl;
  final http.Client _client;

  StockRankApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> _jsonHeaders() => const {
    'Accept': 'application/json',
  };

  void dispose() {
    _client.close();
  }

  /// 종목 랭킹 조회
  ///
  /// GET {baseUrl}/api/ranks
  ///
  /// 백엔드 StockRankingController.getRanks() 호출:
  ///   public List<StockRankDTO> getRanks()
  Future<List<StockRank>> fetchStockRanks() async {
    final uri = Uri.parse('$baseUrl/api/ranks');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '종목 랭킹 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(resp.body);
    return jsonList
        .map((e) => StockRank.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // 국내 메인: 랭킹 + 환율
  //   GET {baseUrl}/api/stock/main?limit=100
  // ---------------------------------------------------------------------------
  Future<StockMainData> fetchDomesticMain({int limit = 100}) async {
    final uri = Uri.parse('$baseUrl/api/stock/main?limit=$limit');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '국내 메인 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    final List<dynamic> ranksJson = json['ranks'] as List<dynamic>? ?? [];
    final double usdKrw = _toDouble(json['usdKrw']) ?? 0.0;

    final ranks = ranksJson
        .map((e) => StockRank.fromJson(e as Map<String, dynamic>))
        .toList();

    return StockMainData(ranks: ranks, usdKrw: usdKrw);
  }

  // ---------------------------------------------------------------------------
  // 해외 메인: 랭킹 + 환율
  //   GET {baseUrl}/api/stock/mainAbroad?limit=100
  // ---------------------------------------------------------------------------
  Future<StockMainData> fetchAbroadMain({int limit = 100}) async {
    final uri = Uri.parse('$baseUrl/api/stock/mainAbroad?limit=$limit');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '해외 메인 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    final List<dynamic> ranksJson = json['ranks'] as List<dynamic>? ?? [];
    final double usdKrw = _toDouble(json['usdKrw']) ?? 0.0;

    final ranks = ranksJson
        .map((e) => StockRank.fromJson(e as Map<String, dynamic>))
        .toList();

    return StockMainData(ranks: ranks, usdKrw: usdKrw);
  }

  // ---------------------------------------------------------------------------
  // 국내 랭킹만 (기존 fetchStockRanks()와 역할 비슷, limit 옵션 포함 버전)
  //   GET {baseUrl}/api/stock/ranks?limit=100
  // ---------------------------------------------------------------------------
  Future<List<StockRank>> fetchDomesticRanks({int limit = 100}) async {
    final uri = Uri.parse('$baseUrl/api/stock/ranks?limit=$limit');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '국내 랭킹 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(resp.body);
    return jsonList
        .map((e) => StockRank.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // 해외 랭킹만
  //   GET {baseUrl}/api/stock/ranks/abroad?limit=100
  // ---------------------------------------------------------------------------
  Future<List<StockRank>> fetchAbroadRanks({int limit = 100}) async {
    final uri = Uri.parse('$baseUrl/api/stock/ranks/abroad?limit=$limit');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '해외 랭킹 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(resp.body);
    return jsonList
        .map((e) => StockRank.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // USD/KRW 환율만
  //   GET {baseUrl}/api/stock/usd-krw
  //   GET {baseUrl}/api/stock/usd-krw?date=YYYY-MM-DD
  // ---------------------------------------------------------------------------
  Future<double> fetchUsdKrw({DateTime? date}) async {
    String query = '';
    if (date != null) {
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      query = '?date=$y-$m-$d';
    }

    final uri = Uri.parse('$baseUrl/api/stock/usd-krw$query');
    final resp = await _client.get(uri, headers: _jsonHeaders());

    if (resp.statusCode != 200) {
      throw Exception(
        '환율 조회 실패: ${resp.statusCode} ${resp.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return _toDouble(json['usdKrw']) ?? 0.0;
  }

}

// 국내/해외 메인 화면용 응답 DTO
class StockMainData {
  final List<StockRank> ranks;
  final double usdKrw;

  StockMainData({
    required this.ranks,
    required this.usdKrw,
  });
}

// 숫자 파싱 유틸
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
