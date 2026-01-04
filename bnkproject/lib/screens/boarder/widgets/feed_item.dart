import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 게시글 카드 위젯 + 모델
 */

class FeedItem {
  final int postId;
  final int authoruId;
  final String author;
  final String timeAgo;
  final DateTime? createdAt;
  final String title;
  final String body;
  final String? avatarUrl;
  final bool showLike;

  int likeCount;
  int commentCount;
  bool isLiked;

  int viewCount;

  // 팔로우 상태
  bool isFollowing;

  FeedItem({
    required this.postId,
    this.authoruId = 0,
    required this.author,
    required this.timeAgo,
    this.createdAt,
    required this.title,
    required this.body,
    this.avatarUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.viewCount = 0,
    this.isFollowing = false,
    this.showLike = true,
  });
}

const List<IconData> _avatarIcons = [
  Icons.headset_mic_rounded,
  Icons.android_rounded,
  Icons.savings_rounded,
  Icons.auto_graph_rounded,
  Icons.rocket_launch_rounded,
  Icons.pets_rounded,
  Icons.sports_esports_rounded,
  Icons.face_rounded,
];

bool _isHttpUrl(String s) => s.startsWith("http://") || s.startsWith("https://");

int _iconIdx(String s) {
  if (s.startsWith("icon:")) {
    final idx = int.tryParse(s.split(":").last);
    if (idx != null && idx >= 0 && idx < _avatarIcons.length) return idx;
  }
  return 0;
}

typedef AsyncVoidCallback = Future<void> Function();

class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final AsyncVoidCallback onToggleLike;
  final AsyncVoidCallback? onToggleFollow;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleLike,
    this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final a = (item.avatarUrl ?? "").trim();
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

                  backgroundImage: (a.startsWith("http://") || a.startsWith("https://"))
                      ? NetworkImage(a)
                      : null,

                  child: a.startsWith("icon:")
                      ? Icon(_avatarIcons[_iconIdx(a)], size: 20, color: Colors.white)
                      : ((!_isHttpUrl(a)) ? const Icon(Icons.person, color: Colors.white70) : null),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.author, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),

                      if (item.createdAt != null)
                        Text(
                          _fmtDateTime(item.createdAt!),
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (onToggleFollow != null)
                TextButton(
                  onPressed: () async => await onToggleFollow!(),
                  child: Text(item.isFollowing ? "팔로잉" : "팔로우"),
                ),
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
                if (item.showLike) ...[
                  IconButton(
                    onPressed: () async => await onToggleLike(),
                    icon: Icon(
                      item.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: item.isLiked ? Colors.redAccent : Colors.white60,
                    ),
                  ),
                  Text(
                    "${item.likeCount}",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(width: 10),
                ],

                const Icon(Icons.mode_comment_outlined, color: Colors.white60, size: 20),
                const SizedBox(width: 6),
                Text(
                  "${item.commentCount}",
                  style: const TextStyle(color: Colors.white60),
                ),

                const Spacer(),

                const Icon(Icons.visibility_outlined, color: Colors.white60, size: 20),
                const SizedBox(width: 6),
                Text(
                  "${item.viewCount}",
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _fmtDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y.$m.$d $hh:$mm";
  }
}
