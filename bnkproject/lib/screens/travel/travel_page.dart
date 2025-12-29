import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  GoogleMapController? _mapController;
  bool _mapCreated = false;

  late final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('haeundae'),
      position: const LatLng(35.1587, 129.1604),
      infoWindow: const InfoWindow(title: '해운대 해수욕장', snippet: '신동백전 결제 미션 가능'),
    ),
    Marker(
      markerId: const MarkerId('gwanganri'),
      position: const LatLng(35.1532, 129.1187),
      infoWindow: const InfoWindow(title: '광안리 해변', snippet: '신동백전 결제 미션 가능'),
    ),
    Marker(
      markerId: const MarkerId('nampo'),
      position: const LatLng(35.0980, 129.0306),
      infoWindow: const InfoWindow(title: '남포동 BIFF거리', snippet: '신동백전 결제 미션 가능'),
    ),
  };

  // Google Map JSON style (다크 느낌 + poi.business 숨김)
  static const _mapStyle = r'''
[
  { "featureType": "all", "elementType": "geometry", "stylers": [{ "color": "#1b1f2a" }] },
  { "featureType": "all", "elementType": "labels.text.fill", "stylers": [{ "color": "#e5e7eb" }] },
  { "featureType": "poi.business", "stylers": [{ "visibility": "off" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#222838" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#0f2136" }] }
]
''';

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _moveToBusanCenter() async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _busanCenter, zoom: 12),
      ),
    );
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
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 76,
              titleSpacing: 0,

              // ✅ 뒤로가기 버튼 추가
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),

              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.40),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.10)),
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ leading이 생겼으니 좌측 padding은 빼고 오른쪽만 유지
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
                          width: 40,
                          height: 40,
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
                            '부기 성장 챌린지',
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
                    // Hero
                    _GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final heroWide = constraints.maxWidth >= 720;
                          final image = Image.asset(
                            'assets/images/travel.png',
                            width: 144,
                            height: 144,
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
                                    '미션을 수행하며 스테이블코인을 보상으로 받으세요.',
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

                    // Map Section
                    _GlassCard(
                      radius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '부산 관광 지도',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              _OutlinedMintButton(
                                label: '가까운 미션 보기',
                                onTap: () {
                                  _showSnack('근처 미션 기능은 위치 권한 연동 시 연결하세요.');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 400,
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: const CameraPosition(
                                      target: _busanCenter,
                                      zoom: 12,
                                    ),
                                    onMapCreated: (c) async {
                                      _mapController = c;
                                      await c.setMapStyle(_mapStyle);
                                      if (mounted) {
                                        setState(() => _mapCreated = true);
                                      }
                                    },
                                    markers: _markers,
                                    mapType: MapType.normal,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    compassEnabled: false,
                                    rotateGesturesEnabled: true,
                                    tiltGesturesEnabled: false,
                                    onTap: (_) => FocusScope.of(context).unfocus(),
                                  ),

                                  // ✅ 지도 로딩/비표시 대비 오버레이 (travel.png 활용)
                                  if (!_mapCreated)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.25),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/images/travel.png',
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                '지도를 불러오는 중…',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '안 뜨면 API KEY/Maps SDK/Google Play 에뮬레이터 확인',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.70),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  // ✅ 워터마크 느낌으로 travel.png 살짝
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Opacity(
                                      opacity: 0.20,
                                      child: Image.asset(
                                        'assets/images/travel.png',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
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
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _moveToBusanCenter,
                                child: const Text('부산 중심으로'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mission Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 900 ? 3 : 1;
                        return GridView.count(
                          crossAxisCount: cols,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols == 1 ? 3.1 : 1.25,
                          children: const [
                            _MissionCard(
                              title: '해운대 맛집 탐방',
                              xpText: '+50 XP',
                              desc: '3곳 방문 시 신동백전 1,000P 지급',
                              accent: _boogiMint,
                              buttonText: '진행하기',
                            ),
                            _MissionCard(
                              title: '광안리 카페 챌린지',
                              xpText: '+120 XP',
                              desc: "결제 2회 시 ‘커피 부기’ 스킨 지급",
                              accent: _boogiGold,
                              buttonText: '참여하기',
                            ),
                            _MissionCard(
                              title: '남포동 로컬마켓',
                              xpText: '+80 XP',
                              desc: '전통시장 결제 시 금리 우대권 제공',
                              accent: Color(0xFF93C5FD),
                              buttonText: '가맹점 보기',
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        '© 2025 BNK부산은행 · 부산시 · 부산관광공사 · 신동백전 추진단',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: child,
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
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBFF8EE),
            fontSize: 12,
            fontWeight: FontWeight.w600,
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

  static const _boogiGold = Color(0xFFFFC93C);
  static const _boogiMint = Color(0xFF38E1C6);

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
                const Text(
                  '현재 레벨',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                Text(
                  levelText,
                  style: const TextStyle(
                    color: _boogiGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
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
                ClipRRect(
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
                ),
                const SizedBox(height: 4),
                Text(
                  xpText,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final String title;
  final String xpText;
  final String desc;
  final Color accent;
  final String buttonText;

  const _MissionCard({
    required this.title,
    required this.xpText,
    required this.desc,
    required this.accent,
    required this.buttonText,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                xpText,
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$buttonText: 연결 로직 붙이세요')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.30)),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.lerp(Colors.white, accent, 0.35),
                  fontWeight: FontWeight.w700,
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
