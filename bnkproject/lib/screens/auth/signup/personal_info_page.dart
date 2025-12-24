// lib/screens/auth/signup/personal_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'signup_done_page.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _nameCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('개인 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('인증수단: ${flow.authChannel}'),
            Text('인증대상: ${flow.verifiedTarget ?? "-"}'),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: '이름')),
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
                  final name = _nameCtrl.text.trim();
                  final pw = _pwCtrl.text.trim();
                  if (name.isEmpty || pw.length < 4) return;

                  context.read<SignupFlowProvider>()
                    ..personalName = name
                    ..personalPassword = pw;

                  // TODO: SignupApi.signupPersonal(payload) 호출
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupDonePage()),
                        (r) => false,
                  );
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
