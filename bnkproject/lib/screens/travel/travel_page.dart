// lib/pages/travel_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  static const _boogiMint = Color(0xFF38E1C6);
  static const _boogiGold = Color(0xFFFFC93C);

  static const _bgTop = Color(0xFF0B1020);
  static const _bgBottom = Color(0xFF0F1730);

  static const _busanCenter = LatLng(35.1796, 129.0756);

  final ScrollController _scrollCtrl = ScrollController();

  int _tabIndex = 0; // 0: mission, 1: reward, 2: map, 3: rank, 4: boogi

  final MapController _mapController = MapController();
  bool _mapReady = false;

  static const _spots = <_Spot>[
    _Spot(
      id: 'haeundae',
      position: LatLng(35.1587, 129.1604),
      title: '해운대 해수욕장',
      snippet: '신동백전 결제 미션 가능',
    ),
    _Spot(
      id: 'gwanganri',
      position: LatLng(35.1532, 129.1187),
      title: '광안리 해변',
      snippet: '신동백전 결제 미션 가능',
    ),
    _Spot(
      id: 'nampo',
      position: LatLng(35.0980, 129.0306),
      title: '남포동 BIFF거리',
      snippet: '신동백전 결제 미션 가능',
    ),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
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

  void _moveToBusanCenter() {
    if (!_mapReady) return;
    _mapController.move(_busanCenter, 12);
  }

  List<Marker> _buildMarkers() {
    return _spots.map((s) {
      return Marker(
        point: s.position,
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => _showSnack('${s.title} · ${s.snippet}'),
          child: Container(
            decoration: BoxDecoration(
              color: _boogiMint.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(color: _boogiMint.withOpacity(0.55), width: 2),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  spreadRadius: 2,
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: const Icon(Icons.place, color: Colors.white, size: 22),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 640;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '여행 ~부기 성장 챌린지~',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'BNK 앱 내 관광 미션 · 신동백전 결정 연동',
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
                      const _LevelXpBlock(
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
                    _GlassCard(
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
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                  children: const [
                                    TextSpan(text: '부산 여행하며 '),
                                    TextSpan(
                                      text: '부기를 성장',
                                      style: TextStyle(color: _boogiMint),
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
                            _QuickCard(
                              title: '오늘의 미션',
                              badgeText: '+50 XP',
                              badgeColor: _boogiMint,
                              desc: '신동백전으로 결제 1회 · 전통시장 방문',
                              buttonText: '미션 보드로 이동',
                              buttonColor: _boogiMint,
                              onTap: () => _goTab(0),
                            ),
                            _QuickCard(
                              title: '보상 수령',
                              badgeText: '신동백전 1,200P',
                              badgeColor: _boogiGold,
                              desc: '완료 보상 3건이 대기 중입니다.',
                              buttonText: '리워드 보관함',
                              buttonColor: _boogiGold,
                              onTap: () => _goTab(1),
                            ),
                            _QuickCard(
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

                    _GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabPill(
                              label: '🎯 미션',
                              active: _tabIndex == 0,
                              onTap: () => _goTab(0),
                            ),
                          ),
                          Expanded(
                            child: _TabPill(
                              label: '💰 리워드',
                              active: _tabIndex == 1,
                              onTap: () => _goTab(1),
                            ),
                          ),
                          Expanded(
                            child: _TabPill(
                              label: '📍 지도',
                              active: _tabIndex == 2,
                              onTap: () => _goTab(2),
                            ),
                          ),
                          Expanded(
                            child: _TabPill(
                              label: '🏆 랭킹',
                              active: _tabIndex == 3,
                              onTap: () => _goTab(3),
                            ),
                          ),
                          Expanded(
                            child: _TabPill(
                              label: '🐳 내 부기',
                              active: _tabIndex == 4,
                              onTap: () => _goTab(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_tabIndex == 0) _buildMissionTab(),
                    if (_tabIndex == 1) _buildRewardTab(),
                    if (_tabIndex == 2) _buildMapTab(),
                    if (_tabIndex == 3) _buildRankTab(),
                    if (_tabIndex == 4) _buildBoogiTab(),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        '© 2025 BNK부산은행 · 부산시 · 부산관광공사 · 신동백전',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
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

  Widget _buildMissionTab() {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '미션 보드',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 1 ? 2.0 : 1.15,
                children: [
                  _MissionProgressCard(
                    category: '일일 미션',
                    title: '신동백전 결제 1회',
                    desc: '5,000원 이상 결제 시 XP 적립',
                    progress: 0.30,
                    progressText: '1/3 진행',
                    rewardText: '+10 XP · +50P',
                    actionText: '가맹점 찾기',
                    accent: _boogiMint,
                    onAction: () => _goTab(2),
                  ),
                  _MissionProgressCard(
                    category: '주간 챌린지',
                    title: '맛집 3곳 투어',
                    desc: '부산관광공사 인증 맛집',
                    progress: 0.66,
                    progressText: '2/3 진행',
                    rewardText: '+50 XP · +200P',
                    actionText: '코스 보기',
                    accent: _boogiMint,
                    onAction: () => _goTab(2),
                  ),
                  _MissionProgressCard(
                    category: '시즌 이벤트',
                    title: '부산불꽃축제 미션',
                    desc: '해운대/광안리 상권 소비',
                    progress: 0.00,
                    progressText: '0/5 진행',
                    rewardText: '+200 XP · +1,000P · 한정 스킨',
                    actionText: '참여하기',
                    accent: _boogiGold,
                    onAction: () => _goTab(2),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTab() {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '리워드 보관함',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 1 ? 2.4 : 1.2,
                children: [
                  _RewardCard(
                    badge: '포인트',
                    title: '1,200P',
                    titleColor: _boogiGold,
                    desc: '신동백전 전환 가능',
                    buttonText: '신동백전으로 전환',
                    accent: _boogiGold,
                    onTap: () => _showSnack('전환 로직 연결하세요.'),
                  ),
                  _RewardCard(
                    badge: '금융 리워드',
                    title: '예적금 금리 +0.1%p',
                    titleColor: Colors.white,
                    desc: '30일 내 사용',
                    buttonText: '적용하기',
                    accent: _boogiMint,
                    onTap: () => _showSnack('적용 로직 연결하세요.'),
                  ),
                  _RewardCard(
                    badge: '한정 아이템',
                    title: '불꽃 부기 스킨',
                    titleColor: Colors.white,
                    desc: '시즌 한정',
                    buttonText: '장착하기',
                    accent: const Color(0xFF818CF8),
                    onTap: () => _goTab(4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '지도 / 지역탐색',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              _OutlinedMintButton(
                label: '가까운 가맹점',
                onTap: () => _showSnack('GPS/거리순 정렬 붙이면 됩니다.'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 260,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _busanCenter,
                      initialZoom: 12.0,
                      onMapReady: () {
                        if (!mounted) return;
                        setState(() => _mapReady = true);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'kr.co.bnk.bnkproject',
                      ),
                      MarkerLayer(markers: _buildMarkers()),
                    ],
                  ),
                  if (!_mapReady)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/travel.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '지도를 불러오는 중…',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '안 뜨면 인터넷/타일 URL/에뮬레이터 네트워크 확인',
                                style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '미션 스팟: 해운대 · 광안리 · 남포동',
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: _moveToBusanCenter,
                child: const Text('부산 중심으로'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 1 ? 2.4 : 1.2,
                children: const [
                  _PlaceCard(
                    title: '해운대 회센터',
                    badge: '미션 대상',
                    desc: '거리 450m · 해산물',
                  ),
                  _PlaceCard(
                    title: '남포동 비빔당',
                    badge: '미션 대상',
                    desc: '거리 1.2km · 한식',
                  ),
                  _PlaceCard(
                    title: '서면 카페웨이브',
                    badge: '추천',
                    desc: '거리 2.0km · 디저트',
                    badgeMuted: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankTab() {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '랭킹 보드',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              Row(
                children: [
                  _SmallFilterChip(label: '서면', onTap: () {}),
                  const SizedBox(width: 6),
                  _SmallFilterChip(label: '광안리', onTap: () {}),
                  const SizedBox(width: 6),
                  _SmallFilterChip(label: '해운대', onTap: () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                color: Colors.white.withOpacity(0.04),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStatePropertyAll(Colors.white.withOpacity(0.06)),
                  columns: const [
                    DataColumn(label: Text('순위', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('닉네임', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('레벨', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('XP', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('이번달 소비', style: TextStyle(color: Color(0xFFCBD5E1)))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('#1', style: TextStyle(color: Colors.white))),
                      DataCell(Text('SeomyeonKing', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.5', style: TextStyle(color: Colors.white))),
                      DataCell(Text('1,240', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 385,000', style: TextStyle(color: Colors.white))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('#2', style: TextStyle(color: Colors.white))),
                      DataCell(Text('HaeundaeWave', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.4', style: TextStyle(color: Colors.white))),
                      DataCell(Text('1,010', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 305,000', style: TextStyle(color: Colors.white))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('#12', style: TextStyle(color: Colors.white))),
                      DataCell(Text('내_부기_최고', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.3', style: TextStyle(color: Colors.white))),
                      DataCell(Text('312', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 118,000', style: TextStyle(color: Colors.white))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoogiTab() {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 부기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _boogiMint.withOpacity(0.18),
                            border: Border.all(color: _boogiMint.withOpacity(0.35), width: 2),
                          ),
                        ),
                        Image.asset(
                          'assets/images/travel.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withOpacity(0.10)),
                            ),
                            child: const Text(
                              'Lv.3 상인 부기',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _XpBar(progress: 0.62),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'XP 312 / 500',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SolidButton(
                      text: '스킨 변경',
                      accent: _boogiMint,
                      onTap: () => _showSnack('스킨 변경 연결하세요.'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GhostButton(
                      text: '배지 보기',
                      onTap: () => _showSnack('배지 상세 연결하세요.'),
                    ),
                  ),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '획득 배지',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: twoCol ? 2 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.75,
                children: const [
                  _BadgeCard(title: '시장 상인 배지', desc: '전통시장 결제 10회'),
                  _BadgeCard(title: '관광 마스터', desc: '관광 미션 5회 완료'),
                  _BadgeCard(title: '금융 리더', desc: '금융상품 3개 연동'),
                  _BadgeCard(title: '불꽃 부기 스킨', desc: '시즌 이벤트 보상', locked: true),
                ],
              ),
            ],
          );

          if (twoCol) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                Expanded(child: right),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(height: 16),
              right,
            ],
          );
        },
      ),
    );
  }
}

class _Spot {
  final String id;
  final LatLng position;
  final String title;
  final String snippet;

  const _Spot({
    required this.id,
    required this.position,
    required this.title,
    required this.snippet,
  });
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const _GlassCard({
    required this.child,
    required this.padding,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  static const _boogiMint = Color(0xFF38E1C6);

  @override
  Widget build(BuildContext context) {
    final bg = active ? _boogiMint.withOpacity(0.15) : Colors.transparent;
    final border = active ? _boogiMint : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border.withOpacity(active ? 0.65 : 0)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final String desc;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.desc,
    required this.buttonText,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                badgeText,
                style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: buttonColor.withOpacity(0.35)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.lerp(Colors.white, buttonColor, 0.35),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionProgressCard extends StatelessWidget {
  final String category;
  final String title;
  final String desc;
  final double progress;
  final String progressText;
  final String rewardText;
  final String actionText;
  final Color accent;
  final VoidCallback onAction;

  const _MissionProgressCard({
    required this.category,
    required this.title,
    required this.desc,
    required this.progress,
    required this.progressText,
    required this.rewardText,
    required this.actionText,
    required this.accent,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35)),
          const SizedBox(height: 10),
          _XpBar(progress: progress),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(progressText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  rewardText,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.30)),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: Color.lerp(Colors.white, accent, 0.35),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String badge;
  final String title;
  final Color titleColor;
  final String desc;
  final String buttonText;
  final Color accent;
  final VoidCallback onTap;

  const _RewardCard({
    required this.badge,
    required this.title,
    required this.titleColor,
    required this.desc,
    required this.buttonText,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.30)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Color.lerp(Colors.white, accent, 0.35), fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final String title;
  final String badge;
  final String desc;
  final bool badgeMuted;

  const _PlaceCard({
    required this.title,
    required this.badge,
    required this.desc,
    this.badgeMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = badgeMuted ? const Color(0xFFCBD5E1) : const Color(0xFF38E1C6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _GhostButton(
                  text: '자세히',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SolidButton(
                  text: '신동백전 결제',
                  accent: const Color(0xFF38E1C6),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SmallFilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool locked;

  const _BadgeCard({
    required this.title,
    required this.desc,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _OutlinedMintButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedMintButton({required this.label, required this.onTap});

  static const _mint = Color(0xFF38E1C6);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _mint.withOpacity(0.16),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _mint.withOpacity(0.35)),
        ),
        child: const Text(
          '가까운 가맹점',
          style: TextStyle(
            color: Color(0xFFBFF8EE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  final String text;
  final Color accent;
  final VoidCallback onTap;

  const _SolidButton({
    required this.text,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.30)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Color.lerp(Colors.white, accent, 0.35),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GhostButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  final double progress;
  const _XpBar({required this.progress});

  static const _boogiMint = Color(0xFF38E1C6);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: Colors.white.withOpacity(0.10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_boogiMint, Color(0xFF3BD9F6)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelXpBlock extends StatelessWidget {
  final String levelText;
  final String xpText;
  final double progress;

  const _LevelXpBlock({
    required this.levelText,
    required this.xpText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('현재 레벨', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                Text(levelText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _XpBar(progress: progress),
                const SizedBox(height: 4),
                Text(xpText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
