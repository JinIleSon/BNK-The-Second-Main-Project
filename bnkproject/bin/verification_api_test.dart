// bin/verification_api_test.dart
//
// VerificationApiClient 테스트 스크립트
// - 이메일 인증번호 전송/검증
// - SMS 인증번호 전송/검증
//
// 실행 방법 (프로젝트 루트에서):
//   dart run bin/verification_api_test.dart
// ※ Adroid Studio Terminal이 아닌 윈도우 명령 프롬프트에서 실행할 것

import 'dart:io';

// pubspec.yaml 의 name 기준으로 수정 (예: name: bnkproject)
import 'package:bnkproject/api/verification_api.dart';

Future<void> main() async {
  // ---------------- 기본 설정 ----------------
  // 서버 주소:
  //  - 로컬:          http://localhost:8080/BNK
  //  - 에뮬레이터:    http://10.0.2.2:8080/BNK
  //  - EC2:          http://3.39.247.70:8080/BNK
  const String baseUrl = 'http://localhost:8080/BNK';

  // 테스트용 이메일 / 휴대폰 번호
  // 실제로 EmailService / SmsService 가 발송 가능한 주소/번호로 바꿔서 사용
  const String testEmail = 'mincheolkang34@gmail.com';      // TODO: 실제 이메일로 변경
  const String testPhone = '010-7724-1425';         // TODO: 실제 휴대폰 번호로 변경

  final api = VerificationApiClient(baseUrl: baseUrl);

  stdout.writeln('=== Verification API 테스트 시작 ===');

  try {
    await _testEmailVerification(api, testEmail);
    await _testSmsVerification(api, testPhone);
  } catch (e, st) {
    stderr.writeln('❌ 테스트 중 에러 발생: $e');
    stderr.writeln(st);
  } finally {
    api.dispose();
  }

  stdout.writeln('=== Verification API 테스트 종료 ===');
}

// ------------------------------------------------------------------
// 1) 이메일 인증 테스트
//    - /api/verification/email/send
//    - /api/verification/email/verify
// ------------------------------------------------------------------
Future<void> _testEmailVerification(
    VerificationApiClient api,
    String email,
    ) async {
  stdout.writeln('\n[1] 이메일 인증 테스트');

  if (email.isEmpty || !email.contains('@')) {
    stdout.writeln('⚠ testEmail 이 올바르게 설정되지 않아 이메일 테스트를 스킵합니다.');
    return;
  }

  stdout.writeln('- 이메일 인증번호 전송 요청...');
  final sendResult = await api.sendEmailCode(email);

  stdout.writeln('  · send: ${sendResult.send}');
  if (!sendResult.send) {
    stdout.writeln('  · error: ${sendResult.error}');
    stdout.writeln('⚠ 이메일 발송 실패로 이메일 인증 테스트 종료');
    return;
  }

  // 실제 받은 인증번호를 콘솔에 입력
  stdout.write('받은 이메일 인증번호를 입력하세요: ');
  final input = stdin.readLineSync()?.trim();

  if (input == null || input.isEmpty) {
    stdout.writeln('⚠ 인증번호가 입력되지 않아 이메일 검증을 스킵합니다.');
    return;
  }

  stdout.writeln('- 이메일 인증번호 검증 요청...');
  final verifyResult = await api.verifyEmailCode(input);

  stdout.writeln('  · matched: ${verifyResult.matched}');
  if (verifyResult.matched) {
    stdout.writeln('✅ 이메일 인증 성공');
  } else {
    stdout.writeln('❌ 이메일 인증 실패 (코드 불일치)');
  }
}

// ------------------------------------------------------------------
// 2) SMS 인증 테스트
//    - /api/verification/sms/send
//    - /api/verification/sms/verify
// ------------------------------------------------------------------
Future<void> _testSmsVerification(
    VerificationApiClient api,
    String phoneNumber,
    ) async {
  stdout.writeln('\n[2] SMS 인증 테스트');

  if (phoneNumber.isEmpty) {
    stdout.writeln('⚠ testPhone 이 설정되지 않아 SMS 테스트를 스킵합니다.');
    return;
  }

  stdout.writeln('- SMS 인증번호 전송 요청...');
  final sendResult = await api.sendSmsCode(phoneNumber);

  stdout.writeln('  · ok: ${sendResult.ok}');
  stdout.writeln('  · message: ${sendResult.message}');

  if (!sendResult.ok) {
    stdout.writeln('⚠ SMS 발송 실패로 SMS 인증 테스트 종료');
    return;
  }

  // 실제 받은 SMS 인증번호를 콘솔에 입력
  stdout.write('받은 SMS 인증번호를 입력하세요: ');
  final input = stdin.readLineSync()?.trim();

  if (input == null || input.isEmpty) {
    stdout.writeln('⚠ 인증번호가 입력되지 않아 SMS 검증을 스킵합니다.');
    return;
  }

  stdout.writeln('- SMS 인증번호 검증 요청...');
  final verifyResult = await api.verifySmsCode(
    phoneNumber: phoneNumber,
    code: input,
  );

  stdout.writeln('  · ok: ${verifyResult.ok}');
  stdout.writeln('  · message: ${verifyResult.message}');
  stdout.writeln('  · verificationToken: ${verifyResult.verificationToken}');

  if (verifyResult.ok) {
    stdout.writeln('✅ SMS 인증 성공');
  } else {
    stdout.writeln('❌ SMS 인증 실패');
  }
}
