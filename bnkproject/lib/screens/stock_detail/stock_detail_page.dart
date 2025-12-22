import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_buy_page.dart';
import 'stock_sell_page.dart';
import '../../api/hoga_ws_api.dart';
import '../../models/order_book.dart';

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

class StockDetailPage extends StatefulWidget {
  final String name;
  final int price;
  final String change;

  // ✅ 추가: WS 구독용 종목코드
  final String stockCode;

  const StockDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.change,
    required this.stockCode,
  });

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  late final HogaWsApi _hogaApi;

  @override
  void initState() {
    super.initState();

    // ✅ 웹/에뮬레이터/실기기 모두 고려: baseUrl 대신 현재 호스트 기준
    final protocol = Uri.base.scheme == 'https' ? 'wss' : 'ws';
    final host = '10.0.2.2';
    final port = ':8080';

    _hogaApi = HogaWsApi(
      wsUri: Uri.parse('$protocol://$host$port/BNK/ws/hoga?code=${widget.stockCode}'),
    );

    _hogaApi.connect();
  }

  @override
  void dispose() {
    _hogaApi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    final isUpFallback = !widget.change.startsWith('-');
    final changeColorFallback = isUpFallback ? Colors.redAccent : Colors.blue[200];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // ✅ 헤더: WS snapshot 있으면 현재가/등락률 실시간 표시
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<OrderBookSnapshot>(
                  stream: _hogaApi.snapshots,
                  builder: (context, snap) {
                    final s = snap.data;

                    final currentPrice = s?.currentPrice ?? widget.price;
                    final rate = s?.changeRate; // % 값
                    final isUp = (rate ?? (isUpFallback ? 1 : -1)) >= 0;
                    final changeColor = isUp ? Colors.redAccent : Colors.blue[200];

                    final changeText = (rate == null)
                        ? '어제보다 ${widget.change.startsWith('-') ? widget.change : '+${widget.change}'}%'
                        : '어제보다 ${rate >= 0 ? '+' : '-'}${rate.abs().toStringAsFixed(2)}%';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentPrice.won,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(changeText, style: TextStyle(color: changeColor ?? changeColorFallback)),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
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

                    // ✅ 여기로 stream 전달
                    _HogaTab(cardColor: cardColor, snapshots: _hogaApi.snapshots),

                    _MyStockTab(cardColor: cardColor),
                    _StockInfoTab(cardColor: cardColor),
                    _CommunityTab(cardColor: cardColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ 하단 구매/판매 버튼 유지 + 가격은 WS 현재가로 넘기기(없으면 기존 price)
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<OrderBookSnapshot>(
              stream: _hogaApi.snapshots,
              builder: (context, snap) {
                final livePrice = snap.data?.currentPrice ?? widget.price;

                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StockSellPage(
                                  name: widget.name,
                                  currentPrice: livePrice,
                                  changePercentText: widget.change,
                                ),
                              ),
                            );
                          },
                          child: const Text('판매하기', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StockBuyPage(
                                  name: widget.name,
                                  currentPrice: livePrice,
                                  changePercentText: widget.change,
                                ),
                              ),
                            );
                          },
                          child: const Text('구매하기', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _ChartFilterButton(label: '1일', selected: true),
            _ChartFilterButton(label: '1주'),
            _ChartFilterButton(label: '3달'),
            _ChartFilterButton(label: '1년'),
            _ChartFilterButton(label: '5년'),
            _ChartFilterButton(label: '전체'),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '일별 · 실시간 시세 보기 >',
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

extension NumComma on num {
  String get comma => NumberFormat('#,###', 'ko_KR').format(this);
}

class _HogaTab extends StatelessWidget {
  final Color cardColor;
  final Stream<OrderBookSnapshot> snapshots;

  const _HogaTab({
    required this.cardColor,
    required this.snapshots,
  });

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[400];

    return StreamBuilder<OrderBookSnapshot>(
      stream: snapshots,
      builder: (context, snap) {
        final data = snap.data;

        if (data == null) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text('호가 수신 대기중...', style: TextStyle(color: grey, fontSize: 12)),
                    const Spacer(),
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
            ],
          );
        }

        // 10레벨을 위/아래로 나누기
        final asks = data.levels
            .map((e) => (price: e.askPrice, qty: e.askQty))
            .where((e) => e.price != null && e.qty != null)
            .toList()
          ..sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0)); // 매도 높은 가격이 위

        final bids = data.levels
            .map((e) => (price: e.bidPrice, qty: e.bidQty))
            .where((e) => e.price != null && e.qty != null)
            .toList()
          ..sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0)); // 매수 높은 가격이 위(보통 UI랑 맞춤)

        final rows = <_OrderBookRowData>[];

        // 매도(상단 10)
        for (final a in asks) {
          rows.add(_OrderBookRowData(
            askQty: (a.qty ?? 0).comma,
            price: (a.price ?? 0).comma,
            change: _rateText(data.changeRate),
          ));
        }

        // 현재가(가운데)
        if (data.currentPrice != null) {
          rows.add(_OrderBookRowData(
            price: data.currentPrice!.comma,
            change: _rateText(data.changeRate),
            isCurrent: true,
          ));
        }

        // 매수(하단 10)
        for (final b in bids) {
          rows.add(_OrderBookRowData(
            bidQty: (b.qty ?? 0).comma,
            price: (b.price ?? 0).comma,
            change: _rateText(data.changeRate),
          ));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '총매수 ${ (data.totalBidQty ?? 0).comma } · 총매도 ${ (data.totalAskQty ?? 0).comma }',
                    style: TextStyle(color: grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    data.sourceType,
                    style: TextStyle(color: grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('매수잔량', style: TextStyle(color: grey, fontSize: 11)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(child: Text('호가', style: TextStyle(color: grey, fontSize: 11))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('매도잔량', style: TextStyle(color: grey, fontSize: 11)),
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

            // 아래 영역은 기존 더미 그대로 유지
            const SizedBox(height: 16),
            Text('왜 올랐을까?', style: TextStyle(color: grey)),
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
                  Text('SK하이닉스가 금융 자회사 설립 허용으로 자금조달이 쉬워졌기 때문이에요.'),
                  SizedBox(height: 6),
                  Text('시카트로닉스 외 3개 종목과 연관'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  static String _rateText(double? rate) {
    if (rate == null) return '';
    final sign = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$sign${rate.abs().toStringAsFixed(2)}%';
  }
}

class _OrderBookRowData {
  final String? bidQty;
  final String price;
  final String change;
  final String? askQty;
  final bool isCurrent;

  const _OrderBookRowData({
    this.bidQty,
    required this.price,
    required this.change,
    this.askQty,
    this.isCurrent = false,
  });
}

class _OrderBookRow extends StatelessWidget {
  final _OrderBookRowData data;

  const _OrderBookRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final bidColor = const Color(0xFF1E3A8A);
    final askColor = const Color(0xFF7F1D1D);
    final isUp = !data.change.startsWith('-');
    final priceColor = isUp ? Colors.redAccent : Colors.blue[200]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
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
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.price,
                  style: TextStyle(
                    color: priceColor,
                    fontWeight: data.isCurrent
                        ? FontWeight.bold
                        : FontWeight.w500,
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
      ('🔥 호재', '최근 3달 사이 +104.1% 상승했어요.', '6분 전'),
      ('🔥 호재', '최근 1년 사이 +233.9% 상승했어요.', '6분 전'),
      ('🟢 소식', '주식 고수들의 76%가 팔았어요.', '21분 전'),
      ('🔴 호재', '매출액이 2분기 연속 상승했어요.', '21분 전'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '10초 요약 보기',
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
                      subtitle: Text(
                        s.$3,
                        style: TextStyle(color: grey),
                      ),
                    ),
                    if (s != summaryItems.last)
                      const Divider(
                          height: 1, color: Colors.white12),
                  ],
                ),
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
        const Text('커뮤니티', style: TextStyle(fontSize: 18)),
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
              Text('💀 누가 뭐래도 난 간다 sk 하이닉스'),
              SizedBox(height: 8),
              Text(
                '168,246개 의견 보기 >',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2025),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '주식 모으기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
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
        Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 40,
              color: Colors.white.withOpacity(0.2),
            ),
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

class _FakeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
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
