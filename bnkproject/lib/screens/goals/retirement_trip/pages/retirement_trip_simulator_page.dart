import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/trip_plan.dart';
import '../services/retirement_trip_service.dart';
import '../retirement_trip_theme.dart';

import '../widgets/glass_card.dart';
import '../widgets/rt_input.dart';

class RetirementTripSimulatorPage extends StatefulWidget {
  const RetirementTripSimulatorPage({super.key});

  @override
  State<RetirementTripSimulatorPage> createState() => _RetirementTripSimulatorPageState();
}

class _RetirementTripSimulatorPageState extends State<RetirementTripSimulatorPage> {
  final _service = const RetirementTripService();
  final _formKey = GlobalKey<FormState>();

  final _currentSavedCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();

  TripPlan? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _currentSavedCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final plan = await _service.loadPlan();
    _plan = plan;
    _currentSavedCtrl.text = plan.currentSaved.toString();
    _monthlyCtrl.text = plan.monthlyContribution.toString();
    if (mounted) setState(() => _loading = false);
  }

  int _parseInt(String s) {
    final onlyDigits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyDigits) ?? 0;
  }

  String _fmtWon(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}원';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  int _monthsUntil(DateTime future) {
    final now0 = DateTime.now();
    final now = DateTime(now0.year, now0.month, now0.day);
    final f = DateTime(future.year, future.month, future.day);

    if (!f.isAfter(now)) return 0;

    int months = (f.year - now.year) * 12 + (f.month - now.month);
    if (months > 0 && f.day < now.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  DateTime _addMonths(DateTime base, int monthsToAdd) {
    final y = base.year;
    final m0 = base.month - 1 + monthsToAdd;

    final ny = y + (m0 ~/ 12);
    final nm = (m0 % 12) + 1;

    final lastDay = DateTime(ny, nm + 1, 0).day;
    final nd = base.day > lastDay ? lastDay : base.day;

    return DateTime(ny, nm, nd);
  }

  int _monthsNeeded(int remaining, int monthly) {
    if (remaining <= 0) return 0;
    if (monthly <= 0) return -1;
    return (remaining / monthly).ceil();
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    await _service.saveSavings(
      currentSaved: _parseInt(_currentSavedCtrl.text),
      monthlyContribution: _parseInt(_monthlyCtrl.text),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final base = _plan;

    final currentSaved = _parseInt(_currentSavedCtrl.text);
    final monthly = _parseInt(_monthlyCtrl.text);

    final goalAmount = base?.goal.targetAmount ?? 0;
    final tripStart = base?.goal.startDate;

    final remaining = goalAmount - currentSaved;
    final remainingSafe = remaining < 0 ? 0 : remaining;

    final monthsNeeded = _monthsNeeded(remainingSafe, monthly);
    final expected = (monthsNeeded < 0) ? null : _addMonths(DateTime.now(), monthsNeeded);

    final monthsToTrip = (tripStart == null) ? 0 : _monthsUntil(tripStart);
    final projectedSaved = currentSaved + (monthly * monthsToTrip);
    final projectedRate = goalAmount <= 0 ? 0 : ((projectedSaved / goalAmount) * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RetirementTripTheme.bgTop, RetirementTripTheme.bgBottom],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 76,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.10)),
                      ),
                    ),
                  ),
                ),
              ),
              title: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  '적립 시뮬레이터',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _save,
                  child: const Text('저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverToBoxAdapter(
                child: _loading
                    ? const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : Column(
                  children: [
                    GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '입력',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _currentSavedCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: rtInputDecoration(label: '현재 적립(원)', hint: '예: 2350000'),
                              validator: (v) => (_parseInt(v ?? '') < 0) ? '0 이상 입력' : null,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _monthlyCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: rtInputDecoration(label: '월 적립액(원)', hint: '예: 250000'),
                              validator: (v) => (_parseInt(v ?? '') < 0) ? '0 이상 입력' : null,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: RetirementTripTheme.violet,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _save,
                                child: const Text('저장'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      radius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '결과(목표 달성까지)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          _ResultRow(label: '목표까지 남은 금액', value: _fmtWon(remainingSafe)),
                          _ResultRow(label: '필요 개월', value: monthsNeeded < 0 ? '계산 불가' : '${monthsNeeded}개월'),
                          _ResultRow(label: '예상 달성일', value: expected == null ? '-' : _fmtDate(expected)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      radius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '결과(여행 시작일까지 자동 시뮬)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          _ResultRow(label: '여행 시작일까지', value: '${monthsToTrip}개월'),
                          _ResultRow(label: '여행 시점 예상 적립액', value: _fmtWon(projectedSaved)),
                          _ResultRow(label: '여행 시점 예상 달성률', value: '$projectedRate%'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
