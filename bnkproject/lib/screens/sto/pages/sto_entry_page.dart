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
                Text('야구 팀을 종목처럼 사고팔며 시즌을 진행합니다.', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),

                _noticeCard(context),
                const SizedBox(height: 10),
                _eventRow(),
                const SizedBox(height: 14),

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
                        _bullet('상위권 팀은 “승”, 하위권은 “패”로 집계됩니다.'),
                        _bullet('뉴스는 더미이며 시장심리 연출용입니다.'),
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

  Widget _noticeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StoTheme.gold.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: StoTheme.gold.withOpacity(0.35)),
            ),
            child: const Icon(Icons.campaign, color: StoTheme.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('공지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('시즌 1 오픈 · 신규 이벤트 진행 중', style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showRulesModal(context),
            child: const Text('규칙 보기'),
          ),
        ],
      ),
    );
  }

  Widget _eventRow() {
    Widget chip(String title, String desc) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: StoTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('이벤트', '첫 거래 보너스'),
        const SizedBox(width: 10),
        chip('미션', '주차별 목표 달성'),
      ],
    );
  }

  void _showRulesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StoTheme.bgTop,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('시즌 규칙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                _rule('기간', '총 12주. 주차 버튼으로 라운드를 진행합니다.'),
                _rule('가격', '각 팀 가격은 주차마다 랜덤 변동(±8%).'),
                _rule('승패', '주간 등락률 상위 절반 “승”, 하위 절반 “패”.'),
                _rule('뉴스', '더미입니다. 실제 데이터/투자조언 아님.'),
                _rule('목표', '시즌 종료 시 총자산 최대화.'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoTheme.mint,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rule(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64, child: Text(k, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          const SizedBox(width: 10),
          Expanded(child: Text(v, style: TextStyle(color: StoTheme.subText, fontWeight: FontWeight.w700))),
        ],
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
