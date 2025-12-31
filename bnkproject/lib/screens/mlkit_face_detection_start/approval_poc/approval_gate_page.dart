import 'package:flutter/material.dart';

import 'services/audit_log_service.dart';
import 'services/biometric_service.dart';
import 'services/challenge_service.dart';
import 'services/device_binding_service.dart';

/// "거래 승인 게이트" PoC 화면.
///
/// 이 화면이 하는 일:
/// 1) 버튼 클릭 → challenge 발급(서버 역할 로컬 모사)
/// 2) OS 생체인증 통과
/// 3) challenge 1회성 consume(재사용 방지 개념)
/// 4) 감사로그 기록
///
/// 금융식 설계 포인트:
/// - 승인 흐름은 "한 번 성공하면 끝"이 아니라
///   "1회성 토큰(챌린지) + 재사용 금지 + 감사기록"이 같이 간다.
class ApprovalGatePage extends StatefulWidget {
  const ApprovalGatePage({super.key});

  @override
  State<ApprovalGatePage> createState() => _ApprovalGatePageState();
}

class _ApprovalGatePageState extends State<ApprovalGatePage> with WidgetsBindingObserver {
  // 서비스들(역할 분리: 화면은 orchestration만)
  final _bio = BiometricService();
  final _device = DeviceBindingService();
  final _challenge = ChallengeService();
  final _audit = AuditLogService();

  String _status = 'READY';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰: 백그라운드 전환 시 challenge 폐기
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 inactive/paused(백그라운드)로 가면 challenge 폐기.
  ///
  /// 의미:
  /// - 승인 시도 중 화면/앱 전환이 생기면 기존 승인컨텍스트를 폐기해서
  ///   "중간 상태 재사용"을 막는 모양새를 만든다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _challenge.invalidate();
    }
  }

  Future<void> _approve() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _status = 'ISSUE_CHALLENGE';
    });

    // (1) 기기 바인딩 ID 확보
    final deviceId = await _device.getOrCreate();

    // (2) challenge 발급(서버 역할 로컬 모사)
    final ch = await _challenge.issue();

    // 감사로그: 승인 시도 시작
    await _audit.append({
      "ts": DateTime.now().toIso8601String(),
      "event": "APPROVAL_ATTEMPT",
      "deviceId": deviceId,
      "result": "START",
      // PoC에서는 흐름 확인용으로 남김(실서비스에서는 민감 취급)
      "challenge": ch,
    });

    try {
      // (3) 생체 지원/등록 여부 체크
      final supported = await _bio.isSupported();
      if (!supported) {
        await _audit.append({
          "ts": DateTime.now().toIso8601String(),
          "event": "APPROVAL_FAIL",
          "deviceId": deviceId,
          "reason": "BIOMETRIC_NOT_SUPPORTED",
        });

        setState(() {
          _status = 'FAIL: BIOMETRIC_NOT_SUPPORTED';
          _busy = false;
        });
        return;
      }

      // (4) 생체 인증 실행
      setState(() => _status = 'BIOMETRIC_AUTH');
      final ok = await _bio.authenticate(reason: '거래 승인을 위해 생체인증을 진행합니다.');

      if (!ok) {
        // 사용자가 취소했거나 실패
        await _audit.append({
          "ts": DateTime.now().toIso8601String(),
          "event": "APPROVAL_FAIL",
          "deviceId": deviceId,
          "reason": "BIOMETRIC_FAILED_OR_CANCELED",
        });

        setState(() {
          _status = 'FAIL: BIOMETRIC_FAILED_OR_CANCELED';
          _busy = false;
        });
        return;
      }

      // (5) challenge 1회성 consume(재사용/리플레이 방지 개념)
      setState(() => _status = 'CONSUME_CHALLENGE');
      final res = await _challenge.consumeIfValid(ch);

      if (!res.ok) {
        await _audit.append({
          "ts": DateTime.now().toIso8601String(),
          "event": "APPROVAL_FAIL",
          "deviceId": deviceId,
          "reason": res.code,
        });

        setState(() {
          _status = 'FAIL: ${res.code}';
          _busy = false;
        });
        return;
      }

      // (6) 승인 성공 기록
      await _audit.append({
        "ts": DateTime.now().toIso8601String(),
        "event": "APPROVAL_SUCCESS",
        "deviceId": deviceId,
        "result": "OK",
      });

      setState(() {
        _status = 'APPROVED';
        _busy = false;
      });
    } catch (e) {
      // local_auth 예외를 사유코드로 치환해서 감사로그에 남김
      final code = BiometricService.mapError(e);

      await _audit.append({
        "ts": DateTime.now().toIso8601String(),
        "event": "APPROVAL_FAIL",
        "deviceId": deviceId,
        "reason": code,
        "raw": e.toString(),
      });

      setState(() {
        _status = 'FAIL: $code';
        _busy = false;
      });
    }
  }

  /// 감사로그 확인(개발자/PoC 확인용)
  Future<void> _showLogs() async {
    final logs = await _audit.readAll();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(logs.map((e) => e.toString()).join('\n\n')),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Gate PoC'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _showLogs,
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Audit Logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('STATUS: $_status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // 승인 버튼
            ElevatedButton(
              onPressed: _busy ? null : _approve,
              child: Text(_busy ? 'PROCESSING...' : 'Approve Trade (Biometric)'),
            ),

            const SizedBox(height: 8),

            // 테스트 편의: challenge 수동 폐기
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                await _challenge.invalidate();
                setState(() => _status = 'CHALLENGE_INVALIDATED');
              },
              child: const Text('Invalidate Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
