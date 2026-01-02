import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/trip_goal.dart';
import '../models/trip_budget.dart';
import '../models/trip_plan.dart';

/// RetirementTripService
/// - Goals PoC용 로컬 저장소(secure storage)에 TripPlan을 JSON으로 저장/로드
/// - 실서비스라면 서버/DB에 저장 + 검증/감사로그가 들어가야 함
class RetirementTripService {
  static const String _kKey = 'poc_retirement_trip_plan_v1';

  final FlutterSecureStorage _ss;

  /// const 생성자 제공: 페이지에서 `const RetirementTripService()` 써도 컴파일 되게 함
  const RetirementTripService({FlutterSecureStorage storage = const FlutterSecureStorage()})
      : _ss = storage;

  /// 플랜 로드
  /// - 저장된 JSON이 없으면 defaultPlan 반환
  Future<TripPlan> loadPlan() async {
    final raw = await _ss.read(key: _kKey);
    if (raw == null || raw.trim().isEmpty) {
      final p = TripPlan.defaultPlan();
      // 첫 진입 시에도 저장해둬야 이후 편집 흐름이 안정적임
      await savePlan(p);
      return p;
    }

    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return TripPlan.fromJson(map);
    } catch (_) {
      // 저장값이 깨졌으면 default로 복구
      final p = TripPlan.defaultPlan();
      await savePlan(p);
      return p;
    }
  }

  /// 플랜 저장
  Future<void> savePlan(TripPlan plan) async {
    final raw = jsonEncode(plan.toJson());
    await _ss.write(key: _kKey, value: raw);
  }

  /// 목표 저장(GoalPage에서 사용)
  Future<void> saveGoal(TripGoal goal) async {
    final plan = await loadPlan();
    await savePlan(plan.copyWith(goal: goal));
  }

  /// 예산 저장(BudgetPage에서 사용)
  Future<void> saveBudget(TripBudget budget) async {
    final plan = await loadPlan();
    await savePlan(plan.copyWith(budget: budget));
  }

  /// 적립값 저장(SimulatorPage에서 사용)
  Future<void> saveSavings({
    required int currentSaved,
    required int monthlyContribution,
  }) async {
    final plan = await loadPlan();
    await savePlan(plan.copyWith(
      currentSaved: currentSaved,
      monthlyContribution: monthlyContribution,
    ));
  }
}

/// (선택) 예전 호출부 호환용 extension
/// - 지금은 서비스에 메서드가 있으니 실제로는 필요 없음.
/// - 남겨도 문제 없음(인스턴스 메서드가 우선 적용됨)
extension RetirementTripServiceCompat on RetirementTripService {
  // 필요시 추가 확장 메서드 넣는 용도(현재는 비워둠)
}
