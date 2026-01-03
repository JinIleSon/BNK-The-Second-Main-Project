import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/signup/authsession.dart';
import 'tabs/boarder_content.dart';
import 'tabs/boarder_list.dart';
import 'tabs/boarder_recommend.dart';
import 'tabs/boarder_following.dart';
import 'tabs/boarder_news.dart';
import 'pages/boarder_profile.dart';

// ✅ demo_main.dart 진입 위젯 사용 (ML Kit 얼굴 검출 PoC)
import 'package:bnkproject/screens/mlkit_face_detection_start/demo_main.dart';
// ✅ 승인 게이트(생체인증) PoC
import 'package:bnkproject/screens/mlkit_face_detection_start/approval_poc/approval_gate_page.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

class BoardMain extends StatefulWidget {
  const BoardMain({super.key});

  @override
  State<BoardMain> createState() => _BoardMainState();
}

class _BoardMainState extends State<BoardMain>
    with SingleTickerProviderStateMixin, RouteAware {
  late final TabController _tabController;

  static const baseUrl = "http://10.0.2.2:8080/BNK";

  String _avatarUrl = "icon:0";
  bool _avatarLoading = false;

  final List<IconData> avatarIcons = const [
    Icons.headset_mic_rounded,
    Icons.android_rounded,
    Icons.savings_rounded,
    Icons.auto_graph_rounded,
    Icons.rocket_launch_rounded,
    Icons.pets_rounded,
    Icons.sports_esports_rounded,
    Icons.face_rounded,
  ];

  int _avatarIndexFromUrl(String url) {
    if (url.startsWith("icon:")) {
      final idx = int.tryParse(url.split(":").last);
      if (idx != null && idx >= 0 && idx < avatarIcons.length) return idx;
    }
    return 0;
  }

  Map<String, String> _authHeaders() {
    final t = authsession.token;
    if (t == null || t.isEmpty) return {"Content-Type": "application/json"};
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $t",
    };
  }

  Future<void> _fetchMyAvatar() async {
    final t = authsession.token;

    if (t == null || t.isEmpty) {
      if (mounted) setState(() => _avatarUrl = "icon:0");
      return;
    }

    if (mounted) setState(() => _avatarLoading = true);

    try {
      final uri = Uri.parse("$baseUrl/api/profile/me");
      final res = await http.get(uri, headers: _authHeaders());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final p = data["profile"] ?? {};
        final avatar = (p["avatarUrl"] ?? "icon:0").toString();

        if (mounted) {
          setState(() => _avatarUrl = avatar.isEmpty ? "icon:0" : avatar);
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {

        if (mounted) setState(() => _avatarUrl = "icon:0");
      }
    } catch (_) {
      // 실패해도 기본 아이콘 유지
    } finally {
      if (mounted) setState(() => _avatarLoading = false);
    }
  }

  Widget _buildAppBarAvatar() {
    final t = authsession.token;

    if (t == null || t.isEmpty) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person_outline, size: 18, color: Colors.white70),
      );
    }

    if (_avatarLoading) {
      return const CircleAvatar(
        radius: 14,
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final idx = _avatarIndexFromUrl(_avatarUrl);
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white10,
      child: Icon(avatarIcons[idx], size: 18, color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchMyAvatar(); // ✅ 첫 진입 시 1회
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ RouteAware 구독 (뒤로 돌아왔을 때 didPopNext 호출되게)
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // ✅ 다른 화면 갔다가 "이 화면으로 돌아올 때" 실행됨 (로그인/프로필 수정 후 자동 갱신)
    _fetchMyAvatar();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // ✅ 구독 해제
    _tabController.dispose();
    super.dispose();
  }


  void _goToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BoarderProfile()),
    );

    if (!mounted) return;
    await _fetchMyAvatar();
  }

  void _goToFaceDetector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MlkitDemoEntryPage()),
    );
  }

  void _goToApprovalGate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApprovalGatePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '피드',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _goToFaceDetector,
            icon: const Icon(Icons.face),
            tooltip: '얼굴인증 테스트',
          ),
          IconButton(
            onPressed: _goToApprovalGate,
            icon: const Icon(Icons.verified_user),
            tooltip: '거래승인 PoC',
          ),
          IconButton(
            onPressed: _goToProfile,
            icon: _buildAppBarAvatar(),
            tooltip: '프로필',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: '추천'),
            Tab(text: '팔로잉'),
            Tab(text: '커뮤니티'),
            Tab(text: '뉴스'),
            Tab(text: '콘텐츠'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: const [
            BoarderRecommend(),
            BoarderFollowing(),
            BoarderList(),
            BoarderNews(),
            BoarderContent(),
          ],
        ),
      ),
    );
  }
}