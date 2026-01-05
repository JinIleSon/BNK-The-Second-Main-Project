import 'package:flutter/material.dart';

import '../settings/settings_page.dart';
import 'package:bnkproject/game/game_entry.dart';
import '../daily_mission/pages/travel_page.dart';
import 'package:bnkproject/screens/sto/pages/sto_season_page.dart';

// ✅ goals 진입점(Entry) import
import 'package:bnkproject/screens/goals/retirement_trip/retirement_trip_entry.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedTopTab = 0; // 0: 알림, 1: 고객센터

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final card = Theme.of(context).cardColor;
    final bodySmall = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TossSettingsPage()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TopSegmentButton(
                      selected: selectedTopTab == 0,
                      icon: Icons.notifications_none,
                      label: '알림',
                      showDot: true,
                      onTap: () => setState(() => selectedTopTab = 0),
                    ),
                  ),
                  Container(width: 1, height: 22, color: Colors.white12),
                  Expanded(
                    child: _TopSegmentButton(
                      selected: selectedTopTab == 1,
                      icon: Icons.headset_mic_outlined,
                      label: '고객센터',
                      onTap: () => setState(() => selectedTopTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _BigMenuRow(title: '매일 주식받는 출석체크', onTap: () {}),
            _BigMenuRow(title: '주식 모으기', trailingText: '수수료 무료', onTap: () {}),
            _BigMenuRow(title: '증시 캘린더', onTap: () {}),
            _BigMenuRow(title: '진행중인 이벤트', trailingText: '4개', onTap: () {}),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 14),

            Text('부기증권 서비스', style: bodySmall),
            const SizedBox(height: 10),

            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.show_chart,
              iconColor: Colors.redAccent,
              title: '주식',
              subtitle: '조건주문 · 지정가 알림',
              onTap: () {},
            ),
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.local_offer_outlined,
              iconColor: Colors.orangeAccent,
              title: '채권',
              onTap: () {},
            ),
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.lightGreenAccent,
              title: '계좌',
              subtitle: '송금 · 환전 · 양도세',
              onTap: () {},
            ),
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.public,
              iconColor: Colors.lightBlueAccent,
              title: '시장정보',
              subtitle: '주요 지수',
              onTap: () {},
            ),
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.forum_outlined,
              iconColor: Colors.blueAccent,
              title: '커뮤니티',
              subtitle: '프로필 · 주제별 커뮤니티',
              onTap: () {},
            ),

            // ✅ 게임
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.sports_esports,
              iconColor: Colors.purpleAccent,
              title: '게임',
              subtitle: '미니게임 · 출석 · 리워드',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const GameEntryPage()),
                );
              },
            ),

            // ✅ 일일 미션 (FLAG)
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.flag_outlined,
              iconColor: Colors.tealAccent,
              title: '일일 미션',
              subtitle: '부산 핫플 · 미션 · 스탬프',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => TravelPage()),
                );
              },
            ),

            // ✅ 은퇴 후 여행 계획 (goals entry)
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.flight_takeoff,
              iconColor: Colors.lightBlueAccent,
              title: '은퇴 후 여행 계획',
              subtitle: '목표 설정 · 예산 · 적립 플랜',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const RetirementTripEntryPage()),
                );
              },
            ),

            // ✅ STO 시즌 투자
            _ServiceTile(
              iconBg: const Color(0xFF2A2C33),
              icon: Icons.sports_baseball,
              iconColor: Colors.amberAccent,
              title: 'STO 시즌 투자',
              subtitle: '야구 시즌처럼 라운드 투자',
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => StoSeasonPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===== 아래부터 헬퍼 위젯들 (이게 없어서 네가 터진 거임) =====

class _TopSegmentButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final bool showDot;
  final VoidCallback onTap;

  const _TopSegmentButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: selected ? Colors.white : Colors.white70,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : Colors.white70),
                if (showDot)
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(radius: 3, backgroundColor: Colors.redAccent),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _BigMenuRow extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _BigMenuRow({
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final trailing = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white54,
      fontWeight: FontWeight.w700,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(title, style: t)),
            if (trailingText != null) ...[
              const SizedBox(width: 10),
              Text(trailingText!, style: trailing),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white38,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: subStyle),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
