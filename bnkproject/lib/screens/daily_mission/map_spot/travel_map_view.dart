import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'map_spot.dart';
import 'place_marker_layer.dart';

class TravelMapView extends StatelessWidget {
  final MapController controller;
  final LatLng initialCenter;
  final double initialZoom;
  final VoidCallback onMapReady;

  final List<Spot> spots;
  final ValueChanged<Spot> onTapSpot;

  const TravelMapView({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.initialZoom,
    required this.onMapReady,
    required this.spots,
    required this.onTapSpot,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'kr.co.bnk.bnkproject',
        ),
        PlaceMarkerLayer(spots: spots, onTapSpot: onTapSpot),
      ],
    );
  }
}
