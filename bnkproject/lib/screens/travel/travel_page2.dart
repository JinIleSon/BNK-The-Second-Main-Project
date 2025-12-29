// lib/travel/travel_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final MapController _mapController = MapController();

  // 부산 기본 중심 (부산역 근처)
  static final LatLng _defaultCenter = LatLng(35.1151, 129.0414);

  LatLng? _myPos;
  Place? _selected;

  List<LatLng> _routePoints = [];
  double? _routeDistanceM; // meters
  double? _routeDurationS; // seconds

  bool _loadingMyPos = false;
  bool _loadingRoute = false;
  String? _error;

  final List<Place> _places = const [
    Place('해운대 해수욕장', '부산 대표 해변', LatLng(35.1587, 129.1604)),
    Place('광안리 해수욕장', '야경/광안대교', LatLng(35.1532, 129.1186)),
    Place('감천문화마을', '포토스팟', LatLng(35.0976, 129.0108)),
    Place('자갈치시장', '먹거리/시장', LatLng(35.0979, 129.0363)),
    Place('흰여울문화마을', '바다 산책로', LatLng(35.0783, 129.0456)),
  ];

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 한 번 현재위치 시도(권한 거부해도 앱 죽지 않게)
    _refreshMyLocation(silent: true);
  }

  Future<void> _refreshMyLocation({bool silent = false}) async {
    setState(() {
      _loadingMyPos = true;
      _error = null;
    });

    try {
      final ok = await _ensureLocationPermission();
      if (!ok) {
        if (!silent) {
          setState(() => _error = '위치 권한이 필요합니다. 설정에서 허용해 주세요.');
        }
        return;
      }


      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _myPos = latLng;
      });

      _mapController.move(latLng, 15.0);
    } catch (e) {
      if (!silent) {
        setState(() => _error = '현재 위치를 가져오지 못했습니다: $e');
      }
    } finally {
      if (mounted) setState(() => _loadingMyPos = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) return false;
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void _selectPlace(Place p) {
    setState(() {
      _selected = p;
      _error = null;
    });
    _mapController.move(p.latLng, 15.0);
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeDistanceM = null;
      _routeDurationS = null;
      _loadingRoute = false;
      _error = null;
    });
  }

  Future<void> _buildRoute() async {
    final from = _myPos;
    final to = _selected?.latLng;

    if (to == null) {
      setState(() => _error = '목적지(장소)를 먼저 선택하세요.');
      return;
    }

    if (from == null) {
      await _refreshMyLocation(silent: false);
      if (_myPos == null) return;
    }

    setState(() {
      _loadingRoute = true;
      _error = null;
    });

    try {
      final start = _myPos!;
      final end = to;

      // OSRM Route API (무료 데모 서버) - geojson으로 polyline 받기
      // /route/v1/{profile}/{coordinates}?geometries=geojson&overview=full
      // 문서: OSRM Route service :contentReference[oaicite:9]{index=9}
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
            '?overview=full&geometries=geojson',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw 'OSRM 요청 실패: ${res.statusCode}';
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? [];
      if (routes.isEmpty) throw '경로를 찾지 못했습니다.';

      final r0 = routes.first as Map<String, dynamic>;
      final distanceM = (r0['distance'] as num).toDouble();
      final durationS = (r0['duration'] as num).toDouble();

      final geom = r0['geometry'] as Map<String, dynamic>;
      final coords = (geom['coordinates'] as List).cast<List>();

      final pts = coords.map((c) {
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList(growable: false);

      setState(() {
        _routePoints = pts;
        _routeDistanceM = distanceM;
        _routeDurationS = durationS;
      });

      // 화면에 경로가 잘 보이도록 중간 지점으로 이동
      if (pts.isNotEmpty) {
        _mapController.move(pts[pts.length ~/ 2], 13.5);
      }
    } catch (e) {
      setState(() => _error = '길찾기 실패: $e');
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final card = Theme.of(context).cardColor;

    final markers = <Marker>[
      for (final p in _places)
        Marker(
          point: p.latLng,
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _selectPlace(p),
            child: Icon(
              Icons.location_pin,
              size: 40,
              color: (_selected?.name == p.name)
                  ? Colors.orangeAccent
                  : Colors.redAccent,
            ),
          ),
        ),
      if (_myPos != null)
        Marker(
          point: _myPos!,
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
    ];

    final polylines = <Polyline>[
      if (_routePoints.isNotEmpty)
        Polyline(
          points: _routePoints,
          strokeWidth: 5,
          color: Colors.lightBlueAccent,
        ),
    ];

    String? routeInfoText;
    if (_routeDistanceM != null && _routeDurationS != null) {
      final km = _routeDistanceM! / 1000.0;
      final min = _routeDurationS! / 60.0;
      routeInfoText = '약 ${km.toStringAsFixed(1)}km · ${min.toStringAsFixed(0)}분';
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('여행'),
        actions: [
          IconButton(
            tooltip: '내 위치',
            onPressed: _loadingMyPos ? null : () => _refreshMyLocation(silent: false),
            icon: _loadingMyPos
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.my_location),
          ),
          IconButton(
            tooltip: '경로 지우기',
            onPressed: _routePoints.isEmpty ? null : _clearRoute,
            icon: const Icon(Icons.layers_clear),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // MAP
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              height: 320,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: 12.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // OSM 정책상 식별 가능한 UA 권장 (패키지명으로)
                    userAgentPackageName: 'com.example.bnkproject',
                    maxZoom: 19,
                  ),

                  PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),

                  // OSM Attribution 권장 (flutter_map 공식 문서 예시 방식)
                  // :contentReference[oaicite:10]{index=10} :contentReference[oaicite:11]{index=11}
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),

            // ACTION BAR (선택/길찾기)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selected == null
                            ? '장소를 선택하세요'
                            : '${_selected!.name}${routeInfoText == null ? '' : ' · $routeInfoText'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _loadingRoute ? null : _buildRoute,
                      icon: _loadingRoute
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.directions),
                      label: const Text('길찾기'),
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // PLACE LIST
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemBuilder: (context, i) {
                  final p = _places[i];
                  final selected = _selected?.name == p.name;

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _selectPlace(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: Colors.orangeAccent.withOpacity(0.9))
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            color: selected ? Colors.orangeAccent : Colors.white54,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.desc,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.white30),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _places.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Place {
  final String name;
  final String desc;
  final LatLng latLng;

  const Place(this.name, this.desc, this.latLng);
}
