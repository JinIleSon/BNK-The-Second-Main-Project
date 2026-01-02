import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/trip_plan.dart';
import '../services/retirement_trip_service.dart';
import '../retirement_trip_theme.dart';

import '../widgets/glass_card.dart';
import '../widgets/goal_progress_bar.dart';

import 'retirement_trip_goal_page.dart';
import 'retirement_trip_budget_page.dart';
import 'retirement_trip_simulator_page.dart';

class RetirementTripSummaryPage extends StatefulWidget {
  const RetirementTripSummaryPage({super.key});

  @override
  State<RetirementTripSummaryPage> createState() => _RetirementTripSummaryPageState();
}

class _RetirementTripSummaryPageState extends State<RetirementTripSummaryPage> {
  final _service = const RetirementTripService();
  late Future<TripPlan> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.loadPlan();
  }

  void _reload() => setState(() => _future = _service.loadPlan());

  Future<void> _pushAndReload(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _reload();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  String _fmtWon(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}원';
  }

  int _monthsUntil(DateTime future) {
    final now0 = DateTime.now();
    final now = DateTime(now0.year, now0.month, now0.day);
    final f = DateTime(future.year, future.month, future.day);

    if (!f.isAfter(now)) return 0;

    int months = (f.year - now.year) * 12 + (f.month - now.month);
    if (months > 0 && f.day < now.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RetirementTripTheme.bgTop, RetirementTripTheme.bgBottom],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 76,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.10)),
                      ),
                    ),
                  ),
                ),
              ),
              title: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  '요약',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<TripPlan>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text('플랜을 불러오지 못했습니다.', style: TextStyle(color: Colors.white70)),
                        ),
                      );
                    }

                    final p = snapshot.data!;
                    final g = p.goal;
                    final b = p.budget;

                    final monthsToTrip = _monthsUntil(g.startDate);
                    final projectedSaved = p.currentSaved + (p.monthlyContribution * monthsToTrip);
                    final projectedRate = g.targetAmount <= 0 ? 0 : ((projectedSaved / g.targetAmount) * 100).round();

                    return Column(
                      children: [
                        GlassCard(
                          radius: 24,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('목표', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              _KV('목적지', g.destination),
                              _KV('기간', '${_fmtDate(g.startDate)} ~ ${_fmtDate(g.endDate)} (${g.durationDays}일)'),
                              _KV('동행', g.companion),
                              _KV('목표금액', _fmtWon(g.targetAmount)),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: RetirementTripTheme.mint,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () => _pushAndReload(const RetirementTripGoalPage()),
                                  child: const Text('목표 수정', style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        GlassCard(
                          radius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('예산', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              _KV('총 예산', _fmtWon(b.total)),
                              const SizedBox(height: 6),
                              for (final e in b.toCategoryMap().entries)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _KV(e.key, _fmtWon(e.value)),
                                ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: RetirementTripTheme.gold,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () => _pushAndReload(const RetirementTripBudgetPage()),
                                  child: const Text('예산 편집', style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        GlassCard(
                          radius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('적립', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              GoalProgressBar(
                                progress: p.progressRate,
                                leftLabel: '현재 적립: ${_fmtWon(p.currentSaved)}',
                                rightLabel: '남은 금액: ${_fmtWon(p.remainingAmount)}',
                              ),
                              const SizedBox(height: 12),
                              _KV('월 적립액', _fmtWon(p.monthlyContribution)),
                              _KV('목표 달성까지', p.monthsNeeded < 0 ? '계산 불가(월 적립액 0)' : '${p.monthsNeeded}개월'),
                              _KV('예상 달성일', p.expectedAchieveDate == null ? '-' : _fmtDate(p.expectedAchieveDate!)),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Colors.white12),
                              const SizedBox(height: 12),
                              const Text(
                                '여행 시작일까지 자동 시뮬',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              _KV('남은 기간', '${monthsToTrip}개월'),
                              _KV('예상 적립액', _fmtWon(projectedSaved)),
                              _KV('예상 달성률', '$projectedRate%'),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: RetirementTripTheme.violet,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () => _pushAndReload(const RetirementTripSimulatorPage()),
                                  child: const Text('적립 조정(시뮬레이터)', style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;

  const _KV(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: TextStyle(color: Colors.white.withOpacity(0.60), fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white.withOpacity(0.90), fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
