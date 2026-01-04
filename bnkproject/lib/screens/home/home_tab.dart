import 'package:bnkproject/models/MypageMain.dart';
import 'package:bnkproject/models/Pcontract.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../account/account_detail_page.dart';

import '../menu/menu_page.dart';

class HomeTab extends StatefulWidget {
  final Color cardColor;
  final TextTheme textTheme;

  final Future<void> Function() onOpenLogin;
  final bool isLoggedIn;

  // ✅ 추가: API 주입 (부모에서 api.fetchMypageMain 넘겨주면 됨)
  final Future<MypageMain> Function() fetchMypageMain;

  const HomeTab({
    super.key,
    required this.cardColor,
    required this.textTheme,
    required this.onOpenLogin,
    required this.isLoggedIn,
    required this.fetchMypageMain,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Future<MypageMain>? _mainFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _mainFuture = widget.fetchMypageMain();
    }
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ 로그인 상태가 false -> true 로 바뀌면 한 번 로드
    if (!oldWidget.isLoggedIn && widget.isLoggedIn) {
      _mainFuture = widget.fetchMypageMain();
      setState(() {});
    }

    // true -> false (로그아웃)
    if (oldWidget.isLoggedIn && !widget.isLoggedIn) {
      _mainFuture = null;
      setState(() {});
    }
  }

  Future<void> _reload() async {
    if (!widget.isLoggedIn) return;
    setState(() {
      _mainFuture = widget.fetchMypageMain();
    });
    try {
      await _mainFuture;
    } catch (_) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.cardColor;
    final textTheme = widget.textTheme;

    return Column(
      children: [
        _TopAppBar(
          onOpenLogin: widget.onOpenLogin,
          isLoggedIn: widget.isLoggedIn,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IndexHeader(cardColor: cardColor, textTheme: textTheme),
                const SizedBox(height: 16),
                _AccountSummary(cardColor: cardColor),
                const SizedBox(height: 16),

                // ✅ 여기만 교체
                _MyHolding(
                  cardColor: cardColor,
                  isLoggedIn: widget.isLoggedIn,
                  onOpenLogin: widget.onOpenLogin,
                  future: _mainFuture,
                  onReload: _reload,
                ),

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
                  cardColor: cardColor,
                  title: '손진일님을 위한 추천 뉴스',
                ),
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
  final Future<void> Function() onOpenLogin;
  final bool isLoggedIn;

  const _TopAppBar({
    required this.onOpenLogin,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            '부기증권',
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
          if (!isLoggedIn)
            IconButton(
              onPressed: onOpenLogin,
              icon: const Icon(Icons.login),
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuPage()),
              );
            },
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

  final bool isLoggedIn;
  final Future<void> Function() onOpenLogin;
  final Future<MypageMain>? future;
  final Future<void> Function() onReload;

  const _MyHolding({
    required this.cardColor,
    required this.isLoggedIn,
    required this.onOpenLogin,
    required this.future,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );
    final valueStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    // ✅ 로그인 전: 안내 카드
    if (!isLoggedIn) {
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text('로그인 후 보유 ETF를 확인할 수 있어요.', style: subStyle),
                ),
                TextButton(
                  onPressed: onOpenLogin,
                  child: const Text('로그인'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final f = future;
    if (f == null) {
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('불러오는 중...', style: subStyle),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '내 종목보기'),
        const SizedBox(height: 8),
        FutureBuilder<MypageMain>(
          future: f,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingCard(cardColor, '보유 ETF 불러오는 중...');
            }
            if (snapshot.hasError) {
              return _errorCard(cardColor, snapshot.error.toString(), onReload);
            }

            final data = snapshot.data!;
            final etfs = List<Pcontract>.from(data.etfList);

            // 보기 좋게: 평가금액 큰 순(psum)으로 정렬
            etfs.sort((a, b) => (b.psum ?? 0).compareTo(a.psum ?? 0));

            // ✅ 총합 계산
            int totalEval = 0; // psum 합(평가금액으로 가정)
            int totalBuy = 0;  // pstock*pprice 합(매수금액)
            for (final e in etfs) {
              final stock = e.pstock ?? 0;
              final buyPrice = e.pprice ?? 0;
              final eval = e.psum ?? 0;

              totalEval += eval;
              totalBuy += stock * buyPrice;
            }

            final totalPnl = totalEval - totalBuy;
            final totalRate = (totalBuy == 0) ? 0.0 : (totalPnl / totalBuy) * 100.0;

            final pnlColor = totalPnl >= 0 ? Colors.redAccent : Colors.blue[200];

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 상단 합계(스크린샷 큰 숫자)
                  Text(_won(totalEval), style: valueStyle),
                  const SizedBox(height: 2),
                  Text(
                    '${totalPnl >= 0 ? '+' : ''}${_won(totalPnl)} (${totalRate.toStringAsFixed(1)}%)',
                    style: subStyle?.copyWith(color: pnlColor),
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 12),

                  // ✅ 리스트
                  if (etfs.isEmpty)
                    Text('보유 ETF가 없습니다.', style: subStyle)
                  else
                    Column(
                      children: [
                        // 너무 길어지면 3개만 보여주고 싶으면 .take(3)
                        for (final e in etfs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HoldingRow(contract: e),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _loadingCard(Color cardColor, String msg) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(msg, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _errorCard(Color cardColor, String msg, Future<void> Function() onReload) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '조회 실패: $msg',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(onPressed: onReload, child: const Text('다시시도')),
        ],
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  final Pcontract contract;

  const _HoldingRow({required this.contract});

  @override
  Widget build(BuildContext context) {
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.grey[400],
    );

    final name = contract.pname ?? contract.fname ?? contract.code ?? '이름없음';

    final qty = contract.pstock ?? 0;
    final buyPrice = contract.pprice ?? 0;
    final evalAmount = contract.psum ?? 0;

    final buyAmount = qty * buyPrice;

    // ✅ 현재가(추정): 평가금액 / 수량
    final nowPrice = (qty <= 0) ? 0 : (evalAmount / qty).round();

    // ✅ 손익률(추정): (평가-매수)/매수
    final pnl = evalAmount - buyAmount;
    final rate = (buyAmount == 0) ? 0.0 : (pnl / buyAmount) * 100.0;

    final rateColor = rate >= 0 ? Colors.redAccent : Colors.blue[200];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text('내 평균 ${_won(buyPrice)}', style: subStyle),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _won(nowPrice),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${rate >= 0 ? '+' : ''}${rate.toStringAsFixed(1)}%',
              style: subStyle?.copyWith(color: rateColor),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---- money helpers ----
final _wonFormatter = NumberFormat('#,###', 'ko_KR');
String _won(num v) => '${_wonFormatter.format(v)}원';

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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const Icon(Icons.chevron_right,
                size: 20, color: Colors.white54),
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
      const _StockChip(
        title: '리카겐바이오',
        change: '+3.4%',
        isUp: true,
      ),
      const _StockChip(
        title: '삼성전자',
        change: '-0.3%',
        isUp: false,
      ),
      const _StockChip(
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
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
        color: const Color(0xFF121318),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
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
            child: const Icon(Icons.close,
                size: 14, color: Colors.white38),
          )
        ],
      ),
    );
  }
}

/// 실시간 거래대금 차트
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
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.$4,
                        style: const TextStyle(
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

  const _NewsSection({
    required this.cardColor,
    required this.title,
  });

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
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
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
            '부기증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 단순 참고 자료이며, '
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
