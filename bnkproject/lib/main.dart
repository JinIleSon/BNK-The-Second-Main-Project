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

class TossLikeHomePage extends StatefulWidget {
  const TossLikeHomePage({super.key});

  @override
  State<TossLikeHomePage> createState() => _TossLikeHomePageState();
}

class _TossLikeHomePageState extends State<TossLikeHomePage> {
  int _selectedIndex = 0; // 0: 홈, 1: 관심, 2: 알림, 3: 마이

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _HomeTab(cardColor: cardColor, textTheme: textTheme);
        break;
      case 1:
        body = const FavoritePage(); // 새로 추가할 관심 페이지
        break;
      case 2:
        body = const DiscoveryPage();
        break;
      case 3:
        body = const Center(
          child: Text('마이 화면은 아직 준비 중입니다.'),
        );
        break;
      default:
        body = _HomeTab(cardColor: cardColor, textTheme: textTheme);
    }

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

/// 기존 홈 화면 내용을 여기로 옮긴 탭 위젯
class _HomeTab extends StatelessWidget {
  final Color cardColor;
  final TextTheme textTheme;

  const _HomeTab({
    required this.cardColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IndexHeader(cardColor: cardColor, textTheme: textTheme),
                const SizedBox(height: 16),
                _AccountSummary(cardColor: cardColor),
                const SizedBox(height: 16),
                _MyHolding(cardColor: cardColor),
                const SizedBox(height: 16),
                _TwoRowMenu(
                  cardColor: cardColor,
                  leftTitle: '주문내역',
                  rightTitle: '판매수익',
                  leftSubtitle: '이번 달 1건',
                  rightSubtitle: '',
                ),
                const SizedBox(height: 24),
                _RecentStocksSection(cardColor: cardColor),
                const SizedBox(height: 24),
                _RealtimeChartSection(cardColor: cardColor),
                const SizedBox(height: 24),
                _NewsSection(
                    cardColor: cardColor, title: '손진일님을 위한 추천 뉴스'),
                const SizedBox(height: 24),
                _SimpleHomeSection(cardColor: cardColor),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
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
      ('5', 'HL만도', '52,200원', '-5.09%'),

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
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0C10),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.home_outlined,
            label: '홈',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.favorite_border,
            label: '관심',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.explore_outlined,   // ✅ 발견
            label: '발견',
            onTap: onTap,
          ),
          _BottomNavItem(
            index: 3,
            selectedIndex: selectedIndex,
            icon: Icons.person_outline,
            label: '마이',
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == selectedIndex;
    final color = isActive ? Colors.white : Colors.white60;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4 - 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
          // 상단 앱바
          Padding(
            padding:
            const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 4),
            child: Row(
              children: [
                Text(
                  '관심',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // AI 신호
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 신호',
                    style: bodySmall?.copyWith(color: Colors.blue[300])),
                const SizedBox(height: 4),
                Text(
                  '오스코텍 최대주주 변경 우려로 5% 하락',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // 탭바
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
                Center(child: Text('주식 탭 내용은 준비 중입니다.')),
                Center(child: Text('채권 탭 내용은 준비 중입니다.')),
                Center(child: Text('그룹추가 탭 내용은 준비 중입니다.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 관심 탭 - '최근 본' 화면
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
          // 최근 본 종목 리스트
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
                          color: s.$3 ? Colors.redAccent : Colors.blue[200],
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

          // 사료 관련 주식
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
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
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

          // 뉴스 섹션
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
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
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

          // 하단 안내
          Text(
            '토스증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 '
                '단순 참고자료로, 투자 결과에 대한 법적 책임을 지지 않습니다.',
            style: bodySmall,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);

    // 실시간 차트용 예시 데이터
    final stocks = [
      ('1', 'SK하이닉스', '588,000원', '+3.8%'),
      ('2', '셀바스AI', '14,870원', '+20.4%'),
      ('3', '에이비엘바이오', '203,000원', '+9.0%'),
      ('4', '테라뷰', '17,170원', '+7.3%'),
      ('5', '페스카로', '33,000원', '+112.9%'),
      ('6', '삼성전자', '107,900원', '-0.4%'),
      ('7', '에코프로', '116,700원', '-0.9%'),
      ('8', '펄트론', '281,500원', '+5.4%'),
      ('9', 'KODEX 레버리지', '44,680원', '-0.1%'),
      ('10', '노타', '44,800원', '+5.0%'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 앱바
        Padding(
          padding:
          const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 4),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '발견',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'S&P 500 6,840.51  -0.08%',
                    style: bodySmall,
                  ),
                ],
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
        ),

        // 상단 카테고리 칩 (국내주식 / 해외주식 / 채권 / ETF)
        SizedBox(
          height: 76,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _DiscoverCategoryChip(
                label: '국내주식',
                emoji: '🇰🇷',
              ),
              _DiscoverCategoryChip(
                label: '해외주식',
                emoji: '🇺🇸',
              ),
              _DiscoverCategoryChip(
                label: '채권',
                emoji: '💰',
              ),
              _DiscoverCategoryChip(
                label: 'ETF',
                emoji: '📊',
              ),
            ],
          ),
        ),

        // 오늘 이벤트 / 코스피
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('오늘 이벤트', style: bodySmall),
              const SizedBox(height: 2),
              Text(
                '노동시장 신규 구인건수(JOLTs) 발표',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '코스피',
                    style: bodySmall,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '4,136.31  -0.1%',
                    style: bodySmall?.copyWith(color: Colors.blue[200]),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 실시간 차트 + 내부 탭
        Expanded(
          child: DefaultTabController(
            length: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '실시간 차트',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                const TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: '거래대금'),
                    Tab(text: '거래량'),
                    Tab(text: '급상승'),
                    Tab(text: '급하락'),
                    Tab(text: '인기'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 거래대금 탭 – 리스트
                      _DiscoveryStockList(
                        stocks: stocks,
                      ),
                      Center(child: Text('거래량 탭은 준비 중입니다.')),
                      Center(child: Text('급상승 탭은 준비 중입니다.')),
                      Center(child: Text('급하락 탭은 준비 중입니다.')),
                      Center(child: Text('인기 탭은 준비 중입니다.')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 상단 카테고리 칩
class _DiscoverCategoryChip extends StatelessWidget {
  final String label;
  final String emoji;

  const _DiscoverCategoryChip({
    required this.label,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// 실시간 차트 리스트 + 아래 카드/버튼
class _DiscoveryStockList extends StatelessWidget {
  final List<(String, String, String, String)> stocks;

  const _DiscoveryStockList({required this.stocks});

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);
    final cardColor = Theme.of(context).cardColor;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final s in stocks)
          Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockDetailPage(
                        name: s.$2,   // 종목 이름
                        price: s.$3,  // 현재가
                        change: s.$4, // 등락률
                      ),
                    ),
                  );
                },
                contentPadding: EdgeInsets.zero,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.$1,
                      style: bodySmall,
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white10,
                      child: Text(
                        s.$2.characters.first,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  s.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  s.$3,
                  style: bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.$4,
                      style: bodySmall?.copyWith(
                        color: s.$4.startsWith('-')
                            ? Colors.blue[200]
                            : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.white60,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
            ],
          ),
        const SizedBox(height: 16),

        // "사람들이 많이 얘기하고 있어요" 카드
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department,
                  size: 20, color: Colors.redAccent),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사람들이 많이 얘기하고 있어요',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '커뮤니티 새 글 급상승',
                    style: bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 더 보기 버튼
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('더 보기'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class StockDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String change;

  const StockDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final isUp = !change.startsWith('-');
    final changeColor = isUp ? Colors.redAccent : Colors.blue[200];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Icon(Icons.share, size: 20),
                    const SizedBox(width: 12),
                    const Icon(Icons.favorite_border, size: 22),
                    const SizedBox(width: 12),
                    const Icon(Icons.more_vert, size: 22),
                  ],
                ),
              ),

              // 종목 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(price,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '어제보다 $change',
                      style: TextStyle(color: changeColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 탭바
              const TabBar(
                indicatorColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                isScrollable: true,
                tabs: [
                  Tab(text: '차트'),
                  Tab(text: '호가'),
                  Tab(text: '내 주식'),
                  Tab(text: '종목정보'),
                  Tab(text: '커뮤니티'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _ChartTab(cardColor: cardColor),
                    _HogaTab(cardColor: cardColor),
                    _MyStockTab(cardColor: cardColor),
                    _StockInfoTab(cardColor: cardColor),
                    _CommunityTab(cardColor: cardColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 하단 구매하기 버튼
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text('구매하기', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartTab extends StatelessWidget {
  final Color cardColor;
  const _ChartTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '현금 30%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 차트 박스
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _FakeChartPainter(),
          ),
        ),

        const SizedBox(height: 12),

        // 기간 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ChartFilterButton(label: "1일", selected: true),
            _ChartFilterButton(label: "1주"),
            _ChartFilterButton(label: "3달"),
            _ChartFilterButton(label: "1년"),
            _ChartFilterButton(label: "5년"),
            _ChartFilterButton(label: "전체"),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          "일별 · 실시간 시세 보기 >",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _ChartFilterButton extends StatelessWidget {
  final String label;
  final bool selected;

  const _ChartFilterButton({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.white : Colors.grey,
      ),
    );
  }
}


class _HogaTab extends StatelessWidget {
  final Color cardColor;

  const _HogaTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[400];

    // 위가 매도호가(빨간쪽), 아래가 매수호가(파란쪽)라고 생각하면 됨
    final rows = <_OrderBookRowData>[
      // 매도 호가들 (현재가 위쪽)
      _OrderBookRowData(askQty: "9,408",  price: "588,000", change: "+3.88%"),
      _OrderBookRowData(askQty: "5,693",  price: "587,000", change: "+3.71%"),
      _OrderBookRowData(askQty: "6,004",  price: "586,000", change: "+3.53%"),
      // 현재가
      _OrderBookRowData(
        bidQty: "10,256",
        price: "585,000",
        change: "+3.35%",
        isCurrent: true,
      ),
      // 매수 호가들 (현재가 아래쪽)
      _OrderBookRowData(bidQty: "14,417", price: "584,000", change: "+3.18%"),
      _OrderBookRowData(bidQty: "17,171", price: "583,000", change: "+3.01%"),
      _OrderBookRowData(bidQty: "29,358", price: "582,000", change: "+2.84%"),
      _OrderBookRowData(bidQty: "19,381", price: "581,000", change: "+2.67%"),
      _OrderBookRowData(bidQty: "13,101", price: "580,000", change: "+2.49%"),
      _OrderBookRowData(bidQty: "12,965", price: "579,000", change: "+2.32%"),
      _OrderBookRowData(bidQty: "11,936", price: "578,000", change: "+2.14%"),
      _OrderBookRowData(bidQty: "9,023",  price: "577,000", change: "+1.96%"),
      _OrderBookRowData(bidQty: "4,423",  price: "576,000", change: "+1.76%"),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 체결강도 + 오른쪽 간단 정보
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                "체결강도 144.8%",
                style: TextStyle(color: grey, fontSize: 12),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("전일 종가 568,000원",
                      style: TextStyle(color: grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text("고가 590,000원 · 저가 570,000원",
                      style: TextStyle(color: grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 실제 호가 테이블
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // 헤더
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text("매수잔량",
                          style: TextStyle(color: grey, fontSize: 11)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text("호가",
                            style: TextStyle(color: grey, fontSize: 11)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("매도잔량",
                            style: TextStyle(color: grey, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),

              for (final r in rows) _OrderBookRow(data: r),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 아래쪽 “왜 올랐을까?” 카드
        Text("왜 올랐을까?", style: TextStyle(color: grey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "SK하이닉스가 금융 자회사 설립 허용으로 자금조달이 쉬워졌기 때문이에요.",
              ),
              SizedBox(height: 6),
              Text("시카트로닉스 외 3개 종목과 연관"),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 주문내역 보기
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Text("주문내역 보기"),
              Spacer(),
              Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// 호가 한 줄에 들어갈 데이터
class _OrderBookRowData {
  final String? bidQty;   // 왼쪽(매수잔량) – 없으면 null
  final String  price;    // 가운데 가격
  final String  change;   // 등락률
  final String? askQty;   // 오른쪽(매도잔량) – 없으면 null
  final bool    isCurrent;

  const _OrderBookRowData({
    this.bidQty,
    required this.price,
    required this.change,
    this.askQty,
    this.isCurrent = false,
  });
}

/// 호가 한 줄 UI
class _OrderBookRow extends StatelessWidget {
  final _OrderBookRowData data;

  const _OrderBookRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final bidColor = const Color(0xFF1E3A8A); // 파란 느낌
    final askColor = const Color(0xFF7F1D1D); // 빨간 느낌
    final isUp = !data.change.startsWith('-');
    final Color priceColor = isUp ? Colors.redAccent : Colors.blue[200]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // ← 높이 대신 여백만
      child: Row(
        children: [
          // 매수잔량(왼쪽)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: data.bidQty == null
                  ? const SizedBox.shrink()
                  : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bidColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.bidQty!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 가격 + 등락률(가운데)
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,          // ← 필요한 만큼만
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.price,
                  style: TextStyle(
                    color: priceColor,
                    fontWeight:
                    data.isCurrent ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.change,
                  style: TextStyle(
                    color: priceColor.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // 매도잔량(오른쪽)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: data.askQty == null
                  ? const SizedBox.shrink()
                  : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: askColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.askQty!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _StockInfoTab extends StatelessWidget {
  final Color cardColor;

  const _StockInfoTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[400];

    final summaryItems = [
      ("🔥 호재", "최근 3달 사이 +104.1% 상승했어요.", "6분 전"),
      ("🔥 호재", "최근 1년 사이 +233.9% 상승했어요.", "6분 전"),
      ("🟢 소식", "주식 고수들의 76%가 팔았어요.", "21분 전"),
      ("🔴 호재", "매출액이 2분기 연속 상승했어요.", "21분 전"),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "10초 요약 보기",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (final s in summaryItems)
                Column(
                  children: [
                    ListTile(
                      leading: Text(s.$1),
                      title: Text(s.$2),
                      subtitle: Text(s.$3, style: TextStyle(color: grey)),
                    ),
                    if (s != summaryItems.last)
                      const Divider(height: 1, color: Colors.white12),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }
}


class _CommunityTab extends StatelessWidget {
  final Color cardColor;

  const _CommunityTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("커뮤니티", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("💀 누가 뭐래도 난 간다 sk 하이닉스"),
              SizedBox(height: 8),
              Text("168,246개 의견 보기 >", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FakeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 임의의 차트 라인 만들기 (토스 느낌)
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height * 0.45);
    path.lineTo(size.width * 0.35, size.height * 0.25);
    path.lineTo(size.width * 0.55, size.height * 0.35);
    path.lineTo(size.width * 0.7, size.height * 0.15);
    path.lineTo(size.width * 0.9, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MyStockTab extends StatelessWidget {
  final Color cardColor;

  const _MyStockTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[400];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 상단 2개 버튼 (주식 모으기 / 조건 주문)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2025),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              // 선택된 탭: 주식 모으기
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '주식 모으기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 비선택 탭: 조건 주문
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  alignment: Alignment.center,
                  child: Text(
                    '조건 주문',
                    style: TextStyle(
                      fontSize: 13,
                      color: grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // "주문 내역  ·  취소 포함"
        Row(
          children: [
            const Text(
              '주문 내역',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '취소 포함',
              style: TextStyle(color: grey, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 60),

        // 비어 있는 상태
        Column(
          children: [
            Icon(Icons.receipt_long,
                size: 40, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              '주문한 내역이 없어요.',
              style: TextStyle(color: grey, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}