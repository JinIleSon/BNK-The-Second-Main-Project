import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/glass_card.dart';
import '../widgets/place_list_card.dart';

import '../map_spot/travel_map_view.dart';
import '../map_spot/map_spot.dart';
import '../map_spot/seomyeon_dummy_points.dart';

class MapTab extends StatefulWidget {
  const MapTab({
    required this.onSnack,
    required this.categoryId,
    super.key,
  });

  final ValueChanged<String> onSnack;
  final String categoryId;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  void _moveToSeomyeon() {
    if (!_mapReady) return;
    _mapController.move(kSeomyeonCenter, 15);
  }

  @override
  Widget build(BuildContext context) {
    final List<Spot> spots = buildSeomyeonDummySpots(widget.categoryId);

    return GlassCard(
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
              TextButton(
                onPressed: _moveToSeomyeon,
                child: const Text('서면으로'),
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
                  TravelMapView(
                    controller: _mapController,
                    initialCenter: kSeomyeonCenter,
                    initialZoom: 15,
                    onMapReady: () {
                      if (!mounted) return;
                      setState(() => _mapReady = true);
                    },
                    spots: spots,
                    onTapSpot: (s) => widget.onSnack('${s.title} · ${s.snippet}'),
                  ),
                  if (!_mapReady)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                        alignment: Alignment.center,
                        child: const Text(
                          '지도를 불러오는 중…',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 아래 카드 3개는 일단 유지(원하면 categoryId 기준으로 동적화 가능)
          PlaceListCard(
            cardColor: Colors.white.withOpacity(0.05),
            title: '해운대 회센터',
            subtitle: '거리 450m · 해산물',
            assetPath: 'assets/images/places/haeundae.jpg',
            badgeText: '미션 대상',
            onTap: () => widget.onSnack('해운대 회센터 상세 연결하세요.'),
          ),
          const SizedBox(height: 12),
          PlaceListCard(
            cardColor: Colors.white.withOpacity(0.05),
            title: '남포동 비빔당',
            subtitle: '거리 1.2km · 한식',
            assetPath: 'assets/images/places/nampo.jpg',
            badgeText: '미션 대상',
            onTap: () => widget.onSnack('남포동 비빔당 상세 연결하세요.'),
          ),
          const SizedBox(height: 12),
          PlaceListCard(
            cardColor: Colors.white.withOpacity(0.05),
            title: '서면 카페웨이브',
            subtitle: '거리 2.0km · 디저트',
            assetPath: 'assets/images/places/seomyeon_cafe.jpg',
            badgeText: '추천',
            badgeMuted: true,
            onTap: () => widget.onSnack('서면 카페웨이브 상세 연결하세요.'),
          ),
        ],
      ),
    );
  }
}
