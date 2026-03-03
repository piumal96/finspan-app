import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../../widgets/life_bar.dart';
import '../../models/simulation_models.dart';
import '../../utils/local_wealth_calculator.dart';
import '../onboarding/onboarding_data.dart';

/// Mobile port of web's SimulatorLifeWeaver.
/// Calculates wealth 100% locally — no API calls, fully real-time.
class SimulatorLifeWeaverScreen extends StatefulWidget {
  final OnboardingData? data;

  const SimulatorLifeWeaverScreen({super.key, this.data});

  @override
  State<SimulatorLifeWeaverScreen> createState() =>
      _SimulatorLifeWeaverScreenState();
}

class _SimulatorLifeWeaverScreenState extends State<SimulatorLifeWeaverScreen> {
  late int _currentAge;
  late int _lifeExpectancy;
  late List<LifeEvent> _events;

  // Computed locally — no API
  late List<LocalWealthPoint> _wealthData;
  late LocalInsights _insights;

  // Monte Carlo State
  bool _enableMonteCarlo = false;
  double _luckPercentile = 50.0;
  LocalMonteCarloResult? _mcResult;

  // History for undo
  final List<List<LifeEvent>> _history = [];

  @override
  void initState() {
    super.initState();
    _currentAge = widget.data?.currentAge ?? 30;
    _lifeExpectancy = widget.data?.lifeExpectancy ?? 90;
    _events = _buildDefaultEvents();
    _recalculate();
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
    if (_enableMonteCarlo) {
      _mcResult = LocalWealthCalculator.calculateMonteCarlo(
        _events,
        _currentAge,
        _lifeExpectancy,
      );
      // For insight cards, base them on the median run to prevent them from jumping around wildly
      _wealthData = _mcResult!.median;
    } else {
      _mcResult = null;
      _wealthData = LocalWealthCalculator.calculate(
        _events,
        _currentAge,
        _lifeExpectancy,
      );
    }

    _insights = LocalWealthCalculator.insights(
      _wealthData,
      _currentAge,
      _events,
    );
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
  }

  void _reset() {
    _saveHistory();
    setState(() {
      _events = _buildDefaultEvents();
      _currentAge = widget.data?.currentAge ?? 30;
      _recalculate();
    });
  }

  void _onAgeChange(int newAge) {
    if (newAge == _currentAge) return;
    setState(() {
      _currentAge = newAge;
      _recalculate(); // Local — instant, no API
    });
  }

