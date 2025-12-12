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
}
