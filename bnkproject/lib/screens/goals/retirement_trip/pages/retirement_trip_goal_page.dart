import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/trip_goal.dart';
import '../services/retirement_trip_service.dart';
import '../retirement_trip_theme.dart';

import '../widgets/glass_card.dart';
import '../widgets/rt_input.dart';

class RetirementTripGoalPage extends StatefulWidget {
  const RetirementTripGoalPage({super.key});

  @override
  State<RetirementTripGoalPage> createState() => _RetirementTripGoalPageState();
}

class _RetirementTripGoalPageState extends State<RetirementTripGoalPage> {
  final _service = const RetirementTripService();
  final _formKey = GlobalKey<FormState>();

  final _destinationCtrl = TextEditingController();
  final _companionCtrl = TextEditingController();
  final _targetAmountCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _companionCtrl.dispose();
    _targetAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final plan = await _service.loadPlan();
    final g = plan.goal;

    _destinationCtrl.text = g.destination;
    _companionCtrl.text = g.companion;
    _targetAmountCtrl.text = g.targetAmount.toString();
    _startDate = g.startDate;
    _endDate = g.endDate;

    if (mounted) setState(() => _loading = false);
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  int _parseInt(String s) {
    final onlyDigits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyDigits) ?? 0;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = _startDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 50),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      if (_endDate != null && _endDate!.isBefore(picked)) {
        setState(() => _endDate = picked);
      }
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final base = _startDate ?? DateTime(now.year, now.month, now.day);
    final initial = _endDate ?? base;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: base,
      lastDate: DateTime(now.year + 50),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 날짜를 선택하세요.')),
      );
      return;
    }

    final goal = TripGoal(
      destination: _destinationCtrl.text.trim(),
      companion: _companionCtrl.text.trim(),
      targetAmount: _parseInt(_targetAmountCtrl.text),
      startDate: _startDate!,
      endDate: _endDate!,
    );

    await _service.saveGoal(goal);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  '목표 설정',
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
                    : GlassCard(
                  radius: 24,
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _destinationCtrl,
                          decoration: rtInputDecoration(label: '목적지', hint: '예: 오사카, 제주, 파리'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '목적지를 입력하세요.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _companionCtrl,
                          decoration: rtInputDecoration(label: '동행', hint: '예: 혼자, 가족, 친구'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '동행을 입력하세요.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _targetAmountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: rtInputDecoration(label: '목표금액(원)', hint: '예: 8000000'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => (_parseInt(v ?? '') <= 0) ? '목표금액은 0보다 커야 합니다.' : null,
                        ),
                        const SizedBox(height: 14),
                        _DateGlassRow(
                          title: '여행 시작일',
                          value: _startDate == null ? '선택' : _fmtDate(_startDate!),
                          onTap: _pickStartDate,
                        ),
                        const SizedBox(height: 10),
                        _DateGlassRow(
                          title: '여행 종료일',
                          value: _endDate == null ? '선택' : _fmtDate(_endDate!),
                          onTap: _pickEndDate,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RetirementTripTheme.mint,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _save,
                            child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateGlassRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateGlassRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.90), fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white.withOpacity(0.70), fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.55)),
          ],
        ),
      ),
    );
  }
}
