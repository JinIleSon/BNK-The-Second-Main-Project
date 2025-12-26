import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/member_api.dart';

// ✅ 신규 회원가입 플로우(개인/기업 선택 → 화면 분기)
import 'signup/signup_flow_provider.dart';
import 'signup/personal_auth_page.dart';
import 'signup/company_info_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  final _idFocus = FocusNode();
  final _pwFocus = FocusNode();

  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _idFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_loading) return;

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final result = await memberApi.login(
        mid: _idCtrl.text.trim(),
        mpw: _pwCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result.ok) {
        Navigator.pop(context, true);
        return;
      }

      setState(() {
        _errorMsg = result.message ?? '로그인에 실패했습니다.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMsg = '네트워크 오류가 발생했습니다.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ✅ 회원가입 유형 선택 바텀시트 (UX 개선 + overflow 방지 + Provider 상태 유지하며 다음 페이지 이동)
  void _openSignupSelector() {
    final rootContext = context;
    final theme = Theme.of(rootContext);

    showModalBottomSheet(
      context: rootContext,
      useRootNavigator: true,
      isScrollControlled: true, // ✅ 작은 화면/큰 글자에서도 안전
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  onTapAfterClose();
                });
              },
              child: Container(
                height: 72,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: theme.colorScheme.primary.withOpacity(0.08),
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
                              color: theme.hintColor,
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

        final maxH = MediaQuery.of(sheetCtx).size.height * 0.75;

        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                16 + MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '회원가입 유형 선택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
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

                  // ✅ 개인회원 → PersonalAuthPage 이동 (Provider 유지)
                  optionCard(
                    icon: Icons.person_outline,
                    title: '개인회원',
                    desc: '휴대폰/이메일 인증 후 가입',
                    onTapAfterClose: () {
                      final flow = rootContext.read<SignupFlowProvider>();
                      flow.selectUserType(SignupUserType.personal);

                      Navigator.of(rootContext, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: flow,
                            child: const PersonalAuthPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ✅ 기업회원 → CompanyInfoPage 이동 (Provider 유지)
                  optionCard(
                    icon: Icons.business_outlined,
                    title: '기업회원',
                    desc: '기업 정보 입력 후 가입',
                    onTapAfterClose: () {
                      final flow = rootContext.read<SignupFlowProvider>();
                      flow.selectUserType(SignupUserType.company);

                      Navigator.of(rootContext, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: flow,
                            child: const CompanyInfoPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  Text(
                    '아래로 스와이프하거나 바깥을 터치하면 닫힙니다.',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final showMascot = bottom == 0;

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
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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

                  TextFormField(
                    controller: _idCtrl,
                    focusNode: _idFocus,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return '아이디를 입력하세요.';
                      return null;
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_pwFocus),
                    decoration: const InputDecoration(
                      labelText: "아이디",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _pwCtrl,
                    focusNode: _pwFocus,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return '비밀번호를 입력하세요.';
                      return null;
                    },
                    onFieldSubmitted: (_) => _doLogin(),
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
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
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
        ),
      ),
    );
  }
}
