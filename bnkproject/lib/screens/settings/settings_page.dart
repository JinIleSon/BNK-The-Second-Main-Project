import 'package:flutter/material.dart';

class TossSettingsPage extends StatelessWidget {
  const TossSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '부기증권 설정',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        children: const [
          _SettingTile(title: '개인 정보 변경'),
          _SettingTile(title: '권리'),
          _GroupDivider(),

          _SectionLabel('종목 첫 화면 설정'),
          _SettingTile(
            title: '보유 종목',
            subtitle: '순서 변경, 숨기기',
          ),
          _GroupDivider(),

          _SettingTile(
            title: '해외종목 기본 통화',
            trailingText: '원 (₩)',
          ),
          _SettingTile(
            title: '국내주식 거래 방식',
            trailingText: '통합 모드',
          ),
          _SettingTile(title: '알림'),
          _SettingTile(title: '계좌'),
          _SettingTile(title: '커뮤니티'),
          _SettingTile(
            title: '거래',
            subtitle: '인증없이 거래, 구매 시 환전 안내',
          ),
          _SettingTile(
            title: '보안',
            subtitle: '해외 접속, 화면 항상 켜기, 로그인된 기기',
          ),
          _GroupDivider(),

          _SettingTile(title: '계좌 만들기'),
          _GroupDivider(),

          _SettingTile(title: '공지사항'),
          _SettingTile(title: '실험실'),
          _SettingTile(title: '자주 묻는 질문'),
          _SettingTile(title: '약관 및 개인정보 처리 동의'),
          _SettingTile(title: '탈퇴하기'),
          _FooterInfo(
            versionText: '웹 버전 : v251214.1837',
            lastAccessText: '마지막 접속 : 모바일 | 25.12.11 13:09',
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white38,
      fontWeight: FontWeight.w600,
    );
    final trailingStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white54,
      fontWeight: FontWeight.w700,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: subStyle),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 10),
              Text(trailingText!, style: trailingStyle),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    // 스샷처럼 "두꺼운 섹션 구분" 느낌
    return Container(
      height: 14,
      color: Colors.black26,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white38,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Text(text, style: style),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  final String versionText;
  final String lastAccessText;

  const _FooterInfo({
    required this.versionText,
    required this.lastAccessText,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white30,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(versionText, style: style),
          const SizedBox(height: 6),
          Text(lastAccessText, style: style),
        ],
      ),
    );
  }
}
