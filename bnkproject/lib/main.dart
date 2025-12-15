import 'package:flutter/material.dart';

import 'screens/home/home_tab.dart';
import 'screens/favorite/favorite_page.dart';
import 'screens/discovery/discovery_page.dart';
import 'screens/boarder/board_main.dart';
import 'api/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toss Style Screen',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05060A),
        cardColor: const Color(0xFF14151B),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const TossLikeHomePage(),
    );
  }
}

class TossLikeHomePage extends StatefulWidget {
  const TossLikeHomePage({super.key});

  @override
  State<TossLikeHomePage> createState() => _TossLikeHomePageState();
}

class _TossLikeHomePageState extends State<TossLikeHomePage> {
  int _selectedIndex = 0; // 0: 홈, 1: 관심, 2: 발견, 3: 마이, 4: 피드(임시)

  bool _isLoggedIn = false; // 피드 이동시 로그인 테스트(이준우)

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = HomeTab(cardColor: cardColor, textTheme: textTheme);
        break;
      case 1:
        body = const FavoritePage();
        break;
      case 2:
        body = const DiscoveryPage();
        break;
      case 3:
        body = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isLoggedIn ? "로그인 상태 ✅" : "로그아웃 상태 ❌"),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        onLoginSuccess: () {
                          setState(() => _isLoggedIn = true);
                        },
                      ),
                    ),
                  );

                  // ✅ LoginPage가 true를 리턴한 경우에만 로그인 처리
                  if (ok == true) {
                    setState(() => _isLoggedIn = true);
                  }
                },
                child: const Text("로그인"),
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoggedIn = false);
                  // (토큰 저장했으면 여기서 같이 삭제)
                },
                child: const Text("로그아웃(임시)"),
              ),
            ],
          ),
        );
        break;
      case 4:
        body = const BoardMain(); // 토스 피드 메인
        break;

      default:
        body = HomeTab(cardColor: cardColor, textTheme: textTheme);
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

/// 하단 탭바
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0C10),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.home_outlined,
            label: '홈',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.favorite_border,
            label: '관심',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.explore_outlined,
            label: '발견',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 3,
            selectedIndex: selectedIndex,
            icon: Icons.person_outline,
            label: '마이',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 4,
            selectedIndex: selectedIndex,
            icon: Icons.dynamic_feed_outlined,
            label: '피드',
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == selectedIndex;
    final color = isActive ? Colors.white : Colors.white60;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5 - 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}