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
    final isPersonal = flow.userType == SignupUserType.personal;
    final isCompany = flow.userType == SignupUserType.company;

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                '유형을 선택하세요',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _TypeIconTile(
                      label: '개인',
                      icon: Icons.person_outline,
                      selected: isPersonal,
                      onTap: () {
                        context
                            .read<SignupFlowProvider>()
                            .selectUserType(SignupUserType.personal);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonalAuthPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeIconTile(
                      label: '기업',
                      icon: Icons.receipt_long_outlined,
                      selected: isCompany,
                      onTap: () {
                        context
                            .read<SignupFlowProvider>()
                            .selectUserType(SignupUserType.company);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyInfoPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 하단 안내 문구(선택)
              Text(
                '개인: 휴대폰/이메일/얼굴 인증 후 가입\n기업: 기업 정보 입력 후 가입',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIconTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeIconTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Colors.white : Colors.white24;
    final bgColor = selected ? Colors.white10 : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 원형 아이콘 영역
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Icon(icon, size: 44, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
