import '../models/sto_price_point.dart';
import '../models/sto_team.dart';
import 'sto_repo.dart';

class MockStoRepo implements StoRepo {
  @override
  Future<List<StoTeam>> fetchInitialTeams() async {
    const week0 = 1;

    // ✅ 현실 팀명(표시) / ✅ 네 파일명(emblem_XX.png) 기준 로고 매핑
    // ⚠️ id는 저장/통계/뉴스 키로 쓰일 수 있으니 "짧은 코드"로 고정해두는 게 안전
    final teams = <StoTeam>[
      _team('LG', 'LG 트윈스', 12000, week0, logo: 'assets/images/sto/emblem_LG.png'),
      _team('HH', '한화 이글스', 12500, week0, logo: 'assets/images/sto/emblem_HH.png'),
      _team('SK', 'SSG 랜더스', 11000, week0, logo: 'assets/images/sto/emblem_SK.png'), // SK 에셋명을 SSG 표기로 사용
      _team('SS', '삼성 라이온즈', 11500, week0, logo: 'assets/images/sto/emblem_SS.png'),
      _team('NC', 'NC 다이노스', 10200, week0, logo: 'assets/images/sto/emblem_NC.png'),
      _team('KT', 'KT 위즈', 10800, week0, logo: 'assets/images/sto/emblem_KT.png'),
      _team('LT', '롯데 자이언츠', 9800, week0, logo: 'assets/images/sto/emblem_LT.png'),
      _team('HT', 'KIA 타이거즈', 13500, week0, logo: 'assets/images/sto/emblem_HT.png'), // HT 에셋명을 KIA 표기로 사용
      _team('OB', '두산 베어스', 11200, week0, logo: 'assets/images/sto/emblem_OB.png'),
      _team('WO', '키움 히어로즈', 10000, week0, logo: 'assets/images/sto/emblem_WO.png'),
    ];

    return teams;
  }

  StoTeam _team(
      String id,
      String name,
      int price,
      int week, {
        required String logo,
      }) {
    return StoTeam(
      id: id,
      name: name,
      logoAsset: logo, // ✅ 여기만 바꾸면 로고 싹 정상화
      price: price,
      changePct: 0,
      history: [StoPricePoint(week: week, price: price)],
    );
  }
}
