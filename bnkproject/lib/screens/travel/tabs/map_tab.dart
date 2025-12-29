import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/glass_card.dart';
// PlaceListCard 쓰는 중이면 import 유지
import '../widgets/place_list_card.dart';

class MapTab extends StatefulWidget {
  const MapTab({required this.onSnack, super.key});
  final ValueChanged<String> onSnack;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  static const LatLng _busanCenter = LatLng(35.1796, 129.0756);

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
          onTap: () => widget.onSnack('${s.title} · ${s.snippet}'),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF38E1C6).withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF38E1C6).withOpacity(0.55), width: 2),
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
                onPressed: _moveToBusanCenter,
                child: const Text('부산 중심으로'),
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

          // 아래 카드 3개도 원래 MapTab 아래에 있던 것. 유지.
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
