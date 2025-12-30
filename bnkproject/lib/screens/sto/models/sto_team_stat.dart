class StoTeamStat {
  final String teamId;
  final int wins;
  final int losses;

  /// 시즌 시작가 대비 누적 수익률 (예: 0.12 = +12%)
  final double seasonReturn;

  const StoTeamStat({
    required this.teamId,
    required this.wins,
    required this.losses,
    required this.seasonReturn,
  });

  StoTeamStat copyWith({int? wins, int? losses, double? seasonReturn}) {
    return StoTeamStat(
      teamId: teamId,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      seasonReturn: seasonReturn ?? this.seasonReturn,
    );
  }
}
