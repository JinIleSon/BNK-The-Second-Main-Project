// bin/mypage_api_test.dart
//
// Mypage 관련 Spring API가 잘 동작하는지 확인하는 테스트 스크립트.
//  - /api/mypage/main
//  - /api/mypage/prod
//  - /api/mypage/editList
//  - /api/mypage/prodCancel (GET)
//
// ⚠ 이 API들은 Principal(로그인 사용자)을 사용하므로
//    세션 쿠키(JSESSIONID)가 필요하다. 브라우저에서 로그인 후
//    개발자 도구 → Network → 쿠키에서 JSESSIONID를 가져와
//    아래 [sessionCookie]에 넣어서 사용.
//
// 실행 (프로젝트 루트에서):
//   dart run bin/mypage_api_test.dart

import 'dart:io';

import 'package:bnkproject/api/mypage_api.dart';
import 'package:bnkproject/models/MypageTransfer.dart';
import 'package:bnkproject/models/EditRequest.dart';
import 'package:bnkproject/models/Pcontract.dart';

Future<void> main() async {
  // --------------------------------------------------
  // 1) baseUrl / 세션 쿠키 설정
  // --------------------------------------------------
  // 예시:
  //   - 로컬 PC에서 서버 실행:       http://localhost:8080/BNK
  //   - 안드로이드 에뮬레이터:      http://10.0.2.2:8080/BNK
  //   - EC2 배포 서버:             http://3.39.247.70:8080/BNK
  const String baseUrl = 'http://localhost:8080/BNK';

  // 브라우저에서 로그인 후 받은 JSESSIONID 복붙
  // 예: 'JSESSIONID=ABCDEF0123456789...'
  const String sessionCookie = 'JSESSIONID=변경하세요';

  final api = MypageApiClient(
    baseUrl: baseUrl,
    sessionCookie: sessionCookie.isEmpty ? null : sessionCookie,
  );

  stdout.writeln('=== Mypage API 테스트 시작 ===');

  try {
    await _testMypageMain(api);
    await _testMypageProd(api);
    await _testEditList(api);
    await _testProdCancelList(api);

    // 🚨 아래 테스트들은 실제로 DB에 영향을 주는 작업이니까
    //    필요할 때만 true로 바꿔서 사용해.
    const bool enableTransferTest = false;
    const bool enableProdCancelPostTest = false;
    const bool enableEditSellBuyTest = false;

    if (enableTransferTest) {
      await _testTransfer(api);
    }
    if (enableProdCancelPostTest) {
      await _testProdCancelPost(api);
    }
    if (enableEditSellBuyTest) {
      await _testEditSellBuy(api);
    }
  } catch (e, st) {
    stderr.writeln('❌ 에러 발생: $e');
    stderr.writeln(st);
  } finally {
    api.dispose();
  }

  stdout.writeln('=== Mypage API 테스트 종료 ===');
}

// ------------------------------------------------------
// 1) /api/mypage/main  테스트
// ------------------------------------------------------
Future<void> _testMypageMain(MypageApiClient api) async {
  stdout.writeln('\n[1] /api/mypage/main 호출 중...');

  try {
    final main = await api.fetchMypageMain();

    stdout.writeln('✅ /api/mypage/main 성공');
    stdout.writeln('- balance: ${main.balance}');
    stdout.writeln('- dealList 개수: ${main.dealList.length}');
    stdout.writeln('- fundList 개수: ${main.fundList.length}');
    stdout.writeln('- contractList 개수: ${main.contractList.length}');
    stdout.writeln('- etfList 개수: ${main.etfList.length}');
  } catch (e) {
    stdout.writeln('❌ /api/mypage/main 실패: $e');
  }
}

// ------------------------------------------------------
// 2) /api/mypage/prod  테스트
// ------------------------------------------------------
Future<void> _testMypageProd(MypageApiClient api) async {
  stdout.writeln('\n[2] /api/mypage/prod 호출 중...');

  try {
    final prod = await api.fetchMypageProd();

    stdout.writeln('✅ /api/mypage/prod 성공');
    stdout.writeln('- plus(입금 총합): ${prod.plus}');
    stdout.writeln('- minus(출금 총합): ${prod.minus}');
    stdout.writeln('- balance: ${prod.balance}');
    stdout.writeln('- dealList 개수: ${prod.dealList.length}');
    stdout.writeln('- contractList 개수: ${prod.contractList.length}');
  } catch (e) {
    stdout.writeln('❌ /api/mypage/prod 실패: $e');
  }
}

// ------------------------------------------------------
// 3) /api/mypage/editList  테스트
//    변경 대상 상품 목록
// ------------------------------------------------------
Future<void> _testEditList(MypageApiClient api) async {
  stdout.writeln('\n[3] /api/mypage/editList 호출 중...');

  try {
    final list = await api.fetchEditList();

    stdout.writeln('✅ /api/mypage/editList 성공');
    stdout.writeln('- 변경 대상 상품 개수: ${list.length}');

    final limit = list.length < 3 ? list.length : 3;
    for (int i = 0; i < limit; i++) {
      final p = list[i];
      stdout.writeln(
          '  [$i] pacc=${p.pacc}, pname=${p.pname}, pbalance=${p.pbalance}');
    }
  } catch (e) {
    stdout.writeln('❌ /api/mypage/editList 실패: $e');
  }
}

