// bin/member_api_test.dart
//
// /api/member 관련 로그인/세션/아이디·비밀번호 찾기 API 테스트 스크립트.
//  - login
//  - me
//  - session/remaining
//  - session/extend
//  - find-id (phone/email)
//  - find-pw (phone/email)
//
// 실행 (프로젝트 루트에서):
//   dart run bin/member_api_test.dart

import 'dart:io';

// pubspec.yaml 의 name 기준으로 수정 (예: name: bnkproject)
import 'package:bnkproject/api/member_api.dart';
import 'package:bnkproject/models/Login.dart';
import 'package:bnkproject/models/SessionInfo.dart';
import 'package:bnkproject/models/FindIdPw.dart';

Future<void> main() async {
  // 1) 환경 설정 ----------------------------------------------------------------

  // 서버 주소:
  //  - 로컬 PC에서 서버 실행:        http://localhost:8080/BNK
  //  - 안드로이드 에뮬레이터:       http://10.0.2.2:8080/BNK
  //  - EC2 배포 서버:              http://3.39.247.70:8080/BNK
  const String baseUrl = 'http://localhost:8080/BNK';

  // 테스트용 아이디/비밀번호 (실제 DB에 있는 계정으로 바꿔야 함)
  const String testMid = 'a123';    // 예시
  const String testMpw = 'qwe123!';    // 예시

  // 아이디 찾기/비번 찾기용 테스트 데이터 (있으면 채우고, 없으면 스킵됨)
  const String testName = '강민철';
  const String testPhone = '01012341001';
  const String testEmail = 'l@email.com';

  final memberApi = MemberApiClient(baseUrl: baseUrl);

  stdout.writeln('=== Member API 테스트 시작 ===');

  try {
    // 2) 로그인 테스트 -----------------------------------------------------------
    final loginResult = await _testLogin(memberApi, testMid, testMpw);

    if (!loginResult.ok) {
      stdout.writeln('⚠ 로그인 실패 상태라, 이후 테스트 일부는 의미가 없을 수 있음.');
    } else {
      // 3) /me 테스트 ------------------------------------------------------------
      await _testMe(memberApi);

      // 4) 세션 남은 시간 / 연장 테스트 -----------------------------------------
      await _testSessionRemaining(memberApi);
      await _testSessionExtend(memberApi);
    }

    // 5) 아이디 찾기 테스트 (phone / email) -------------------------------------
    await _testFindId(memberApi, testName, testPhone, testEmail);

    // 6) 비밀번호 찾기 테스트 (phone / email) -----------------------------------
    await _testFindPw(memberApi, testMid, testPhone, testEmail);

    // 7) 로그아웃 테스트 ---------------------------------------------------------
    await _testLogout(memberApi);
  } catch (e, st) {
    stderr.writeln('❌ 전체 테스트 중 에러 발생: $e');
    stderr.writeln(st);
  } finally {
    memberApi.dispose();
  }

  stdout.writeln('=== Member API 테스트 종료 ===');
}

// ---------------------------------------------------------------------------
// 2) 로그인 테스트
// ---------------------------------------------------------------------------
Future<LoginResult> _testLogin(
    MemberApiClient api, String mid, String mpw) async {
  stdout.writeln('\n[1] /api/member/login 호출 중...');
  final result = await api.login(mid: mid, mpw: mpw);

  if (result.ok) {
    stdout.writeln('✅ 로그인 성공');
    stdout.writeln('- user.mid: ${result.user?.mid}');
    stdout.writeln('- user.mname: ${result.user?.mname}');
    stdout.writeln('- token: ${result.token}');
    stdout.writeln('- sessionExpiresIn: ${result.sessionExpiresIn}');
    stdout.writeln('- 저장된 sessionCookie: ${api.sessionCookie}');
  } else {
    stdout.writeln('❌ 로그인 실패: ${result.message}');
  }

  return result;
}

