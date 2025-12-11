import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toss Style Screen',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05060A),
        cardColor: const Color(0xFF14151B),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const TossLikeHomePage(),
    );
  }
}

class TossLikeHomePage extends StatelessWidget {
  const TossLikeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _TopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // S&P + 안내 카드
                    _IndexHeader(cardColor: cardColor, textTheme: textTheme),
                    const SizedBox(height: 16),
                    // 내 계좌보기
                    _AccountSummary(cardColor: cardColor),
                    const SizedBox(height: 16),
                    // 내 종목보기
                    _MyHolding(cardColor: cardColor),
                    const SizedBox(height: 16),
                    // 주문내역 / 판매수익
                    _TwoRowMenu(
                      cardColor: cardColor,
                      leftTitle: '주문내역',
                      rightTitle: '판매수익',
                      leftSubtitle: '이번 달 1건',
                      rightSubtitle: '',
                    ),
                    const SizedBox(height: 24),
                    // 수익분석 / 최근 본 종목
                    _RecentStocksSection(cardColor: cardColor),
                    const SizedBox(height: 24),
                    // 실시간 거래대금 차트
                    _RealtimeChartSection(cardColor: cardColor),
                    const SizedBox(height: 24),
                    // 추천 뉴스
                    _NewsSection(cardColor: cardColor, title: '손진일님을 위한 추천 뉴스'),
                    const SizedBox(height: 24),
                    // 간편 홈 보기
                    _SimpleHomeSection(cardColor: cardColor),
                    const SizedBox(height: 32),
                    const SizedBox(height: 48), // 바텀탭 여유
                  ],
                ),
              ),
            ),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

/// 상단 앱바
class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            '토스증권',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'S&P 500 6,840.51  -0.08%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }
}

/// S&P 헤더 + 안내 카드
class _IndexHeader extends StatelessWidget {
  final Color cardColor;
  final TextTheme textTheme;

  const _IndexHeader({
    required this.cardColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 안내 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.monetization_on,
                  size: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본계좌 송금한도 안내',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '한도 올리기 >',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.blue[300],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

/// 내 계좌보기
class _AccountSummary extends StatelessWidget {
  final Color cardColor;

  const _AccountSummary({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AccountDetailPage(),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: '내 계좌보기',
            rightText: '14:27 기준',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('원화', style: labelStyle),
                      const SizedBox(height: 4),
                      Text('11원', style: valueStyle),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('달러', style: labelStyle),
                      const SizedBox(height: 4),
                      Text('\$0.00', style: valueStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 내 종목보기
class _MyHolding extends StatelessWidget {
  final Color cardColor;

  const _MyHolding({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );
    final valueStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '내 종목보기'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('948,500원', style: valueStyle),
              const SizedBox(height: 2),
              Text('-12,000원 (1.2%)', style: subStyle?.copyWith(
                color: Colors.blue[200],
              )),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('리카겐바이오',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('내 평균 192,100원', style: subStyle),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '189,500원',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+3.4%',
                        style: subStyle?.copyWith(color: Colors.redAccent),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 주문내역 / 판매수익 2열 메뉴
class _TwoRowMenu extends StatelessWidget {
  final Color cardColor;
  final String leftTitle;
  final String rightTitle;
  final String leftSubtitle;
  final String rightSubtitle;

  const _TwoRowMenu({
    required this.cardColor,
    required this.leftTitle,
    required this.rightTitle,
    this.leftSubtitle = '',
    this.rightSubtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    Widget item(String title, String subtitle) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: labelStyle),
                ],
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20, color: Colors.white54),
          ],
        ),
      );
    }

    return Column(
      children: [
        item(leftTitle, leftSubtitle),
        const SizedBox(height: 8),
        item(rightTitle, rightSubtitle),
      ],
    );
  }
}

/// 최근 본 종목 섹션
class _RecentStocksSection extends StatelessWidget {
  final Color cardColor;

  const _RecentStocksSection({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _StockChip(
        title: '리카겐바이오',
        change: '+3.4%',
        isUp: true,
      ),
      _StockChip(
        title: '삼성전자',
        change: '-0.3%',
        isUp: false,
      ),
      _StockChip(
        title: 'BMNU',
        change: '+1.3%',
        isUp: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: '최근 본 종목',
          rightText: '더 보기',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: chips,
        ),
      ],
    );
  }
}

class _StockChip extends StatelessWidget {
  final String title;
  final String change;
  final bool isUp;

  const _StockChip({
    required this.title,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white10;
    final changeColor = isUp ? Colors.redAccent : Colors.blue[200];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
        color: const Color(0xFF121318),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(
            change,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: changeColor),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.close, size: 14, color: Colors.white38),
          )
        ],
      ),
    );
  }
}

/// 실시간 거래대금 차트 섹션 (리스트 형태로 단순화)
class _RealtimeChartSection extends StatelessWidget {
  final Color cardColor;

