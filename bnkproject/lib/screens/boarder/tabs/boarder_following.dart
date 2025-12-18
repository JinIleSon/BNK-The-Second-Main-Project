import 'package:flutter/material.dart';
import '../widgets/category_tab.dart';
import '../widgets/feed_item.dart';
import '../widgets/new_item.dart';
import '../pages/boarder_detail.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 팔로잉 탭
 */

class BoarderFollowing extends StatefulWidget {
  const BoarderFollowing({super.key});

  @override
  State<BoarderFollowing> createState() => _BoarderFollowingState();
}

class _BoarderFollowingState extends State<BoarderFollowing> {
  int channelIndex = 0;

  // 팔로잉 상단 채널(동그라미)
  final channels = const <ChipItem>[
    ChipItem("미국주식\n이야기", iconUrl: "https://picsum.photos/seed/us2/80/80"),
    ChipItem("국내주식\n토론", iconUrl: "https://picsum.photos/seed/kr/80/80"),
  ];

  // 팔로잉 피드 더미
  final items = <FeedItem>[
    FeedItem(
      postId: 101,
      author: "미국주식이야기",
      timeAgo: "3분 전 · 지수총총님이 남긴 글",
      title: "스페이스X 관련 기사 핵심만",
      body: "IPO 루머가 아니라 내부 커뮤니케이션이 포인트...",
      avatarUrl: "https://i.pravatar.cc/200?img=4",
      likeCount: 12,
      commentCount: 1,
      isLiked: false,
    ),
    FeedItem(
      postId: 102,
      author: "국내주식토론",
      timeAgo: "20분 전",
      title: "테슬라 이슈, 국내 수혜주는?",
      body: "변동성 커질 수 있어서 보수적으로 접근...",
      avatarUrl: "https://i.pravatar.cc/200?img=22",
      likeCount: 8,
      commentCount: 2,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            const SizedBox(height: 10),

            CategoryTab(
              items: channels,
              selectedIndex: channelIndex,
              onTap: (i) => setState(() => channelIndex = i),
              circleStyle: true,
            ),

            const SizedBox(height: 10),

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

        // 우측 하단 고정 “글쓰기”
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: "write_following", // ✅ recommend랑 다르게
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