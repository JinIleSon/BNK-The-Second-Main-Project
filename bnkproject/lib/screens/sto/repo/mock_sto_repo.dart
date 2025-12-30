import '../models/sto_price_point.dart';
import '../models/sto_team.dart';
import 'sto_repo.dart';

class MockStoRepo implements StoRepo {
  @override
  Future<List<StoTeam>> fetchInitialTeams() async {
    // 최소 MVP: 6팀 고정. 로고는 사용자가 나중에 넣어도 됨.
    const week0 = 1;
    final teams = <StoTeam>[
      _team('busan', '부산 갈매기', 12000, week0),
      _team('seoul', '서울 타이거', 13500, week0),
      _team('daegu', '대구 라이온', 11000, week0),
      _team('incheon', '인천 웨이브', 9800, week0),
      _team('gwangju', '광주 히어로', 10200, week0),
      _team('daejeon', '대전 이글', 12500, week0),
    ];
    return teams;
  }

  StoTeam _team(String id, String name, int price, int week) {
    return StoTeam(
      id: id,
      name: name,
      logoAsset: 'assets/images/sto/teams/$id.png',
      price: price,
      changePct: 0,
      history: [StoPricePoint(week: week, price: price)],
    );
  }
}
