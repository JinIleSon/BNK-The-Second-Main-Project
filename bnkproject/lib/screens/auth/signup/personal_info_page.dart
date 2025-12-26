// lib/screens/auth/signup/personal_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'signup_done_page.dart';
import '../login_main.dart';
import 'package:bnkproject/screens/auth/signup/signup_api.dart';
import 'package:bnkproject/api/member_api.dart';


class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // DB 내용 참고해서 보기 편하게 수정(2025.12.26 이준우)
  final _idCtrl = TextEditingController();   // ✅ mid
  final _nameCtrl = TextEditingController(); // ✅ mname
  final _pwCtrl = TextEditingController();   // ✅ mpw
  late final SignupApi signupApi = SignupApi(baseUrl);

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    /*
        - 휴대폰 인증 완료된 값(예: 01012345678)
        - personal_auth_page 휴대폰 인증에 사용한 휴대폰 번호 저장
     */
    final mphone = flow.verifiedTarget;

    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 인증수단, 인증대상 Text 삭제 (2025.12.26 이준우)

            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pwCtrl,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final mid = _idCtrl.text.trim();
                  final mname = _nameCtrl.text.trim();
                  final mpw = _pwCtrl.text.trim();

                  if (mid.isEmpty) return;
                  if (mname.isEmpty) return;
                  if (mpw.length < 4) return;

                  if (mphone == null || mphone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('휴대폰 인증이 완료되지 않았습니다.')),
                    );
                    return;
                  }

                  try {
                    final res = await signupApi.signupPersonal(
                      mid: mid,
                      mpw: mpw,
                      mname: mname,
                      mphone: mphone,
                    );

                    if (!mounted) return;

                    if (!res.ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res.message.isNotEmpty ? res.message : '회원가입 실패')),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입 완료! 로그인 해주세요.')),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (r) => false,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('네트워크 오류: $e')),
                    );
                  }
                },
                child: const Text('가입 완료'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
