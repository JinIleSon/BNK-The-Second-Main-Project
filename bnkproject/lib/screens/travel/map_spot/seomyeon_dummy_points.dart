import 'package:latlong2/latlong.dart';
import 'map_spot.dart';

// 서면 기준점(대략)
const LatLng kSeomyeonCenter = LatLng(35.157900, 129.059500);

// ✅ 서면 주변 더미 좌표 50개(고정)
final List<LatLng> kSeomyeonDummyPoints50 = [
  LatLng(35.158900, 129.059500),
  LatLng(35.156573, 129.060981),
  LatLng(35.158242, 129.056587),
  LatLng(35.159379, 129.062610),
  LatLng(35.154066, 129.058661),
  LatLng(35.160480, 129.058050),
  LatLng(35.156111, 129.055256),
  LatLng(35.157205, 129.064612),
  LatLng(35.160011, 129.056171),
  LatLng(35.153708, 129.062697),
  LatLng(35.158800, 129.052182),
  LatLng(35.154341, 129.063632),
  LatLng(35.163655, 129.058074),
  LatLng(35.152396, 129.056791),
  LatLng(35.159356, 129.067295),
  LatLng(35.162896, 129.052742),
  LatLng(35.150513, 129.064278),
  LatLng(35.165264, 129.061133),
  LatLng(35.152369, 129.049210),
  LatLng(35.156105, 129.067977),
  LatLng(35.163361, 129.046531),
  LatLng(35.149787, 129.059419),
  LatLng(35.166285, 129.054998),
  LatLng(35.154964, 129.045279),
  LatLng(35.153703, 129.070674),
  LatLng(35.168319, 129.049824),
  LatLng(35.148303, 129.055583),
  LatLng(35.164909, 129.068819),
  LatLng(35.156742, 129.043081),
  LatLng(35.151993, 129.071090),
  LatLng(35.166239, 129.043777),
  LatLng(35.146523, 129.064500),
  LatLng(35.170239, 129.058001),
  LatLng(35.150581, 129.043398),
  LatLng(35.150337, 129.072691),
  LatLng(35.172205, 129.053120),
  LatLng(35.145727, 129.051325),
  LatLng(35.167719, 129.071615),
  LatLng(35.159672, 129.039957),
  LatLng(35.147094, 129.073200),
  LatLng(35.169050, 129.038743),
  LatLng(35.144690, 129.060259),
  LatLng(35.174877, 129.061455),
  LatLng(35.147906, 129.039714),
  LatLng(35.147221, 129.075373),
  LatLng(35.176639, 129.048336),
  LatLng(35.143450, 129.046734),
  LatLng(35.170218, 129.073617),
  LatLng(35.162085, 129.037727),
  LatLng(35.146317, 129.076233),
];

String _label(String id) {
  switch (id) {
    case 'food':
      return '맛집';
    case 'market':
      return '전통시장';
    case 'sight':
      return '관광지';
    case 'cafe':
      return '카페';
    case 'dongbaek':
      return '동백전';
    case 'bnk_partner':
      return 'BNK제휴';
    default:
      return id;
  }
}

List<Spot> buildSeomyeonDummySpots(String categoryId) {
  final label = _label(categoryId);

  return List.generate(kSeomyeonDummyPoints50.length, (i) {
    final p = kSeomyeonDummyPoints50[i];
    final n = (i + 1).toString().padLeft(2, '0');
    return Spot(
      id: '$categoryId-seomyeon-$n',
      position: p,
      title: '서면 $label 더미가맹점 $n',
      snippet: '미션 가능(더미)',
    );
  });
}
