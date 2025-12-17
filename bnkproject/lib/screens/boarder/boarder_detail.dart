import 'package:flutter/material.dart';

import 'boarder_comment.dart';
import 'widgets/feed_item.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 게시글 상세 페이지
 */

class BoarderDetail extends StatelessWidget {
  final FeedItem item;

  const BoarderDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("상세")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 본문
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text("${item.author} · ${item.timeAgo}",
                    style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 12),
                Text(item.body, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
          const Divider(height: 1),

          // 댓글
          Expanded(
            child: BoarderComment(
              postId: item.postId,
              onAddComment: () {
                item.commentCount += 1;
              },
            ),
          ),
        ],
      ),
    );
  }
}
