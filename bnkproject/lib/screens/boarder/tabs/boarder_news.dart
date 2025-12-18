import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 뉴스 탭
 */

class _NewsItem {
  final String title, publisher, timeAgo, thumbUrl;
  final String? ticker;
  final double? changePct;
  const _NewsItem({
    required this.title,
    required this.publisher,
    required this.timeAgo,
    required this.thumbUrl,
    this.ticker,
    this.changePct,
  });
}

class BoarderNews extends StatefulWidget {
  const BoarderNews({super.key});

  @override
  State<BoarderNews> createState() => _BoarderNewsState();
}

class _BoarderNewsState extends State<BoarderNews> {
  bool showAll = false;

  final List<_NewsItem> news30 = List.generate(30, (i) {
    final id = i + 1;
    return _NewsItem(
      title: "실시간 주요 뉴스 더미 #$id — 시장/테마/기업 이슈 요약",
      publisher: (id % 3 == 0) ? "머니투데이" : (id % 3 == 1) ? "이투데이" : "매일경제",
      timeAgo: "${(id * 3) % 59 + 1}분 전",
      thumbUrl: "https://picsum.photos/seed/news$id/300/300",
    );
  });

  final watchNews = const <_NewsItem>[
    _NewsItem(
      ticker: "LG전자",
      changePct: 3.3,
      title: "“안전하고, 편리한 탑승 경험”… LG전자, CES 2026 AI 전략",
      publisher: "이투데이",
      timeAgo: "34분 전",
      thumbUrl: "https://picsum.photos/seed/lg/300/300",
    ),
    _NewsItem(
      ticker: "라파스",
      changePct: 6.0,
      title: "라파스, ‘붙이는 알레르기 비염약’ 임상 1상 성공",
      publisher: "머니투데이",
      timeAgo: "1시간 전",
      thumbUrl: "https://picsum.photos/seed/bio/300/300",
    ),
    _NewsItem(
      ticker: "삼성전자",
      changePct: 4.8,
      title: "삼성전자, 메모리 사이클 반등… 저평가된 글로벌 1등",
      publisher: "딜사이트",
      timeAgo: "1시간 전",
      thumbUrl: "https://picsum.photos/seed/ss/300/300",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mainNews = news30.take(showAll ? 30 : 5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _sectionTitle(
          title: "실시간 주요 뉴스",
          rightText: showAll ? "접기" : "더보기",
          onTapRight: () => setState(() => showAll = !showAll),
        ),
        const SizedBox(height: 10),
        ...mainNews.map(_newsTile),

        const SizedBox(height: 22),
        _sectionTitle(title: "관심 종목 뉴스", rightText: ">", onTapRight: () {}),
        const SizedBox(height: 10),
        ...watchNews.map(_watchTile),
      ],
    );
  }

  Widget _sectionTitle({
    required String title,
    required String rightText,
    required VoidCallback onTapRight,
  }) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        InkWell(
          onTap: onTapRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(rightText, style: const TextStyle(color: Colors.white60)),
          ),
        ),
      ],
    );
  }

  Widget _newsTile(_NewsItem n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text("${n.publisher} · ${n.timeAgo}", style: const TextStyle(color: Colors.white60)),
            ]),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(n.thumbUrl, width: 64, height: 64, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _watchTile(_NewsItem n) {
    final sign = (n.changePct ?? 0) >= 0 ? "+" : "";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "${n.ticker} $sign${(n.changePct ?? 0).toStringAsFixed(1)}%",
                style: TextStyle(
                  color: (n.changePct ?? 0) >= 0 ? Colors.redAccent : Colors.blueAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text("${n.publisher} · ${n.timeAgo}", style: const TextStyle(color: Colors.white60)),
            ]),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(n.thumbUrl, width: 64, height: 64, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