  const _RealtimeChartSection({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('1', 'SK하이닉스', '586,000원', '+3.5%'),
      ('2', '셀바스AI', '15,030원', '+21.7%'),
      ('3', '에이비엘바이오', '204,500원', '+9.8%'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '실시간 거래대금 차트'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              for (final item in items)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white10,
                    child: Text(
                      item.$1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(
                    item.$2,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item.$3,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.$4,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite_border,
                          size: 18, color: Colors.white60),
                    ],
                  ),
                ),
              const Divider(height: 1, color: Colors.white12),
              TextButton(
                onPressed: () {},
                child: const Text('다른 차트 보기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 뉴스 섹션
class _NewsSection extends StatelessWidget {
  final Color cardColor;
  final String title;

  const _NewsSection({required this.cardColor, required this.title});

  @override
  Widget build(BuildContext context) {
    final news = [
      (
      '코스피, 기관ㆍ외인 순매도에 하락 전환...',
      '한국경제 - 3시간 전'
      ),
      (
      '삼성SDI, 2조원대 ESS 배터리 수주...\n美 에너지 업체에 LFP 공급',
      '전자신문 - 2시간 전'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              for (final n in news)
                Column(
                  children: [
                    ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        n.$1,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          n.$2,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12),
                        ),
                      ),
                      trailing: const Icon(Icons.favorite_border,
                          size: 18, color: Colors.white60),
                    ),
                    if (n != news.last)
                      const Divider(height: 1, color: Colors.white12),
                  ],
                ),
              TextButton(
                onPressed: () {},
                child: const Text('다른 뉴스 보기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 간편 홈 보기 / 하단 안내
class _SimpleHomeSection extends StatelessWidget {
  final Color cardColor;

  const _SimpleHomeSection({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '간편 홈 보기'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            '토스증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 단순 참고 자료이며, '
                '투자 결과에 대한 법적 책임을 지지 않습니다.',
            style: bodySmall?.copyWith(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}

/// 공통 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? rightText;

  const _SectionHeader({required this.title, this.rightText});

  @override
  Widget build(BuildContext context) {
    final right = rightText;
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (right != null)
          Text(
            right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
      ],
    );
  }
}

/// 하단 탭바
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    // 실제 BottomNavigationBar 대신, 디자인 비슷하게 Container로 구현
    return Container(
      padding:
      const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _BottomNavItem(icon: Icons.home_outlined, label: '홈', isActive: true),
          _BottomNavItem(icon: Icons.bar_chart, label: '순위'),
          _BottomNavItem(icon: Icons.notifications_none, label: '알림'),
          _BottomNavItem(icon: Icons.person_outline, label: '마이'),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodySmall = Theme.of(context).textTheme.bodySmall;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: SafeArea(
          child: Column(
            children: [
              // 상단: 뒤로가기 + 관리
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('관리'),
                    ),
                  ],
                ),
              ),

              // 탭바 (내 계좌 / 수익분석)
              const TabBar(
                indicatorColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: '내 계좌'),
                  Tab(text: '수익분석'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _AccountTab(cardColor: cardColor),
                    Center(
                      child: Text(
                        '수익분석 화면은 아직 준비 중입니다.',
                        style: bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  final Color cardColor;

  const _AccountTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);
    final titleStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    final bigNumber = Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 계좌 번호 + 총 자산
        Text('토스증권 145-01-502041', style: bodySmall),
        const SizedBox(height: 6),
        Text('948,011원', style: bigNumber),
        const SizedBox(height: 12),

        // 채우기 / 보내기 / 환전 버튼
        Row(
          children: const [
            _RoundedTextButton(label: '채우기'),
            SizedBox(width: 8),
            _RoundedTextButton(label: '보내기'),
            SizedBox(width: 8),
            _RoundedTextButton(label: '환전'),
          ],
        ),
        const SizedBox(height: 24),

        // 주문 가능 금액 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('주문 가능 금액'),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.grey[500]),
                ],
              ),
              const SizedBox(height: 6),
              Text('11원', style: titleStyle),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
              _AccountRow(
                leadingText: '원화',
                value: '11원',
              ),
              const SizedBox(height: 8),
              _AccountRow(
                leadingText: '달러',
                value: '\$0.00 (0원)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 투자 총입금 금액 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('투자 총입금 금액'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('948,000원', style: titleStyle),
                  const SizedBox(width: 4),
                  Text(
                    '-1.3%',
                    style: bodySmall?.copyWith(color: Colors.blue[200]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('국내주식', style: bodySmall),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('948,500원', style: bodySmall),
                      Text(
                        '-1.2%',
                        style: bodySmall?.copyWith(color: Colors.blue[200]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 12월 수익 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text('12월 수익'),
              const Spacer(),
              Text(
                '+0원',
                style: bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 메뉴 리스트 (주식 빌려주기 등)
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _MenuTile(title: '주식 빌려주기'),
              _MenuTile(title: '거래ㆍ입출금ㆍ환전 내역'),
              _MenuTile(
                title: '주문 내역',
                trailingText: '이번 달 1건',
              ),
              _MenuTile(title: '내 권리'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 기준 환율 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('기준 환율'),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.grey[500]),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '1,470.40원',
                    style: titleStyle,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+14.0 (1.0%)',
                    style: bodySmall?.copyWith(color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '12월 10일 오전 10:00 기준',
                style: bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 안내 문구
        Text(
          '토스증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 단순 참고 자료이며, '
              '투자 결과에 대한 법적 책임을 지지 않습니다.',
          style: bodySmall,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// 위쪽 버튼 3개 공통 위젯
class _RoundedTextButton extends StatelessWidget {
  final String label;

  const _RoundedTextButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: () {},
        child: Text(label),
      ),
    );
  }
}

/// 카드 안에서 왼쪽 텍스트 + 오른쪽 금액
class _AccountRow extends StatelessWidget {
  final String leadingText;
  final String value;

  const _AccountRow({
    required this.leadingText,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall;

    return Row(
      children: [
        Text(leadingText, style: bodySmall),
        const Spacer(),
        Text(value, style: bodySmall),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right,
            size: 16, color: Colors.white54),
      ],
    );
  }
}

/// 메뉴 타일 공통
class _MenuTile extends StatelessWidget {
  final String title;
  final String? trailingText;

  const _MenuTile({required this.title, this.trailingText});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);

    return ListTile(
      dense: true,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(trailingText!, style: bodySmall),
            ),
          const Icon(Icons.chevron_right,
              size: 18, color: Colors.white54),
        ],
      ),
    );
  }
}
