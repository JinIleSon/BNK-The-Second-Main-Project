import 'dart:ui';
import 'package:flutter/material.dart';

import 'retirement_trip_theme.dart';
import 'widgets/glass_card.dart';

import 'pages/retirement_trip_plan_page.dart';
import 'pages/retirement_trip_goal_page.dart';
import 'pages/retirement_trip_budget_page.dart';
import 'pages/retirement_trip_simulator_page.dart';
import 'pages/retirement_trip_summary_page.dart';

class RetirementTripEntryPage extends StatelessWidget {
  const RetirementTripEntryPage({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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
                            'Goal 기반 적립 플랜',
                            style: TextStyle(
                              color: RetirementTripTheme.subText,
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWide) const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ✅ 추가: Hero(큰 family.png) + CTA
                    GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/goals/family.png', // ✅ 큰 히어로 이미지
                              width: isWide ? 260 : 220,
                              height: isWide ? 260 : 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '가족과 떠날 “은퇴 여행”\n지금부터 숫자로 계획하세요.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '목표 → 예산 → 적립 시뮬로, 여행 시작일까지 얼마나 모일지 바로 확인합니다.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RetirementTripTheme.mint,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () => _push(context, const RetirementTripPlanPage()),
                              child: const Text(
                                '지금 계획 시작하기',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ 기존 메뉴 리스트 유지
                    GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _EntryItem(
                            title: '계획 메인',
                            subtitle: '현재 목표/예산/달성률 요약',
                            onTap: () => _push(context, const RetirementTripPlanPage()),
                          ),
                          const Divider(color: Colors.white12, height: 18),
                          _EntryItem(
                            title: '목표 설정',
                            subtitle: '목적지 · 기간 · 동행 · 목표금액',
                            onTap: () => _push(context, const RetirementTripGoalPage()),
                          ),
                          const Divider(color: Colors.white12, height: 18),
                          _EntryItem(
                            title: '예산 설정',
                            subtitle: '항공/숙박/식비/교통/관광/예비비',
                            onTap: () => _push(context, const RetirementTripBudgetPage()),
                          ),
                          const Divider(color: Colors.white12, height: 18),
                          _EntryItem(
                            title: '적립 시뮬레이터',
                            subtitle: '월 적립액/기간 기반 달성 가능성 계산',
                            onTap: () => _push(context, const RetirementTripSimulatorPage()),
                          ),
                          const Divider(color: Colors.white12, height: 18),
                          _EntryItem(
                            title: '요약',
                            subtitle: '목표/예산/시뮬 결과 한 번에 보기',
                            onTap: () => _push(context, const RetirementTripSummaryPage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EntryItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: RetirementTripTheme.subText, fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.55)),
          ],
        ),
      ),
    );
  }
}
