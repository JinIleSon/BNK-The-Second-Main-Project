import '../models/sto_team.dart';

abstract class StoRepo {
  Future<List<StoTeam>> fetchInitialTeams();
}
