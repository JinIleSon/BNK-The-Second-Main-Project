// bin/fund_model_test.dart
//
// Fund 모델(FundDTO 대응)이 JSON과 잘 매핑되는지 테스트하는 스크립트.
// 1) 로컬 sample JSON → Fund.fromJson → 출력
// 2) (선택) 백엔드 Fund 리스트 API를 호출해보고 싶을 때 쓸 수 있는 뼈대도 포함.
//
// 실행 (프로젝트 루트에서):
//   dart run bin/fund_model_test.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// pubspec.yaml 의 name 기준으로 패키지명 맞출 것 (예: name: bnkproject)
import 'package:bnkproject/models/Fund.dart';

Future<void> main() async {
  stdout.writeln('=== Fund 모델 테스트 시작 ===');

  // 1) 로컬 JSON으로 파싱 테스트
  _testLocalJson();

  // 2) (옵션) 실제 API 호출 테스트
  //   - true 로 바꾸고
  //   - baseUrl / endpointPath 를 프로젝트에 맞게 수정해서 사용
  const bool enableApiTest = false;
  if (enableApiTest) {
    await _testApi();
  }

  stdout.writeln('=== Fund 모델 테스트 종료 ===');
}

// ------------------------------------------------------
// 1) 로컬 sample JSON → Fund 파싱 테스트
// ------------------------------------------------------
void _testLocalJson() {
  stdout.writeln('\n[1] 로컬 JSON → Fund.fromJson 테스트');

  // 백엔드 FundDTO 구조를 기반으로 적당히 샘플 값 구성
  final Map<String, dynamic> sampleJson = {
    'fid': 'F00001',
    'fname': 'BNK 퇴직연금 안정형 펀드',
    'famc': 'BNK자산운용',
    'frlvl': 2,
    'ftype': '채권형',
    'frefpr': 1023.45,
    'fsetdt': '2024-01-15',
    'ftc': 0.5,
    'fm1pr': 0.3,
    'fm3pr': 1.2,
    'fm6pr': 2.8,
    'fm12pr': 4.5,
    'facmpr': 3.1,
    // mypage - 나의 투자용 필드
    'pacc': '312-123-456789',
    'pnew': '2025-11-01T09:00:00',
    'pend': '2026-11-01T09:00:00',
    'pbalance': 1500000,
    // 모달 정보
    'basedt': '2025-12-10',
    'evaltype': '수익률',
    'mgmtcomp': 'BNK자산운용',
    'grade3y': 'A',
    'grade5y': 'A+',
    'relatedfund': 'BNK 퇴직연금 성장형 펀드',
    'investregion': '국내',
    'past2023': '4.2',
    'past2024': '3.8',
    'fee1y': '0.45',
    'fee3y': '0.40',
    'startinfo': '2024-01-15 설정',
    'salesfee': '없음',
    'familysize': '300억',
    'trustfee': '0.25',
    'aum': '500억',
    'redeemfee': '없음',
    'chart1': 'chart1-url-or-data',
    'chart2': 'chart2-url-or-data',
    'pname': '퇴직연금 안정형',
  };

  final fund = Fund.fromJson(sampleJson);

  stdout.writeln('✅ Fund.fromJson 성공');
  stdout.writeln('- fid: ${fund.fid}');
  stdout.writeln('- fname: ${fund.fname}');
  stdout.writeln('- famc: ${fund.famc}');
  stdout.writeln('- frlvl: ${fund.frlvl}');
  stdout.writeln('- frefpr: ${fund.frefpr}');
  stdout.writeln('- pacc: ${fund.pacc}');
  stdout.writeln('- pbalance: ${fund.pbalance}');
  stdout.writeln('- basedt: ${fund.basedt}');
  stdout.writeln('- aum: ${fund.aum}');
  stdout.writeln('- pname: ${fund.pname}');

  // 다시 JSON으로 변환 확인
  final backToJson = fund.toJson();
  stdout.writeln('\n[로컬] Fund.toJson 결과:');
  stdout.writeln(jsonEncode(backToJson));
}

// ------------------------------------------------------
// 2) (옵션) 실제 Spring API 를 호출해보고 싶은 경우
//    enableApiTest 를 true 로 바꾸고 사용
// ------------------------------------------------------
Future<void> _testApi() async {
  stdout.writeln('\n[2] 실제 Fund API 호출 테스트');

  // TODO: 실제 프로젝트에 맞게 baseUrl / endpointPath 수정 필요
  // 예시:
  //   - 로컬 PC에서 서버 실행:       http://localhost:8080/BNK
  //   - 안드로이드 에뮬레이터:      http://10.0.2.2:8080/BNK
  //   - EC2 배포 서버:             http://3.39.247.70:8080/BNK
  const baseUrl = 'http://localhost:8080/BNK';

  // 예시 엔드포인트 (실제 사용하는 Fund 리스트 API로 수정할 것)
  //   예: GET /api/fund/list, /api/product/funds 등
  final uri = Uri.parse('$baseUrl/api/fund/list'); // ← 프로젝트에 맞게 변경

  final resp = await http.get(
    uri,
    headers: const {
      'Accept': 'application/json',
    },
  );

  stdout.writeln('- HTTP status: ${resp.statusCode}');
  if (resp.statusCode != 200) {
    stdout.writeln('❌ Fund API 호출 실패: ${resp.body}');
    return;
  }

  final List<dynamic> jsonList = jsonDecode(resp.body);
  final funds = jsonList
      .map((e) => Fund.fromJson(e as Map<String, dynamic>))
      .toList();

  stdout.writeln('✅ Fund API 호출 및 파싱 성공');
  stdout.writeln('- 펀드 개수: ${funds.length}');

  final limit = funds.length < 3 ? funds.length : 3;
  for (int i = 0; i < limit; i++) {
    final f = funds[i];
    stdout.writeln(
        '  [$i] fid=${f.fid}, fname=${f.fname}, frlvl=${f.frlvl}, pbalance=${f.pbalance}');
  }
}
