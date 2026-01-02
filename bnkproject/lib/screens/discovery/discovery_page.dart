import 'package:bnkproject/models/StockRank.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../api/stock_rank_api.dart';
import '../stock_detail/stock_detail_page.dart';
import '../menu/menu_page.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);

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
        ),
        SizedBox(
          height: 76,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _DiscoverCategoryChip(label: '국내주식', emoji: '🇰🇷'),
              _DiscoverCategoryChip(label: '해외주식', emoji: '🇺🇸'),
              _DiscoverCategoryChip(label: '채권', emoji: '💰'),
              _DiscoverCategoryChip(label: 'ETF', emoji: '📊'),
            ],
          ),
        ),
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
                  Text('코스피', style: bodySmall),
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
                      _DiscoveryStockList(),
                      const Center(child: Text('거래량 탭은 준비 중입니다.')),
                      const Center(child: Text('급상승 탭은 준비 중입니다.')),
                      const Center(child: Text('급하락 탭은 준비 중입니다.')),
                      const Center(child: Text('인기 탭은 준비 중입니다.')),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

/*
  날짜 : 2025.12.17.
  이름 : 강민철
  내용 : 주식 리스트를 API와 연결
 */
class _DiscoveryStockList extends StatefulWidget {
  const _DiscoveryStockList({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryStockListState();
}
class _DiscoveryStockListState extends State<_DiscoveryStockList> with TickerProviderStateMixin{
  OverlayEntry? _toastEntry;
  AnimationController? _toastController;

  void _showLowestChangeRateOnce() {
    if (_shownLowestToast) return;
    if (_stocks.isEmpty) return;

    final lowest = _stocks.reduce((a, b) => a.changeRate <= b.changeRate ? a : b);
    _shownLowestToast = true;

    // setState 직후 안전하게 띄우기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showSmoothToast('최저 등락률: ${lowest.name}  ${lowest.changeRate}%');
    });
  }

  void _showSmoothToast(String message) {
    // 기존 토스트가 있으면 정리
    _toastEntry?.remove();
    _toastEntry = null;

    _toastController?.dispose();
    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );

    final anim = CurvedAnimation(
      parent: _toastController!,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final cardColor = Theme.of(context).cardColor;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 15.5,
      color: Colors.white.withOpacity(0.9),
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
    );

    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bottom = 16.0 + bottomSafe + 56.0; // 하단바 위로 살짝 띄움(원하면 조절)

    _toastEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: 16,
          right: 16,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(anim),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 16,
                        offset: Offset(0, 8),
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down, size: 20, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_toastEntry!);
    _toastController!.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      try {
        await _toastController?.reverse();
      } finally {
        _toastEntry?.remove();
        _toastEntry = null;
      }
    });
  }
  final api = StockRankApiClient(baseUrl: 'http://10.0.2.2:8080/BNK');

  List<StockRank> _stocks = [];
  bool _loading = true;

  Timer? _refreshTimer;

  // 주기 갱신 중복 호출 방지
  bool _isRefreshing = false;

  bool _shownLowestToast = false;

  // 최초 로드
  Future<void> _initialLoad() async {
    try {
      final main = await api.fetchDomesticMain();
      if (!mounted) return;

      setState(() {
        _stocks = main.ranks;
        _loading = false;
      });

      // ✅ 거래대금(현재 탭) 데이터 중 "가장 낮은 등락률" 1회 토스트
      _showLowestChangeRateOnce();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // 주기 갱신
  Future<void> _refreshRanks() async {
    // 이미 로딩 중이거나 화면이 없으면 중복 호출 방지
    if (!mounted) return;

    // 이미 갱신 중이면 이번 틱은 스킵
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final ranks = await api.fetchStockRanks();
      if (!mounted) return;

      setState(() {
        _stocks = ranks; // 깜빡임 없이 데이터만 교체
      });
      // ✅ “한 번만”이라면 refresh에서는 호출하지 않음
      // (만약 refresh 때도 1번만 띄우고 싶으면 여기서 호출해도 되지만,
      //  지금 요구사항은 1회만이니 initialLoad에서만)
    } catch (_) {
      // ignore
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void initState() {
    super.initState();

    // 최초 1회 로드
    _initialLoad();

    // 1.5초마다 갱신
    _refreshTimer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (_) => _refreshRanks()
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    _toastEntry?.remove();
    _toastController?.dispose();

    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.grey[400]);
    final cardColor = Theme.of(context).cardColor;

    if (_loading && _stocks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stocks.isEmpty) {
      return const Center(child: Text('거래대금 목록이 없습니다.'));
    }

      return ListView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final s in _stocks)
            Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockDetailPage(
                          name: s.name,
                          price: s.price,
                          change: s.changeRate.toString(),
                          stockCode: s.code,
                        ),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.rank.toString(),
                        style: bodySmall,
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white10,
                        child: Text(
                          s.name.characters.first,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    WonFormatter(s.price).won,
                    style: bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.changeRate.toString().startsWith('-') ? '${s.changeRate}%' : '+${s.changeRate}%',
                        style: bodySmall?.copyWith(
                          color: s.changeRate.toString().startsWith('-')
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

/*
  날짜 : 2025.12.18.
  이름 : 강민철
  내용 : 원화 formatter
 */
extension WonFormatter on num {
  String get won {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(this)}원';
  }
}