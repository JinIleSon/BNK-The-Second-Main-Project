// lib/screens/auth/signup/signup_type_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_flow_provider.dart';
import 'personal_auth_page.dart';
import 'company_info_page.dart';

class SignupTypePage extends StatelessWidget {
  const SignupTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignupFlowProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('신규가입')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _typeButton(
              context: context,
              title: '개인 가입',
              selected: flow.userType == SignupUserType.personal,
              onTap: () {
                context.read<SignupFlowProvider>().selectUserType(SignupUserType.personal);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalAuthPage()));
              },
            ),
            const SizedBox(height: 12),
            _typeButton(
              context: context,
              title: '기업 가입',
              selected: flow.userType == SignupUserType.company,
              onTap: () {
                context.read<SignupFlowProvider>().selectUserType(SignupUserType.company);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyInfoPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title),
      ),
    );
  }
}
