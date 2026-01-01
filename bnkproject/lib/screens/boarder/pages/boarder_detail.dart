import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/boarder_comment.dart';
import '../widgets/feed_item.dart';
import 'boarder_edit.dart';

/*
    날짜 : 2025.12.17 / 2025.12.31
    이름 : 이준우
    내용 : 게시글 상세 페이지 / 게시글 수정 & 삭제 기능 추가
 */

class BoarderDetail extends StatelessWidget {
  final FeedItem item;

  const BoarderDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상세"),
        actions: [
          TextButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoarderEditPage(item: item),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context, "updated");
              }
            },
            child: const Text("수정", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse("http://10.0.2.2:8080/BNK/api/post/board/${item.postId}");
              final res = await http.delete(uri, headers: {"X-UID": "${item.authoruId}"});
              if (res.statusCode == 200 && context.mounted) {
                Navigator.pop(context, "deleted");
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("삭제 실패: ${res.statusCode}")),
                );
              }
            },
            child: const Text("삭제", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
