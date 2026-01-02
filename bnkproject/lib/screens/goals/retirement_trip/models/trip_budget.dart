class TripBudget {
  final int flight;        // 항공
  final int lodging;       // 숙박
  final int food;          // 식비
  final int transport;     // 교통
  final int activities;    // 관광/액티비티
  final int contingency;   // 예비비

  const TripBudget({
    required this.flight,
    required this.lodging,
    required this.food,
    required this.transport,
    required this.activities,
    required this.contingency,
  });

  int get total => flight + lodging + food + transport + activities + contingency;

  /// UI에서 상위 항목 표시용
  Map<String, int> toCategoryMap() => {
    '항공': flight,
    '숙박': lodging,
    '식비': food,
    '교통': transport,
    '관광': activities,
    '예비비': contingency,
  };

  Map<String, dynamic> toJson() => {
    'flight': flight,
    'lodging': lodging,
    'food': food,
    'transport': transport,
    'activities': activities,
    'contingency': contingency,
  };

  factory TripBudget.fromJson(Map<String, dynamic> json) {
    return TripBudget(
      flight: (json['flight'] ?? 0) as int,
      lodging: (json['lodging'] ?? 0) as int,
      food: (json['food'] ?? 0) as int,
      transport: (json['transport'] ?? 0) as int,
      activities: (json['activities'] ?? 0) as int,
      contingency: (json['contingency'] ?? 0) as int,
    );
  }

  TripBudget copyWith({
    int? flight,
    int? lodging,
    int? food,
    int? transport,
    int? activities,
    int? contingency,
  }) {
    return TripBudget(
      flight: flight ?? this.flight,
      lodging: lodging ?? this.lodging,
      food: food ?? this.food,
      transport: transport ?? this.transport,
      activities: activities ?? this.activities,
      contingency: contingency ?? this.contingency,
    );
  }
}
