import 'package:flutter/material.dart';

import 'screens/home/home_tab.dart';
import 'screens/favorite/favorite_page.dart';
import 'screens/discovery/discovery_page.dart';
import 'screens/boarder/boarder_main.dart';
import 'screens/my/my_page.dart';
import 'screens/auth/login_main.dart';
import 'screens/splash/splash_screen.dart';

import 'screens/auth/signup/signup_flow_provider.dart';
import 'screens/auth/signup/signup_type_page.dart';

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
      home: SplashScreen(next: const TossLikeHomePage()),

    );
  }
}

class TossLikeHomePage extends StatefulWidget {
  const TossLikeHomePage({super.key});

  @override
  State<TossLikeHomePage> createState() => _TossLikeHomePageState();
}

class _TossLikeHomePageState extends State<TossLikeHomePage> {
  int _selectedIndex = 0; // 0: 홈, 1: 관심, 2: 발견, 3: 마이, 4: 피드
  bool _isLoggedIn = false; // 나중에 인증, 인가 설정

  Future<void> _openLogin() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (ok == true) {
      setState(() => _isLoggedIn = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = HomeTab(
            cardColor: cardColor,
            textTheme: textTheme,
            onOpenLogin: _openLogin,
            isLoggedIn: _isLoggedIn,
        );
        break;
      case 1:
        body = const FavoritePage();
        break;
      case 2:
        body = const DiscoveryPage();
        break;
      case 3:
        body = MyPage(
          onLogout: () {
            setState(() => _isLoggedIn = false);
          },
        );
        break;
      case 4:
        body = const BoardMain(); // 토스 피드 메인
        break;

      default:
        body = HomeTab(
            cardColor: cardColor,
            textTheme: textTheme,
            onOpenLogin: _openLogin,
            isLoggedIn: _isLoggedIn,
        );
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        onOpenLogin: _openLogin,
        isLoggedIn: _isLoggedIn,
      ),
    );
  }
}

/// 하단 탭바
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  final Future<void> Function() onOpenLogin;
  final bool isLoggedIn;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.onOpenLogin,
    required this.isLoggedIn,
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