// lib/screens/auth/signup/signup_done_page.dart
import 'package:flutter/material.dart';

class SignupDonePage extends StatelessWidget {
  const SignupDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가입 완료')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('가입이 완료되었습니다.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
