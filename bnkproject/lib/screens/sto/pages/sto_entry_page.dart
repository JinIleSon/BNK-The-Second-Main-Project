import 'package:flutter/material.dart';
import '../sto_theme.dart';
import 'sto_season_page.dart';

class StoEntryPage extends StatelessWidget {
  const StoEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: StoTheme.bgGradient()),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text('STO 시즌 투자', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('야구 팀을 종목처럼 사고팔며 시즌을 진행합니다.',
                    style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: StoTheme.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _boogiBaseball(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '미션: 시즌 종료(12주)까지\n총자산을 최대로 만들어라',
                                style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w800, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _bullet('주차마다 가격이 변동됩니다.'),
                        _bullet('매수/매도로 현금/보유가 바뀝니다.'),
                        _bullet('포트폴리오에서 손익을 확인합니다.'),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => const StoSeasonPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoTheme.mint,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: const Text('시즌 시작', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: StoTheme.mint, borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _boogiBaseball() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 84,
        height: 84,
        color: Colors.white.withOpacity(0.06),
        child: Image.asset(
          'assets/images/sto/boogi_baseball.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.sports_baseball, color: Colors.white, size: 44),
        ),
      ),
    );
  }
}
