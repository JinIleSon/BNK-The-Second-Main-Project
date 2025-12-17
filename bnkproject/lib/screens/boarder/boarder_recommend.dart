import 'package:flutter/material.dart';
import 'widgets/category_tab.dart';
import 'widgets/feed_item.dart';
import 'widgets/new_item.dart';
import 'boarder_detail.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 추천
 */

class BoarderRecommend extends StatefulWidget {
  const BoarderRecommend({super.key});

  @override
  State<BoarderRecommend> createState() => _BoarderRecommendState();
}

class _BoarderRecommendState extends State<BoarderRecommend> {
  int chipIndex = 0;

  // 추천 상단 카테고리 (사진 느낌)
  final chips = const <ChipItem>[
    ChipItem("전체"),
    ChipItem("미국주식이야기", iconUrl: "https://picsum.photos/seed/us/80/80"),
    ChipItem("따박따박배당투자", iconUrl: "https://picsum.photos/seed/div/80/80"),
  ];

  // 추천 피드 더미
  final items = <FeedItem>[
    FeedItem(
      postId: 1,
      author: "StockStory",
      timeAgo: "2시간 전 · 뉴스케일파워에 남긴 글",
      title: "원자력 스타트업의 번지점프, 바닥은 어디인가",
      body: "11월 6일, 3분기 실적 발표가 모든 걸 바꿔놨다...\n주당순손실/매출 쇼크 → 장중 급락...",
      avatarUrl: "https://i.pravatar.cc/200?img=12",
      likeCount: 18,
      commentCount: 3,
      isLiked: false,
    ),
    FeedItem(
      postId: 2,
      author: "미국주식이야기",
      timeAgo: "3분 전 · 지수총총님이 남긴 글",
      title: "스페이스X 상장 초읽기",
      body: "블룸버그 보도 기준 IPO 관련 내용 정리.\n밸류/시점/규제 포인트만 빠르게.",
      avatarUrl: "https://i.pravatar.cc/200?img=4",
      likeCount: 42,
      commentCount: 6,
      isLiked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const SizedBox(height: 10),

            CategoryTab(
              items: chips,
              selectedIndex: chipIndex,
              onTap: (i) => setState(() => chipIndex = i),
            ),

            const SizedBox(height: 14),

            ...items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FeedItemCard(
                item: it,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BoarderDetail(item: it)),
                  );
                  setState(() {});
                },
                onToggleLike: () {
                  setState(() {
                    it.isLiked = !it.isLiked;
                    it.likeCount += it.isLiked ? 1 : -1;
                  });
                },
              ),
            )),
          ],
        ),

        // 우측 하단 고정 글쓰기 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: "write_recommend", // 팔로잉이랑 겹치면 다른 값으로
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewItemPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("글쓰기"),
            ),
          ),
        ),
      ],
    );
  }
}
