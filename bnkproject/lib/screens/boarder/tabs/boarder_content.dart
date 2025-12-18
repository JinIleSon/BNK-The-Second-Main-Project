import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 콘텐츠 탭 페이지
 */

class _ContentItem {
  final String author, timeAgo, title, body, avatarUrl, coverUrl;
  final int commentCount;
  const _ContentItem({
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.body,
    required this.avatarUrl,
    required this.coverUrl,
    this.commentCount = 0,
  });
}

class BoarderContent extends StatelessWidget {
  const BoarderContent({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const <_ContentItem>[
      _ContentItem(
        author: "2026년 대비하기",
        timeAgo: "22시간 전",
        title: "내년 미국 주식시장의 가장 큰 리스크는?",
        body: "증시 상승을 이끌었던 ‘AI’가 동시에 위험 요인으로도 주목 받아요. 예상 시나리오를 정리해볼게요.",
        avatarUrl: "https://i.pravatar.cc/200?img=35",
        coverUrl: "https://picsum.photos/seed/content_ai/900/520",
        commentCount: 7,
      ),
      _ContentItem(
        author: "이주의 투자 포인트",
        timeAgo: "1일 전",
        title: "성장주 흐름, 이번 주 고용에 달렸어요",
        body: "고용이 무난하면 그간 떨어진 성장주가 ‘매수 기회’가 될 수도 있어요.",
        avatarUrl: "https://i.pravatar.cc/200?img=7",
        coverUrl: "https://picsum.photos/seed/content_growth/900/520",
        commentCount: 4,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final c = items[i];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121318),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: NetworkImage(c.avatarUrl)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.author, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(c.timeAgo, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ]),
                  ),
                  const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(c.body, style: const TextStyle(color: Colors.white70, height: 1.35)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(c.coverUrl, height: 170, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text("${c.commentCount}", style: const TextStyle(color: Colors.white60)),
                  const Spacer(),
                  const Icon(Icons.more_horiz, color: Colors.white60),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}