import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 감사로그를 로컬에 저장하는 서비스.
///
/// 금융 관점 포인트:
/// - 실제 서비스는 서버(로그/감사 시스템)에 남기는 게 원칙.
/// - PoC는 서버가 없으니 "어떤 이벤트를 어떤 필드로 남길지"를 설계하고,
///   저장/조회가 된다면 PoC로 충분하다.
///
/// 주의:
/// - 민감정보(PII/바이오 데이터/원본 얼굴 이미지)는 로그에 남기면 안 된다.
/// - PoC라도 challenge를 남기는 건 실서비스에선 조심해야 한다.
///   (여기서는 흐름 설명 목적의 PoC)
class AuditLogService {
  static const _kLogs = 'poc_audit_logs';
  final FlutterSecureStorage _ss = const FlutterSecureStorage();

  /// 이벤트 1건 추가(append-only)
  Future<void> append(Map<String, dynamic> event) async {
    final raw = await _ss.read(key: _kLogs);

    // 저장소에 JSON 배열로 유지
    final List<dynamic> list = raw == null ? [] : (jsonDecode(raw) as List<dynamic>);
    list.add(event);

    await _ss.write(key: _kLogs, value: jsonEncode(list));
  }

  /// 전체 로그 조회
  Future<List<Map<String, dynamic>>> readAll() async {
    final raw = await _ss.read(key: _kLogs);
    if (raw == null) return [];

    final list = (jsonDecode(raw) as List<dynamic>);
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// 로그 초기화(테스트 편의)
  Future<void> clear() => _ss.delete(key: _kLogs);
}