// ------------------------------------------------------
// 4) /api/mypage/prodCancel (GET) 테스트
//    해지 대상 상품 목록
// ------------------------------------------------------
Future<void> _testProdCancelList(MypageApiClient api) async {
  stdout.writeln('\n[4] /api/mypage/prodCancel (GET) 호출 중...');

  try {
    final list = await api.fetchProdCancelList();

    stdout.writeln('✅ /api/mypage/prodCancel(GET) 성공');
    stdout.writeln('- 해지 대상 상품 개수: ${list.length}');

    final limit = list.length < 3 ? list.length : 3;
    for (int i = 0; i < limit; i++) {
      final p = list[i];
      stdout.writeln(
          '  [$i] pacc=${p.pacc}, pname=${p.pname}, pbalance=${p.pbalance}');
    }
  } catch (e) {
    stdout.writeln('❌ /api/mypage/prodCancel(GET) 실패: $e');
  }
}

// ------------------------------------------------------
// 5) (옵션) /api/mypage/transfer  테스트
//    실제 계좌이체 (DB 영향 있음)
// ------------------------------------------------------
Future<void> _testTransfer(MypageApiClient api) async {
  stdout.writeln('\n[5] /api/mypage/transfer 호출 중...');

  // ⚠ 실제로 존재하는 계좌번호/금액으로 바꿔서 테스트해야 한다.
  final req = TransferRequestModel(
    dbalance: 1000,          // 이체 금액
    dwho: '테스트이체',         // 누구에게 / 사유
    myAcc: '내계좌번호',        // 예: '312-123-456789'
    yourAcc: '상대계좌번호',    // 예: '312-987-654321'
  );

  try {
    final ok = await api.transfer(req);
    stdout.writeln('✅ /api/mypage/transfer 성공: $ok');
  } catch (e) {
    stdout.writeln('❌ /api/mypage/transfer 실패: $e');
  }
}

// ------------------------------------------------------
// 6) (옵션) /api/mypage/prodCancel (POST) 테스트
//    실제 상품 해지 (DB 영향 있음)
// ------------------------------------------------------
Future<void> _testProdCancelPost(MypageApiClient api) async {
  stdout.writeln('\n[6] /api/mypage/prodCancel (POST) 호출 중...');

  final cancelList = await api.fetchProdCancelList();
  if (cancelList.isEmpty) {
    stdout.writeln('⚠ 해지 가능한 상품이 없어 테스트를 건너뜀');
    return;
  }

  final target = cancelList.first;
  final req = ProdCancelRequestModel(
    pacc: target.pacc ?? '',
    pbalance: target.pbalance ?? 0,
    recvAcc: '해지금 받는 계좌번호', // 실제 계좌로 변경
    pcpid: target.pcpid ?? '',     // Fund/Pcontract id 등 (필요하다면)
  );

  try {
    final ok = await api.prodCancel(req);
    stdout.writeln('✅ /api/mypage/prodCancel(POST) 성공: $ok');
  } catch (e) {
    stdout.writeln('❌ /api/mypage/prodCancel(POST) 실패: $e');
  }
}

// ------------------------------------------------------
// 7) (옵션) 변경 매도/매수 테스트 (editSell / editBuy)
//    실제로 상품 변경이 일어나므로 조심해서 사용
// ------------------------------------------------------
Future<void> _testEditSellBuy(MypageApiClient api) async {
  stdout.writeln('\n[7] /api/mypage/editSell & editBuy 호출 중...');

  final list = await api.fetchEditList();
  if (list.isEmpty) {
    stdout.writeln('⚠ 변경 가능한 상품이 없어 테스트를 건너뜀');
    return;
  }

  final Pcontract first = list.first;
  final String pacc = first.pacc ?? '';

  // ⚠ sellTypes 값은 백엔드 로직에 맞게 수정해야 한다.
  //    예: ["ALL"], ["PART"] 등
  final request = EditRequest(
    pacc: pacc,
    sellTypes: ['ALL'],             // TODO: 백엔드에서 사용하는 실제 값으로 변경
    products: [first],              // 하나만 테스트
    totalAmount: first.pbalance ?? 0,
  );

  try {
    final sellOk = await api.editSell(request);
    stdout.writeln('✅ editSell 성공: $sellOk');
  } catch (e) {
    stdout.writeln('❌ editSell 실패: $e');
  }

  try {
    final buyOk = await api.editBuy(request);
    stdout.writeln('✅ editBuy 성공: $buyOk');
  } catch (e) {
    stdout.writeln('❌ editBuy 실패: $e');
  }
}
