import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import '../../services/simulation_service.dart';
import '../../models/simulation_models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MonteCarloScreen extends StatefulWidget {
  final OnboardingData data;

  const MonteCarloScreen({super.key, required this.data});

  @override
  State<MonteCarloScreen> createState() => _MonteCarloScreenState();
}

class _MonteCarloScreenState extends State<MonteCarloScreen> {
  final SimulationService _simService = SimulationService();
  MonteCarloResult? _mcResult;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runMonteCarlo();
  }

  Future<void> _runMonteCarlo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mcParams = widget.data.toSimulationParams;
      final result = await _simService.runMonteCarlo(mcParams);

      if (mounted) {
        setState(() {
          _mcResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Analysis failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Converts a raw simulation year (0-indexed) to the user's actual age
  int _yearToAge(int year) => widget.data.currentAge + year;

  /// Format large dollar amounts: 1200000 → "$1.2M", 500000 → "$500K"
  String _formatDollars(double value) {
    if (value <= 0) return '\$0';
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  /// Find the age at which P10 (worst case) first hits zero, or null if it stays positive
  int? get _worstCaseShortfallAge {
    if (_mcResult == null) return null;
    for (final stat in _mcResult!.stats) {
      if (stat.netWorthP10 <= 0) return _yearToAge(stat.year);
    }
    return null;
  }

  /// P90 final value (best case ending wealth)
  double get _bestCaseEnding {
    if (_mcResult == null || _mcResult!.stats.isEmpty) return 0;
    return _mcResult!.stats.last.netWorthP90;
  }

  /// Median final value (expected ending wealth)
  double get _medianEnding {
    if (_mcResult == null || _mcResult!.stats.isEmpty) return 0;
    return _mcResult!.stats.last.netWorthMedian;
  }

  /// P10 final value (worst case ending wealth, could be 0)
  double get _worstCaseEnding {
    if (_mcResult == null || _mcResult!.stats.isEmpty) return 0;
    return _mcResult!.stats.last.netWorthP10;
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: FinSpanTheme.charcoal),
        title: Text(
          'Monte Carlo Analysis',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : _buildResultsState(),
      ),
    );
  }

  // ─── Loading ─────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: FinSpanTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(
            'Running 100 Market Scenarios…',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Testing your plan against decades of market volatility',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FinSpanTheme.bodyGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Error ───────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _runMonteCarlo,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Results ─────────────────────────────────────────────────────────────

  Widget _buildResultsState() {
    if (_mcResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContextBanner(),
          const SizedBox(height: 16),
          _buildSuccessRateCard(_mcResult!.successRate),
          const SizedBox(height: 16),
          _buildTrajectoryChart(),
          const SizedBox(height: 16),
          _buildScenarioCards(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Context Banner ───────────────────────────────────────────────────────

  Widget _buildContextBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FinSpanTheme.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.info,
            size: 16,
            color: FinSpanTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Based on ${_formatDollars(widget.data.totalSavings)} in savings, '
              'retiring at ${widget.data.retirementAge}, '
              'living to ${widget.data.lifeExpectancy}.',
              style: const TextStyle(
                fontSize: 12,
                color: FinSpanTheme.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Success Rate Card ────────────────────────────────────────────────────

  Widget _buildSuccessRateCard(double rate) {
    Color color = rate >= 80
        ? FinSpanTheme.vibrantGreen
        : rate >= 50
        ? Colors.orange
        : Colors.redAccent;

    String rateLabel = rate >= 80
        ? 'Highly Resilient'
        : rate >= 50
        ? 'Moderate Risk'
        : 'High Risk';

    String rateDesc = rate >= 80
        ? 'Your plan survived to age ${widget.data.lifeExpectancy} in ${rate.toStringAsFixed(0)}% of ${_mcResult!.numSimulations} market scenarios.'
        : rate >= 50
        ? 'Your plan ran short in ${(100 - rate).toStringAsFixed(0)}% of scenarios. Consider saving more or adjusting your retirement age.'
        : 'Your portfolio may run out of money in many market scenarios. A strategy review is strongly recommended.';

    return FinSpanCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Probability of Success',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: FinSpanTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${rate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: FinSpanTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            rateDesc,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FinSpanTheme.bodyGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trajectory Chart ─────────────────────────────────────────────────────

  Widget _buildTrajectoryChart() {
    if (_mcResult!.stats.isEmpty) return const SizedBox.shrink();

    // Build age-based data — map each stat's "year" field to actual age
    final List<_AgeStat> ageStats = _mcResult!.stats.map((s) {
      return _AgeStat(
        age: _yearToAge(s.year).toDouble(),
        median: s.netWorthMedian,
        p10: s.netWorthP10.clamp(0, double.infinity),
        p90: s.netWorthP90,
      );
    }).toList();

    double maxY = ageStats.fold(0.0, (m, s) => s.p90 > m ? s.p90 : m);
    double dynamicMaxY = maxY > 0 ? maxY * 1.15 : 10000000;
    double yInterval = dynamicMaxY / 5;

    return FinSpanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wealth Trajectory',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: FinSpanTheme.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shaded band shows the range of realistic outcomes across all simulations.',
            style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                lineType: TrackballLineType.vertical,
                tooltipSettings: const InteractiveTooltip(
                  enable: true,
                  format: 'Age point.x\npoint.y',
                ),
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              ),
              primaryXAxis: NumericAxis(
                minimum: widget.data.currentAge.toDouble(),
                maximum: widget.data.lifeExpectancy.toDouble(),
                interval: 10,
                title: AxisTitle(
                  text: 'Age',
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Color(0xFFEEEEEE),
                ),
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: dynamicMaxY,
                interval: yInterval,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Color(0xFFEEEEEE),
                ),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  double val = details.value.toDouble();
                  if (val == 0) return ChartAxisLabel('\$0', null);
                  if (val >= 1000000) {
                    return ChartAxisLabel(
                      '\$${(val / 1000000).toStringAsFixed(1)}M',
                      null,
                    );
                  }
                  return ChartAxisLabel(
                    '\$${(val / 1000).toStringAsFixed(0)}K',
                    null,
                  );
                },
              ),
              series: <CartesianSeries>[
                // Shaded confidence band (P10 to P90)
                RangeAreaSeries<_AgeStat, double>(
                  dataSource: ageStats,
                  xValueMapper: (_AgeStat s, _) => s.age,
                  highValueMapper: (_AgeStat s, _) => s.p90,
                  lowValueMapper: (_AgeStat s, _) => s.p10,
                  color: FinSpanTheme.primaryGreen.withValues(alpha: 0.12),
                  borderColor: Colors.transparent,
                  name: 'Range (P10–P90)',
                  legendIconType: LegendIconType.rectangle,
                ),

                // P90 — best case bound
                SplineSeries<_AgeStat, double>(
                  dataSource: ageStats,
                  xValueMapper: (_AgeStat s, _) => s.age,
                  yValueMapper: (_AgeStat s, _) => s.p90,
                  color: const Color(0xFF3B82F6),
                  width: 1.5,
                  dashArray: const <double>[6, 4],
                  name: 'Lucky (P90)',
                  markerSettings: const MarkerSettings(isVisible: false),
                ),

                // P10 — worst case bound
                SplineSeries<_AgeStat, double>(
                  dataSource: ageStats,
                  xValueMapper: (_AgeStat s, _) => s.age,
                  yValueMapper: (_AgeStat s, _) => s.p10,
                  color: Colors.orange,
                  width: 1.5,
                  dashArray: const <double>[6, 4],
                  name: 'Unlucky (P10)',
                  markerSettings: const MarkerSettings(isVisible: false),
                ),

                // Median — solid bold green line
                SplineSeries<_AgeStat, double>(
                  dataSource: ageStats,
                  xValueMapper: (_AgeStat s, _) => s.age,
                  yValueMapper: (_AgeStat s, _) => s.median,
                  color: FinSpanTheme.primaryGreen,
                  width: 3,
                  name: 'Expected (Median)',
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(
                'Expected',
                FinSpanTheme.primaryGreen,
                solid: true,
              ),
              _buildLegendItem(
                'Lucky (P90)',
                const Color(0xFF3B82F6),
                solid: false,
              ),
              _buildLegendItem('Unlucky (P10)', Colors.orange, solid: false),
              _buildLegendItem(
                'Range',
                FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
                solid: true,
                isRect: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color, {
    bool solid = true,
    bool isRect = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isRect
            ? Container(
                width: 18,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
        ),
      ],
    );
  }

  // ─── Scenario Summary Cards ───────────────────────────────────────────────

  Widget _buildScenarioCards() {
    final shortfallAge = _worstCaseShortfallAge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scenario Outcomes',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: FinSpanTheme.charcoal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What your portfolio looks like at age ${widget.data.lifeExpectancy} across market conditions.',
          style: const TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScenarioCard(
                icon: LucideIcons.trendingUp,
                label: 'Best Case',
                sublabel: 'Favorable markets (P90)',
                value: _formatDollars(_bestCaseEnding),
                color: FinSpanTheme.vibrantGreen,
                bgColor: FinSpanTheme.vibrantGreen.withValues(alpha: 0.08),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildScenarioCard(
                icon: LucideIcons.minus,
                label: 'Expected',
                sublabel: 'Typical markets (Median)',
                value: _formatDollars(_medianEnding),
                color: FinSpanTheme.primaryGreen,
                bgColor: FinSpanTheme.primaryGreen.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildWorstCaseCard(shortfallAge),
      ],
    );
  }

  Widget _buildScenarioCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: FinSpanTheme.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: const TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
          ),
        ],
      ),
    );
  }

  Widget _buildWorstCaseCard(int? shortfallAge) {
    final bool hasShortfall = shortfallAge != null;
    const Color badColor = Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasShortfall ? LucideIcons.alertTriangle : LucideIcons.trendingDown,
            size: 18,
            color: badColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Worst Case (P10)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: badColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasShortfall) ...[
                  Text(
                    'Potential shortfall at age $shortfallAge',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: FinSpanTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'In poor market conditions, funds may be depleted before the end of your plan. Consider increasing savings rate or reducing expenses.',
                    style: TextStyle(
                      fontSize: 11,
                      color: FinSpanTheme.bodyGray,
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  Text(
                    _formatDollars(_worstCaseEnding),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: FinSpanTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Even in adverse markets, your portfolio survives. This is a positive sign, though a buffer is always wise.',
                    style: TextStyle(
                      fontSize: 11,
                      color: FinSpanTheme.bodyGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for age-mapped chart series
class _AgeStat {
  final double age;
  final double median;
  final double p10;
  final double p90;

  const _AgeStat({
    required this.age,
    required this.median,
    required this.p10,
    required this.p90,
  });
}
