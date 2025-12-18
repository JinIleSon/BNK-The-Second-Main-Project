import 'package:flutter/material.dart';
import '../widgets/feed_item.dart';
import '../pages/boarder_detail.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 게시판 목록 (Board)
    유형 : Tab 전용 View
 */

class BoarderList extends StatefulWidget {
  const BoarderList({super.key});

  @override
  State<BoarderList> createState() => _BoarderListState();
}

class _BoarderListState extends State<BoarderList> {
  // 게시판 더미 데이터
  final items = <FeedItem>[
    FeedItem(
      postId: 101,
      author: "운영자",
      timeAgo: "1일 전",
      title: "[공지] 게시판 이용 안내",
      body: "본 게시판은 건전한 투자 정보 공유를 목적으로 운영됩니다.",
      avatarUrl: "https://i.pravatar.cc/200?img=1",
      likeCount: 3,
      commentCount: 0,
      isLiked: false,
    ),
    FeedItem(
      postId: 102,
      author: "익명",
      timeAgo: "3시간 전",
      title: "ETF 장기투자 전략 질문드립니다",
      body: "연금 계좌에서 ETF 비중을 어떻게 가져가야 할까요?",
      avatarUrl: "https://i.pravatar.cc/200?img=8",
      likeCount: 5,
      commentCount: 2,
      isLiked: false,
    ),
    FeedItem(
      postId: 103,
      author: "투자초보",
      timeAgo: "10분 전",
      title: "미국 배당주 추천 부탁드립니다",
      body: "월배당 위주로 보고 있는데 의견 듣고 싶습니다.",
      avatarUrl: "https://i.pravatar.cc/200?img=14",
      likeCount: 1,
      commentCount: 1,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: items.map((it) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FeedItemCard(
            item: it,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoarderDetail(item: it),
                ),
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
        );
      }).toList(),
    );
  }
}
