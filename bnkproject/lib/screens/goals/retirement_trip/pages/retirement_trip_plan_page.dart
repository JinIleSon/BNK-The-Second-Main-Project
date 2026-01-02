import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/trip_plan.dart';
import '../services/retirement_trip_service.dart';
import '../retirement_trip_theme.dart';

import '../widgets/glass_card.dart';
import '../widgets/goal_progress_bar.dart';
import '../widgets/simulator_result_card.dart';

import 'retirement_trip_goal_page.dart';
import 'retirement_trip_budget_page.dart';
import 'retirement_trip_simulator_page.dart';
import 'retirement_trip_summary_page.dart';

class RetirementTripPlanPage extends StatefulWidget {
  const RetirementTripPlanPage({super.key});

  @override
  State<RetirementTripPlanPage> createState() => _RetirementTripPlanPageState();
}

class _RetirementTripPlanPageState extends State<RetirementTripPlanPage> {
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
    final isWide = MediaQuery.of(context).size.width >= 640;

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
              title: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.20)),
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: Image.asset(
                          RetirementTripTheme.heroAsset,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '은퇴 후 여행 계획',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '목표 설정 · 예산 · 적립 플랜',
                            style: TextStyle(
                              color: RetirementTripTheme.subText,
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.summarize_outlined, color: Colors.white),
                      onPressed: () => _pushAndReload(const RetirementTripSummaryPage()),
                      tooltip: '요약',
                    ),
                    if (isWide) const SizedBox(width: 4),
                  ],
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

                    final plan = snapshot.data!;
                    final goal = plan.goal;
                    final budget = plan.budget;

                    final goalTitle = '${goal.destination} (${goal.durationDays}일)';
                    final goalSub = '${_fmtDate(goal.startDate)} ~ ${_fmtDate(goal.endDate)} · ${goal.companion}';

                    final targetText = _fmtWon(goal.targetAmount);
                    final savedText = _fmtWon(plan.currentSaved);
                    final remainText = _fmtWon(plan.remainingAmount);
                    final budgetTotalText = _fmtWon(budget.total);

                    final monthsToTrip = _monthsUntil(goal.startDate);
                    final projectedSaved = plan.currentSaved + (plan.monthlyContribution * monthsToTrip);
                    final projectedSavedText = _fmtWon(projectedSaved);
                    final projectedRate = goal.targetAmount <= 0
                        ? 0
                        : ((projectedSaved / goal.targetAmount) * 100).round();

                    final top3 = budget.toCategoryMap().entries.take(3).toList();

                    return Column(
                      children: [
                        GlassCard(
                          radius: 24,
                          padding: const EdgeInsets.all(18),
                          child: _HeaderBlock(
                            title: goalTitle,
                            subtitle: goalSub,
                            trailing: '수정',
                            onTrailing: () => _pushAndReload(const RetirementTripGoalPage()),
                            bottomText: '목표금액: $targetText',
                            accent: RetirementTripTheme.mint,
                          ),
                        ),
                        const SizedBox(height: 12),

                        GlassCard(
                          radius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CardTitle(
                                title: '예산',
                                trailing: '편집',
                                onTrailing: () => _pushAndReload(const RetirementTripBudgetPage()),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '총 예산: $budgetTotalText',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (final e in top3)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          e.key,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.80),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _fmtWon(e.value),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.65),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                '※ 전체 항목은 예산 편집에서 확인',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.40),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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
                              const _CardTitle(title: '달성 현황'),
                              const SizedBox(height: 10),
                              GoalProgressBar(
                                progress: plan.progressRate,
                                leftLabel: '현재 적립: $savedText',
                                rightLabel: '남은 금액: $remainText',
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
                              const _CardTitle(title: '자동 시뮬(여행 시작일까지)'),
                              const SizedBox(height: 10),
                              _KeyValueRow(label: '남은 기간', value: '${monthsToTrip}개월'),
                              _KeyValueRow(label: '예상 적립액', value: projectedSavedText),
                              _KeyValueRow(label: '예상 달성률', value: '$projectedRate%'),
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
                              _CardTitle(
                                title: '시뮬레이터(목표 달성까지)',
                                trailing: '실행',
                                onTrailing: () => _pushAndReload(const RetirementTripSimulatorPage()),
                              ),
                              const SizedBox(height: 10),
                              SimulatorResultCard(
                                monthlyContribution: plan.monthlyContribution,
                                monthsNeeded: plan.monthsNeeded,
                                expectedDate: plan.expectedAchieveDate,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: RetirementTripTheme.violet,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () => _pushAndReload(const RetirementTripSimulatorPage()),
                                  child: const Text('월 적립/현재 적립 조정하기'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            '© 2025 BNK부산은행 · Goals PoC',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            textAlign: TextAlign.center,
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

class _HeaderBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTrailing;
  final String bottomText;
  final Color accent;

  const _HeaderBlock({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTrailing,
    required this.bottomText,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
            ),
            InkWell(
              onTap: onTrailing,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  trailing,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: RetirementTripTheme.subText,
            fontSize: 12,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          bottomText,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;

  const _CardTitle({required this.title, this.trailing, this.onTrailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          InkWell(
            onTap: onTrailing,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                trailing!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
