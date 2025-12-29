import 'package:latlong2/latlong.dart';

class Spot {
  final String id;
  final LatLng position;
  final String title;
  final String snippet;

  const Spot({
    required this.id,
    required this.position,
    required this.title,
    required this.snippet,
  });
}
