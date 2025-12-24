import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/member_api.dart';

// ✅ 신규 회원가입 플로우(개인/기업 선택 → 화면 분기)
import 'signup/signup_flow_provider.dart';
import 'signup/personal_auth_page.dart';
import 'signup/company_info_page.dart';

/*
  날짜 : 2025.12.22(월)
  이름 : 이준우
  내용 :
   - login.main 프론트 생성(home_tab 우측 상단 누르면 이동)
   - my_page case 3 login 기능 가져와서 page 분리

  날짜 : 2025.12.24(수)
  이름 : 조지영
  내용 :
   - signup 버튼 클릭 시 개인/기업 회원가입 선택 바텀시트 추가
   - 회원가입 진입 동선 개선(개인/기업 타입 선택 → 가입 페이지 이동)
   - 회원가입 유형 선택 UI(개인/기업) 및 라우팅 연결
   - 회원가입 버튼을 유형 선택 모달로 변경(개인/기업 분기)
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
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMsg = result.message ?? '로그인에 실패했습니다.';
      });
    }
  }

  // ✅ 회원가입 유형 선택(개인/기업) 바텀시트 → 신규 플로우 연결
  void _openSignupSelector() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '회원가입 유형 선택',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);

                    // ✅ 개인 플로우 선택 + 개인 인증 화면 진입
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
                  child: const Text('개인회원'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);

                    // ✅ 기업 플로우 선택 + 기업 정보 입력 화면 진입
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
                  child: const Text('기업회원'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final showMascot = bottom == 0; // ✅ 키보드 올라오면 이미지 숨김

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
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ 부기 캐릭터(로그인 폼 상단)
              if (showMascot) ...[
                const SizedBox(height: 8),
                Center(
                  child: Image.asset(
                    'assets/images/boogi.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
              ],

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

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: 아이디 찾기 페이지로 이동
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
                    onPressed: _openSignupSelector,
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
