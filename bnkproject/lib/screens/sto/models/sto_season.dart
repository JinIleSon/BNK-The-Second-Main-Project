enum StoSeasonStatus { ready, running, ended }

class StoSeason {
  final int week;
  final int maxWeeks;
  final StoSeasonStatus status;

  const StoSeason({
    required this.week,
    required this.maxWeeks,
    required this.status,
  });

  bool get isEnded => status == StoSeasonStatus.ended;

  StoSeason copyWith({int? week, StoSeasonStatus? status}) {
    return StoSeason(
      week: week ?? this.week,
      maxWeeks: maxWeeks,
      status: status ?? this.status,
    );
  }
}
