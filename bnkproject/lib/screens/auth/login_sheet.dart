import 'package:flutter/material.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "로그인",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _idCtrl,
            decoration: const InputDecoration(
              labelText: "아이디",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _pwCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "비밀번호",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              // ✅ 임시 로그인 성공 처리 (나중에 API/인증 붙이면 됨)
              Navigator.pop(context, true);
            },
            child: const Text("로그인"),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("나중에 할래요"),
          ),
        ],
      ),
    );
  }
}
