// bin/chart_api_test.dart
//
// Flutter UI는 전혀 건드리지 않고,
// ChartApiClient가 실제로 /api/chart 를 잘 호출하는지만 확인하는 스크립트.

import 'package:bnkproject/api/chart_api.dart';
import 'package:bnkproject/models/candle.dart';

Future<void> main() async {
  // ⚠️ 여기 baseUrl 은 "호스트 PC 입장"에서의 주소야.
  // Spring 서버가 같은 PC에서 돌고 있으면 localhost 사용
  final api = ChartApiClient(
    baseUrl: 'http://localhost:8080/BNK', // 예: context-path 가 /BNK 일 때
  );

  try {
    final List<Candle> candles = await api.fetchCandles(
      code: '005930',   // 테스트 종목 코드
      interval: '1m',   // 인터벌
    );

    print('받은 캔들 개수: ${candles.length}');
    if (candles.isNotEmpty) {
      final first = candles.first;
      print('첫 캔들: ${first.toJson()}');
      print('첫 캔들 시각(DateTime): ${first.dateTime}');
    }
  } catch (e, st) {
    print('❌ 에러 발생: $e');
    print(st);
  }
}
