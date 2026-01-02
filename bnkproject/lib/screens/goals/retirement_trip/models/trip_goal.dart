class TripGoal {
  final String destination;     // 목적지
  final String companion;       // 동행
  final int targetAmount;       // 목표금액(원)
  final DateTime startDate;     // 여행 시작일
  final DateTime endDate;       // 여행 종료일

  const TripGoal({
    required this.destination,
    required this.companion,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
  });

  /// 여행 기간(일) - 단순 계산 (시작~종료 포함)
  int get durationDays {
    final days = endDate.difference(startDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  Map<String, dynamic> toJson() => {
    'destination': destination,
    'companion': companion,
    'targetAmount': targetAmount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory TripGoal.fromJson(Map<String, dynamic> json) {
    return TripGoal(
      destination: (json['destination'] ?? '') as String,
      companion: (json['companion'] ?? '') as String,
      targetAmount: (json['targetAmount'] ?? 0) as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  TripGoal copyWith({
    String? destination,
    String? companion,
    int? targetAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TripGoal(
      destination: destination ?? this.destination,
      companion: companion ?? this.companion,
      targetAmount: targetAmount ?? this.targetAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
