import 'package:flutter/material.dart';

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
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '어제보다 $change',
                      style: TextStyle(color: changeColor),
                    ),
                  ],
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

class _HogaTab extends StatelessWidget {
  final Color cardColor;

  const _HogaTab({required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[400];

    final rows = <_OrderBookRowData>[
      _OrderBookRowData(askQty: '9,408', price: '588,000', change: '+3.88%'),
      _OrderBookRowData(askQty: '5,693', price: '587,000', change: '+3.71%'),
      _OrderBookRowData(askQty: '6,004', price: '586,000', change: '+3.53%'),
      _OrderBookRowData(
        bidQty: '10,256',
        price: '585,000',
        change: '+3.35%',
        isCurrent: true,
      ),
      _OrderBookRowData(bidQty: '14,417', price: '584,000', change: '+3.18%'),
      _OrderBookRowData(bidQty: '17,171', price: '583,000', change: '+3.01%'),
      _OrderBookRowData(bidQty: '29,358', price: '582,000', change: '+2.84%'),
      _OrderBookRowData(bidQty: '19,381', price: '581,000', change: '+2.67%'),
      _OrderBookRowData(bidQty: '13,101', price: '580,000', change: '+2.49%'),
      _OrderBookRowData(bidQty: '12,965', price: '579,000', change: '+2.32%'),
      _OrderBookRowData(bidQty: '11,936', price: '578,000', change: '+2.14%'),
      _OrderBookRowData(bidQty: '9,023', price: '577,000', change: '+1.96%'),
      _OrderBookRowData(bidQty: '4,423', price: '576,000', change: '+1.76%'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                '체결강도 144.8%',
                style: TextStyle(color: grey, fontSize: 12),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '전일 종가 568,000원',
                    style: TextStyle(color: grey, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '고가 590,000원 · 저가 570,000원',
                    style: TextStyle(color: grey, fontSize: 11),
                  ),
                ],
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        '매수잔량',
                        style: TextStyle(color: grey, fontSize: 11),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          '호가',
                          style:
                          TextStyle(color: grey, fontSize: 11),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '매도잔량',
                          style:
                          TextStyle(color: grey, fontSize: 11),
                        ),
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
              Text(
                'SK하이닉스가 금융 자회사 설립 허용으로 자금조달이 쉬워졌기 때문이에요.',
              ),
              SizedBox(height: 6),
              Text('시카트로닉스 외 3개 종목과 연관'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Text('주문내역 보기'),
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
