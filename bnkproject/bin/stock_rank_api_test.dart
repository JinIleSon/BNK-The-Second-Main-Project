// bin/stock_rank_api_test.dart
//
// StockRankApiClient 테스트 스크립트
//  - /api/ranks
//  - /api/stock/main
//  - /api/stock/mainAbroad
//  - /api/stock/ranks
//  - /api/stock/ranks/abroad
//  - /api/stock/usd-krw
//
// 실행 (프로젝트 루트에서):
//   dart run bin/stock_rank_api_test.dart

import 'dart:io';

// pubspec.yaml의 name 기준으로 맞춰서 변경 (예: name: bnkproject)
import 'package:bnkproject/api/stock_rank_api.dart';

Future<void> main() async {
  // --------- 환경 설정 ---------
  // 서버 주소:
  //  - 에뮬레이터: http://10.0.2.2:8080/BNK
  //  - 로컬(dart run): http://localhost:8080/BNK
  //  - EC2: http://3.39.247.70:8080/BNK
  const String baseUrl = 'http://localhost:8080/BNK';

  final api = StockRankApiClient(baseUrl: baseUrl);

  stdout.writeln('=== StockRankApiClient 테스트 시작 ===');

  try {
    await _testRealtimeRanks(api);
    await _testDomesticMain(api);
    await _testAbroadMain(api);
    await _testDomesticRanksOnly(api);
    await _testAbroadRanksOnly(api);
    await _testUsdKrw(api);
  } catch (e, st) {
    stderr.writeln('❌ 전체 테스트 중 오류 발생: $e');
    stderr.writeln(st);
  } finally {
    api.dispose();
  }

  stdout.writeln('=== StockRankApiClient 테스트 종료 ===');
}

// ---------------------------------------------------------------------------
// 1) 기존 실시간 랭킹 (/api/ranks → fetchStockRanks())
// ---------------------------------------------------------------------------
Future<void> _testRealtimeRanks(StockRankApiClient api) async {
  stdout.writeln('\n[1] /api/ranks (fetchStockRanks) 테스트');

  try {
    final ranks = await api.fetchStockRanks();
    stdout.writeln('✅ 실시간 랭킹 조회 성공');
    stdout.writeln('- 종목 수: ${ranks.length}');

    if (ranks.isNotEmpty) {
      final top = ranks.first;
      stdout.writeln(
          '- 1위: ${top.rank}위 / ${top.code} / ${top.name} / 가격=${top.price} / 등락률=${top.changeRate}');
    }
  } catch (e) {
    stdout.writeln('❌ 실시간 랭킹 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 2) 국내 메인 (/api/stock/main → fetchDomesticMain())
// ---------------------------------------------------------------------------
Future<void> _testDomesticMain(StockRankApiClient api) async {
  stdout.writeln('\n[2] /api/stock/main (fetchDomesticMain) 테스트');

  try {
    final data = await api.fetchDomesticMain(limit: 50);
    stdout.writeln('✅ 국내 메인 조회 성공');
    stdout.writeln('- 랭킹 수: ${data.ranks.length}');
    stdout.writeln('- usdKrw: ${data.usdKrw}');

    if (data.ranks.isNotEmpty) {
      final top = data.ranks.first;
      stdout.writeln(
          '- 1위: ${top.rank}위 / ${top.code} / ${top.name} / 가격=${top.price} / 등락률=${top.changeRate}');
    }
  } catch (e) {
    stdout.writeln('❌ 국내 메인 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 3) 해외 메인 (/api/stock/mainAbroad → fetchAbroadMain())
// ---------------------------------------------------------------------------
Future<void> _testAbroadMain(StockRankApiClient api) async {
  stdout.writeln('\n[3] /api/stock/mainAbroad (fetchAbroadMain) 테스트');

  try {
    final data = await api.fetchAbroadMain(limit: 50);
    stdout.writeln('✅ 해외 메인 조회 성공');
    stdout.writeln('- 랭킹 수: ${data.ranks.length}');
    stdout.writeln('- usdKrw: ${data.usdKrw}');

    if (data.ranks.isNotEmpty) {
      final top = data.ranks.first;
      stdout.writeln(
          '- 1위(해외): ${top.rank}위 / ${top.code} / ${top.name} / 가격=${top.price} / 등락률=${top.changeRate}');
    }
  } catch (e) {
    stdout.writeln('❌ 해외 메인 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 4) 국내 랭킹만 (/api/stock/ranks → fetchDomesticRanks())
// ---------------------------------------------------------------------------
Future<void> _testDomesticRanksOnly(StockRankApiClient api) async {
  stdout.writeln('\n[4] /api/stock/ranks (fetchDomesticRanks) 테스트');

  try {
    final ranks = await api.fetchDomesticRanks(limit: 30);
    stdout.writeln('✅ 국내 랭킹만 조회 성공');
    stdout.writeln('- 종목 수: ${ranks.length}');

    if (ranks.isNotEmpty) {
      final top = ranks.first;
      stdout.writeln(
          '- 1위(국내): ${top.rank}위 / ${top.code} / ${top.name} / 가격=${top.price} / 등락률=${top.changeRate}');
    }
  } catch (e) {
    stdout.writeln('❌ 국내 랭킹만 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 5) 해외 랭킹만 (/api/stock/ranks/abroad → fetchAbroadRanks())
// ---------------------------------------------------------------------------
Future<void> _testAbroadRanksOnly(StockRankApiClient api) async {
  stdout.writeln('\n[5] /api/stock/ranks/abroad (fetchAbroadRanks) 테스트');

  try {
    final ranks = await api.fetchAbroadRanks(limit: 30);
    stdout.writeln('✅ 해외 랭킹만 조회 성공');
    stdout.writeln('- 종목 수: ${ranks.length}');

    if (ranks.isNotEmpty) {
      final top = ranks.first;
      stdout.writeln(
          '- 1위(해외): ${top.rank}위 / ${top.code} / ${top.name} / 가격=${top.price} / 등락률=${top.changeRate}');
    }
  } catch (e) {
    stdout.writeln('❌ 해외 랭킹만 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 6) 환율 (/api/stock/usd-krw → fetchUsdKrw())
// ---------------------------------------------------------------------------
Future<void> _testUsdKrw(StockRankApiClient api) async {
  stdout.writeln('\n[6] /api/stock/usd-krw (fetchUsdKrw) 테스트');

  try {
    final todayFx = await api.fetchUsdKrw();
    stdout.writeln('✅ 오늘 환율 조회 성공: $todayFx');

    // 필요하면 과거 날짜도 한번 호출해보기
    final yesterday =
    DateTime.now().subtract(const Duration(days: 1));
    final yFx = await api.fetchUsdKrw(date: yesterday);
    stdout.writeln(
        '✅ 어제(${yesterday.toIso8601String().substring(0, 10)}) 환율 조회 성공: $yFx');
  } catch (e) {
    stdout.writeln('❌ 환율 조회 실패: $e');
  }
}
