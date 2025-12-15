import 'package:flutter/material.dart';
import '../menu/menu_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 8, top: 8, bottom: 4),
            child: Row(
              children: [
                Text(
                  '관심',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  'S&P 500 6,840.51 -0.08%',
                  style: bodySmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MenuPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 신호',
                  style:
                  bodySmall?.copyWith(color: Colors.blue[300]),
                ),
                const SizedBox(height: 4),
                Text(
                  '오스코텍 최대주주 변경 우려로 5% 하락',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '최근 본'),
              Tab(text: '주식'),
              Tab(text: '채권'),
              Tab(text: '그룹추가'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _FavoriteRecentTab(cardColor: cardColor),
                const Center(child: Text('주식 탭 내용은 준비 중입니다.')),
                const Center(child: Text('채권 탭 내용은 준비 중입니다.')),
                const Center(child: Text('그룹추가 탭 내용은 준비 중입니다.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRecentTab extends StatelessWidget {
  final Color cardColor;

  const _FavoriteRecentTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);

    final recentStocks = [
      ('리카겐바이오', '+3.6%', true, '189,800원'),
      ('삼성전자', '-0.3%', false, '108,000원'),
      ('BMNU', '+1.1%', true, '15,924원'),
      ('SK하이닉스', '+3.7%', true, '587,000원'),
      ('더멕스', '+1.6%', true, '31,000원'),
      ('자인웍스', '-3.2%', false, '36,868원'),
    ];

    final relatedStocks = [
      ('한일사료', '3,085원', '-0.3%', false),
      ('팜스토리', '1,176원', '-0.3%', false),
      ('고려산업', '2,485원', '-0.6%', false),
    ];

    final newsList = [
      (
      'SK하이닉스 +3.7%',
      'SK하이닉스, "자사주 중시 상장 추진" 보도에...\n주가 3%↑',
      '매일경제 - 4시간 전'
      ),
      (
      'MULL +0.2%   마이크론 테크놀로지 +0.1%',
      'SK하이닉스, 60만 회복하나..."미국 ADR 상장 검토 소식에 3%대↑"',
      '매일경제 - 4시간 전'
      ),
      (
      '한화오션 -2.0%   기아 -0.5%',
      '50대 기업 여유돈 42% 늘어… SK하이닉스 증가율 \'1위\'',
      '아주경제 - 4시간 전'
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          for (final s in recentStocks)
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white10,
                    child: Text(
                      s.$1.characters.first,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(
                    s.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    s.$4,
                    style: bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.$2,
                        style: bodySmall?.copyWith(
                          color: s.$3
                              ? Colors.redAccent
                              : Colors.blue[200],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.close,
                          size: 18, color: Colors.white54),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            '손진일님이 관심 있어 할\n사료 관련 주식',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '최근 찾아본 주식을 분석했어요.',
            style: bodySmall,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final r in relatedStocks)
                  Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white10,
                          child: Text(
                            r.$1.characters.first,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(r.$1),
                        subtitle: Text(
                          r.$2,
                          style: bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.$3,
                              style: bodySmall?.copyWith(
                                color: r.$4
                                    ? Colors.redAccent
                                    : Colors.blue[200],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.favorite_border,
                                size: 18, color: Colors.white60),
                          ],
                        ),
                      ),
                      if (r != relatedStocks.last)
                        const Divider(height: 1, color: Colors.white12),
                    ],
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('다른 종목 보기'),
          ),
          const SizedBox(height: 16),
          Text(
            '최근 본 종목과 관련된 뉴스',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final n in newsList)
                  Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            n.$1,
                            style: bodySmall?.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.$2,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n.$3,
                              style: bodySmall,
                            ),
                          ],
                        ),
                        trailing: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 24),
                        ),
                      ),
                      if (n != newsList.last)
                        const Divider(height: 1, color: Colors.white12),
                    ],
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('다른 뉴스 보기'),
          ),
          const SizedBox(height: 24),
          Text(
            '부기증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 '
                '단순 참고자료로, 투자 결과에 대한 법적 책임을 지지 않습니다.',
            style: bodySmall,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