  void _onEventMove(String id, int newAge) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1 || _events[index].startAge == newAge) return;
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
      _recalculate(); // Local — instant, no API
    });
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
        _EventOption(LifeEventType.job, 'New Job', Icons.work, Colors.blue),
        _EventOption(
          LifeEventType.sideHustle,
          'Side Income',
          Icons.star,
          Colors.amber,
        ),
        _EventOption(
          LifeEventType.jobLoss,
          'Work Gap',
          Icons.warning_amber,
          Colors.orange,
        ),
        _EventOption(
          LifeEventType.careerBreak,
          'Career Break',
          Icons.flight,
          Colors.cyan,
        ),
        _EventOption(
          LifeEventType.business,
          'Start Business',
          Icons.rocket_launch,
          Colors.purple,
        ),
        _EventOption(
          LifeEventType.jobChange,
          'Job Change',
          Icons.swap_horiz,
          Colors.teal,
        ),
      ],
      '🏡 Home & Family': [
        _EventOption(
          LifeEventType.rent,
          'Renting',
          Icons.apartment,
          Colors.brown,
        ),
        _EventOption(LifeEventType.home, 'Buy Home', Icons.home, Colors.orange),
        _EventOption(
          LifeEventType.marriage,
          'Partner Up',
          Icons.favorite,
          Colors.pink,
        ),
        _EventOption(
          LifeEventType.children,
          'Have Kids',
          Icons.child_care,
          Colors.purple,
        ),
        _EventOption(
          LifeEventType.familySupport,
          'Support Family',
          Icons.handshake,
          Colors.indigo,
        ),
      ],
      '🌟 Life Changes': [
        _EventOption(
          LifeEventType.education,
          'Education',
          Icons.school,
          Colors.indigo,
        ),
        _EventOption(
          LifeEventType.retirement,
          'Retire',
          Icons.beach_access,
          Colors.green,
        ),
        _EventOption(
          LifeEventType.health,
          'Health Event',
          Icons.health_and_safety,
          Colors.red,
        ),
        _EventOption(
          LifeEventType.move,
          'Move Cities',
          Icons.location_on,
          Colors.teal,
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
                        Navigator.pop(ctx);
                        setState(() {
                          _events.add(
                            LifeEvent(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              type: opt.type,
                              name: opt.label,
                              startAge: age,
                              endAge: _defaultEndAge(opt.type, age),
                              params: _defaultParams(opt.type),
                            ),
                          );
                          _recalculate();
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
      default:
        return {};
    }
  }

  void _showEventEditor(LifeEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: FinSpanTheme.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEventIcon(event.type),
                  color: _getEventColor(event.type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Age ${event.startAge}${event.endAge != null ? ' – ${event.endAge}' : ''}',
              style: const TextStyle(
                color: FinSpanTheme.bodyGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                    _events.removeWhere((e) => e.id == event.id);
                    _recalculate();
                  });
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
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double maxWealth = _wealthData.isEmpty
        ? 1
        : _wealthData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = (maxWealth * 1.2)
        .clamp(10000, 2000000000)
        .toDouble();

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        title: const Text(
          'Life Simulator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_history.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Undo'),
              onPressed: _undo,
            ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightCards(),
              const SizedBox(height: 20),
              _buildMonteCarloToggle(),
              if (_enableMonteCarlo) ...[
                const SizedBox(height: 16),
                _buildLuckSlider(),
              ],
              const SizedBox(height: 20),
              _buildWealthChart(dynamicMaxY),
              const SizedBox(height: 20),
              FinSpanCard(
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),
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

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio:
          1.3, // Reduced from 1.8 to give cards more vertical room on small screens
      children: [
        _insightCard(
          'Net Worth',
          'at age $_currentAge',
          _formatMoney(ins.netWorth),
          FinSpanTheme.primaryGreen,
        ),
        _insightCard(
          'Monthly Cash Flow',
          ins.monthlyCashFlow >= 0 ? 'surplus' : 'spending more',
          _formatMoney(ins.monthlyCashFlow),
          ins.monthlyCashFlow >= 0 ? FinSpanTheme.primaryGreen : Colors.orange,
        ),
        _insightCard(
          'Life Stress',
          ins.stressLevel < 55
              ? 'Manageable'
              : ins.stressLevel < 75
              ? 'Elevated'
              : 'High',
          stressEmoji,
          ins.stressLevel < 55
              ? FinSpanTheme.primaryGreen
              : ins.stressLevel < 75
              ? Colors.orange
              : Colors.red,
        ),
        _insightCard(
          'Retirement',
          'planned at ${ins.retirementAge}',
          ins.riskLevel == 'safe'
              ? '✓ On Track'
              : ins.riskLevel == 'caution'
              ? '⚡ Tight'
              : '👀 Needs Attention',
          ins.riskLevel == 'safe'
              ? FinSpanTheme.primaryGreen
              : ins.riskLevel == 'caution'
              ? Colors.orange
              : Colors.red,
        ),
      ],
    );
  }

  Widget _insightCard(
    String label,
    String sublabel,
    String value,
    Color color,
  ) {
    return FinSpanCard(
      padding: const EdgeInsets.all(8), // Reduced from 12 to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FinSpanTheme.charcoal,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: FinSpanTheme.bodyGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonteCarloToggle() {
    return FinSpanCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: FinSpanTheme.primaryGreen,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monte Carlo Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (_enableMonteCarlo && _mcResult != null)
                    const Text(
                      '100 simulations generated',
                      style: TextStyle(
                        fontSize: 12,
                        color: FinSpanTheme.primaryGreen,
                      ),
                    )
                  else
                    const Text(
                      'Test market volatility locally',
                      style: TextStyle(
                        fontSize: 12,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Switch(
            value: _enableMonteCarlo,
            activeColor: FinSpanTheme.primaryGreen,
            onChanged: (val) {
              setState(() {
                _enableMonteCarlo = val;
                _recalculate();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLuckSlider() {
    // Determine title text based on slider position
    String luckLabel = '😐 Average';
    if (_luckPercentile < 30) luckLabel = '😢 Unlucky';
    if (_luckPercentile > 70) luckLabel = '🤩 Lucky';

    // Interpolate final portfolio value based on P10, Median, P90
    double val = 0;
    if (_mcResult != null) {
      if (_luckPercentile < 50) {
        double t = _luckPercentile / 50.0;
        val =
            _mcResult!.p10.last.total +
            (_mcResult!.median.last.total - _mcResult!.p10.last.total) * t;
      } else {
        double t = (_luckPercentile - 50.0) / 50.0;
        val =
            _mcResult!.median.last.total +
            (_mcResult!.p90.last.total - _mcResult!.median.last.total) * t;
      }
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
            value: _luckPercentile,
            interval: 50,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 0,
            activeColor: FinSpanTheme.primaryGreen,
            onChanged: (dynamic value) {
              setState(() {
                _luckPercentile = value;
                // No need to _recalculate, just redraws the chart selection
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
                    text: '${_luckPercentile.toInt()}th percentile: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: 'Final portfolio ${_formatMoney(val)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWealthChart(double dynamicMaxY) {
    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wealth Trajectory',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            'Live preview — drag to explore',
            style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipSettings: const InteractiveTooltip(enable: true),
              ),
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
              ),
              series: <CartesianSeries>[
                if (_enableMonteCarlo && _mcResult != null) ...[
                  SplineSeries<LocalWealthPoint, double>(
                    dataSource: _wealthData, // The deterministic base plan
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
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _wealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.taxable,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    name: 'Taxable',
                    animationDuration: 0,
                  ),
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _wealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.taxDeferred,
                    color: const Color(0xFF10B981).withValues(alpha: 0.7),
                    name: 'Tax-Deferred',
                    animationDuration: 0,
                  ),
                  StackedAreaSeries<LocalWealthPoint, double>(
                    dataSource: _wealthData,
                    xValueMapper: (d, _) => d.age.toDouble(),
                    yValueMapper: (d, _) => d.roth,
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                    name: 'Roth',
                    animationDuration: 0,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_enableMonteCarlo) ...[
                Flexible(
                  child: _legendDot('Your Plan', const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _legendDot(
                    '90th Percentile',
                    FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _legendDot(
                    '10th Percentile',
                    Colors.red.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _legendDot('50th Percentile', const Color(0xFFF59E0B)),
                ),
              ] else ...[
                _legendDot('Taxable', const Color(0xFF6B7280)),
                const SizedBox(width: 16),
                _legendDot('Tax-Deferred', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _legendDot('Roth', const Color(0xFFF59E0B)),
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
      case LifeEventType.home:
        return Colors.orange;
      case LifeEventType.marriage:
        return Colors.pink;
      case LifeEventType.children:
        return Colors.purple;
      case LifeEventType.retirement:
        return Colors.green;
      case LifeEventType.education:
        return Colors.indigo;
      case LifeEventType.business:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return Icons.work;
      case LifeEventType.home:
        return Icons.home;
      case LifeEventType.marriage:
        return Icons.favorite;
      case LifeEventType.children:
        return Icons.child_care;
      case LifeEventType.retirement:
        return Icons.beach_access;
      case LifeEventType.education:
        return Icons.school;
      case LifeEventType.business:
        return Icons.rocket_launch;
      default:
        return Icons.event;
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
