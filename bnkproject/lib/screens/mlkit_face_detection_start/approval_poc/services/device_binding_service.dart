import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// 기기 바인딩 ID를 생성하고 Secure Storage에 영구 저장.
///
/// 금융 관점 포인트:
/// - "계정 ↔ 기기"를 묶는 개념의 출발점.
/// - 서버 연동 시: 로그인/승인 요청마다 deviceBindingId를 같이 보내고,
///   서버는 계정별 허용 기기 목록(등록/해지/변경)을 관리한다.
///
/// PoC는 서버가 없으니 "기기별 고유 ID를 안정적으로 유지"만 증명하면 된다.
class DeviceBindingService {
  static const _kKey = 'device_binding_id';

  // Secure Storage: iOS Keychain / Android Keystore 기반 저장
  final FlutterSecureStorage _ss = const FlutterSecureStorage();

  // UUID 생성기
  final Uuid _uuid = const Uuid();

  /// 있으면 읽고, 없으면 생성해서 저장 후 반환
  Future<String> getOrCreate() async {
    final existing = await _ss.read(key: _kKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final created = _uuid.v4();
    await _ss.write(key: _kKey, value: created);
    return created;
  }
}
