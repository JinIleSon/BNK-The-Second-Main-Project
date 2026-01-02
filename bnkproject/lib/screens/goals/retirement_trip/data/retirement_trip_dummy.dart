import '../models/trip_goal.dart';
import '../models/trip_budget.dart';
import '../models/trip_plan.dart';

/// retirement_trip 도메인 더미 데이터.
///
/// 목적:
/// - PoC 단계에서 화면/흐름을 빠르게 검증.
/// - service가 실제 저장소(API/DB)로 바뀌어도 pages를 거의 안 건드리게 만드는 용도.
///
/// 보안/품질 원칙:
/// - 개인정보/실명/식별자 같은 PII는 넣지 않는다.
/// - 금액/기간은 테스트가 가능한 현실적 범위를 사용.
class RetirementTripDummy {
  static TripPlan seedPlan() {
    final goal = TripGoal(
      destination: '오사카',
      startDate: DateTime(2032, 4, 10),
      endDate: DateTime(2032, 4, 16),
      companion: '가족',
      targetAmount: 8_000_000,
    );

    final budget = TripBudget(
      flight: 1_600_000,
      lodging: 2_400_000,
      food: 1_200_000,
      transport: 400_000,
      activities: 900_000,
      contingency: 500_000,
    );

    return TripPlan(
      goal: goal,
      budget: budget,
      currentSaved: 2_350_000,
      monthlyContribution: 250_000,
    );
  }
}
