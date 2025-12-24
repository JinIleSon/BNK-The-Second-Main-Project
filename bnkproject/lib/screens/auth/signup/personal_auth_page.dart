// lib/screens/auth/signup/personal_auth_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'personal_info_page.dart';

// TODO: 너 프로젝트의 FaceAuthScreen/FaceAuthResult import 경로로 수정
import '../../face/face_auth_screen.dart';
import '../../face/face_auth_result.dart';

class PersonalAuthPage extends StatelessWidget {
  const PersonalAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개인 인증'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '휴대폰'),
              Tab(text: '이메일'),
              Tab(text: '얼굴'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OtpAuthTab(channel: AuthChannel.phone),
            _OtpAuthTab(channel: AuthChannel.email),
            _FaceAuthTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: flow.canGoPersonalInfo
                ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
            )
                : null,
            child: const Text('다음'),
          ),
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

class _OtpAuthTabState extends State<_OtpAuthTab> {
  final _targetCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _sent = false;
  bool _busy = false;
  String? _msg;

  @override
  void dispose() {
    _targetCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.channel == AuthChannel.phone;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _targetCtrl,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: isPhone ? '휴대폰 번호' : '이메일',
              hintText: isPhone ? '01012345678' : 'test@sample.com',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                    final target = _targetCtrl.text.trim();
                    if (target.isEmpty) {
                      setState(() => _msg = 'target을 입력해라');
                      return;
                    }
                    setState(() {
                      _busy = true;
                      _msg = null;
                    });
                    try {
                      // TODO: 실제 API 연결 시 SignupApi 주입해서 호출
                      await Future.delayed(const Duration(milliseconds: 300));
                      setState(() => _sent = true);
                      setState(() => _msg = '인증코드 발송됨');
                    } catch (e) {
                      setState(() => _msg = '발송 실패: $e');
                    } finally {
                      setState(() => _busy = false);
                    }
                  },
                  child: const Text('코드 발송'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeCtrl,
            enabled: _sent,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '인증코드'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: (!_sent || _busy)
                ? null
                : () async {
              final target = _targetCtrl.text.trim();
              final code = _codeCtrl.text.trim();
              if (code.length < 4) {
                setState(() => _msg = '코드가 짧다');
                return;
              }
              setState(() {
                _busy = true;
                _msg = null;
              });
              try {
                // TODO: 실제 API verify 호출
                await Future.delayed(const Duration(milliseconds: 300));

                context.read<SignupFlowProvider>().setPersonalVerified(
                  channel: widget.channel,
                  target: target,
                );
                setState(() => _msg = '인증 성공');
              } catch (e) {
                setState(() => _msg = '인증 실패: $e');
              } finally {
                setState(() => _busy = false);
              }
            },
            child: const Text('인증 확인'),
          ),
          const SizedBox(height: 12),
          if (_msg != null) Align(alignment: Alignment.centerLeft, child: Text(_msg!)),
        ],
      ),
    );
  }
}

class _FaceAuthTab extends StatelessWidget {
  const _FaceAuthTab();

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('현재 상태: ${flow.faceCapturePath == null ? "미완료" : "완료"}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              // TODO: FaceAuthScreen이 String/Result 반환 형태에 맞춰 수정
              final result = await Navigator.push<FaceAuthResult>(
                context,
                MaterialPageRoute(builder: (_) => const FaceAuthScreen()),
              );
              if (result == null) return;

              context.read<SignupFlowProvider>().setFaceResult(
                path: result.path,
                turnedLeft: result.turnedLeft,
                turnedRight: result.turnedRight,
              );
            },
            child: const Text('얼굴 인증 시작'),
          ),
          const SizedBox(height: 12),
          Text('path: ${flow.faceCapturePath ?? "-"}'),
          Text('turnedLeft: ${flow.faceTurnedLeft}'),
          Text('turnedRight: ${flow.faceTurnedRight}'),
        ],
      ),
    );
  }
}
