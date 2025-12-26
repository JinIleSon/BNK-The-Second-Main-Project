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

  // ✅ UX 개선: 엄지로 누르기 편한 카드형 바텀시트 + 안전한 네비게이션(pop 후 push 프레임 분리)
  void _openSignupSelector() {
    final rootContext = context;

    showModalBottomSheet(
      context: rootContext,
      useRootNavigator: true, // ✅ nested navigator 꼬임 방지
      isScrollControlled: false,
      showDragHandle: true,
      backgroundColor: Theme.of(rootContext).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        Widget optionCard({
          required IconData icon,
          required String title,
          required String desc,
          required VoidCallback onTapAfterClose,
        }) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pop(sheetCtx);

                // ✅ pop 직후 push는 프레임 넘겨서 안정화
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  onTapAfterClose();
                });
              },
              child: Container(
                height: 72, // ✅ 엄지 타깃 크게
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(rootContext).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Theme.of(rootContext)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                      ),
                      child: Icon(icon),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(rootContext).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '회원가입 유형 선택',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      icon: const Icon(Icons.close),
                      tooltip: '닫기',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                optionCard(
                  icon: Icons.person_outline,
                  title: '개인회원',
                  desc: '휴대폰/이메일 인증 후 가입',
                  onTapAfterClose: () {
                    rootContext
                        .read<SignupFlowProvider>()
                        .selectUserType(SignupUserType.personal);

                    Navigator.of(rootContext, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const PersonalAuthPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                optionCard(
                  icon: Icons.business_outlined,
                  title: '기업회원',
                  desc: '기업 정보 입력 후 가입',
                  onTapAfterClose: () {
                    rootContext
                        .read<SignupFlowProvider>()
                        .selectUserType(SignupUserType.company);

                    Navigator.of(rootContext, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const CompanyInfoPage()),
                    );
                  },
                ),

                const SizedBox(height: 12),
                Text(
                  '아래로 스와이프하거나 바깥을 터치하면 닫힙니다.',
                  style: TextStyle(fontSize: 12, color: Theme.of(rootContext).hintColor),
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
                onSubmitted: (_) {
                  if (!_loading) _doLogin();
                },
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
