import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';

import 'spot.dart';
import 'place_marker.dart';

class PlaceMarkerLayer extends StatelessWidget {
  final List<Spot> spots;
  final void Function(Spot spot) onTapSpot;

  const PlaceMarkerLayer({
    super.key,
    required this.spots,
    required this.onTapSpot,
  });

  @override
  Widget build(BuildContext context) {
    final markers = spots
        .map(
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
