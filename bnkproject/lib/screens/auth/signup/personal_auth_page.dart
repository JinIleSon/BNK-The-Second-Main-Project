// lib/screens/auth/signup/personal_auth_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'signup_flow_provider.dart';
import 'personal_info_page.dart';

import '../../../api/verification_api.dart';

// ✅ ML Kit 데모 진입 페이지 import
import '../../mlkit_face_detection_start/demo_main.dart';

class PersonalAuthPage extends StatelessWidget {
  const PersonalAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('본인 인증'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '휴대폰'),
              Tab(text: '얼굴'),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ElevatedButton(
              onPressed: flow.canGoPersonalInfo
                  ? () {
                // ✅ 다음 페이지에서도 Provider 유지
                final f = context.read<SignupFlowProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: f,
                      child: const PersonalInfoPage(),
                    ),
                  ),
                );
              }
                  : null,
              child: const Text('다음'),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _OtpAuthTab(channel: AuthChannel.phone),
            _FaceAuthTab(),
          ],
        ),
      ),
    );
  }
}

class _OtpAuthTab extends StatefulWidget {
  final AuthChannel channel;
  const _OtpAuthTab({required this.channel});

  @override
  State<_OtpAuthTab> createState() => _OtpAuthTabState();
}

class _OtpAuthTabState extends State<_OtpAuthTab>
    with AutomaticKeepAliveClientMixin {
  final _targetCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _sent = false;
  bool _busy = false;
  String? _msg;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _targetCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  bool _isValidTarget(String target) {
    if (widget.channel == AuthChannel.phone) {
      return RegExp(r'^\d{10,11}$').hasMatch(target);
    }
    // email
    return target.contains('@') && target.contains('.');
  }

  Future<void> _sendCode() async {
    final target = _targetCtrl.text.trim();

    if (target.isEmpty) {
      setState(() => _msg = '휴대폰 번호를 입력하세요.');
      return;
    }
    if (!_isValidTarget(target)) {
      setState(() => _msg = '휴대폰 번호 형식이 올바르지 않습니다.');
      return;
    }

    setState(() {
      _busy = true;
      _msg = null;
    });

    try {
      // 실제 SMS 발송 API(연동 완료) : verification_api
      final res = await verificationApi.sendSmsCode(target);

      setState(() {
        _sent = res.ok;
        _msg = res.message.isNotEmpty
            ? res.message
            : (res.ok ? '인증코드를 발송했습니다.' : '인증코드 발송에 실패했습니다.');
      });
    } catch (e) {
      setState(() => _msg = '발송 실패: $e');
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    final target = _targetCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (!_sent) return;

    if (code.length < 4) {
      setState(() => _msg = '인증코드를 확인하세요.');
      return;
    }

    setState(() {
      _busy = true;
      _msg = null;
    });

    try {
      // ✅ 실제 SMS 검증 API
      final res = await verificationApi.verifySmsCode(
        phoneNumber: target,
        code: code,
      );

      if (res.ok) {
        context.read<SignupFlowProvider>().setPersonalVerified(
          channel: AuthChannel.phone,
          target: target,
        );
      }

      setState(() {
        _msg = res.message.isNotEmpty
            ? res.message
            : (res.ok ? '인증이 완료되었습니다.' : '인증 실패');
      });
    } catch (e) {
      setState(() => _msg = '인증 실패: $e');
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isPhone = widget.channel == AuthChannel.phone;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isPhone ? '휴대폰 인증' : '이메일 인증',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _targetCtrl,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
          enabled: !_busy,
          decoration: InputDecoration(
            labelText: isPhone ? '휴대폰 번호' : '이메일',
            hintText: isPhone ? '01012345678' : 'test@sample.com',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _busy ? null : _sendCode,
            child: _busy
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
                : Text(_sent ? '코드 재발송' : '코드 발송'),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeCtrl,
          enabled: _sent && !_busy,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '인증코드'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: (!_sent || _busy) ? null : _verifyCode,
            child: const Text('인증 확인'),
          ),
        ),
        const SizedBox(height: 12),
        if (_msg != null)
          Text(
            _msg!,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
      ],
    );
  }
}

