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
import '../../services/simulation_service.dart';
import '../../services/user_service.dart';
import '../../services/local_storage_service.dart';

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

  // Home tab wealth trajectory data (local deterministic)
  List<LocalWealthPoint> _homeWealthData = [];

  // Monte Carlo — backend API state
  bool _homeEnableMonteCarlo = false;
  bool _mcIsLoading = false;
  MonteCarloResult? _apiMcResult;

  // Per-series visibility — tapping the legend dot toggles each line,
  // exactly like ApexCharts' built-in legend click behaviour on the web.
  bool _showYourPlan = true;
  bool _showP90 = true;
  bool _showMedian = true;
  bool _showP10 = true;
  bool _showSelectedRun = true;

  // Pre-converted chart data points from API stats
  List<_McChartPoint> _mcP90Points = [];
  List<_McChartPoint> _mcMedianPoints = [];
  List<_McChartPoint> _mcP10Points = [];
  // The single run picked by the Luck Slider — shown as the amber 5th line
  List<_McChartPoint> _mcSelectedRunPoints = [];

  @override
  void initState() {
    super.initState();
    _currentData = widget.data ?? OnboardingData();
    _showAlert = widget.fromSim && widget.result != null;
    _initHomeWealthData();
    // Restore MC toggle state from Hive so the user's last preference persists.
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _homeEnableMonteCarlo = LocalStorageService.loadMcEnabled(uid);
  }

  void _onDataSaved(OnboardingData updated) {
    final bool mcWasOn = _homeEnableMonteCarlo;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    setState(() {
      _currentData = updated;
      _initHomeWealthData();
      // Reset MC state — will re-run below if it was active
      _apiMcResult = null;
      _homeEnableMonteCarlo = false;
      _mcIsLoading = false;
      _buildApiMcChartData();
    });

    // ── Persist: Hive first (instant, no network), Firebase second (async) ──
    LocalStorageService.saveProfile(uid, updated);
    UserService().saveUserProfile(updated).catchError(
      (e) => debugPrint('⚠️ Firestore save failed: $e'),
    );

    // ── If MC was ON, re-run it with the new plan data automatically ────────
    // A short delay lets the chart finish redrawing the base line first so the
    // UI doesn't jump from "loading" to "loaded" in a single frame.
    if (mcWasOn) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _onMcToggled(true);
      });
    }
  }

  /// Converts backend MonteCarloResult.stats into chart-plottable points.
  /// Also computes the amber "selected run" line from allRuns + _luckSliderValue,
  /// matching exactly how the web picks it: sort runs by finalNw, index by percentile.
  void _buildApiMcChartData() {
    if (_apiMcResult == null || _apiMcResult!.stats.isEmpty) {
      _mcP90Points = [];
      _mcMedianPoints = [];
      _mcP10Points = [];
      _mcSelectedRunPoints = [];
      return;
    }
    final startAge = _currentData.currentAge.toDouble();
    final stats = _apiMcResult!.stats;
    _mcP90Points = stats
        .asMap()
        .entries
        .map((e) => _McChartPoint(startAge + e.key, e.value.netWorthP90))
        .toList();
    _mcMedianPoints = stats
        .asMap()
        .entries
        .map((e) => _McChartPoint(startAge + e.key, e.value.netWorthMedian))
        .toList();
    _mcP10Points = stats
        .asMap()
        .entries
        .map((e) => _McChartPoint(startAge + e.key, e.value.netWorthP10))
        .toList();

    // Amber line: sort runs by final net-worth (best = 100th pct, worst = 0th)
    // then pick the run at luckSliderValue% — identical to the web's logic.
    _mcSelectedRunPoints = _computeSelectedRunPoints(_luckSliderValue);
  }

  List<_McChartPoint> _computeSelectedRunPoints(double luck) {
    final runs = _apiMcResult?.allRuns ?? [];
    if (runs.isEmpty) return [];
    final sorted = [...runs]..sort((a, b) => a.finalNw.compareTo(b.finalNw));
    final idx = (luck / 100 * (sorted.length - 1))
        .floor()
        .clamp(0, sorted.length - 1);
    final run = sorted[idx];
    // Use index-based age mapping (same as P90/Median/P10 points) so this line
    // always aligns perfectly with the other series on the chart X-axis.
    // The backend may return P1_Age as a 0-based year index rather than an
    // absolute age, which would plot far off the visible range.
    final startAge = _currentData.currentAge.toDouble();
    return run.data
        .asMap()
        .entries
        .map((e) => _McChartPoint(startAge + e.key, e.value.netWorth))
        .toList();
  }

  /// Async handler for the MC toggle — calls backend production API.
  Future<void> _onMcToggled(bool val) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (!val) {
      setState(() {
        _homeEnableMonteCarlo = false;
        _apiMcResult = null;
        _mcIsLoading = false;
        _buildApiMcChartData();
      });
      LocalStorageService.saveMcEnabled(uid, enabled: false);
      return;
    }

    setState(() {
      _homeEnableMonteCarlo = true;
      _mcIsLoading = true;
    });

    try {
      final result = await SimulationService().runMonteCarlo(
        _currentData.toSimulationParams,
        volatility: 0.15,
        numSims: 100,
      );
      if (mounted) {
        if (result == null || result.stats.isEmpty) {
          // API returned but produced no usable stats — treat as failure
          setState(() {
            _homeEnableMonteCarlo = false;
            _mcIsLoading = false;
          });
          LocalStorageService.saveMcEnabled(uid, enabled: false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Monte Carlo returned no data. Please check your plan inputs.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        setState(() {
          _apiMcResult = result;
          _mcIsLoading = false;
          _buildApiMcChartData();
        });
        LocalStorageService.saveMcEnabled(uid, enabled: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _homeEnableMonteCarlo = false;
          _mcIsLoading = false;
        });
        LocalStorageService.saveMcEnabled(uid, enabled: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monte Carlo simulation failed. Check your connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _initHomeWealthData() {
    final age = _currentData.currentAge > 0 ? _currentData.currentAge : 30;
    final lifeExp =
        _currentData.lifeExpectancy > 0 ? _currentData.lifeExpectancy : 90;

    // Use the user's actual annual expenses as the base. currentExpenses is
    // an annual figure in OnboardingData.  We subtract a rough housing estimate
    // so the home-purchase event doesn't double-count.
    final double baseExpenses = _currentData.currentExpenses > 0
        ? (_currentData.currentExpenses * 0.6) // ~60% is non-housing
        : 36000.0;

    _homeWealthData = LocalWealthCalculator.calculate(
      _buildHomeEvents(),
      age,
      lifeExp,
      initialTaxable: _currentData.taxableSavings,
      initialTaxDeferred: _currentData.taxDeferredSavings,
      initialRoth: _currentData.taxFreeSavings,
      baseYearlyExpenses: baseExpenses,
    );
  }

  /// Builds the three default life-planning events for the home chart,
  /// seeded with the user's real salary from My Plan.
  List<LifeEvent> _buildHomeEvents() {
    final age = _currentData.currentAge > 0 ? _currentData.currentAge : 30;
    final lifeExp =
        _currentData.lifeExpectancy > 0 ? _currentData.lifeExpectancy : 90;
    final int retAge = _currentData.retirementAge > 0
        ? _currentData.retirementAge
        : 65;

    // Use the actual salary so the income trajectory reflects the user's plan.
    // Fall back to 'good' ($85K) only if no salary has been entered yet.
    final Map<String, dynamic> jobParams = {
      'incomeLevel': 'good',
      if (_currentData.currentSalary > 0) 'salary': _currentData.currentSalary,
    };

    // Use actual retirement expenses when available; otherwise use
    // 70 % of current expenses as the commonly-cited rule of thumb.
    final double retirementMonthly = _currentData.currentExpenses > 0
        ? (_currentData.currentExpenses * 0.7) / 12
        : 5000.0;

    return [
      LifeEvent(
        id: '1',
        type: LifeEventType.job,
        name: 'Current Job',
        startAge: age,
        params: jobParams,
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
        startAge: retAge,
        params: {'monthlySpending': retirementMonthly},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Current Savings: always use the user's actual account balances (not local calc seed)
    final double currentWealth = _currentData.totalSavings > 0
        ? _currentData.totalSavings
        : (widget.result?.standardResults.isNotEmpty == true
            ? widget.result!.standardResults.first.netWorth
            : 0);

    // 10-year projection: always use the local calc seeded from current plan
    // data.  widget.result is the stale initial API run and must not take
    // priority after the user updates My Plan.
    final double projected10Years = _homeWealthData.length > 10
        ? _homeWealthData[10].total
        : _homeWealthData.isNotEmpty
            ? _homeWealthData.last.total
            : currentWealth;

    final int retirementAge =
        _currentData.retirementAge > 0 ? _currentData.retirementAge : 65;
    final int currentAge =
        _currentData.currentAge > 0 ? _currentData.currentAge : 35;
    final int yearsToRetirement = (retirementAge - currentAge).clamp(0, 50);

    // Use the computed getter (salary × contribution rate) so this card
    // always reflects the user's latest plan even if explicit fields are 0.
    final double annualContribution =
        _currentData.totalHouseholdContribPerYear > 0
            ? _currentData.totalHouseholdContribPerYear
            : _currentData.currentSalary * 0.10; // sensible 10 % fallback

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
          // Simulator tab — fully local, no API, real-time.
          // onWealthUpdated fires after every recalculation so the home
          // Wealth Trajectory chart stays in sync with the simulator.
          SimulatorLifeWeaverScreen(
            data: _currentData,
            onWealthUpdated: (data) {
              if (mounted) setState(() => _homeWealthData = data);
            },
          ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) =>
                          DetailedResultsScreen(data: _currentData),
                    ),
                  );
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

            const SizedBox(height: 16),

            // 4. Monte Carlo Analysis — appears right below wealth chart
            _buildHomeMonteCarloCard(),

            const SizedBox(height: 24),

            // 5. Portfolio Breakdown
            _buildPortfolioBreakdown(),

            const SizedBox(height: 24),

            // 6. Quick Action Banner
            _buildSimulationBanner(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Tappable legend item — matches the web's ApexCharts legend behaviour.
  /// When [active] is false the item dims to signal the series is hidden.
  /// [dashed] renders a small dashed line instead of a solid dot (percentile lines).
  Widget _legendItem(
    String label,
    Color color, {
    bool dashed = false,
    bool active = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: active ? 1.0 : 0.35,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 10,
              child: dashed
                  ? CustomPaint(painter: _DashedLinePainter(color))
                  : Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                    ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10, color: FinSpanTheme.bodyGray),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Simple non-tappable legend dot — used in the luck-slider sheet.
  Widget _mcLegendDot(String label, Color color, {bool dashed = false}) =>
      _legendItem(label, color, dashed: dashed, active: true);

  Widget _mcFilterChip(
    String label,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: selected ? color : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? color : Colors.grey.shade500,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeMonteCarloCard() {
    final bool mcReady = _homeEnableMonteCarlo && _apiMcResult != null;
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
            child: _mcIsLoading
                ? const Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: FinSpanTheme.primaryGreen,
                    ),
                  )
                : const Icon(
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
                  _mcIsLoading
                      ? 'Running 100 scenarios via backend…'
                      : mcReady
                          ? '${_apiMcResult!.successRate.toStringAsFixed(0)}% success · ${_luckDescription(_luckSliderValue)}'
                          : 'Test 100 market scenarios (backend)',
                  style: TextStyle(
                    fontSize: 11,
                    color: mcReady
                        ? FinSpanTheme.primaryGreen
                        : FinSpanTheme.bodyGray,
                  ),
                ),
              ],
            ),
          ),
          if (mcReady)
            GestureDetector(
              onTap: _showLuckSliderSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            onChanged: _mcIsLoading ? null : _onMcToggled,
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
    if (_apiMcResult == null || _apiMcResult!.stats.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final stats = _apiMcResult!.stats;
            final lastStat = stats.last;

            // Interpolate final portfolio value based on luck slider
            double selectedVal;
            if (_luckSliderValue <= 50) {
              final t = _luckSliderValue / 50.0;
              selectedVal = lastStat.netWorthP10 +
                  (lastStat.netWorthMedian - lastStat.netWorthP10) * t;
            } else {
              final t = (_luckSliderValue - 50.0) / 50.0;
              selectedVal = lastStat.netWorthMedian +
                  (lastStat.netWorthP90 - lastStat.netWorthMedian) * t;
            }

            String formatMoney(double v) {
              if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
              if (v >= 1000) return '\$${(v / 1000).round()}K';
              return '\$${v.toStringAsFixed(0)}';
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
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
                                  '${_apiMcResult!.successRate.toStringAsFixed(0)}% Success',
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
                          Text(
                            '${_apiMcResult!.numSimulations} simulations • ${(_apiMcResult!.volatility * 100).toStringAsFixed(0)}% volatility • backend API',
                            style: const TextStyle(
                              color: FinSpanTheme.bodyGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const SizedBox(height: 24),

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
                              final pts = _computeSelectedRunPoints(
                                  value as double);
                              setSheetState(() => _luckSliderValue = value);
                              setState(() {
                                _luckSliderValue = value;
                                _mcSelectedRunPoints = pts;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Percentile result card
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
                                  'Estimated portfolio: ${formatMoney(selectedVal)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _badgeChip(
                                      'P10: ${formatMoney(lastStat.netWorthP10)}',
                                      Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    _badgeChip(
                                      'P50: ${formatMoney(lastStat.netWorthMedian)}',
                                      const Color(0xFF8B5CF6),
                                    ),
                                    const SizedBox(width: 6),
                                    _badgeChip(
                                      'P90: ${formatMoney(lastStat.netWorthP90)}',
                                      FinSpanTheme.primaryGreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _badgeChip(
                                '${_apiMcResult!.successRate.toStringAsFixed(1)}% success',
                                FinSpanTheme.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              _badgeChip(
                                '${_apiMcResult!.numSimulations} runs',
                                const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 6),
                              _badgeChip(
                                '${(_apiMcResult!.volatility * 100).toStringAsFixed(0)}% vol',
                                const Color(0xFF8B5CF6),
                              ),
                            ],
                          ),

                          // ── Outcome Distribution (histogram) ─────────────
                          if (_apiMcResult!.allRuns.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Outcome Distribution',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${_apiMcResult!.numSimulations} simulations',
                              style: const TextStyle(
                                color: FinSpanTheme.bodyGray,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Builder(builder: (_) {
                              final finalNetWorths = _apiMcResult!.allRuns
                                  .map((r) => r.finalNw)
                                  .toList();
                              final minNW = finalNetWorths
                                  .reduce((a, b) => a < b ? a : b);
                              final maxNW = finalNetWorths
                                  .reduce((a, b) => a > b ? a : b);
                              const int numBins = 12;
                              final binSize = maxNW == minNW
                                  ? 1.0
                                  : (maxNW - minNW) / numBins;
                              final List<_BinData> bins =
                                  List.generate(numBins, (i) {
                                final lo = minNW + i * binSize;
                                final hi = lo + binSize;
                                final count = finalNetWorths
                                    .where((nw) => nw >= lo &&
                                        (i == numBins - 1 ? nw <= hi : nw < hi))
                                    .length;
                                final label = lo.abs() >= 1000000
                                    ? '${(lo / 1000000).toStringAsFixed(1)}M'
                                    : '${(lo / 1000).toInt()}K';
                                return _BinData(label, count);
                              });
                              return SizedBox(
                                height: 160,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  margin: EdgeInsets.zero,
                                  primaryXAxis: CategoryAxis(
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
                                    labelRotation: -45,
                                    labelStyle: const TextStyle(fontSize: 8),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    axisLine: const AxisLine(width: 0),
                                    majorTickLines:
                                        const MajorTickLines(size: 0),
                                    axisLabelFormatter:
                                        (AxisLabelRenderDetails d) {
                                      return ChartAxisLabel(
                                          d.value.toInt().toString(), null);
                                    },
                                  ),
                                  series: <CartesianSeries>[
                                    ColumnSeries<_BinData, String>(
                                      dataSource: bins,
                                      xValueMapper: (d, _) => d.label,
                                      yValueMapper: (d, _) => d.count,
                                      color: FinSpanTheme.primaryGreen
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(4),
                                      animationDuration: 0,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // ── Market Returns for selected-percentile run ────
                          if (_apiMcResult!.allRuns.isNotEmpty) ...[
                            const SizedBox(height: 24),
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
                            Builder(builder: (_) {
                              final sortedRuns = [
                                ..._apiMcResult!.allRuns
                              ]..sort((a, b) => a.finalNw.compareTo(b.finalNw));
                              final runIndex = ((_luckSliderValue / 100) *
                                      (sortedRuns.length - 1))
                                  .round()
                                  .clamp(0, sortedRuns.length - 1);
                              final selectedRun = sortedRuns[runIndex];
                              final List<_ReturnBar> returnBars = [];
                              for (int i = 1;
                                  i < selectedRun.data.length;
                                  i++) {
                                final prev = selectedRun.data[i - 1].netWorth;
                                final curr = selectedRun.data[i].netWorth;
                                final pct = prev > 0
                                    ? ((curr - prev) / prev * 100)
                                    : 0.0;
                                returnBars.add(_ReturnBar(
                                    selectedRun.data[i].age, pct));
                              }
                              return SizedBox(
                                height: 160,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  margin: EdgeInsets.zero,
                                  primaryXAxis: NumericAxis(
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
                                    axisLabelFormatter:
                                        (AxisLabelRenderDetails d) {
                                      return ChartAxisLabel(
                                          'Age ${d.value.toInt()}', null);
                                    },
                                  ),
                                  primaryYAxis: NumericAxis(
                                    axisLine: const AxisLine(width: 0),
                                    majorTickLines:
                                        const MajorTickLines(size: 0),
                                    axisLabelFormatter:
                                        (AxisLabelRenderDetails d) {
                                      return ChartAxisLabel(
                                          '${d.value.toInt()}%', null);
                                    },
                                  ),
                                  series: <CartesianSeries>[
                                    ColumnSeries<_ReturnBar, double>(
                                      dataSource: returnBars,
                                      xValueMapper: (d, _) => d.age.toDouble(),
                                      yValueMapper: (d, _) => d.returnPct,
                                      pointColorMapper: (d, _) =>
                                          d.returnPct >= 0
                                              ? FinSpanTheme.primaryGreen
                                                  .withValues(alpha: 0.85)
                                              : Colors.red
                                                  .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(2),
                                      animationDuration: 0,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              children: [
                                _badgeChip(
                                    '↑ Positive', FinSpanTheme.primaryGreen),
                                _badgeChip('↓ Negative', Colors.red),
                              ],
                            ),
                          ],
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

  Color _successColor(double rate) {
    if (rate >= 80) return FinSpanTheme.primaryGreen;
    if (rate >= 50) return Colors.orange;
    return Colors.redAccent;
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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

  Widget _buildStatsGrid(
    double current,
    double projected,
    double contribution,
    int years,
  ) {
    // Format helpers
    String fmtMoney(double v) {
      if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}K';
      return '\$${v.toStringAsFixed(0)}';
    }

    final items = [
      (
        'Current Savings',
        fmtMoney(current),
        LucideIcons.wallet,
        FinSpanTheme.primaryGreen,
      ),
      (
        '10Y Projection',
        fmtMoney(projected),
        LucideIcons.trendingUp,
        const Color(0xFF3B82F6),
      ),
      (
        'Annual Contrib.',
        fmtMoney(contribution),
        LucideIcons.piggyBank,
        const Color(0xFFF97316),
      ),
      (
        'Yrs to Retire',
        '$years yrs',
        LucideIcons.calendarDays,
        const Color(0xFF8B5CF6),
      ),
    ];

    final double cardW =
        (MediaQuery.of(context).size.width - 32) * 0.52; // ~52% of usable width

    // Bust out of the parent's 16px padding so the carousel starts flush with
    // the screen edge and the leading card has its own left gutter.
    return Transform.translate(
      offset: const Offset(-16, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final (title, value, icon, color) = items[i];
            return SizedBox(
              width: cardW,
              child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 17),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: FinSpanTheme.charcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 11,
                            color: FinSpanTheme.bodyGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
    final age = _currentData.currentAge > 0 ? _currentData.currentAge : 30;
    final lifeExp =
        _currentData.lifeExpectancy > 0 ? _currentData.lifeExpectancy : 90;
    final bool mcActive = _homeEnableMonteCarlo && _apiMcResult != null;

    double maxTotal = _homeWealthData.isEmpty
        ? 10000000
        : _homeWealthData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    if (mcActive && _mcP90Points.isNotEmpty) {
      final p90Max =
          _mcP90Points.map((d) => d.value).reduce((a, b) => a > b ? a : b);
      if (p90Max > maxTotal) maxTotal = p90Max;
    }
    final dynamicMaxY = (maxTotal * 1.2).clamp(10000.0, 2000000000.0);

    String fmt(double v) {
      if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000) return '\$${(v / 1000).toInt()}K';
      return '\$${v.toStringAsFixed(0)}';
    }

    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wealth Trajectory',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: FinSpanTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mcActive
                          ? 'With Monte Carlo overlay (100 scenarios)'
                          : 'Based on your current plan',
                      style: const TextStyle(
                        fontSize: 11,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Success-rate badge (MC active) or Simulator shortcut
              if (mcActive) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _successColor(_apiMcResult!.successRate)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _successColor(_apiMcResult!.successRate)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${_apiMcResult!.successRate.toStringAsFixed(0)}% Success',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _successColor(_apiMcResult!.successRate),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _showLuckSliderSheet,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.settings2,
                            size: 12, color: FinSpanTheme.primaryGreen),
                        SizedBox(width: 3),
                        Text(
                          'Luck',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: FinSpanTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Simulator →',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),

          // Loading bar while API call is running
          if (_mcIsLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE8F5E9),
              color: FinSpanTheme.primaryGreen,
              minHeight: 2,
            ),
          ],

          // ── P10/P50/P90 stat row (MC active only) ─────────────────────
          if (mcActive && _mcP10Points.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _statPill('P10', fmt(_mcP10Points.last.value), Colors.red),
                const SizedBox(width: 6),
                _statPill('Median', fmt(_mcMedianPoints.last.value),
                    const Color(0xFF8B5CF6)),
                const SizedBox(width: 6),
                _statPill('P90', fmt(_mcP90Points.last.value),
                    FinSpanTheme.primaryGreen),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // ── Chart ─────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: mcActive ? 240 : 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: NumericAxis(
                minimum: age.toDouble(),
                maximum: lifeExp.toDouble(),
                interval: 10,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                    fontSize: 9, color: FinSpanTheme.bodyGray),
                axisLabelFormatter: (AxisLabelRenderDetails d) =>
                    ChartAxisLabel('Age ${d.value.toInt()}', null),
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
                labelStyle: const TextStyle(
                    fontSize: 9, color: FinSpanTheme.bodyGray),
                axisLabelFormatter: (AxisLabelRenderDetails d) {
                  final v = d.value.toDouble();
                  if (v == 0) return ChartAxisLabel(r'$0', null);
                  if (v >= 1000000) {
                    return ChartAxisLabel(
                        '\$${(v / 1000000).toStringAsFixed(1)}M', null);
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
                if (mcActive) ...[
                  // 1. 10th Percentile — thin dashed red
                  SplineSeries<_McChartPoint, double>(
                    dataSource: _showP10 ? _mcP10Points : [],
                    xValueMapper: (d, _) => d.age,
                    yValueMapper: (d, _) => d.value,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                    name: '10th Percentile',
                    animationDuration: 0,
                    dashArray: const <double>[4, 4],
                    width: 1,
                  ),
                  // 2. Median — thin dashed purple
                  SplineSeries<_McChartPoint, double>(
                    dataSource: _showMedian ? _mcMedianPoints : [],
                    xValueMapper: (d, _) => d.age,
                    yValueMapper: (d, _) => d.value,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                    name: 'Median',
                    animationDuration: 0,
                    dashArray: const <double>[4, 4],
                    width: 1,
                  ),
                  // 3. 90th Percentile — thin dashed green
                  SplineSeries<_McChartPoint, double>(
                    dataSource: _showP90 ? _mcP90Points : [],
                    xValueMapper: (d, _) => d.age,
                    yValueMapper: (d, _) => d.value,
                    color: const Color(0xFF10B981).withValues(alpha: 0.8),
                    name: '90th Percentile',
                    animationDuration: 0,
                    dashArray: const <double>[4, 4],
                    width: 1,
                  ),
                  // 4. Selected luck-slider run — solid amber, 2px
                  SplineSeries<_McChartPoint, double>(
                    dataSource: _showSelectedRun ? _mcSelectedRunPoints : [],
                    xValueMapper: (d, _) => d.age,
                    yValueMapper: (d, _) => d.value,
                    color: const Color(0xFFF59E0B),
                    name: '${_luckSliderValue.toInt()}th Percentile',
                    animationDuration: 0,
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: false),
                  ),
                  // 5. Your Plan — bold solid indigo (top, 3px)
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _showYourPlan ? _homeWealthData : [],
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF6366F1),
                    name: 'Your Plan',
                    animationDuration: 0,
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: false),
                  ),
                ] else ...[
                  // Default (MC off): clean SplineArea — single solid indigo line
                  SplineAreaSeries<LocalWealthPoint, double>(
                    dataSource: _homeWealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.total,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderColor: const Color(0xFF6366F1),
                    borderWidth: 2.5,
                    name: 'Your Plan',
                    animationDuration: 0,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Legend ─────────────────────────────────────────────────────
          // When MC is active each item is tappable — tap to toggle that line,
          // exactly like ApexCharts' built-in legend-click on the web.
          if (mcActive)
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _legendItem('Your Plan', const Color(0xFF6366F1),
                    active: _showYourPlan,
                    onTap: () =>
                        setState(() => _showYourPlan = !_showYourPlan)),
                _legendItem('90th Percentile', const Color(0xFF10B981),
                    dashed: true,
                    active: _showP90,
                    onTap: () => setState(() => _showP90 = !_showP90)),
                _legendItem('Median', const Color(0xFF8B5CF6),
                    dashed: true,
                    active: _showMedian,
                    onTap: () => setState(() => _showMedian = !_showMedian)),
                _legendItem('10th Percentile', const Color(0xFFEF4444),
                    dashed: true,
                    active: _showP10,
                    onTap: () => setState(() => _showP10 = !_showP10)),
                _legendItem(
                  '${_luckSliderValue.toInt()}th Percentile',
                  const Color(0xFFF59E0B),
                  active: _showSelectedRun,
                  onTap: () =>
                      setState(() => _showSelectedRun = !_showSelectedRun),
                ),
              ],
            )
          else
            _legendItem('Your Plan', const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _buildPortfolioBreakdown() {
    // Use actual user savings ratios — not hardcoded mock data
    final double taxDeferred = _currentData.taxDeferredSavings;
    final double taxFree = _currentData.taxFreeSavings;
    final double taxable = _currentData.taxableSavings;
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
                      animationDuration: 0,
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
                SimulationRunnerScreen(data: _currentData),
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

/// A single (age, value) data point used for MC percentile series on the chart.
class _McChartPoint {
  final double age;
  final double value;
  const _McChartPoint(this.age, this.value);
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

/// Draws a small dashed horizontal line — used in the legend to represent
/// the dashed percentile series (P90/Median/P10) visually.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 3.0;
    const dashGap = 2.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
