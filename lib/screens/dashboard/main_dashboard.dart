import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../../widgets/dashboard_alert_card.dart';
import '../simulation/simulation_runner.dart';
import '../simulation/simulator_life_weaver.dart';
import '../accounts/accounts_breakdown.dart';
import '../onboarding/onboarding_data.dart';
import '../../models/simulation_models.dart';
import '../simulation/detailed_results.dart';
import '../profile/profile_screen.dart';
import '../../utils/local_wealth_calculator.dart';

class MainDashboardScreen extends StatefulWidget {
  final SimulationResult? result;
  final OnboardingData? data;
  final bool fromSim;

  const MainDashboardScreen({
    super.key,
    this.result,
    this.data,
    this.fromSim = false,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  bool _showAlert = false;
  double _luckSliderValue = 50.0;

  // Mutable copy of onboarding data — updated when user saves from My Plan
  late OnboardingData _currentData;

  // Home tab Local Monte Carlo
  bool _homeEnableMonteCarlo = false;
  LocalMonteCarloResult? _homeMcResult;
  List<LocalWealthPoint> _homeWealthData = [];

  @override
  void initState() {
    super.initState();
    _currentData = widget.data ?? OnboardingData();
    _showAlert = widget.fromSim && widget.result != null;
    _initHomeWealthData();
  }

  void _onDataSaved(OnboardingData updated) {
    setState(() => _currentData = updated);
  }

  void _initHomeWealthData() {
    final age = widget.data?.currentAge ?? 30;
    final lifeExp = widget.data?.lifeExpectancy ?? 90;
    _homeWealthData = LocalWealthCalculator.calculate(
      _buildHomeEvents(),
      age,
      lifeExp,
    );
  }

  /// Same default events as `SimulatorLifeWeaverScreen._buildDefaultEvents()`
  /// so the Home Wealth Trajectory matches the Simulator tab exactly.
  List<LifeEvent> _buildHomeEvents() {
    final age = widget.data?.currentAge ?? 30;
    final lifeExp = widget.data?.lifeExpectancy ?? 90;
    return [
      LifeEvent(
        id: '1',
        type: LifeEventType.job,
        name: 'Current Job',
        startAge: age,
        params: const {'incomeLevel': 'good'},
      ),
      LifeEvent(
        id: '2',
        type: LifeEventType.home,
        name: 'Buy Home',
        startAge: (age + 5).clamp(age, lifeExp),
        params: const {'costLevel': 'expensive', 'hasGoodSavings': true},
      ),
      LifeEvent(
        id: '3',
        type: LifeEventType.retirement,
        name: 'Retirement',
        startAge: widget.data?.retirementAge ?? 65,
        params: const {'lifestyleLevel': 'moderate'},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Derive current wealth from local wealth calculator (first data point = today)
    final double currentWealth = _homeWealthData.isNotEmpty
        ? _homeWealthData.first.total
        : (widget.result?.standardResults.first.total ?? 0);

    // 10-year projection: use calculator data at index 10 if available
    double projected10Years;
    if (widget.result != null && widget.result!.standardResults.length > 10) {
      projected10Years = widget.result!.standardResults[10].total;
    } else if (_homeWealthData.length > 10) {
      projected10Years = _homeWealthData[10].total;
    } else {
      projected10Years = _homeWealthData.isNotEmpty
          ? _homeWealthData.last.total
          : currentWealth;
    }

    final int retirementAge = widget.data?.retirementAge ?? 65;
    final int currentAge = widget.data?.currentAge ?? 35;
    final int yearsToRetirement = (retirementAge - currentAge).clamp(0, 50);

    // Annual contributions from actual OnboardingData fields
    final double annualContribution =
        (widget.data?.userFourOneKContrib ?? 0) +
        (widget.data?.userRothIRAContrib ?? 0) +
        (widget.data?.spouseFourOneKContrib ?? 0) +
        (widget.data?.spouseRothIRAContrib ?? 0);

    // Personalize greeting with user's display name
    final String? displayName = FirebaseAuth.instance.currentUser?.displayName;
    final String firstName = displayName?.split(' ').first ?? '';
    final String greeting = firstName.isNotEmpty
        ? 'Hi, $firstName 👋'
        : 'Hi, Welcome back 👋';

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo mark
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          FinSpanTheme.primaryGreen,
                          FinSpanTheme.vibrantGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'FS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: FinSpanTheme.charcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Text(
                          'Your financial dashboard',
                          style: TextStyle(
                            fontSize: 11,
                            color: FinSpanTheme.bodyGray,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User avatar button
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FinSpanTheme.primaryGreen.withValues(
                            alpha: 0.2,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: FinSpanTheme.primaryGreen,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(
            context,
            currentWealth,
            projected10Years,
            annualContribution,
            yearsToRetirement,
          ),
          AccountsBreakdownScreen(data: _currentData),
          // Simulator tab — fully local, no API, real-time
          SimulatorLifeWeaverScreen(data: _currentData),
          ProfileScreen(data: _currentData, onDataSaved: _onDataSaved),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    double currentWealth,
    double projected10Years,
    double annualContribution,
    int yearsToRetirement,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Redirection Alert (Mobile Match of Web Alert Card)
            if (_showAlert && widget.result != null) ...[
              DashboardAlertCard(
                title: widget.result!.shortfallAge != null
                    ? "🎯 Optimization Needed"
                    : "✅ Great News!",
                message: widget.result!.shortfallAge != null
                    ? "Your plan covers until age ${widget.result!.shortfallAge}. Let's optimize it for your target."
                    : "Your retirement plan is on track! Your savings should last through your target age.",
                severity: widget.result!.shortfallAge != null
                    ? 'warning'
                    : 'success',
                runwayAge: widget.result!.shortfallAge ?? 95,
                targetAge: 95,
                onAdjustPlan: () {
                  if (widget.data != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            DetailedResultsScreen(data: widget.data!),
                      ),
                    );
                  }
                },
                onDismiss: () => setState(() => _showAlert = false),
              ),
              const SizedBox(height: 24),
            ],

            // 2. Main Stats Grid (Mobile Match of Web AnalyticsWidgetSummary)
            _buildStatsGrid(
              currentWealth,
              projected10Years,
              annualContribution,
              yearsToRetirement,
            ),

            const SizedBox(height: 24),

            // 3. Wealth Trajectory Preview
            _buildWealthPreview(),

            const SizedBox(height: 24),

            // 4. Portfolio Breakdown (New Piece from Web Dashboard)
            _buildPortfolioBreakdown(),

            const SizedBox(height: 24),

            // 5. Monte Carlo Analysis — Inline Local (replaces old popup card)
            _buildHomeMonteCarloCard(),

            const SizedBox(height: 24),

            // 6. Original Quick Action
            _buildSimulationBanner(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper for legend dots in the Home MC chart
  Widget _mcLegendDot(String label, Color color) {
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHomeMonteCarloCard() {
    return FinSpanCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FinSpanTheme.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.lineChart,
              color: FinSpanTheme.primaryGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monte Carlo Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _homeEnableMonteCarlo
                      ? '100 simulations • ${_luckDescription(_luckSliderValue)}'
                      : 'Test 100 market scenarios',
                  style: TextStyle(
                    fontSize: 11,
                    color: _homeEnableMonteCarlo
                        ? FinSpanTheme.primaryGreen
                        : FinSpanTheme.bodyGray,
                  ),
                ),
              ],
            ),
          ),
          if (_homeEnableMonteCarlo && _homeMcResult != null)
            GestureDetector(
              onTap: _showLuckSliderSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.settings2,
                      size: 14,
                      color: FinSpanTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_luckSliderValue.toInt()}th%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: FinSpanTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Switch(
            value: _homeEnableMonteCarlo,
            activeColor: FinSpanTheme.primaryGreen,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (val) {
              setState(() {
                _homeEnableMonteCarlo = val;
                if (val && _homeMcResult == null) {
                  final age = widget.data?.currentAge ?? 30;
                  final lifeExp = widget.data?.lifeExpectancy ?? 90;
                  // Use same events as Simulator tab
                  _homeMcResult = LocalWealthCalculator.calculateMonteCarlo(
                    _buildHomeEvents(),
                    age,
                    lifeExp,
                  );
                } else if (!val) {
                  _homeMcResult = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String _luckDescription(double percentile) {
    if (percentile >= 90) return '🍀 Very Lucky';
    if (percentile >= 75) return '😊 Lucky';
    if (percentile >= 60) return '👍 Above Average';
    if (percentile >= 40) return '😐 Average';
    if (percentile >= 25) return '😕 Below Average';
    if (percentile >= 10) return '😞 Unlucky';
    return '😰 Very Unlucky';
  }

  void _showLuckSliderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final mc = _homeMcResult!;

            // Compute selected value at _luckSliderValue
            double selectedVal;
            if (_luckSliderValue < 50) {
              double t = _luckSliderValue / 50.0;
              selectedVal =
                  mc.p10.last.total +
                  (mc.median.last.total - mc.p10.last.total) * t;
            } else {
              double t = (_luckSliderValue - 50.0) / 50.0;
              selectedVal =
                  mc.median.last.total +
                  (mc.p90.last.total - mc.median.last.total) * t;
            }

            String formatMoney(double v) {
              if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
              if (v >= 1000) return '\$${(v / 1000).round()}K';
              return '\$${v.toStringAsFixed(0)}';
            }

            // ── Outcome Distribution histogram (20 bins of final net worth) ─
            final finalNetWorths = mc.allRuns.map((r) => r.last.total).toList();
            final minNW = finalNetWorths.reduce((a, b) => a < b ? a : b);
            final maxNW = finalNetWorths.reduce((a, b) => a > b ? a : b);
            const int numBins = 12;
            final binSize = (maxNW - minNW) / numBins;
            final List<_BinData> bins = List.generate(numBins, (i) {
              final lo = minNW + i * binSize;
              final hi = lo + binSize;
              final count = finalNetWorths
                  .where(
                    (nw) => nw >= lo && (i == numBins - 1 ? nw <= hi : nw < hi),
                  )
                  .length;
              final label = lo >= 1000000
                  ? '${(lo / 1000000).toStringAsFixed(1)}M'
                  : '${(lo / 1000).toInt()}K';
              return _BinData(label, count);
            });

            // ── Market Returns from selected-percentile run ──────────────────
            // Pick which run to use based on _luckSliderValue
            final sortedRuns = [...mc.allRuns]
              ..sort((a, b) => a.last.total.compareTo(b.last.total));
            final runIndex =
                ((_luckSliderValue / 100) * (sortedRuns.length - 1))
                    .round()
                    .clamp(0, sortedRuns.length - 1);
            final selectedRun = sortedRuns[runIndex];

            // Year-over-year % change in total wealth as a proxy for market return
            final List<_ReturnBar> returnBars = [];
            for (int i = 1; i < selectedRun.length; i++) {
              final prev = selectedRun[i - 1].total;
              final curr = selectedRun[i].total;
              final pct = prev > 0 ? ((curr - prev) / prev * 100) : 0.0;
              returnBars.add(_ReturnBar(selectedRun[i].age, pct.toDouble()));
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: FinSpanTheme.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Monte Carlo Analysis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: FinSpanTheme.primaryGreen.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${(mc.allRuns.where((r) => r.last.total > 0).length / mc.allRuns.length * 100).toStringAsFixed(0)}% Success',
                                  style: const TextStyle(
                                    color: FinSpanTheme.primaryGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '100 simulations • 15% volatility',
                            style: TextStyle(
                              color: FinSpanTheme.bodyGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Luck Slider ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Luck Slider',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _luckDescription(_luckSliderValue),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SfSlider(
                            min: 0.0,
                            max: 100.0,
                            value: _luckSliderValue,
                            interval: 25,
                            showLabels: true,
                            enableTooltip: true,
                            minorTicksPerInterval: 0,
                            activeColor: FinSpanTheme.primaryGreen,
                            onChanged: (dynamic value) {
                              setSheetState(() => _luckSliderValue = value);
                              setState(() => _luckSliderValue = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Percentile result
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FinSpanTheme.primaryGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  FinSpanTheme.primaryGreen.withValues(
                                    alpha: 0.03,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: FinSpanTheme.primaryGreen.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_luckSliderValue.toInt()}th percentile outcome',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: FinSpanTheme.bodyGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Final portfolio: ${formatMoney(selectedVal)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _badgeChip(
                                      'P10: ${formatMoney(mc.p10.last.total)}',
                                      Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    _badgeChip(
                                      'P50: ${formatMoney(mc.median.last.total)}',
                                      const Color(0xFF8B5CF6),
                                    ),
                                    const SizedBox(width: 6),
                                    _badgeChip(
                                      'P90: ${formatMoney(mc.p90.last.total)}',
                                      FinSpanTheme.primaryGreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Outcome Distribution ──────────────────────────
                          const Text(
                            'Outcome Distribution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            '100 simulations',
                            style: TextStyle(
                              color: FinSpanTheme.bodyGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              margin: EdgeInsets.zero,
                              primaryXAxis: CategoryAxis(
                                majorGridLines: const MajorGridLines(width: 0),
                                labelRotation: -45,
                                labelStyle: const TextStyle(fontSize: 8),
                              ),
                              primaryYAxis: NumericAxis(
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                axisLabelFormatter: (AxisLabelRenderDetails d) {
                                  return ChartAxisLabel(
                                    d.value.toInt().toString(),
                                    null,
                                  );
                                },
                              ),
                              series: <CartesianSeries>[
                                ColumnSeries<_BinData, String>(
                                  dataSource: bins,
                                  xValueMapper: (d, _) => d.label,
                                  yValueMapper: (d, _) => d.count,
                                  color: FinSpanTheme.primaryGreen.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  animationDuration: 400,
                                ),
                              ],
                            ),
                          ),
                          // Stats chips below histogram
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _badgeChip(
                                '${(mc.allRuns.where((r) => r.last.total > 0).length / mc.allRuns.length * 100).toStringAsFixed(1)}% success',
                                FinSpanTheme.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              _badgeChip('100 runs', const Color(0xFF6B7280)),
                              const SizedBox(width: 6),
                              _badgeChip('15% vol', const Color(0xFF8B5CF6)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Market Returns ────────────────────────────────
                          Text(
                            'Market Returns',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${_luckSliderValue.toInt()}th percentile scenario',
                            style: const TextStyle(
                              color: FinSpanTheme.bodyGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              margin: EdgeInsets.zero,
                              primaryXAxis: NumericAxis(
                                majorGridLines: const MajorGridLines(width: 0),
                                axisLabelFormatter: (AxisLabelRenderDetails d) {
                                  return ChartAxisLabel(
                                    'Age ${d.value.toInt()}',
                                    null,
                                  );
                                },
                              ),
                              primaryYAxis: NumericAxis(
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                axisLabelFormatter: (AxisLabelRenderDetails d) {
                                  return ChartAxisLabel(
                                    '${d.value.toInt()}%',
                                    null,
                                  );
                                },
                              ),
                              series: <CartesianSeries>[
                                ColumnSeries<_ReturnBar, double>(
                                  dataSource: returnBars,
                                  xValueMapper: (d, _) => d.age.toDouble(),
                                  yValueMapper: (d, _) => d.returnPct,
                                  pointColorMapper: (d, _) => d.returnPct >= 0
                                      ? FinSpanTheme.primaryGreen.withValues(
                                          alpha: 0.85,
                                        )
                                      : Colors.red.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(2),
                                  animationDuration: 400,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: [
                              _badgeChip(
                                '↑ Positive',
                                FinSpanTheme.primaryGreen,
                              ),
                              _badgeChip('↓ Negative', Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _badgeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSuccessColor(double rate) {
    if (rate >= 80) return FinSpanTheme.vibrantGreen;
    if (rate >= 50) return Colors.orange;
    return Colors.redAccent;
  }

  Widget _buildStatsGrid(
    double current,
    double projected,
    double contribution,
    int years,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Current Savings',
                '\$${(current / 1000000).toStringAsFixed(1)}M',
                LucideIcons.wallet,
                FinSpanTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '10Y Projection',
                '\$${(projected / 1000000).toStringAsFixed(1)}M',
                LucideIcons.trendingUp,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Annual Contrib.',
                '\$${(contribution / 1000).toStringAsFixed(0)}K',
                LucideIcons.piggyBank,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Years to Retire',
                '$years Years',
                LucideIcons.calendarDays,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
    Widget? child,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: FinSpanTheme.charcoal,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: FinSpanTheme.bodyGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildWealthPreview() {
    final age = widget.data?.currentAge ?? 30;
    final lifeExp = widget.data?.lifeExpectancy ?? 90;

    double maxTotal = _homeWealthData.isEmpty
        ? 10000000
        : _homeWealthData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    if (_homeEnableMonteCarlo && _homeMcResult != null) {
      final p90Max = _homeMcResult!.p90
          .map((d) => d.total)
          .reduce((a, b) => a > b ? a : b);
      if (p90Max > maxTotal) maxTotal = p90Max;
    }
    final dynamicMaxY = (maxTotal * 1.2).clamp(10000.0, 2000000000.0);

    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wealth Trajectory',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    _homeEnableMonteCarlo
                        ? 'With Monte Carlo overlay (100 scenarios)'
                        : 'Deterministic projection',
                    style: const TextStyle(
                      fontSize: 11,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
              if (_homeEnableMonteCarlo && _homeMcResult != null)
                TextButton.icon(
                  onPressed: _showLuckSliderSheet,
                  icon: const Icon(LucideIcons.settings2, size: 14),
                  label: const Text('Luck', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: FinSpanTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  child: const Text(
                    'Simulator →',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipSettings: const InteractiveTooltip(enable: true),
              ),
              primaryXAxis: NumericAxis(
                minimum: age.toDouble(),
                maximum: lifeExp.toDouble(),
                interval: 10,
                majorGridLines: const MajorGridLines(width: 0),
                axisLabelFormatter: (AxisLabelRenderDetails d) {
                  return ChartAxisLabel('Age ${d.value.toInt()}', null);
                },
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: dynamicMaxY,
                interval: dynamicMaxY / 4,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                axisLabelFormatter: (AxisLabelRenderDetails d) {
                  final v = d.value.toDouble();
                  if (v == 0) return ChartAxisLabel(r'$0', null);
                  if (v >= 1000000) {
                    return ChartAxisLabel(
                      r'$' + '${(v / 1000000).toStringAsFixed(1)}M',
                      null,
                    );
                  }
                  return ChartAxisLabel(r'$' + '${(v / 1000).toInt()}K', null);
                },
              ),
              series: <CartesianSeries>[
                if (_homeEnableMonteCarlo && _homeMcResult != null) ...[
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _homeWealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF6366F1),
                    name: 'Your Plan',
                    animationDuration: 300,
                    width: 3,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _homeMcResult!.p90,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                    name: '90th Percentile (Lucky)',
                    animationDuration: 300,
                    dashArray: const <double>[5, 5],
                    width: 1.5,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _homeMcResult!.median,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF8B5CF6),
                    name: '50th Percentile (Median)',
                    animationDuration: 300,
                    width: 2,
                  ),
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _homeMcResult!.p10,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: Colors.red.withValues(alpha: 0.8),
                    name: '10th Percentile (Unlucky)',
                    animationDuration: 300,
                    dashArray: const <double>[5, 5],
                    width: 1.5,
                  ),
                ] else ...[
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _homeWealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.taxable,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.6),
                    name: 'Taxable',
                    animationDuration: 500,
                  ),
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _homeWealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.taxDeferred,
                    color: const Color(0xFF10B981).withValues(alpha: 0.6),
                    name: 'Tax-Deferred',
                    animationDuration: 500,
                  ),
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _homeWealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.roth,
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                    name: 'Roth',
                    animationDuration: 500,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 4,
            spacing: 12,
            children: _homeEnableMonteCarlo
                ? [
                    _mcLegendDot('Your Plan', const Color(0xFF6366F1)),
                    _mcLegendDot(
                      '90th Pct',
                      FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                    ),
                    _mcLegendDot('Median', const Color(0xFF8B5CF6)),
                    _mcLegendDot('10th Pct', Colors.red.withValues(alpha: 0.8)),
                  ]
                : [
                    _mcLegendDot('Taxable', const Color(0xFF6B7280)),
                    _mcLegendDot('Tax-Deferred', const Color(0xFF10B981)),
                    _mcLegendDot('Roth', const Color(0xFFF59E0B)),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioBreakdown() {
    // Use actual user savings ratios — not hardcoded mock data
    final double taxDeferred = widget.data?.taxDeferredSavings ?? 0;
    final double taxFree = widget.data?.taxFreeSavings ?? 0;
    final double taxable = widget.data?.taxableSavings ?? 0;
    final double total = taxDeferred + taxFree + taxable;

    // Fallback to sensible defaults if no data yet
    final double deferredPct = total > 0 ? (taxDeferred / total * 100) : 50;
    final double freePct = total > 0 ? (taxFree / total * 100) : 30;
    final double taxablePct = total > 0 ? (taxable / total * 100) : 20;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  LucideIcons.pieChart,
                  color: FinSpanTheme.primaryGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio Allocation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: FinSpanTheme.charcoal,
                    ),
                  ),
                  Text(
                    'By account type',
                    style: TextStyle(
                      fontSize: 11,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries<_PieData, String>>[
                    DoughnutSeries<_PieData, String>(
                      dataSource: [
                        _PieData(
                          'Tax-Deferred',
                          deferredPct,
                          FinSpanTheme.primaryGreen,
                        ),
                        _PieData('Tax-Free', freePct, const Color(0xFF3B82F6)),
                        _PieData(
                          'Taxable',
                          taxablePct,
                          const Color(0xFFF59E0B),
                        ),
                      ],
                      xValueMapper: (_PieData data, _) => data.x,
                      yValueMapper: (_PieData data, _) => data.y,
                      pointColorMapper: (_PieData data, _) => data.color,
                      innerRadius: '65%',
                      radius: '100%',
                      strokeWidth: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildAllocationLegend(
                      'Tax-Deferred',
                      '${deferredPct.toStringAsFixed(0)}%',
                      FinSpanTheme.primaryGreen,
                    ),
                    const SizedBox(height: 10),
                    _buildAllocationLegend(
                      'Tax-Free (Roth)',
                      '${freePct.toStringAsFixed(0)}%',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 10),
                    _buildAllocationLegend(
                      'Taxable',
                      '${taxablePct.toStringAsFixed(0)}%',
                      const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationLegend(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: FinSpanTheme.bodyGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SimulationRunnerScreen(data: widget.data ?? OnboardingData()),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [FinSpanTheme.primaryGreen, FinSpanTheme.vibrantGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.zap, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Full Simulation',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Get a detailed retirement forecast with tax optimization',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const navItems = [
      _NavItem(LucideIcons.layoutDashboard, 'Home'),
      _NavItem(LucideIcons.wallet, 'Accounts'),
      _NavItem(LucideIcons.lineChart, 'Simulator'),
      _NavItem(LucideIcons.userCog, 'My Plan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(isSelected ? 8 : 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FinSpanTheme.primaryGreen.withValues(
                                    alpha: 0.12,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? FinSpanTheme.primaryGreen
                                : const Color(0xFFB0B8C1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? FinSpanTheme.primaryGreen
                                : const Color(0xFFB0B8C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PieData {
  _PieData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class _BinData {
  final String label;
  final int count;
  const _BinData(this.label, this.count);
}

class _ReturnBar {
  final int age;
  final double returnPct;
  const _ReturnBar(this.age, this.returnPct);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
