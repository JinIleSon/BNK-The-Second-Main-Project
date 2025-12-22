// bin/etf_api_test.dart
//
// Flutter UI(main.dart)는 건드리지 않고,
// ETF 관련 Spring API가 잘 동작하는지 단독으로 테스트하는 스크립트.
//
// 실행 방법 (프로젝트 루트에서):
//   dart run bin/etf_api_test.dart

import 'dart:io';

// ⚠ 여기 패키지명은 pubspec.yaml 의 name 을 사용해야 한다.
// 예: pubspec.yaml 에 name: bnkproject 라고 되어 있으면:
import 'package:bnkproject/api/etf_api.dart';
import 'package:bnkproject/models/EtfTrade.dart';

Future<void> main() async {
  // 이 스크립트는 에뮬레이터가 아니라 PC에서 직접 실행하니까,
  // baseUrl 은 localhost 기준으로 설정하는 게 자연스럽다.
  final api = EtfApiClient(
    baseUrl: 'http://localhost:8080/BNK', // 필요하면 /BNK 부분은 프로젝트에 맞게 수정
  );

  stdout.writeln('=== ETF API 테스트 시작 ===');

  try {
    // 1) 메인 데이터 테스트 (랭킹 + 환율)
    await _testMain(api);

    // 2) 주문 화면 데이터 테스트
    await _testOrder(api);

    // 3) (선택) 매수/매도 테스트 - 주석 해제 후 사용
    // await _testBuy(api);
    // await _testSell(api);

  } catch (e, st) {
    stderr.writeln('❌ 에러 발생: $e');
    stderr.writeln(st);
  } finally {
    api.dispose();
  }

  stdout.writeln('=== ETF API 테스트 종료 ===');
}

// ------------------------------------------------------
// 1) /api/etf/main 테스트
// ------------------------------------------------------
Future<void> _testMain(EtfApiClient api) async {
  stdout.writeln('\n[1] /api/etf/main 호출 중...');

  final mainData = await api.fetchEtfMain();

  stdout.writeln('✅ /api/etf/main 성공');
  stdout.writeln('- 환율(usdKrw): ${mainData.usdKrw}');
  stdout.writeln('- ETF 랭킹 개수: ${mainData.etfs.length}');

  if (mainData.etfs.isNotEmpty) {
    final first = mainData.etfs.first;
    stdout.writeln('- 첫 ETF: code=${first.code}, name=${first.name}, '
        'price=${first.price}, changeRate=${first.changeRate}');
  }
}

// ------------------------------------------------------
// 2) /api/etf/order 테스트
//   - 메인에서 받은 첫 ETF code/name 으로 주문 데이터 조회
// ------------------------------------------------------
Future<void> _testOrder(EtfApiClient api) async {
  stdout.writeln('\n[2] /api/etf/order 호출 중...');

  // 먼저 메인에서 하나 가져와서 그걸로 주문 데이터 조회
  final mainData = await api.fetchEtfMain();

  if (mainData.etfs.isEmpty) {
    stdout.writeln('⚠ 랭킹 ETF가 없어서 주문 테스트를 건너뜀');
    return;
  }

  final first = mainData.etfs.first;
  final code = first.code ?? '';
  final name = first.name;

  stdout.writeln('- 테스트 대상 ETF: code=$code, name=$name');

  final orderData = await api.fetchEtfOrder(
    code: code,
    name: name, // null이어도 됨
  );

  stdout.writeln('✅ /api/etf/order 성공');
  stdout.writeln('- code: ${orderData.code}');
  stdout.writeln('- stockName: ${orderData.stockName}');
  stdout.writeln('- pcuid(로그인 사용자): ${orderData.pcuid}');
  stdout.writeln('- 계좌 개수(accountList): ${orderData.accountList.length}');

  if (orderData.accountList.isNotEmpty) {
    final acc = orderData.accountList.first;
    stdout.writeln('  · 첫 계좌 pacc: ${acc.pacc}, pbalance: ${acc.pbalance}');
  }

  if (orderData.stock != null) {
    stdout.writeln('- 보유 ETF 있음: '
        'pname=${orderData.stock!.pname}, psum=${orderData.stock!.psum}');
  } else {
    stdout.writeln('- 해당 종목 보유 없음(stock == null)');
  }

  if (orderData.etfSnap != null) {
    stdout.writeln('- etfSnap: rank=${orderData.etfSnap!.rank}, '
        'price=${orderData.etfSnap!.price}, premiumRate=${orderData.etfSnap!.premiumRate}');
  }
}

// ------------------------------------------------------
// 3) (옵션) /api/etf/buy 테스트
//   실제 DB에 매수 기록이 들어가니까, 필요할 때만 주석 해제해서 사용
// ------------------------------------------------------
Future<void> _testBuy(EtfApiClient api) async {
  stdout.writeln('\n[3] /api/etf/buy 호출 중...');

  // 여기 값들은 테스트 환경에 맞게 수정해서 사용해야 한다.
  final request = EtfBuy(
    pcuid: 'testUser',              // 테스트용 사용자 ID
    pstock: 1,                      // 수량 1
    pprice: 100_000,                // 단가 100,000
    psum: 100_000,                  // 총액 100,000
    pname: '테스트ETF',              // ETF 이름
    pacc: '123-456-789012',         // 테스트용 계좌번호
    code: 'TESTCODE',               // 종목코드
  );

  final result = await api.buyEtf(request);
  stdout.writeln('✅ /api/etf/buy 성공, result=${result.result}');
}

// ------------------------------------------------------
// 4) (옵션) /api/etf/sell 테스트
// ------------------------------------------------------
Future<void> _testSell(EtfApiClient api) async {
  stdout.writeln('\n[4] /api/etf/sell 호출 중...');

  final request = EtfSell(
    psum: 100_000,                  // 매도 금액
    pacc: '123-456-789012',
    pname: '테스트ETF',
    pcuid: 'testUser',
    code: 'TESTCODE',
  );

  final result = await api.sellEtf(request);
  stdout.writeln('✅ /api/etf/sell 성공, result=${result.result}');
}
