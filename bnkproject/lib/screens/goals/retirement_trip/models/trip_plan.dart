import 'trip_goal.dart';
import 'trip_budget.dart';

class TripPlan {
  final TripGoal goal;
  final TripBudget budget;

  /// 현재 적립액(원)
  final int currentSaved;

  /// 월 적립액(원)
  final int monthlyContribution;

  const TripPlan({
    required this.goal,
    required this.budget,
    required this.currentSaved,
    required this.monthlyContribution,
  });

  /// 남은 금액(원)
  int get remainingAmount {
    final v = goal.targetAmount - currentSaved;
    return v < 0 ? 0 : v;
  }

  /// 진행률(0.0 ~ 1.0)
  double get progressRate {
    if (goal.targetAmount <= 0) return 0.0;
    final r = currentSaved / goal.targetAmount;
    if (r < 0) return 0.0;
    if (r > 1) return 1.0;
    return r;
  }

  /// 목표 달성까지 필요한 개월(월적립이 0이면 -1)
  int get monthsNeeded {
    final rem = remainingAmount;
    if (rem <= 0) return 0;
    if (monthlyContribution <= 0) return -1;
    // ceil(rem / monthly)
    return (rem / monthlyContribution).ceil();
  }

  /// 목표 달성 예상일(개월 단위로 근사)
  DateTime? get expectedAchieveDate {
    final m = monthsNeeded;
    if (m < 0) return null;
    return _addMonths(DateTime.now(), m);
  }

  TripPlan copyWith({
    TripGoal? goal,
    TripBudget? budget,
    int? currentSaved,
    int? monthlyContribution,
  }) {
    return TripPlan(
      goal: goal ?? this.goal,
      budget: budget ?? this.budget,
      currentSaved: currentSaved ?? this.currentSaved,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
    );
  }

  Map<String, dynamic> toJson() => {
    'goal': goal.toJson(),
    'budget': budget.toJson(),
    'currentSaved': currentSaved,
    'monthlyContribution': monthlyContribution,
  };

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      goal: TripGoal.fromJson((json['goal'] as Map).cast<String, dynamic>()),
      budget: TripBudget.fromJson((json['budget'] as Map).cast<String, dynamic>()),
      currentSaved: (json['currentSaved'] ?? 0) as int,
      monthlyContribution: (json['monthlyContribution'] ?? 0) as int,
    );
  }

  /// PoC 초기값
  factory TripPlan.defaultPlan() {
    final now = DateTime.now();
    final start = DateTime(now.year + 1, now.month, now.day);
    final end = DateTime(now.year + 1, now.month, now.day + 4);

    return TripPlan(
      goal: TripGoal(
        destination: '오사카',
        companion: '가족',
        targetAmount: 8000000,
        startDate: start,
        endDate: end,
      ),
      budget: const TripBudget(
        flight: 1200000,
        lodging: 1800000,
        food: 900000,
        transport: 350000,
        activities: 500000,
        contingency: 400000,
      ),
      currentSaved: 2350000,
      monthlyContribution: 250000,
    );
  }

  static DateTime _addMonths(DateTime base, int monthsToAdd) {
    final y = base.year;
    final m0 = base.month - 1 + monthsToAdd;

    final ny = y + (m0 ~/ 12);
    final nm = (m0 % 12) + 1;

    final lastDay = DateTime(ny, nm + 1, 0).day;
    final nd = base.day > lastDay ? lastDay : base.day;

    return DateTime(ny, nm, nd, base.hour, base.minute, base.second, base.millisecond, base.microsecond);
  }
}
