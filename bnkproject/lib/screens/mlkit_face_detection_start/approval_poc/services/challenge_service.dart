import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// 서버의 "챌린지(Nonce) 발급/만료/1회성 소모"를 로컬로 모사.
///
/// 금융 관점 포인트:
/// - 서버 연동 시에는 보통:
///   1) 서버가 challenge 발급(짧은 TTL)
///   2) 앱이 생체인증 성공 후 challenge 포함해 confirm 호출
///   3) 서버가 challenge를 1회성으로 consume 처리(재사용/리플레이 방지)
///
/// 지금은 서버가 없으니:
/// - Secure Storage에 challenge/만료시간/소모 여부를 저장해 "동일 개념"을 PoC로 증명한다.
class ChallengeService {
  static const _kChallenge = 'poc_challenge';
  static const _kExpiresAt = 'poc_challenge_expires_at';
  static const _kConsumed = 'poc_challenge_consumed';

  final FlutterSecureStorage _ss = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  /// challenge 발급
  /// - ttl: 만료시간(기본 2분)
  Future<String> issue({Duration ttl = const Duration(minutes: 2)}) async {
    final challenge = _uuid.v4();
    final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch.toString();

    // 서버가 DB/Redis에 저장하는 걸, PoC에서는 Secure Storage로 대체
    await _ss.write(key: _kChallenge, value: challenge);
    await _ss.write(key: _kExpiresAt, value: expiresAt);
    await _ss.write(key: _kConsumed, value: 'false');

    return challenge;
  }

  /// challenge 강제 폐기(취소, 백그라운드 전환 등)
  Future<void> invalidate() async {
    await _ss.delete(key: _kChallenge);
    await _ss.delete(key: _kExpiresAt);
    await _ss.delete(key: _kConsumed);
  }

  /// challenge 검증 + 1회성 consume
  ///
  /// 반환:
  /// - ok=true면 승인 진행 가능
  /// - ok=false면 reason(code)로 실패 사유를 남긴다(감사로그)
  Future<ChallengeCheckResult> consumeIfValid(String challenge) async {
    final stored = await _ss.read(key: _kChallenge);
    final expStr = await _ss.read(key: _kExpiresAt);
    final consumedStr = await _ss.read(key: _kConsumed);

    // 발급 자체가 없거나, 데이터가 깨진 경우
    if (stored == null || expStr == null || consumedStr == null) {
      return ChallengeCheckResult(false, 'CHALLENGE_MISSING');
    }

    // 다른 challenge를 들고 온 경우(위조/불일치)
    if (stored != challenge) {
      return ChallengeCheckResult(false, 'CHALLENGE_MISMATCH');
    }

    // 만료 체크
    final exp = int.tryParse(expStr) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now > exp) {
      // 만료된 건 재사용 불가: 즉시 폐기
      await invalidate();
      return ChallengeCheckResult(false, 'CHALLENGE_EXPIRED');
    }

    // 1회성 소모 체크: 이미 소모된 challenge면 리플레이로 간주
    final consumed = consumedStr == 'true';
    if (consumed) {
      return ChallengeCheckResult(false, 'REPLAY_DETECTED');
    }

    // 여기서 consume 처리(서버라면 DB/Redis에서 "사용됨"으로 표시)
    await _ss.write(key: _kConsumed, value: 'true');

    return ChallengeCheckResult(true, 'OK');
  }
}

/// challenge 검증 결과 DTO
class ChallengeCheckResult {
  final bool ok;
  final String code;
  ChallengeCheckResult(this.ok, this.code);
}
