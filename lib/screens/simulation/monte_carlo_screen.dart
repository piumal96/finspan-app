import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import '../../services/simulation_service.dart';
import '../../models/simulation_models.dart';

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
      // You can customize bounds here if needed (e.g. increase volatility)
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: FinSpanTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(
            'Running 100 Simulations...',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Testing against market volatility',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _runMonteCarlo,
            child: const Text('Retry Analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    if (_mcResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLuckyBar(_mcResult!.successRate),
          const SizedBox(height: 24),
          _buildChartCard(),
        ],
      ),
    );
  }

  Widget _buildLuckyBar(double rate) {
    Color color = rate >= 80
        ? FinSpanTheme.vibrantGreen
        : rate >= 50
        ? Colors.orange
        : Colors.redAccent;

    return FinSpanCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Probability of Success',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              Text(
                '${(rate).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: FinSpanTheme.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate >= 80
                ? 'Your plan is highly resilient to market shocks.'
                : rate >= 50
                ? 'Your plan has moderate risk. Consider adjusting goals.'
                : 'High risk detected. We recommend reviewing your strategy.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FinSpanTheme.bodyGray),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    if (_mcResult!.stats.isEmpty) return const SizedBox.shrink();

    // Find absolute max Y for decent scaling
    double maxY = 0;
    for (var s in _mcResult!.stats) {
      if (s.netWorthP90 > maxY) maxY = s.netWorthP90;
    }
    // Calculate a good interval
    double dynamicMaxY = maxY > 0 ? (maxY * 1.1) : 10000000;

    return FinSpanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wealth Trajectory Bounds',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipSettings: const InteractiveTooltip(
                  enable: true,
                  format: 'Age point.x: LKR point.y',
                ),
              ),
              primaryXAxis: NumericAxis(
                minimum: widget.data.currentAge.toDouble(),
                maximum: widget.data.lifeExpectancy.toDouble(),
                interval: 10,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: dynamicMaxY,
                interval: dynamicMaxY / 5,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  double val = details.value.toDouble();
                  if (val == 0) return ChartAxisLabel('', null);
                  if (val >= 1000000) {
                    return ChartAxisLabel('${(val / 1000000).toInt()}M', null);
                  }
                  return ChartAxisLabel('${(val / 1000).toInt()}K', null);
                },
              ),
              series: <CartesianSeries>[
                // P90 - Lucky
                SplineSeries<MonteCarloStat, double>(
                  dataSource: _mcResult!.stats,
                  xValueMapper: (MonteCarloStat data, _) =>
                      data.year.toDouble(),
                  yValueMapper: (MonteCarloStat data, _) => data.netWorthP90,
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 2,
                  dashArray: const <double>[5, 5],
                  name: 'Lucky (P90)',
                ),
                // P10 - Unlucky
                SplineSeries<MonteCarloStat, double>(
                  dataSource: _mcResult!.stats,
                  xValueMapper: (MonteCarloStat data, _) =>
                      data.year.toDouble(),
                  yValueMapper: (MonteCarloStat data, _) => data.netWorthP10,
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                  dashArray: const <double>[5, 5],
                  name: 'Unlucky (P10)',
                ),
                SplineAreaSeries<MonteCarloStat, double>(
                  dataSource: _mcResult!.stats,
                  xValueMapper: (MonteCarloStat data, _) =>
                      data.year.toDouble(),
                  yValueMapper: (MonteCarloStat data, _) => data.netWorthMedian,
                  color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                  borderColor: FinSpanTheme.primaryGreen,
                  borderWidth: 3,
                  name: 'Expected (Median)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Expected', FinSpanTheme.primaryGreen),
              const SizedBox(width: 16),
              _buildLegendItem(
                'Lucky (P90)',
                Colors.blue.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                'Unlucky (P10)',
                Colors.orange.withValues(alpha: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
        ),
      ],
    );
  }
}
