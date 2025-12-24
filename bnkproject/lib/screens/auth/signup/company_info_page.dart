// lib/screens/auth/signup/company_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'signup_done_page.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  final _companyName = TextEditingController();
  final _bizNo = TextEditingController();
  final _managerName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _companyName.dispose();
    _bizNo.dispose();
    _managerName.dispose();
    _email.dispose();
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기업 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _companyName, decoration: const InputDecoration(labelText: '회사명')),
            const SizedBox(height: 12),
            TextField(controller: _bizNo, decoration: const InputDecoration(labelText: '사업자번호')),
            const SizedBox(height: 12),
            TextField(controller: _managerName, decoration: const InputDecoration(labelText: '담당자명')),
            const SizedBox(height: 12),
            TextField(controller: _email, decoration: const InputDecoration(labelText: '이메일')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: '연락처')),
            const SizedBox(height: 12),
            TextField(controller: _pw, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final flow = context.read<SignupFlowProvider>();
                  flow
                    ..companyName = _companyName.text.trim()
                    ..bizNo = _bizNo.text.trim()
                    ..managerName = _managerName.text.trim()
                    ..companyEmail = _email.text.trim()
                    ..companyPhone = _phone.text.trim()
                    ..companyPassword = _pw.text.trim();

                  // TODO: SignupApi.signupCompany(payload) 호출
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