// ---------------------------------------------------------------------------
// 3) /api/member/me 테스트 (내 정보 + 세션 잔여시간)
// ---------------------------------------------------------------------------
Future<void> _testMe(MemberApiClient api) async {
  stdout.writeln('\n[2] /api/member/me 호출 중...');

  try {
    final me = await api.me();
    if (!me.ok || me.user == null) {
      stdout.writeln('⚠ /me 응답 ok=false 또는 user=null, message=${me.message}');
      return;
    }

    stdout.writeln('✅ /me 성공');
    stdout.writeln('- mid: ${me.user!.mid}');
    stdout.writeln('- name: ${me.user!.mname}');
    stdout.writeln('- remainSeconds: ${me.remainSeconds}');
  } catch (e) {
    stdout.writeln('❌ /me 호출 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 4) /api/member/session/remaining 테스트
// ---------------------------------------------------------------------------
Future<void> _testSessionRemaining(MemberApiClient api) async {
  stdout.writeln('\n[3] /api/member/session/remaining 호출 중...');

  try {
    final SessionInfo info = await api.getSessionRemaining();
    stdout.writeln('✅ 세션 남은 시간 조회 성공');
    stdout.writeln('- remainSeconds: ${info.remainSeconds}');
  } catch (e) {
    stdout.writeln('❌ 세션 남은 시간 조회 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 5) /api/member/session/extend 테스트
// ---------------------------------------------------------------------------
Future<void> _testSessionExtend(MemberApiClient api) async {
  stdout.writeln('\n[4] /api/member/session/extend 호출 중...');

  try {
    final SessionInfo info = await api.extendSession();
    stdout.writeln('✅ 세션 연장 성공');
    stdout.writeln('- 새로운 remainSeconds: ${info.remainSeconds}');
  } catch (e) {
    stdout.writeln('❌ 세션 연장 실패: $e');
  }
}

// ---------------------------------------------------------------------------
// 6) 아이디 찾기 테스트 (휴대폰 / 이메일)
// ---------------------------------------------------------------------------
Future<void> _testFindId(
    MemberApiClient api,
    String name,
    String phone,
    String email,
    ) async {
  stdout.writeln('\n[5] 아이디 찾기 테스트 시작');

  // 휴대폰으로 아이디 찾기
  if (name.isNotEmpty && phone.isNotEmpty) {
    stdout.writeln('- /api/member/find-id/phone 호출 중...');
    try {
      final FindIdResult res = await api.findIdByPhone(
        name: name,
        phone: phone,
      );
      if (res.ok) {
        stdout.writeln('✅ 휴대폰으로 아이디 찾기 성공: mid=${res.mid}');
      } else {
        stdout.writeln('⚠ 휴대폰으로 아이디 찾기 실패: ${res.message}');
      }
    } catch (e) {
      stdout.writeln('❌ 휴대폰 아이디 찾기 API 에러: $e');
    }
  } else {
    stdout.writeln('- 이름/휴대폰 미설정 → 휴대폰 아이디 찾기 스킵');
  }

  // 이메일로 아이디 찾기
  if (name.isNotEmpty && email.isNotEmpty) {
    stdout.writeln('- /api/member/find-id/email 호출 중...');
    try {
      final FindIdResult res = await api.findIdByEmail(
        name: name,
        email: email,
      );
      if (res.ok) {
        stdout.writeln('✅ 이메일로 아이디 찾기 성공: mid=${res.mid}');
      } else {
        stdout.writeln('⚠ 이메일로 아이디 찾기 실패: ${res.message}');
      }
    } catch (e) {
      stdout.writeln('❌ 이메일 아이디 찾기 API 에러: $e');
    }
  } else {
    stdout.writeln('- 이름/이메일 미설정 → 이메일 아이디 찾기 스킵');
  }
}

// ---------------------------------------------------------------------------
// 7) 비밀번호 찾기 테스트 (휴대폰 / 이메일, 임시 비밀번호 발급)
// ---------------------------------------------------------------------------
Future<void> _testFindPw(
    MemberApiClient api,
    String mid,
    String phone,
    String email,
    ) async {
  stdout.writeln('\n[6] 비밀번호 찾기 테스트 시작');

  // 휴대폰으로 비밀번호 찾기
  if (mid.isNotEmpty && phone.isNotEmpty) {
    stdout.writeln('- /api/member/find-pw/phone 호출 중...');
    try {
      final FindPwResult res = await api.findPwByPhone(
        mid: mid,
        phone: phone,
      );
      if (res.ok) {
        stdout.writeln('✅ 휴대폰으로 비밀번호 찾기 성공 (임시 비번): ${res.tempPw}');
      } else {
        stdout.writeln('⚠ 휴대폰 비밀번호 찾기 실패: ${res.message}');
      }
    } catch (e) {
      stdout.writeln('❌ 휴대폰 비밀번호 찾기 API 에러: $e');
    }
  } else {
    stdout.writeln('- mid/휴대폰 미설정 → 휴대폰 비밀번호 찾기 스킵');
  }

  // 이메일로 비밀번호 찾기
  if (mid.isNotEmpty && email.isNotEmpty) {
    stdout.writeln('- /api/member/find-pw/email 호출 중...');
    try {
      final FindPwResult res = await api.findPwByEmail(
        mid: mid,
        email: email,
      );
      if (res.ok) {
        stdout.writeln('✅ 이메일로 비밀번호 찾기 성공 (임시 비번): ${res.tempPw}');
      } else {
        stdout.writeln('⚠ 이메일 비밀번호 찾기 실패: ${res.message}');
      }
    } catch (e) {
      stdout.writeln('❌ 이메일 비밀번호 찾기 API 에러: $e');
    }
  } else {
    stdout.writeln('- mid/이메일 미설정 → 이메일 비밀번호 찾기 스킵');
  }
}

// ---------------------------------------------------------------------------
// 8) 로그아웃 테스트
// ---------------------------------------------------------------------------
Future<void> _testLogout(MemberApiClient api) async {
  stdout.writeln('\n[7] /api/member/logout 호출 중...');

  final ok = await api.logout();
  if (ok) {
    stdout.writeln('✅ 로그아웃 성공');
  } else {
    stdout.writeln('⚠ 로그아웃 응답 코드가 200이 아님 (그래도 클라이언트 토큰/세션은 초기화됨)');
  }
}
