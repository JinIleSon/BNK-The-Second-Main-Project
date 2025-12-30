enum StoNewsImpact { bull, bear, neutral }

class StoNewsItem {
  final String id;
  final int week;
  final String teamId; // 'league' 가능
  final String title;
  final String body;
  final StoNewsImpact impact;
  final DateTime at;

  const StoNewsItem({
    required this.id,
    required this.week,
    required this.teamId,
    required this.title,
    required this.body,
    required this.impact,
    required this.at,
  });
}
