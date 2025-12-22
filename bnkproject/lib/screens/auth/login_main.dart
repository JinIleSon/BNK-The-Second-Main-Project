import 'package:flutter/material.dart';
import '../../api/member_api.dart';

/*
  날짜 : 2025.12.22(월)
  이름 : 이준우
  내용 :
   - login.main 프론트 생성(home_tab 우측 상단 누르면 이동)
   - my_page case 3 login 기능 가져와서 page 분리
*/

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final result = await memberApi.login(
      mid: _idCtrl.text.trim(),
      mpw: _pwCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result.ok) {
      // 로그인 성공
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMsg = result.message ?? '로그인에 실패했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 올라올 때 하단 패딩값
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "로그인",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 키보드 올라올 때도 버튼/입력창 가려지지 않게
          padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: bottom + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _idCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "아이디",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _pwCtrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loading ? null : _doLogin(),
                decoration: const InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              if (_errorMsg != null) ...[
                Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
              ],

              ElevatedButton(
                onPressed: _loading ? null : _doLogin,
                child: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("로그인"),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("홈으로"),
              ),

              // 나중에 확장할 영역(아이디찾기/비번찾기/회원가입)
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: 아이디 찾기 페이지로 이동
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const FindIdPage()));
                    },
                    child: const Text("아이디 찾기"),
                  ),
                  const Text("|"),
                  TextButton(
                    onPressed: () {
                      // TODO: 비밀번호 찾기 페이지로 이동
                    },
                    child: const Text("비밀번호 찾기"),
                  ),
                  const Text("|"),
                  TextButton(
                    onPressed: () {
                      // TODO: 회원가입 페이지로 이동
                    },
                    child: const Text("회원가입"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
