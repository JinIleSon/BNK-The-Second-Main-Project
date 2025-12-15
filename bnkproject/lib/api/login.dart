import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Android Emulator에서 PC 로컬 Spring 접근
const String baseUrl = "http://10.0.2.2:8080/BNK";

/*
    날짜 : 2025.12.15
    이름 : 이준우
    내용 : 마이페이지 로그인 테스트
 */

class AuthSession {
  static String? token;
  static String? mid;
  static String? role;

  static bool get isLoggedIn => token != null;

  static void clear() {
    token = null;
    mid = null;
    role = null;
  }
}

// 마이페이지 임시 로그인 구현중
class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final midCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  bool loading = false;
  String msg = "";

  Future<void> doLogin() async {
    final mid = midCtrl.text.trim();
    final mpw = pwCtrl.text;

    if (mid.isEmpty || mpw.isEmpty) {
      setState(() => msg = "아이디/비밀번호를 입력해 주세요.");
      return;
    }

    setState(() {
      loading = true;
      msg = "";
    });

    try {
      final uri = Uri.parse("$baseUrl/api/mobile/auth/login");

      debugPrint("➡️ [LOGIN] POST $uri");
      debugPrint("➡️ [LOGIN] body={mid:$mid, mpw:${'*' * mpw.length}}");

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mid": mid, "mpw": mpw}),
      );

      final raw = utf8.decode(res.bodyBytes);

      debugPrint("⬅️ [LOGIN] status=${res.statusCode}");
      debugPrint("⬅️ [LOGIN] rawBody=$raw");

      final data = jsonDecode(raw);

      if (res.statusCode == 200 && data["ok"] == true) {
        AuthSession.token = data["token"];
        AuthSession.mid = data["mid"];
        AuthSession.role = data["role"];

        widget.onLoginSuccess();
        Navigator.pop(context, true);
        return;
      }

      setState(() => msg = "status=${res.statusCode}\n$raw");
    } catch (e) {
      setState(() => msg = "에러: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    midCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: midCtrl,
              decoration: const InputDecoration(labelText: "아이디 (mid)"),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: pwCtrl,
              decoration: const InputDecoration(labelText: "비밀번호 (mpw)"),
              obscureText: true,
              onSubmitted: (_) async => await doLogin(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : doLogin,
                child: Text(loading ? "로그인 중..." : "로그인"),
              ),
            ),
            const SizedBox(height: 10),
            Text(msg),
          ],
        ),
      ),
    );
  }
}
