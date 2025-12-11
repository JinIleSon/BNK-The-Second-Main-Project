import 'package:flutter/material.dart';

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
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text('부기증권 145-01-502041', style: bodySmall),
        const SizedBox(height: 6),
        Text('948,011원', style: bigNumber),
        const SizedBox(height: 12),
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
              const _AccountRow(
                leadingText: '원화',
                value: '11원',
              ),
              const SizedBox(height: 8),
              const _AccountRow(
                leadingText: '달러',
                value: '\$0.00 (0원)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                    style:
                    bodySmall?.copyWith(color: Colors.blue[200]),
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
                        style:
                        bodySmall?.copyWith(color: Colors.blue[200]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
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
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
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
                    style: bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
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
        Text(
          '부기증권에서 제공하는 투자 정보는 고객의 투자 판단을 위한 단순 참고 자료이며, '
              '투자 결과에 대한 법적 책임을 지지 않습니다.',
          style: bodySmall,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

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
