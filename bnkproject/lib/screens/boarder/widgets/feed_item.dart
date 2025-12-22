import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 게시글 카드 위젯 + 모델
 */

class FeedItem {
  final int postId;
  final String author;
  final String timeAgo;
  final String title;
  final String body;
  final String? avatarUrl;

  int likeCount;
  int commentCount;
  bool isLiked;

  FeedItem({
    required this.postId,
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.body,
    this.avatarUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleLike;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121318),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(0xFF1C1D22),
                  backgroundImage: (item.avatarUrl != null && item.avatarUrl!.isNotEmpty)
                      ? NetworkImage(item.avatarUrl!)
                      : null,
                  child: (item.avatarUrl == null || item.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.author, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(item.timeAgo, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("팔로우")),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(
              item.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: onToggleLike,
                  icon: Icon(
                    item.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: item.isLiked ? Colors.redAccent : Colors.white60,
                  ),
                ),
                Text("${item.likeCount}", style: const TextStyle(color: Colors.white60)),
                const SizedBox(width: 10),
                const Icon(Icons.mode_comment_outlined, color: Colors.white60, size: 20),
                const SizedBox(width: 6),
                Text("${item.commentCount}", style: const TextStyle(color: Colors.white60)),
                const Spacer(),
                const Icon(Icons.ios_share, color: Colors.white60, size: 20),
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz, color: Colors.white60),
              ],
            )
          ],
        ),
      ),
    );
  }
}