class _FaceAuthTab extends StatefulWidget {
  const _FaceAuthTab();

  @override
  State<_FaceAuthTab> createState() => _FaceAuthTabState();
}

class _FaceAuthTabState extends State<_FaceAuthTab>
    with AutomaticKeepAliveClientMixin {
  String? _msg;
  bool _busy = false;

  @override
  bool get wantKeepAlive => true;

  /// ✅ FaceDetectorApp(Entry)에서 반환 가능한 타입
  /// 1) bool true  : 성공
  /// 2) Map        : { ok:false, code, reason } 같은 "실패/중단" 결과(백그라운드 전환 등)
  ///
  /// ❗️중요 방어 정책
  /// - bool true 외에는 절대 성공 저장(setFaceResult) 하지 않는다.
  /// - Map(ok:false)이면 실패 메시지 출력만 하고 종료
  Future<void> _startFaceAuth(BuildContext context) async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _msg = null;
    });

    // ✅ ML Kit 진입 페이지로 push (MaterialApp 절대 push 금지)
    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const MlkitDemoEntryPage()),
    );

    if (!mounted) return;

    // 복귀 후 버튼 상태 원복
    setState(() => _busy = false);

    // 사용자가 뒤로가기 등으로 그냥 나온 경우
    if (result == null) {
      setState(() => _msg = '얼굴 인증이 취소되었습니다.');
      return;
    }

    // ✅ 성공은 bool true ONLY
    if (result is bool) {
      if (result == true) {
        context.read<SignupFlowProvider>().setFaceResult(
          path: 'mlkit_verified',
          turnedLeft: true,
          turnedRight: true,
        );
        setState(() => _msg = '얼굴 인증 완료');
      } else {
        // bool false는 실패로 간주
        setState(() => _msg = '얼굴 인증 실패');
      }
      return;
    }

    // ✅ 실패/중단 결과는 Map으로 온다. ok==true가 아니면 성공 저장 금지.
    if (result is Map) {
      final ok = result['ok'] == true;

      if (!ok) {
        final reason = (result['reason'] ?? '얼굴 인증 실패').toString();
        final code = (result['code'] ?? '').toString();
        setState(() => _msg = code.isEmpty ? reason : '$reason ($code)');
        return;
      }

      // ok=true 케이스는 원칙상 FaceDetectorApp에서 사용하지 않지만,
      // 혹시 확장할 경우를 대비해 안전 처리.
      final path = (result['path'] ?? 'mlkit_verified').toString();
      final turnedLeft = result['turnedLeft'] == true;
      final turnedRight = result['turnedRight'] == true;

      // ✅ 미션 3개 고정이면 좌/우가 반드시 true여야 성공으로 인정
      if (!(turnedLeft && turnedRight)) {
        setState(() => _msg = '얼굴 인증 실패: 미션 미완료');
        return;
      }

      context.read<SignupFlowProvider>().setFaceResult(
        path: path,
        turnedLeft: turnedLeft,
        turnedRight: turnedRight,
      );
      setState(() => _msg = '얼굴 인증 완료');
      return;
    }

    // 나머지 타입은 실패 처리
    setState(() => _msg = '알 수 없는 결과 타입: ${result.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final flow = context.watch<SignupFlowProvider>();

    final statusText = (flow.faceCapturePath == null)
        ? '미완료'
        : (flow.faceTurnedLeft && flow.faceTurnedRight ? '완료' : '부분 완료');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '얼굴 인증',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text('현재 상태: $statusText'),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _busy ? null : () => _startFaceAuth(context),
            child: _busy
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
                : const Text('얼굴 인증 시작'),
          ),
        ),
        const SizedBox(height: 12),
        Text('path: ${flow.faceCapturePath ?? "-"}'),
        Text('turnedLeft: ${flow.faceTurnedLeft}'),
        Text('turnedRight: ${flow.faceTurnedRight}'),
        if (_msg != null) ...[
          const SizedBox(height: 12),
          Text(_msg!, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ],
    );
  }
}
