import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/local_storage_service.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../../widgets/life_bar.dart';
import '../../models/simulation_models.dart';
import '../../utils/local_wealth_calculator.dart';
import '../onboarding/onboarding_data.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Mobile port of web's SimulatorLifeWeaver.
/// Calculates wealth 100% locally — no API calls, fully real-time.
class SimulatorLifeWeaverScreen extends StatefulWidget {
  final OnboardingData? data;

  /// Called after every local recalculation with the latest wealth trajectory.
  /// The home dashboard listens to this for real-time chart sync.
  final ValueChanged<List<LocalWealthPoint>>? onWealthUpdated;

  const SimulatorLifeWeaverScreen({
    super.key,
    this.data,
    this.onWealthUpdated,
  });

  @override
  State<SimulatorLifeWeaverScreen> createState() =>
      _SimulatorLifeWeaverScreenState();
}

class _SimulatorLifeWeaverScreenState extends State<SimulatorLifeWeaverScreen>
    with AutomaticKeepAliveClientMixin {
  late int _currentAge;
  late int _lifeExpectancy;
  late List<LifeEvent> _events;

  // Computed locally — no API
  late List<LocalWealthPoint> _wealthData;
  late LocalInsights _insights;

  // Monte Carlo State
  bool _enableMonteCarlo = false;
  LocalMonteCarloResult? _mcResult;
  // Deterministic (base) plan — used as "Your Plan" overlay when MC is active
  List<LocalWealthPoint> _deterministicData = [];

  // History for undo
  final List<List<LifeEvent>> _history = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentAge = widget.data?.currentAge ?? 30;
    _lifeExpectancy = widget.data?.lifeExpectancy ?? 90;
    _loadFromHive();
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _loadFromHive() {
    // Restore MC toggle state.
    _enableMonteCarlo = LocalStorageService.loadMcEnabled(_uid);

    // Restore custom events — fall back to defaults if nothing is saved yet.
    final savedEvents = LocalStorageService.loadSimEvents(_uid);
    final savedAge = LocalStorageService.loadSimCurrentAge(_uid);
    if (savedEvents != null && savedEvents.isNotEmpty) {
      _events = savedEvents;
      if (savedAge != null) {
        _currentAge = savedAge.clamp(18, _lifeExpectancy - 1);
      }
    } else {
      _events = _buildDefaultEvents();
    }
    _recalculate();
  }

  /// Persists current events and age to Hive after every mutation.
  void _saveToHive() {
    LocalStorageService.saveSimEvents(_uid, _events);
    LocalStorageService.saveSimCurrentAge(_uid, _currentAge);
  }

  List<LifeEvent> _buildDefaultEvents() {
    final data = widget.data;
    return [
      LifeEvent(
        id: '1',
        type: LifeEventType.job,
        name: 'Current Job',
        startAge: _currentAge,
        params: const {'incomeLevel': 'good'},
      ),
      LifeEvent(
        id: '2',
        type: LifeEventType.home,
        name: 'Buy Home',
        startAge: (_currentAge + 5).clamp(_currentAge, _lifeExpectancy),
        params: const {'costLevel': 'expensive', 'hasGoodSavings': true},
      ),
      LifeEvent(
        id: '3',
        type: LifeEventType.retirement,
        name: 'Retirement',
        startAge: data?.retirementAge ?? 65,
        params: const {'lifestyleLevel': 'moderate'},
      ),
    ];
  }

  void _recalculate() {
    final double initTaxable = widget.data?.taxableSavings ?? 0;
    final double initTaxDeferred = widget.data?.taxDeferredSavings ?? 0;
    final double initRoth = widget.data?.taxFreeSavings ?? 0;

    // Always compute the deterministic path — it's the "Your Plan" baseline
    _deterministicData = LocalWealthCalculator.calculate(
      _events,
      _currentAge,
      _lifeExpectancy,
      initialTaxable: initTaxable,
      initialTaxDeferred: initTaxDeferred,
      initialRoth: initRoth,
    );
    _wealthData = _deterministicData;

    if (_enableMonteCarlo) {
      _mcResult = LocalWealthCalculator.calculateMonteCarlo(
        _events,
        _currentAge,
        _lifeExpectancy,
        initialTaxable: initTaxable,
        initialTaxDeferred: initTaxDeferred,
        initialRoth: initRoth,
      );
    } else {
      _mcResult = null;
    }

    _insights = LocalWealthCalculator.insights(
      _wealthData,
      _currentAge,
      _events,
    );

    // Notify home dashboard for real-time chart sync.
    // Deferred to the next frame so we never call parent setState
    // from inside our own setState callback.
    if (widget.onWealthUpdated != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onWealthUpdated!(_wealthData);
      });
    }
  }

  void _saveHistory() {
    _history.add(
      List.from(
        _events.map(
          (e) => LifeEvent(
            id: e.id,
            type: e.type,
            name: e.name,
            startAge: e.startAge,
            endAge: e.endAge,
            params: Map.from(e.params),
          ),
        ),
      ),
    );
    if (_history.length > 20) _history.removeAt(0);
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _events = _history.removeLast();
      _recalculate();
    });
    _saveToHive();
  }

  void _reset() {
    _saveHistory();
    setState(() {
      _events = _buildDefaultEvents();
      _currentAge = widget.data?.currentAge ?? 30;
      _recalculate();
    });
    _saveToHive();
  }

  void _onAgeChange(int newAge) {
    if (newAge == _currentAge) return;
    setState(() {
      _currentAge = newAge;
      _recalculate();
    });
    _saveToHive();
  }

  void _onEventMove(String id, int newAge) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1 || _events[index].startAge == newAge) return;
    _saveHistory();
    setState(() {
      final old = _events[index];
      _events[index] = LifeEvent(
        id: old.id,
        type: old.type,
        name: old.name,
        startAge: newAge,
        endAge: old.endAge != null
            ? (newAge + (old.endAge! - old.startAge))
            : null,
        params: old.params,
      );
      _recalculate();
    });
    _saveToHive();
  }

  void _addEvent(int age) {
    _showEventPicker(age);
  }

  void _onEventTap(LifeEvent event) {
    _showEventEditor(event);
  }

  void _showEventPicker(int age) {
    _saveHistory();
    final categories = <String, List<_EventOption>>{
      '💼 Work & Income': [
        _EventOption(
          LifeEventType.job,
          'New Job',
          LucideIcons.briefcase,
          Colors.blue,
        ),
        _EventOption(
          LifeEventType.sideHustle,
          'Side Income',
          LucideIcons.star,
          Colors.amber,
        ),
        _EventOption(
          LifeEventType.jobLoss,
          'Work Gap',
          LucideIcons.alertTriangle,
          Colors.orange,
        ),
        _EventOption(
          LifeEventType.careerBreak,
          'Career Break',
          LucideIcons.plane,
          Colors.cyan,
        ),
        _EventOption(
          LifeEventType.business,
          'Start Business',
          LucideIcons.rocket,
          Colors.purple,
        ),
        _EventOption(
          LifeEventType.jobChange,
          'Job Change',
          LucideIcons.arrowLeftRight,
          Colors.teal,
        ),
      ],
      '🏡 Home & Family': [
        _EventOption(
          LifeEventType.rent,
          'Renting',
          LucideIcons.building,
          Colors.brown,
        ),
        _EventOption(
          LifeEventType.home,
          'Buy Home',
          LucideIcons.home,
          Colors.orange,
        ),
        _EventOption(
          LifeEventType.marriage,
          'Partner Up',
          LucideIcons.heart,
          Colors.pink,
        ),
        _EventOption(
          LifeEventType.children,
          'Have Kids',
          LucideIcons.baby,
          Colors.purple,
        ),
        _EventOption(
          LifeEventType.familySupport,
          'Support Family',
          LucideIcons.heartHandshake,
          Colors.indigo,
        ),
        _EventOption(
          LifeEventType.car,
          'Buy a Car',
          LucideIcons.car,
          Colors.blueGrey,
        ),
        _EventOption(
          LifeEventType.insurance,
          'Life Insurance',
          LucideIcons.shieldCheck,
          Colors.teal,
        ),
      ],
      '🌟 Life Changes': [
        _EventOption(
          LifeEventType.education,
          'Education',
          LucideIcons.graduationCap,
          Colors.indigo,
        ),
        _EventOption(
          LifeEventType.retirement,
          'Retire',
          LucideIcons.palmtree,
          Colors.green,
        ),
        _EventOption(
          LifeEventType.health,
          'Health Event',
          LucideIcons.heartPulse,
          Colors.red,
        ),
        _EventOption(
          LifeEventType.move,
          'Move Cities',
          LucideIcons.mapPin,
          Colors.teal,
        ),
        _EventOption(
          LifeEventType.vacation,
          'Vacation',
          LucideIcons.plane,
          Colors.cyan,
        ),
        _EventOption(
          LifeEventType.oneTimeExpense,
          'One-Time Expense',
          LucideIcons.receipt,
          Colors.deepOrange,
        ),
      ],
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: FinSpanTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: FinSpanTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Add event at age $age',
                              style: const TextStyle(
                                color: FinSpanTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              for (final entry in categories.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FinSpanTheme.bodyGray,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((ctx2, i) {
                    final opt = entry.value[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: opt.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(opt.icon, color: opt.color, size: 20),
                      ),
                      title: Text(
                        opt.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        final newEvent = LifeEvent(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          type: opt.type,
                          name: opt.label,
                          startAge: age,
                          endAge: _defaultEndAge(opt.type, age),
                          params: _defaultParams(opt.type),
                        );

                        Navigator.pop(ctx);

                        setState(() {
                          _events.add(newEvent);
                          _recalculate();
                        });
                        _saveToHive();

                        // Immediately open editor for the new event to allow details config
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) _showEventEditor(newEvent);
                        });
                      },
                    );
                  }, childCount: entry.value.length),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  int? _defaultEndAge(LifeEventType type, int startAge) {
    switch (type) {
      case LifeEventType.rent:
        return startAge + 5;
      case LifeEventType.children:
        return startAge + 18;
      case LifeEventType.jobLoss:
        return startAge + 1;
      case LifeEventType.careerBreak:
        return startAge + 1;
      case LifeEventType.familySupport:
        return startAge + 5;
      case LifeEventType.car:
        return startAge + 7;
      case LifeEventType.insurance:
        return startAge + 20;
      default:
        return null;
    }
  }

  Map<String, dynamic> _defaultParams(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return {'incomeLevel': 'good'};
      case LifeEventType.retirement:
        return {'lifestyleLevel': 'moderate'};
      case LifeEventType.home:
        return {'costLevel': 'expensive', 'hasGoodSavings': true};
      case LifeEventType.rent:
        return {'costLevel': 'moderate'};
      case LifeEventType.children:
        return {'count': 1, 'costLevel': 'moderate'};
      case LifeEventType.health:
        return {'severity': 'moderate', 'hasInsurance': true};
      case LifeEventType.car:
        return {'carPrice': 30000};
      case LifeEventType.vacation:
        return {'tripCost': 5000};
      case LifeEventType.oneTimeExpense:
        return {'amount': 15000};
      case LifeEventType.insurance:
        return {'monthlyPremium': 100, 'coverageAmount': 500000};
      case LifeEventType.jobLoss:
        return {'gapMonths': 6.0, 'monthlySpending': 3000.0, 'hasSeverance': false, 'hasEmergencyFund': true};
      case LifeEventType.careerBreak:
        return {'breakMonths': 12.0, 'monthlySpending': 3000.0, 'hasSavings': true};
      default:
        return {};
    }
  }

  // ─── Format helpers ────────────────────────────────────────────────────────

  String _fmtPercent(double v) => '${v.toStringAsFixed(1)}%';
  String _fmtYears(double v) => '${v.toInt()} yr${v.toInt() != 1 ? 's' : ''}';
  String _fmtInt(double v) => v.toInt().toString();

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    StateSetter setModalState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: FinSpanTheme.bodyGray),
          ),
          Switch(
            value: value,
            activeThumbColor: FinSpanTheme.primaryGreen,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) {
              onChanged(v);
              setModalState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ─── Full event editor ──────────────────────────────────────────────────────

  void _showEventEditor(LifeEvent event) {
    final int index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) {
          final ev = _events[index]; // always reads live state
          final color = _getEventColor(ev.type);

          // ── Param helpers ──────────────────────────────────────────────────
          double p(String key, double fallback) {
            final val = ev.params[key];
            if (val is num) return val.toDouble();
            return fallback;
          }

          void updateParam(String key, dynamic value) {
            final newParams = Map<String, dynamic>.from(ev.params)..[key] = value;
            setState(() {
              _events[index] = LifeEvent(
                id: ev.id, type: ev.type, name: ev.name,
                startAge: ev.startAge, endAge: ev.endAge,
                params: newParams,
              );
              _recalculate();
            });
            setModalState(() {});
            _saveToHive();
          }

          void updateStartAge(int newAge) {
            final dur = ev.endAge != null ? ev.endAge! - ev.startAge : 0;
            setState(() {
              _events[index] = LifeEvent(
                id: ev.id, type: ev.type, name: ev.name,
                startAge: newAge,
                endAge: ev.endAge != null ? newAge + dur : null,
                params: ev.params,
              );
              _recalculate();
            });
            setModalState(() {});
            _saveToHive();
          }

          void updateDuration(int newDur) {
            setState(() {
              _events[index] = LifeEvent(
                id: ev.id, type: ev.type, name: ev.name,
                startAge: ev.startAge,
                endAge: ev.startAge + newDur,
                params: ev.params,
              );
              _recalculate();
            });
            setModalState(() {});
            _saveToHive();
          }

          // ── Slider widget helper ───────────────────────────────────────────
          Widget pSlider(
            String label,
            String formatted,
            double value,
            double min,
            double max,
            int divisions,
            void Function(double) onChange,
          ) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FinSpanTheme.charcoal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatted,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    activeColor: color,
                    inactiveColor: color.withValues(alpha: 0.18),
                    onChanged: onChange,
                  ),
                ],
              ),
            );
          }

          // ── Event-specific controls per type ───────────────────────────────
          List<Widget> buildControls() {
            switch (ev.type) {
              case LifeEventType.job:
                return [
                  pSlider('Annual Salary', _formatMoney(p('salary', 55000)),
                    p('salary', 55000), 20000, 300000, 56,
                    (v) => updateParam('salary', v)),
                  pSlider('Annual Raise', _fmtPercent(p('annualRaise', 2.5)),
                    p('annualRaise', 2.5), 0, 10, 20,
                    (v) => updateParam('annualRaise', v)),
                ];
              case LifeEventType.jobChange:
                return [
                  pSlider('New Salary', _formatMoney(p('newSalary', 75000)),
                    p('newSalary', 75000), 20000, 400000, 76,
                    (v) => updateParam('newSalary', v)),
                ];
              case LifeEventType.sideHustle:
                return [
                  pSlider('Monthly Income', _formatMoney(p('monthlyIncome', 1000)),
                    p('monthlyIncome', 1000), 100, 10000, 99,
                    (v) => updateParam('monthlyIncome', v)),
                ];
              case LifeEventType.education:
                return [
                  pSlider('Total Tuition', _formatMoney(p('tuition', 40000)),
                    p('tuition', 40000), 5000, 300000, 59,
                    (v) => updateParam('tuition', v)),
                  pSlider('Duration', _fmtYears(p('durationYears', 4)),
                    p('durationYears', 4), 1, 8, 7,
                    (v) => updateParam('durationYears', v.roundToDouble())),
                ];
              case LifeEventType.rent:
                return [
                  pSlider('Monthly Rent', _formatMoney(p('monthlyRent', 2000)),
                    p('monthlyRent', 2000), 500, 8000, 75,
                    (v) => updateParam('monthlyRent', v)),
                ];
              case LifeEventType.home:
                return [
                  pSlider('Home Price', _formatMoney(p('homePrice', 400000)),
                    p('homePrice', 400000), 100000, 2000000, 76,
                    (v) => updateParam('homePrice', v)),
                  pSlider('Down Payment', _fmtPercent(p('downPaymentPercent', 20)),
                    p('downPaymentPercent', 20), 0, 50, 10,
                    (v) => updateParam('downPaymentPercent', v.roundToDouble())),
                ];
              case LifeEventType.marriage:
                return [
                  pSlider('Wedding Cost', _formatMoney(p('weddingCost', 25000)),
                    p('weddingCost', 25000), 0, 150000, 30,
                    (v) => updateParam('weddingCost', v)),
                  pSlider('Partner Income', _formatMoney(p('partnerIncome', 55000)),
                    p('partnerIncome', 55000), 0, 300000, 60,
                    (v) => updateParam('partnerIncome', v)),
                ];
              case LifeEventType.children:
                return [
                  pSlider('Number of Kids', _fmtInt(p('numKids', 1)),
                    p('numKids', 1), 1, 5, 4,
                    (v) => updateParam('numKids', v.round())),
                  pSlider('Annual Cost / Child', _formatMoney(p('annualCostPerKid', 15000)),
                    p('annualCostPerKid', 15000), 5000, 40000, 35,
                    (v) => updateParam('annualCostPerKid', v)),
                ];
              case LifeEventType.business:
                return [
                  pSlider('Startup Cost', _formatMoney(p('startupCost', 50000)),
                    p('startupCost', 50000), 5000, 500000, 99,
                    (v) => updateParam('startupCost', v)),
                  pSlider('Expected Revenue', _formatMoney(p('expectedRevenue', 80000)),
                    p('expectedRevenue', 80000), 20000, 500000, 48,
                    (v) => updateParam('expectedRevenue', v)),
                ];
              case LifeEventType.retirement:
                return [
                  pSlider('Monthly Spending', _formatMoney(p('monthlySpending', 4000)),
                    p('monthlySpending', 4000), 1500, 15000, 27,
                    (v) => updateParam('monthlySpending', v)),
                ];
              case LifeEventType.health:
                return [
                  pSlider('Medical Cost', _formatMoney(p('medicalCost', 25000)),
                    p('medicalCost', 25000), 1000, 300000, 299,
                    (v) => updateParam('medicalCost', v)),
                ];
              case LifeEventType.move:
                return [
                  pSlider('Moving Cost', _formatMoney(p('movingCost', 5000)),
                    p('movingCost', 5000), 1000, 50000, 49,
                    (v) => updateParam('movingCost', v)),
                ];
              case LifeEventType.familySupport:
                return [
                  pSlider('Monthly Amount', _formatMoney(p('monthlyAmount', 500)),
                    p('monthlyAmount', 500), 100, 5000, 49,
                    (v) => updateParam('monthlyAmount', v)),
                  pSlider('Support Duration', _fmtYears(p('supportYears', 5)),
                    p('supportYears', 5), 1, 25, 24,
                    (v) => updateParam('supportYears', v.roundToDouble())),
                ];
              case LifeEventType.car:
                return [
                  pSlider('Car Price', _formatMoney(p('carPrice', 30000)),
                    p('carPrice', 30000), 5000, 150000, 29,
                    (v) => updateParam('carPrice', v)),
                ];
              case LifeEventType.vacation:
                return [
                  pSlider('Trip Cost', _formatMoney(p('tripCost', 5000)),
                    p('tripCost', 5000), 500, 50000, 99,
                    (v) => updateParam('tripCost', v)),
                ];
              case LifeEventType.oneTimeExpense:
                return [
                  pSlider('Amount', _formatMoney(p('amount', 15000)),
                    p('amount', 15000), 1000, 200000, 199,
                    (v) => updateParam('amount', v)),
                ];
              case LifeEventType.insurance:
                return [
                  pSlider('Monthly Premium', _formatMoney(p('monthlyPremium', 100)),
                    p('monthlyPremium', 100), 10, 2000, 199,
                    (v) => updateParam('monthlyPremium', v)),
                  pSlider('Coverage Amount', _formatMoney(p('coverageAmount', 500000)),
                    p('coverageAmount', 500000), 10000, 5000000, 499,
                    (v) => updateParam('coverageAmount', v)),
                  pSlider('Term Length', _fmtYears(p('termLength', 20)),
                    p('termLength', 20), 1, 40, 39,
                    (v) => updateParam('termLength', v.roundToDouble())),
                ];
              case LifeEventType.jobLoss:
                return [
                  pSlider('Gap Duration (months)', _fmtInt(p('gapMonths', 6)),
                    p('gapMonths', 6), 1, 24, 23,
                    (v) => updateParam('gapMonths', v.roundToDouble())),
                  pSlider('Monthly Spending During Gap', _formatMoney(p('monthlySpending', 3000)),
                    p('monthlySpending', 3000), 500, 10000, 19,
                    (v) => updateParam('monthlySpending', v)),
                  _buildToggleRow(
                    'Has Severance Pay',
                    ev.params['hasSeverance'] as bool? ?? false,
                    (v) => updateParam('hasSeverance', v),
                    setModalState,
                  ),
                  _buildToggleRow(
                    'Has Emergency Fund',
                    ev.params['hasEmergencyFund'] as bool? ?? true,
                    (v) => updateParam('hasEmergencyFund', v),
                    setModalState,
                  ),
                ];
              case LifeEventType.careerBreak:
                return [
                  pSlider('Break Duration (months)', _fmtInt(p('breakMonths', 12)),
                    p('breakMonths', 12), 1, 36, 35,
                    (v) => updateParam('breakMonths', v.roundToDouble())),
                  pSlider('Monthly Spending', _formatMoney(p('monthlySpending', 3000)),
                    p('monthlySpending', 3000), 500, 10000, 19,
                    (v) => updateParam('monthlySpending', v)),
                  _buildToggleRow(
                    'Has Savings Buffer',
                    ev.params['hasSavings'] as bool? ?? true,
                    (v) => updateParam('hasSavings', v),
                    setModalState,
                  ),
                ];
            }
          }

          final controls = buildControls();
          final startAgeMax = (_lifeExpectancy - 1).toDouble();
          final startAgeMin = _currentAge.toDouble();
          final startAgeDivisions =
              (startAgeMax - startAgeMin).clamp(1, 80).toInt();
          final curDuration = ev.endAge != null
              ? (ev.endAge! - ev.startAge).clamp(1, 50)
              : 1;

          // ── Modal layout ───────────────────────────────────────────────────
          return DraggableScrollableSheet(
            initialChildSize: 0.72,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: FinSpanTheme.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getEventIcon(ev.type), color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ev.name,
                              style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold,
                                color: FinSpanTheme.charcoal,
                              ),
                            ),
                            Text(
                              'Age ${ev.startAge}${ev.endAge != null ? ' – ${ev.endAge}' : ''}',
                              style: const TextStyle(
                                fontSize: 12, color: FinSpanTheme.bodyGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Timing card ──────────────────────────────────────────
                  _editorCard(
                    label: 'TIMING',
                    children: [
                      pSlider(
                        'Start Age', 'Age ${ev.startAge}',
                        ev.startAge.toDouble(),
                        startAgeMin, startAgeMax, startAgeDivisions,
                        (v) => updateStartAge(v.round()),
                      ),
                      if (ev.endAge != null)
                        pSlider(
                          'Duration', _fmtYears(curDuration.toDouble()),
                          curDuration.toDouble(), 1, 50, 49,
                          (v) => updateDuration(v.round()),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Parameters card (event-specific) ─────────────────────
                  if (controls.isNotEmpty) ...[
                    _editorCard(label: 'PARAMETERS', children: controls),
                    const SizedBox(height: 10),
                  ],

                  // Live preview tip
                  Center(
                    child: Text(
                      '⚡ Chart updates live as you drag',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                      label: const Text(
                        'Remove Event',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveHistory();
                        setState(() {
                          _events.removeWhere((e) => e.id == ev.id);
                          _recalculate();
                        });
                        _saveToHive();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Reusable card container used in the event editor.
  Widget _editorCard({required String label, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FinSpanTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: FinSpanTheme.bodyGray,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final double maxWealth = _wealthData.isEmpty
        ? 1
        : _wealthData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = (maxWealth * 1.2)
        .clamp(10000, 2000000000)
        .toDouble();

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back button needed in tab view
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        title: const Text(
          'Life Simulator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_history.isNotEmpty)
            TextButton.icon(
              icon: const Icon(LucideIcons.undo2, size: 18),
              label: const Text('Undo'),
              onPressed: _undo,
            ),
          TextButton.icon(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Reset'),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightCards(),
              const SizedBox(height: 8),
              _buildWealthChart(dynamicMaxY),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: const EdgeInsets.all(12),
                child: FinSpanLifeBar(
                  currentAge: _currentAge,
                  retirementAge:
                      _events
                          .where((e) => e.type == LifeEventType.retirement)
                          .map((e) => e.startAge)
                          .firstOrNull ??
                      65,
                  lifeExpectancy: _lifeExpectancy,
                  events: _events,
                  onAddEvent: _addEvent,
                  onEventTap: _onEventTap,
                  onEventMove: _onEventMove,
                  onAgeChange: _onAgeChange,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '💡 Drag events or the age handle to see your future change.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCards() {
    final ins = _insights;
    final stressEmoji = ins.stressLevel < 35
        ? '😌'
        : ins.stressLevel < 55
        ? '🙂'
        : ins.stressLevel < 75
        ? '😐'
        : '😟';

    return Row(
      children: [
        Expanded(
          child: _insightCard(
            'Net Worth',
            _formatMoney(ins.netWorth),
            FinSpanTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _insightCard(
            'Cash Flow',
            _formatMoney(ins.monthlyCashFlow),
            ins.monthlyCashFlow >= 0
                ? FinSpanTheme.primaryGreen
                : Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _insightCard(
            'Stress',
            stressEmoji,
            ins.stressLevel < 55
                ? FinSpanTheme.primaryGreen
                : ins.stressLevel < 75
                ? Colors.orange
                : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _insightCard(
            'Plan',
            ins.riskLevel == 'safe' ? 'On Track' : 'Adjustment',
            ins.riskLevel == 'safe' ? FinSpanTheme.primaryGreen : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _insightCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FinSpanTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: FinSpanTheme.bodyGray),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWealthChart(double dynamicMaxY) {
    return FinSpanCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wealth Trajectory',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Live preview — drag to explore',
                    style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Monte Carlo',
                    style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
                  ),
                  Switch(
                    value: _enableMonteCarlo,
                    onChanged: (v) {
                      setState(() {
                        _enableMonteCarlo = v;
                        _recalculate();
                      });
                      LocalStorageService.saveMcEnabled(_uid, enabled: v);
                    },
                    activeThumbColor: FinSpanTheme.primaryGreen,
                    activeTrackColor: FinSpanTheme.primaryGreen.withValues(alpha: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: NumericAxis(
                minimum: _currentAge.toDouble(),
                maximum: _lifeExpectancy.toDouble(),
                interval: 10,
                majorGridLines: const MajorGridLines(width: 0),
                axisLabelFormatter: (AxisLabelRenderDetails d) {
                  return ChartAxisLabel('Age ${d.value.toInt()}', null);
                },
                plotBands: [
                  PlotBand(
                    isVisible: true,
                    start: _currentAge.toDouble(),
                    end: _currentAge.toDouble() + 0.4,
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.9),
                    text: 'Age $_currentAge',
                    textAngle: 0,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    horizontalTextAlignment: TextAnchor.start,
                    verticalTextAlignment: TextAnchor.end,
                  ),
                ],
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: dynamicMaxY,
                interval: dynamicMaxY / 4,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Colors.grey.withValues(alpha: 0.15),
                  dashArray: const <double>[4, 4],
                ),
                axisLabelFormatter: (AxisLabelRenderDetails d) {
                  final v = d.value.toDouble();
                  if (v == 0) {
                    return ChartAxisLabel('\$0', null);
                  }
                  if (v >= 1000000) {
                    return ChartAxisLabel(
                      '\$${(v / 1000000).toStringAsFixed(1)}M',
                      null,
                    );
                  }
                  return ChartAxisLabel('\$${(v / 1000).toInt()}K', null);
                },
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: 0,
                    end: 0,
                    borderColor: Colors.red.shade400,
                    borderWidth: 1.5,
                    dashArray: const <double>[6, 4],
                    text: 'Break Even',
                    textStyle: TextStyle(
                      color: Colors.red.shade500,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    horizontalTextAlignment: TextAnchor.end,
                    verticalTextAlignment: TextAnchor.start,
                  ),
                ],
              ),
              series: <CartesianSeries>[
                if (_enableMonteCarlo && _mcResult != null) ...[
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _deterministicData, // Deterministic base plan
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF6366F1), // Indigo/Blue
                    name: 'Your Plan',
                    animationDuration: 0,
                    width: 3,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _mcResult!.p90,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                    name: '90th Percentile',
                    animationDuration: 0,
                    dashArray: const <double>[5, 5],
                    width: 1.5,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _mcResult!.median,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFFF59E0B), // Orange
                    name: '50th Percentile',
                    animationDuration: 0,
                    width: 2,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _mcResult!.p10,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: Colors.red.withValues(alpha: 0.8),
                    name: '10th Percentile',
                    animationDuration: 0,
                    dashArray: const <double>[5, 5],
                    width: 1.5,
                  ),
                ] else ...[
                  SplineAreaSeries<LocalWealthPoint, double>(
                    dataSource: _wealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderColor: const Color(0xFF6366F1),
                    borderWidth: 2.5,
                    name: 'Your Plan',
                    animationDuration: 0,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              if (_enableMonteCarlo) ...[
                _legendDot('Your Plan', const Color(0xFF6366F1)),
                _legendDot(
                  '90th Pct',
                  FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                ),
                _legendDot('10th Pct', Colors.red.withValues(alpha: 0.8)),
                _legendDot('50th Pct', const Color(0xFFF59E0B)),
              ] else ...[
                _legendDot('Your Plan', const Color(0xFF6366F1)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: FinSpanTheme.bodyGray),
        ),
      ],
    );
  }

  String _formatMoney(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).round()}K';
    if (value < 0) return '-\$${value.abs().toStringAsFixed(0)}';
    return '\$${value.toStringAsFixed(0)}';
  }

  Color _getEventColor(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return Colors.blue;
      case LifeEventType.jobChange:
        return Colors.teal;
      case LifeEventType.jobLoss:
        return Colors.orange;
      case LifeEventType.sideHustle:
        return Colors.amber;
      case LifeEventType.careerBreak:
        return Colors.cyan;
      case LifeEventType.home:
        return Colors.orange;
      case LifeEventType.rent:
        return Colors.brown;
      case LifeEventType.marriage:
        return Colors.pink;
      case LifeEventType.children:
        return Colors.purple;
      case LifeEventType.familySupport:
        return Colors.indigo;
      case LifeEventType.retirement:
        return Colors.green;
      case LifeEventType.education:
        return Colors.indigo;
      case LifeEventType.business:
        return Colors.purple;
      case LifeEventType.health:
        return Colors.red;
      case LifeEventType.move:
        return Colors.teal;
      case LifeEventType.car:
        return Colors.blueGrey;
      case LifeEventType.vacation:
        return Colors.cyan;
      case LifeEventType.oneTimeExpense:
        return Colors.deepOrange;
      case LifeEventType.insurance:
        return Colors.teal;
    }
  }

  IconData _getEventIcon(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return LucideIcons.briefcase;
      case LifeEventType.jobChange:
        return LucideIcons.arrowLeftRight;
      case LifeEventType.jobLoss:
        return LucideIcons.alertTriangle;
      case LifeEventType.sideHustle:
        return LucideIcons.star;
      case LifeEventType.careerBreak:
        return LucideIcons.plane;
      case LifeEventType.home:
        return LucideIcons.home;
      case LifeEventType.rent:
        return LucideIcons.building;
      case LifeEventType.marriage:
        return LucideIcons.heart;
      case LifeEventType.children:
        return LucideIcons.baby;
      case LifeEventType.familySupport:
        return LucideIcons.heartHandshake;
      case LifeEventType.retirement:
        return LucideIcons.palmtree;
      case LifeEventType.education:
        return LucideIcons.graduationCap;
      case LifeEventType.business:
        return LucideIcons.rocket;
      case LifeEventType.health:
        return LucideIcons.heartPulse;
      case LifeEventType.move:
        return LucideIcons.mapPin;
      case LifeEventType.car:
        return LucideIcons.car;
      case LifeEventType.vacation:
        return LucideIcons.plane;
      case LifeEventType.oneTimeExpense:
        return LucideIcons.receipt;
      case LifeEventType.insurance:
        return LucideIcons.shieldCheck;
    }
  }
}

class _EventOption {
  final LifeEventType type;
  final String label;
  final IconData icon;
  final Color color;

  const _EventOption(this.type, this.label, this.icon, this.color);
}
