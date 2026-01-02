  // lib/api/chart_api.dart
//
// BNK First - /api/chart/{code}?interval=... 엔드포인트를 호출해서
// Candle 리스트를 가져오는 Flutter 클라이언트

import 'dart:convert';
import 'package:http/http.dart' as http;

// 상대 경로 import (패키지명 모를 때 제일 안전)
import '../models/candle.dart';

class ChartApiClient {
  /// 예: 'http://10.0.2.2:8080/BNK' 또는 'http://3.39.247.70:8080/BNK'
  final String baseUrl;
  final http.Client _client;

  ChartApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 특정 종목(code)의 차트 데이터를 가져오는 메서드
  ///
  /// [code] 예: "005930"
  /// [interval] 예: "1m", "5m" 등 (백엔드에서 지원하는 값)
  ///
  /// 날짜 : 2025.12.11.
  /// 이름 : 강민철
  /// 내용 : 키움 차트 불러오기 API
  ///
  /// GET {baseUrl}/api/chart/{code}?interval={interval}
  Future<List<Candle>> fetchCandles({
    required String code,
    String interval = '1m',
  }) async {
    final uri = Uri.parse('$baseUrl/api/chart/$code').replace(
      queryParameters: {
        'interval': interval,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        '캔들 데이터 조회 실패: '
            '${response.statusCode} ${response.body}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(response.body);

    return jsonList
        .map((e) => Candle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
