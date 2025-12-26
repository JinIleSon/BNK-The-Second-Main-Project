// lib/screens/auth/signup/personal_auth_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'signup_flow_provider.dart';
import 'personal_info_page.dart';

// TODO: 너 프로젝트의 FaceAuthScreen/FaceAuthResult import 경로로 수정
import '../../face/face_auth_screen.dart';
import '../../face/face_auth_result.dart';

import '../../../api/verification_api.dart';

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
          keyboardType:
          isPhone ? TextInputType.phone : TextInputType.emailAddress,
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

  @override
  bool get wantKeepAlive => true;

  Future<void> _startFaceAuth(BuildContext context) async {
    setState(() => _msg = null);

    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const FaceAuthScreen()),
    );

    if (!mounted) return;
    if (result == null) return;

    // String path 반환 케이스
    if (result is String) {
      context.read<SignupFlowProvider>().setFaceResult(
        path: result,
        turnedLeft: true,
        turnedRight: true,
      );
      setState(() => _msg = '얼굴 인증 결과를 저장했습니다.');
      return;
    }

    // FaceAuthResult 반환 케이스
    if (result is FaceAuthResult) {
      context.read<SignupFlowProvider>().setFaceResult(
        path: result.path,
        turnedLeft: result.turnedLeft,
        turnedRight: result.turnedRight,
      );
      setState(() => _msg = '얼굴 인증 결과를 저장했습니다.');
      return;
    }

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
            onPressed: () => _startFaceAuth(context),
            child: const Text('얼굴 인증 시작'),
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
