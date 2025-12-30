import 'package:flutter/material.dart';

import 'tabs/boarder_content.dart';
import 'tabs/boarder_list.dart';
import 'tabs/boarder_recommend.dart';
import 'tabs/boarder_following.dart';
import 'tabs/boarder_news.dart';
import 'pages/boarder_profile.dart';

// ✅ demo_main.dart 진입 위젯 사용
import 'package:bnkproject/mlkit_face_detection_start/demo_main.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : (게시판)피드 main

    날짜 : 2025.12.30(화)
    추가 : 조지영
    내용 : (게시판)AppBar 우측 액션에 얼굴인증(ML Kit) 테스트 진입 버튼 추가
 */

class BoardMain extends StatefulWidget {
  const BoardMain({super.key});

  @override
  State<BoardMain> createState() => _BoardMainState();
}

class _BoardMainState extends State<BoardMain> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BoarderProfile()),
    );
  }

  // ✅ 얼굴인증(ML Kit) 테스트 화면으로 이동 (demo_main.dart 경유)
  void _goToFaceDetector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MlkitDemoEntryPage()),
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _goToFaceDetector,
            icon: const Icon(Icons.face),
            tooltip: '얼굴인증 테스트',
          ),
          IconButton(
            onPressed: _goToProfile,
            icon: const CircleAvatar(
              radius: 14,
              child: Icon(Icons.person, size: 18),
            ),
            tooltip: '프로필',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
