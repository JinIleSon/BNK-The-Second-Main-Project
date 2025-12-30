import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'map_spot.dart';
import 'place_marker.dart';

class PlaceMarkerLayer extends StatelessWidget {
  final List<Spot> spots;
  final ValueChanged<Spot> onTapSpot;

  const PlaceMarkerLayer({
    super.key,
    required this.spots,
    required this.onTapSpot,
  });

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = spots
        .map<Marker>(
          (s) => Marker(
        point: s.position,
        width: 44,
        height: 44,
        child: PlaceMarker(onTap: () => onTapSpot(s)),
      ),
    )
        .toList();

    return MarkerLayer(markers: markers);
  }
}
