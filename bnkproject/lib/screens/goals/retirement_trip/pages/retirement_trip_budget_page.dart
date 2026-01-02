import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/trip_budget.dart';
import '../services/retirement_trip_service.dart';
import '../retirement_trip_theme.dart';

import '../widgets/glass_card.dart';
import '../widgets/rt_input.dart';

class RetirementTripBudgetPage extends StatefulWidget {
  const RetirementTripBudgetPage({super.key});

  @override
  State<RetirementTripBudgetPage> createState() => _RetirementTripBudgetPageState();
}

class _RetirementTripBudgetPageState extends State<RetirementTripBudgetPage> {
  final _service = const RetirementTripService();
  final _formKey = GlobalKey<FormState>();

  final _flightCtrl = TextEditingController();
  final _lodgingCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  final _transportCtrl = TextEditingController();
  final _activitiesCtrl = TextEditingController();
  final _contingencyCtrl = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _flightCtrl.dispose();
    _lodgingCtrl.dispose();
    _foodCtrl.dispose();
    _transportCtrl.dispose();
    _activitiesCtrl.dispose();
    _contingencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final plan = await _service.loadPlan();
    final b = plan.budget;

    _flightCtrl.text = b.flight.toString();
    _lodgingCtrl.text = b.lodging.toString();
    _foodCtrl.text = b.food.toString();
    _transportCtrl.text = b.transport.toString();
    _activitiesCtrl.text = b.activities.toString();
    _contingencyCtrl.text = b.contingency.toString();

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

  int _totalPreview() {
    return _parseInt(_flightCtrl.text) +
        _parseInt(_lodgingCtrl.text) +
        _parseInt(_foodCtrl.text) +
        _parseInt(_transportCtrl.text) +
        _parseInt(_activitiesCtrl.text) +
        _parseInt(_contingencyCtrl.text);
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final budget = TripBudget(
      flight: _parseInt(_flightCtrl.text),
      lodging: _parseInt(_lodgingCtrl.text),
      food: _parseInt(_foodCtrl.text),
      transport: _parseInt(_transportCtrl.text),
      activities: _parseInt(_activitiesCtrl.text),
      contingency: _parseInt(_contingencyCtrl.text),
    );

    await _service.saveBudget(budget);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _refreshPreview() => setState(() {});

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
                  '예산 설정',
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
                        _MoneyField(label: '항공', controller: _flightCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 10),
                        _MoneyField(label: '숙박', controller: _lodgingCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 10),
                        _MoneyField(label: '식비', controller: _foodCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 10),
                        _MoneyField(label: '교통', controller: _transportCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 10),
                        _MoneyField(label: '관광', controller: _activitiesCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 10),
                        _MoneyField(label: '예비비', controller: _contingencyCtrl, onChanged: _refreshPreview),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '총 예산',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Text(
                                _fmtWon(_totalPreview()),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RetirementTripTheme.gold,
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

class _MoneyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _MoneyField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  int _parseInt(String s) {
    final onlyDigits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyDigits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: rtInputDecoration(label: '$label(원)', hint: '예: 500000'),
      validator: (v) => (_parseInt(v ?? '') < 0) ? '0 이상 입력' : null,
      onChanged: (_) => onChanged(),
    );
  }
}
