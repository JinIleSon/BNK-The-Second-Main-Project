import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  final VoidCallback onLogout;

  const MyPage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _LoggedInView(onLogout: onLogout);
  }
}

/// -------------------- 로그아웃 화면(기존 코드 유지) --------------------
class _LoggedOutView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const _LoggedOutView({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<_LoggedOutView> createState() => _LoggedOutViewState();
}

class _LoggedOutViewState extends State<_LoggedOutView> {
  final TextEditingController midCtrl = TextEditingController();
  final TextEditingController pwCtrl = TextEditingController();

  bool loading = false;
  String? errorMsg;

  Future<void> _handleLogin() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320, // ← 여기 숫자 줄이면 더 좁아짐 (예: 280, 300 등)
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: midCtrl,
                decoration: const InputDecoration(
                  labelText: '아이디',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pwCtrl,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (errorMsg != null)
                Text(
                  errorMsg!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("로그인", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- 로그인 화면(토스 스타일) --------------------
class _LoggedInView extends StatelessWidget {
  final VoidCallback onLogout;
  const _LoggedInView({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '마이',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: Colors.white),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            _CardBox(
              color: cardColor,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.person, color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '사용자 님',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '프로필/계정 설정',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _SectionTitle('내 정보'),
            const SizedBox(height: 8),
            _CardBox(
              color: cardColor,
              child: Column(
                children: const [
                  _MenuTile(
                    icon: Icons.badge_outlined,
                    title: '내 계정',
                    subtitle: '연락처/보안/인증 관리',
                  ),
                  _DividerLine(),
                  _MenuTile(
                    icon: Icons.notifications_none,
                    title: '알림',
                    subtitle: '알림 설정',
                  ),
                  _DividerLine(),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: '보안',
                    subtitle: '비밀번호/생체인증',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _SectionTitle('서비스'),
            const SizedBox(height: 8),
            _CardBox(
              color: cardColor,
              child: Column(
                children: const [
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: '이용내역',
                    subtitle: '결제/구독/거래 내역',
                  ),
                  _DividerLine(),
                  _MenuTile(
                    icon: Icons.support_agent_outlined,
                    title: '고객센터',
                    subtitle: '문의/도움말',
                  ),
                  _DividerLine(),
                  _MenuTile(
                    icon: Icons.campaign_outlined,
                    title: '공지사항',
                    subtitle: '업데이트/안내',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _SectionTitle('앱 설정'),
            const SizedBox(height: 8),
            _CardBox(
              color: cardColor,
              child: Column(
                children: [
                  const _MenuTile(
                    icon: Icons.color_lens_outlined,
                    title: '테마',
                    subtitle: '다크 모드 사용 중',
                  ),
                  const _DividerLine(),
                  _SwitchTile(
                    icon: Icons.visibility_outlined,
                    title: '잔고 숨기기',
                    subtitle: '홈에서 금액 가리기',
                    initialValue: false,
                    onChanged: (v) {},
                  ),
                  const _DividerLine(),
                  const _MenuTile(
                    icon: Icons.info_outline,
                    title: '버전 정보',
                    subtitle: 'v1.0.0',
                    showChevron: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: onLogout, // ✅ 여기서 로그아웃 처리
                child: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------- 아래 위젯들은 그대로 -------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.white60,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;
  final Color color;
  const _CardBox({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showChevron;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white70, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              setState(() => value = v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Colors.white10);
  }
}
