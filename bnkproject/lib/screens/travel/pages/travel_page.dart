// lib/screens/travel/pages/travel_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../travel_theme.dart';

import '../tabs/mission_tab.dart';
import '../tabs/reward_tab.dart';
import '../tabs/map_tab.dart';
import '../tabs/rank_tab.dart';
import '../tabs/boogi_tab.dart';

import '../widgets/glass_card.dart';
import '../widgets/boogi_category_bar.dart';
import '../widgets/quick_card.dart';
import '../widgets/tab_pill.dart';
import '../widgets/xp.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final ScrollController _scrollCtrl = ScrollController();

  int _tabIndex = 0; // 0: mission, 1: reward, 2: map_spot.dart, 3: rank, 4: boogi
  String _categoryId = 'food';

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _selectCategory(String id) {
    setState(() => _categoryId = id);
    // TODO: 여기서 미션/스팟/리스트를 카테고리로 필터링 연결
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goTab(int idx) {
    setState(() => _tabIndex = idx);
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 640;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TravelTheme.bgTop, TravelTheme.bgBottom],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 76,
              titleSpacing: 0,
              automaticallyImplyLeading: true,
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
                          'assets/images/travel.png',
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
                            '일일 미션 ~방구석에 있으면 뭐하노~',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'BNK 앱 내 관광 미션 · 신동백전 결제 연동',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 12),
                      LevelXpBlock(
                        levelText: 'Lv.3 상인 부기',
                        xpText: 'XP 312 / 500',
                        progress: 0.62,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final heroWide = constraints.maxWidth >= 720;

                          final image = Image.asset(
                            'assets/images/travel.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          );

                          final text = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(text: '일일 미션하며 '),
                                    TextSpan(
                                      text: '부기를 성장',
                                      style: TextStyle(color: TravelTheme.boogiMint),
                                    ),
                                    TextSpan(text: '시키자!'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '부산관광공사 인증 명소를 방문하고, 신동백전으로 결제하면 XP가 쌓입니다.\n'
                                    '미션을 수행하며 스테이블코인으로 보상을 받으세요.',
                                style: TextStyle(
                                  color: Color(0xFFC7D2FE),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );

                          if (heroWide) {
                            return Row(
                              children: [
                                image,
                                const SizedBox(width: 18),
                                Expanded(child: text),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              image,
                              const SizedBox(height: 12),
                              text,
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    BoogiCategoryBar(
                      selectedId: _categoryId,
                      onSelect: _selectCategory,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 900 ? 3 : 1;
                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols == 1 ? 3.0 : 1.35,
                          children: [
                            QuickCard(
                              title: '오늘의 미션',
                              badgeText: '+50 XP',
                              badgeColor: TravelTheme.boogiMint,
                              desc: '신동백전으로 결제 1회 · 전통시장 방문',
                              buttonText: '미션 보드로 이동',
                              buttonColor: TravelTheme.boogiMint,
                              onTap: () => _goTab(0),
                            ),
                            QuickCard(
                              title: '보상 수령',
                              badgeText: '신동백전 1,200P',
                              badgeColor: TravelTheme.boogiGold,
                              desc: '완료 보상 3건이 대기 중입니다.',
                              buttonText: '리워드 보관함',
                              buttonColor: TravelTheme.boogiGold,
                              onTap: () => _goTab(1),
                            ),
                            QuickCard(
                              title: '현재 랭킹',
                              badgeText: '서면 지역 #12',
                              badgeColor: const Color(0xFFCBD5E1),
                              desc: 'TOP 10 진입까지 180 XP 남음',
                              buttonText: '랭킹 보드',
                              buttonColor: const Color(0xFF818CF8),
                              onTap: () => _goTab(3),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Expanded(child: TabPill(label: '🎯 미션', active: _tabIndex == 0, onTap: () => _goTab(0))),
                          Expanded(child: TabPill(label: '💰 리워드', active: _tabIndex == 1, onTap: () => _goTab(1))),
                          Expanded(child: TabPill(label: '📍 지도', active: _tabIndex == 2, onTap: () => _goTab(2))),
                          Expanded(child: TabPill(label: '🏆 랭킹', active: _tabIndex == 3, onTap: () => _goTab(3))),
                          Expanded(child: TabPill(label: '🐳 내 부기', active: _tabIndex == 4, onTap: () => _goTab(4))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_tabIndex == 0) MissionTab(onGoTab: _goTab),
                    if (_tabIndex == 1) RewardTab(onSnack: _showSnack, onGoTab: _goTab),
                    if (_tabIndex == 2) MapTab(onSnack: _showSnack, categoryId: _categoryId), // ✅ 변경
                    if (_tabIndex == 3) const RankTab(),
                    if (_tabIndex == 4) BoogiTab(onSnack: _showSnack),

                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        '© 2025 BNK부산은행 · 부산시 · 부산관광공사 · 신동백전',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        textAlign: TextAlign.center,
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
