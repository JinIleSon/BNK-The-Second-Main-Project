// lib/screens/auth/signup/company_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'signup_api.dart';
import '../login_main.dart';

/*
    날짜 : 2025.12.29
    이름 : 이준우
    내용 : 기업 회원가입 백엔드 연동
*/

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  final _mid = TextEditingController();
  final _companyName = TextEditingController();
  final _bizNo = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();

  bool _loading = false;

  final inputDeco = const InputDecoration(
    border: UnderlineInputBorder(),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white54, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.purpleAccent, width: 1),
    ),
  );

  @override
  void dispose() {
    _mid.dispose();
    _companyName.dispose();
    _bizNo.dispose();
    _email.dispose();
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _signupCompany() async {
    if (_loading) return;

    final mid = _mid.text.trim();
    final mpw = _pw.text.trim();
    final mname = _companyName.text.trim();
    final mjumin = _bizNo.text.trim();
    final memail = _email.text.trim();
    final mphone = _phone.text.trim();

    if (mid.isEmpty || mpw.isEmpty || mname.isEmpty || mjumin.isEmpty || memail.isEmpty || mphone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수값을 모두 입력하세요.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final api = SignupApi('http://10.0.2.2:8080/BNK');

      final result = await api.signupCompany(
        mid: mid,
        mpw: mpw,
        mname: mname,
        mjumin: mjumin,
        memail: memail,
        mphone: mphone,
      );

      if (!mounted) return;

      if (!result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message.isNotEmpty ? result.message : '회원가입 실패')),
        );
        return;
      }

      final flow = context.read<SignupFlowProvider>();
      flow
        ..companyName = mname
        ..bizNo = mjumin
        ..companyEmail = memail
        ..companyPhone = mphone
        ..companyPassword = mpw;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (r) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기업 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _companyName,
              decoration: inputDeco.copyWith(labelText: '회사명'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _bizNo,
              decoration: inputDeco.copyWith(labelText: '사업자번호'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _email,
              decoration: inputDeco.copyWith(labelText: '이메일'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phone,
              decoration: inputDeco.copyWith(labelText: '연락처'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _mid,
              decoration: inputDeco.copyWith(labelText: '아이디'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pw,
              decoration: inputDeco.copyWith(labelText: '비밀번호'),
              obscureText: true,
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _signupCompany,
                child: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('가입 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}