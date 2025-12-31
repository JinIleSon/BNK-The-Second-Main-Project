import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// OS 생체인증(Face ID / Touch ID / Android BiometricPrompt)을 호출하는 래퍼.
///
/// 금융 관점 포인트:
/// - "얼굴 검출"이 아니라 "승인 게이트"로 쓰는 것.
/// - 생체는 eKYC(본인확인)가 아니라 "기기 소유자 확인"에 가깝다.
///   (그래서 서버 연동 시에는 챌린지/서명/기기바인딩 같은 통제가 같이 붙는다.)
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// 생체인증 사용 가능 여부(기기 지원 + 생체 검사 가능)
  Future<bool> isSupported() async {
    // 기기가 생체를 지원하는지
    final supported = await _auth.isDeviceSupported();
    // 생체 사용 가능 상태인지(등록 여부 등)
    final canCheck = await _auth.canCheckBiometrics;
    return supported && canCheck;
  }

  /// 생체 인증 실행
  ///
  /// options:
  /// - biometricOnly: 비밀번호/패턴 같은 디바이스 크리덴셜로 우회하지 않게 함(정책상 필요 시 조정)
  /// - stickyAuth: 인증 팝업 중 앱 전환 등에도 최대한 상태 유지(UX 개선)
  /// - useErrorDialogs: OS 기본 에러 다이얼로그 사용(UX 편의)
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      // 위에서 에러코드 맵핑을 위해 호출부로 던짐
      rethrow;
    }
  }

  /// 에러를 "감사로그용 사유코드"로 단순 맵핑
  ///
  /// 실제 서비스면 플랫폼별 에러를 더 엄격히 분기하고,
  /// LOCKOUT 시 대체 인증(OTP/PIN/FIDO)로 전환 같은 정책이 들어간다.
  static String mapError(Object e) {
    final s = e.toString();

    if (s.contains(auth_error.notAvailable)) return 'BIOMETRIC_NOT_AVAILABLE';
    if (s.contains(auth_error.notEnrolled)) return 'BIOMETRIC_NOT_ENROLLED';
    if (s.contains(auth_error.lockedOut)) return 'BIOMETRIC_LOCKED_OUT';
    if (s.contains(auth_error.permanentlyLockedOut)) return 'BIOMETRIC_PERMANENT_LOCKED_OUT';

    return 'BIOMETRIC_ERROR';
  }
}
