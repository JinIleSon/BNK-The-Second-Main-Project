import 'package:flutter/material.dart';

import 'tabs/boarder_content.dart';
import 'tabs/boarder_list.dart';
import 'tabs/boarder_recommend.dart';
import 'tabs/boarder_following.dart';
import 'tabs/boarder_news.dart';
import 'pages/boarder_profile.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : (게시판)피드 main
 */

class BoardMain extends StatefulWidget {
  const BoardMain({Key? key}) : super(key: key);

  @override
  State<BoardMain> createState() => _BoardMainState();
}

class _BoardMainState extends State<BoardMain>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 추천 / 팔로잉 / 뉴스 / 콘텐츠 → 5개 탭
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToProfile() {
    // 우측 상단 프로필 아이콘 눌렀을 때 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BoarderProfile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
            onPressed: _goToProfile,
            icon: const CircleAvatar(
              radius: 14,
              child: Icon(Icons.person, size: 18),
            ),
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
            Tab(text: '게시판'),
            Tab(text: '뉴스'),
            Tab(text: '콘텐츠'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
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
