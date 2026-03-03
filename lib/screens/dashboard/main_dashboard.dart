import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../../widgets/dashboard_alert_card.dart';
import '../simulation/simulation_runner.dart';
import '../accounts/accounts_breakdown.dart';
import '../onboarding/onboarding_data.dart';
import '../../models/simulation_models.dart';
import '../simulation/detailed_results.dart';

import '../profile/profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _showAlert = widget.fromSim && widget.result != null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate metrics from simulation or default
    final double currentWealth =
        widget.result?.standardResults.first.total ?? 45200000;

    // 10 year projection
    double projected10Years = currentWealth * 1.5; // fallback
    if (widget.result != null && widget.result!.standardResults.length > 10) {
      projected10Years = widget.result!.standardResults[10].total;
    }

    final int retirementAge = widget.data?.retirementAge ?? 65;
    final int currentAge = widget.data?.currentAge ?? 35;
    final int yearsToRetirement = (retirementAge - currentAge).clamp(0, 50);

    final double annualContribution =
        (widget.data?.userFourOneKContrib ?? 0) +
        (widget.data?.userRothIRAContrib ?? 0) +
        (widget.data?.taxableSavings != null ? 150000 * 12 : 0);

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              backgroundColor: FinSpanTheme.backgroundLight,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 12, bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: FinSpanTheme.primaryGreen,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'Hi, Welcome back 👋',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: CircleAvatar(
                      backgroundColor: FinSpanTheme.dividerColor,
                      child: const Icon(
                        Icons.person,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                  ),
                ),
              ],
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
          const AccountsBreakdownScreen(),
          DetailedResultsScreen(
            data: widget.data ?? OnboardingData(),
            isTab: true,
            onRunNew: () => setState(
              () => _selectedIndex = 0,
            ), // Lead back to home to run new
          ),
          ProfileScreen(data: widget.data),
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

            // 5. Monte Carlo Inline Results (Replaced with a trigger card)
            if (widget.result?.monteCarlo != null) ...[
              FinSpanCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_rounded,
                          color: FinSpanTheme.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monte Carlo Analysis',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.result!.monteCarlo!.successRate.toStringAsFixed(1)}% Success Probability',
                              style: const TextStyle(
                                color: FinSpanTheme.bodyGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FinSpanTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _showMonteCarloPopup,
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 6. Original Quick Action
            _buildSimulationBanner(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showMonteCarloPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: FinSpanTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bump
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildMonteCarloHeader(),
                      const SizedBox(height: 24),
                      _buildMonteCarloSlider(widget.result!.monteCarlo!),
                      const SizedBox(height: 24),
                      _buildMonteCarloSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonteCarloHeader() {
    final mc = widget.result!.monteCarlo!;
    Color successColor = _getSuccessColor(mc.successRate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: FinSpanTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monte Carlo Analysis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${mc.successRate.toStringAsFixed(1)}% Success',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Switch(
              value: true,
              onChanged: (val) {},
              activeColor: FinSpanTheme.primaryGreen,
            ),
            const Text('Enable', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildMonteCarloSlider(MonteCarloResult mc) {
    // Determine title text based on slider position
    String luckLabel = '😐 Average';
    if (_luckSliderValue < 30) luckLabel = '😢 Unlucky';
    if (_luckSliderValue > 70) luckLabel = '🤩 Lucky';

    // Interpolate final portfolio value based on P10, P50, P90
    double val;
    if (_luckSliderValue < 50) {
      double t = _luckSliderValue / 50.0;
      val =
          mc.stats.last.netWorthP10 +
          (mc.stats.last.netWorthMedian - mc.stats.last.netWorthP10) * t;
    } else {
      double t =
          (_luckSliderValue - 50.0) /
          50.0; // Wait, actually backend provides P90 as luckiest. Assume P90 maps to slider >= 90
      // Map 50-100 to P50-P90 range for simplicity
      val =
          mc.stats.last.netWorthMedian +
          (mc.stats.last.netWorthP90 - mc.stats.last.netWorthMedian) * t;
    }

    return FinSpanCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Luck Slider',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(luckLabel, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SfSlider(
            min: 0.0,
            max: 100.0,
            value: _luckSliderValue,
            interval: 50,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 0,
            activeColor: FinSpanTheme.primaryGreen,
            onChanged: (dynamic value) {
              setState(() {
                _luckSliderValue = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: FinSpanTheme.charcoal,
                ),
                children: [
                  TextSpan(
                    text: '${_luckSliderValue.toInt()}th percentile: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'Final portfolio LKR ${(val / 1000000).toStringAsFixed(1)}M',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonteCarloSection() {
    final mc = widget.result!.monteCarlo!;
    double maxY = 0;
    for (var s in mc.stats) {
      if (s.netWorthP90 > maxY) maxY = s.netWorthP90;
    }
    double dynamicMaxY = maxY > 0 ? (maxY * 1.1) : 10000000;

    // Calculate simulated year-over-year median returns for the bar chart
    List<_ReturnData> returnData = [];
    for (int i = 1; i < mc.stats.length; i++) {
      double prev = mc.stats[i - 1].netWorthMedian;
      double curr = mc.stats[i].netWorthMedian;
      double percentChange = 0;
      if (prev > 0) {
        percentChange = ((curr - prev) / prev) * 100;
      }
      returnData.add(_ReturnData(mc.stats[i].year, percentChange));
    }

    return Column(
      children: [
        FinSpanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outcome Distribution',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                '100 simulations',
                style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                  ),
                  primaryXAxis: NumericAxis(
                    minimum: widget.data?.currentAge.toDouble() ?? 35,
                    maximum: widget.data?.lifeExpectancy.toDouble() ?? 95,
                    interval: 10,
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: dynamicMaxY,
                    interval: dynamicMaxY / 5,
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    axisLabelFormatter: (AxisLabelRenderDetails details) {
                      double val = details.value.toDouble();
                      if (val == 0) return ChartAxisLabel('0', null);
                      if (val >= 1000000) {
                        return ChartAxisLabel(
                          '${(val / 1000000).toInt()}M',
                          null,
                        );
                      }
                      return ChartAxisLabel('${(val / 1000).toInt()}K', null);
                    },
                  ),
                  series: <CartesianSeries>[
                    SplineSeries<MonteCarloStat, double>(
                      dataSource: mc.stats,
                      xValueMapper: (MonteCarloStat data, _) =>
                          data.year.toDouble(),
                      yValueMapper: (MonteCarloStat data, _) =>
                          data.netWorthP90,
                      color: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
                      width: 2,
                      dashArray: const <double>[5, 5],
                      name: 'Lucky',
                    ),
                    SplineSeries<MonteCarloStat, double>(
                      dataSource: mc.stats,
                      xValueMapper: (MonteCarloStat data, _) =>
                          data.year.toDouble(),
                      yValueMapper: (MonteCarloStat data, _) =>
                          data.netWorthP10,
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 2,
                      dashArray: const <double>[5, 5],
                      name: 'Unlucky',
                    ),
                    SplineAreaSeries<MonteCarloStat, double>(
                      dataSource: mc.stats,
                      xValueMapper: (MonteCarloStat data, _) =>
                          data.year.toDouble(),
                      yValueMapper: (MonteCarloStat data, _) =>
                          data.netWorthMedian,
                      color: FinSpanTheme.primaryGreen.withValues(alpha: 0.2),
                      borderColor: FinSpanTheme.primaryGreen,
                      borderWidth: 2,
                      name: 'Median',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSuccessColor(mc.successRate),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${mc.successRate.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '100 runs',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(mc.volatility * 100).toInt()}% vol',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FinSpanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Market Returns',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                '50th percentile scenario',
                style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  primaryXAxis: NumericAxis(
                    isVisible: true,
                    title: AxisTitle(
                      text: 'Age',
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    labelStyle: const TextStyle(color: Colors.transparent),
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(
                      text: 'Return %',
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    minimum: -30,
                    maximum: 40,
                    interval: 10,
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    labelFormat: '{value}%',
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<_ReturnData, double>(
                      dataSource: returnData,
                      xValueMapper: (_ReturnData data, _) =>
                          data.year.toDouble(),
                      yValueMapper: (_ReturnData data, _) => data.percentChange,
                      pointColorMapper: (_ReturnData data, _) =>
                          data.percentChange >= 0
                          ? FinSpanTheme.vibrantGreen
                          : Colors.redAccent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: FinSpanTheme.vibrantGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_upward,
                          size: 12,
                          color: FinSpanTheme.vibrantGreen,
                        ),
                        SizedBox(width: 4),
                        Text('Positive', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_downward,
                          size: 12,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text('Negative', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
                'LKR ${(current / 1000000).toStringAsFixed(1)}M',
                Icons.account_balance_wallet,
                FinSpanTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '10Y Projection',
                'LKR ${(projected / 1000000).toStringAsFixed(1)}M',
                Icons.trending_up,
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
                'LKR ${(contribution / 1000).toStringAsFixed(0)}K',
                Icons.savings,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Years to Retire',
                '$years Years',
                Icons.event,
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
    return FinSpanCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _buildWealthPreview() {
    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wealth Trajectory',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
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
                child: const Text('View Full', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: widget.result != null
                ? SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    primaryXAxis: const NumericAxis(isVisible: false),
                    primaryYAxis: const NumericAxis(isVisible: false),
                    series: <CartesianSeries<WealthDataPoint, double>>[
                      StackedAreaSeries<WealthDataPoint, double>(
                        dataSource: widget.result!.standardResults,
                        xValueMapper: (WealthDataPoint data, _) =>
                            data.age.toDouble(),
                        yValueMapper: (WealthDataPoint data, _) => data.taxable,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                        animationDuration: 1000,
                      ),
                      StackedAreaSeries<WealthDataPoint, double>(
                        dataSource: widget.result!.standardResults,
                        xValueMapper: (WealthDataPoint data, _) =>
                            data.age.toDouble(),
                        yValueMapper: (WealthDataPoint data, _) =>
                            data.preTaxP1 + data.preTaxP2,
                        color: const Color(0xFF10B981).withValues(alpha: 0.7),
                        animationDuration: 1000,
                      ),
                      StackedAreaSeries<WealthDataPoint, double>(
                        dataSource: widget.result!.standardResults,
                        xValueMapper: (WealthDataPoint data, _) =>
                            data.age.toDouble(),
                        yValueMapper: (WealthDataPoint data, _) =>
                            data.rothP1 + data.rothP2,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                        animationDuration: 1000,
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "Run simulation to see projection",
                      style: TextStyle(
                        fontSize: 12,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                  ),
          ),
          if (widget.result != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Taxable', const Color(0xFF6B7280)),
                const SizedBox(width: 16),
                _buildLegendItem('Tax-Deferred', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _buildLegendItem('Roth', const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolioBreakdown() {
    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Allocation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries<_PieData, String>>[
                    DoughnutSeries<_PieData, String>(
                      dataSource: [
                        _PieData('Dividend', 45, FinSpanTheme.primaryGreen),
                        _PieData('Growth', 35, Colors.blue),
                        _PieData('Fixed Income', 20, Colors.orange),
                      ],
                      xValueMapper: (_PieData data, _) => data.x,
                      yValueMapper: (_PieData data, _) => data.y,
                      pointColorMapper: (_PieData data, _) => data.color,
                      innerRadius: '60%',
                      radius: '100%',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildAllocationLegend(
                      'Dividend',
                      '45%',
                      FinSpanTheme.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildAllocationLegend('Growth', '35%', Colors.blue),
                    const SizedBox(height: 12),
                    _buildAllocationLegend(
                      'Fixed Income',
                      '20%',
                      Colors.orange,
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: FinSpanTheme.bodyGray,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
          border: Border.all(
            color: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Simulation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Update your plan and see new results",
                    style: TextStyle(
                      fontSize: 12,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: FinSpanTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: FinSpanTheme.dividerColor, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Simulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
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

class _ReturnData {
  _ReturnData(this.year, this.percentChange);
  final int year;
  final double percentChange;
}
