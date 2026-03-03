import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import '../../widgets/life_bar.dart';
import '../../services/simulation_service.dart';
import '../../models/simulation_models.dart';
import '../dashboard/main_dashboard.dart';

class DetailedResultsScreen extends StatefulWidget {
  final OnboardingData data;
  final bool isTab;
  final VoidCallback? onRunNew;

  const DetailedResultsScreen({
    super.key,
    required this.data,
    this.isTab = false,
    this.onRunNew,
  });

  @override
  State<DetailedResultsScreen> createState() => _DetailedResultsScreenState();
}

class _DetailedResultsScreenState extends State<DetailedResultsScreen> {
  SimulationResult? _result;
  final SimulationService _simService = SimulationService();
  late List<LifeEvent> _displayEvents;
  late int _currentAge;
  bool _isCalculated = false;
  bool _showLifeEvents = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentAge = widget.data.currentAge;
    _displayEvents = List.from(widget.data.lifeEvents);
    if (_displayEvents.isEmpty) {
      _displayEvents.addAll([
        LifeEvent(
          id: '1',
          type: LifeEventType.job,
          name: 'Current Job',
          startAge: _currentAge,
        ),
        LifeEvent(
          id: '2',
          type: LifeEventType.home,
          name: 'Buy Home',
          startAge: _currentAge + 5,
        ),
        LifeEvent(
          id: '4',
          type: LifeEventType.retirement,
          name: 'Retirement',
          startAge: widget.data.retirementAge,
        ),
      ]);
    }
    _runSimulation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _runSimulation() async {
    setState(() => _isCalculated = false);

    final params = RetirementSimulationParams(
      p1StartAge: _currentAge,
      p2StartAge: widget.data.includePartner
          ? (widget.data.spouseAge ?? widget.data.currentAge)
          : widget.data.currentAge, // Backend needs non-zero age
      endSimulationAge: widget.data.lifeExpectancy,
      inflationRate: widget.data.generalInflation / 100,
      annualSpendGoal: widget.data.annualSpendingGoal,
      filingStatus: widget.data.taxFilingStatus == 'single' ? 'Single' : 'MFJ',
      p1EmploymentIncome: widget.data.annualSalary,
      p1EmploymentUntilAge: widget.data.retirementAge,
      p2EmploymentIncome: widget.data.includePartner
          ? widget.data.spouseSalary
          : 0,
      p2EmploymentUntilAge: widget.data.includePartner
          ? (widget.data.spouseRetirementAge ?? widget.data.retirementAge)
          : widget.data.retirementAge, // Match web app logic
      p1SsAmount: widget.data.socialSecurityBenefit, // Monthly, no *12
      p1SsStartAge: widget.data.socialSecurityAge,
      p2SsAmount: widget.data.includePartner
          ? widget
                .data
                .spouseSocialSecurityBenefit // Monthly, no *12
          : 0,
      p2SsStartAge: widget.data.includePartner
          ? widget.data.spouseSocialSecurityAge
          : 67, // Default from web app
      p1Pension: widget.data.pensionIncome,
      p1PensionStartAge: 65, // Web app default
      p2Pension: 0,
      p2PensionStartAge: 65,
      balTaxable:
          widget.data.taxableSavings +
          (widget.data.includePartner ? widget.data.spouseTaxableSavings : 0),
      balPretaxP1: widget.data.taxDeferredSavings,
      balPretaxP2: widget.data.includePartner
          ? widget.data.spouseTaxDeferredSavings
          : 0,
      balRothP1: widget.data.taxFreeSavings,
      balRothP2: widget.data.includePartner
          ? widget.data.spouseTaxFreeSavings
          : 0,
      growthRateTaxable: widget.data.expectedReturn / 100,
      growthRatePretaxP1: widget.data.expectedReturn / 100,
      growthRatePretaxP2: widget.data.expectedReturn / 100,
      growthRateRothP1: widget.data.expectedReturn / 100,
      growthRateRothP2: widget.data.expectedReturn / 100,
      taxableBasisRatio: 0.8, // Match web app
      targetTaxBracketRate:
          (double.tryParse(widget.data.taxTargetBracket.replaceAll('%', '')) ??
              22.0) /
          100,
      rental1Income: widget.data.rentalIncome, // Monthly, match web app
    );

    try {
      final result = await _simService.runSimulation(params);

      if (mounted) {
        setState(() {
          if (result != null) {
            _result = result;
          }
          _isCalculated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Simulation Error: $e')));
        setState(
          () => _isCalculated = true,
        ); // Allow showing last result or empty state
      }
    }
  }

  void _onAgeChange(int newAge) {
    if (newAge != _currentAge) {
      setState(() => _currentAge = newAge);
      // Debounce: only actually call the API 600ms after the user stops dragging
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), _runSimulation);
    }
  }

  void _onEventMove(String id, int newAge) {
    final index = _displayEvents.indexWhere((e) => e.id == id);
    if (index != -1 && _displayEvents[index].startAge != newAge) {
      setState(() {
        final oldEvent = _displayEvents[index];
        _displayEvents[index] = LifeEvent(
          id: oldEvent.id,
          type: oldEvent.type,
          name: oldEvent.name,
          startAge: newAge,
          endAge: oldEvent.endAge != null
              ? (newAge + (oldEvent.endAge! - oldEvent.startAge))
              : null,
          params: oldEvent.params,
        );
      });
      // Debounce: only call API 600ms after user stops dragging the event
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), _runSimulation);
    }
  }

  void _onAddEvent(int age) {
    _showEventDialog(age);
  }

  void _onEventTap(LifeEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${event.name}'),
        content: Text(
          'Would you like to remove this event or edit its duration?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _displayEvents.removeWhere((e) => e.id == event.id);
              });
              _runSimulation();
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(int age) {
    String name = '';
    LifeEventType selectedType = LifeEventType.job;
    int duration = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Event at Age $age'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g. New Car, Wedding',
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              DropdownButton<LifeEventType>(
                value: selectedType,
                isExpanded: true,
                items: LifeEventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Duration (Years)',
                  hintText: '0 for one-time event',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => duration = int.tryParse(val) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _displayEvents.add(
                      LifeEvent(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: selectedType,
                        name: name,
                        startAge: age,
                        endAge: duration > 0 ? (age + duration) : null,
                      ),
                    );
                  });
                  _runSimulation();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCalculated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double maxWealth = 0;
    final results = _result?.standardResults ?? [];
    for (var year in results) {
      if (year.total > maxWealth) maxWealth = year.total;
    }
    double dynamicMaxY = (maxWealth * 1.2)
        .clamp(1000000, 1000000000)
        .toDouble();

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: FinSpanTheme.charcoal),
        title: Text(
          'Detailed Results',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isCalculated)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_result == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to calculate your results.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your connection and try again.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _runSimulation,
                          child: const Text('Retry Calculation'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                _buildWealthChart(context, dynamicMaxY),
                const SizedBox(height: 24),
                FinSpanCard(
                  child: FinSpanLifeBar(
                    currentAge: _currentAge,
                    retirementAge: widget.data.retirementAge,
                    lifeExpectancy: widget.data.lifeExpectancy,
                    events: _displayEvents,
                    onAddEvent: _onAddEvent,
                    onEventTap: _onEventTap,
                    onEventMove: _onEventMove,
                    onAgeChange: _onAgeChange,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildKeyTakeaways(context),
              const SizedBox(height: 32),
              if (!widget.isTab)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _result == null
                        ? null
                        : () {
                            // Redirect to dashboard with results, clearing the stack
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainDashboardScreen(
                                  result: _result,
                                  data: widget.data.copyWith(
                                    lifeEvents: _displayEvents,
                                    currentAge: _currentAge,
                                  ),
                                  fromSim: true,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                    child: const Text('Return to Dashboard'),
                  ),
                ),
              if (widget.isTab && _result == null && _isCalculated)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onRunNew,
                    child: const Text('Run New Simulation'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWealthChart(BuildContext context, double dynamicMaxY) {
    List<PlotBand> plotBands = [];
    if (_showLifeEvents) {
      for (var event in _displayEvents) {
        Color bandColor;
        switch (event.type) {
          case LifeEventType.retirement:
            bandColor = Colors.purple.withValues(alpha: 0.2);
            break;
          case LifeEventType.rent:
          case LifeEventType.home:
            bandColor = Colors.blue.withValues(alpha: 0.2);
            break;
          default:
            bandColor = FinSpanTheme.primaryGreen.withValues(alpha: 0.1);
        }

        plotBands.add(
          PlotBand(
            isVisible: true,
            start: event.startAge,
            end: event.endAge ?? event.startAge + 1, // small band if no end age
            color: bandColor,
            text: event.name,
            textAngle: 270,
            textStyle: const TextStyle(
              color: FinSpanTheme.charcoal,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            horizontalTextAlignment: TextAnchor.start,
            verticalTextAlignment: TextAnchor.middle,
          ),
        );
      }
    }

    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wealth Trajectory',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Life Events Overlay',
                        style: TextStyle(
                          fontSize: 12,
                          color: _showLifeEvents
                              ? FinSpanTheme.primaryGreen
                              : FinSpanTheme.bodyGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_showLifeEvents)
                        Text(
                          '(${_displayEvents.length} events)',
                          style: const TextStyle(
                            fontSize: 10,
                            color: FinSpanTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  Switch(
                    value: _showLifeEvents,
                    onChanged: (val) => setState(() => _showLifeEvents = val),
                    activeThumbColor: FinSpanTheme.primaryGreen,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
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
                maximum: widget.data.lifeExpectancy.toDouble(),
                interval: 10,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                plotBands: [
                  ...plotBands,
                  // Current age cursor line – mirrors web WealthChart ReferenceLine
                  PlotBand(
                    isVisible: true,
                    start: _currentAge.toDouble(),
                    end: _currentAge.toDouble() + 0.5,
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.85),
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
                interval: dynamicMaxY / 5,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                numberFormat: null,
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  double val = details.value.toDouble();
                  if (val == 0) return ChartAxisLabel('\$0', null);
                  if (val >= 1000000) {
                    return ChartAxisLabel(
                      '\$${(val / 1000000).toStringAsFixed(1)}M',
                      null,
                    );
                  }
                  return ChartAxisLabel('\$${(val / 1000).toInt()}K', null);
                },
              ),
              series: <CartesianSeries>[
                StackedAreaSeries<WealthDataPoint, double>(
                  dataSource: _result?.standardResults ?? [],
                  xValueMapper: (WealthDataPoint data, _) =>
                      data.age.toDouble(),
                  yValueMapper: (WealthDataPoint data, _) => data.taxable,
                  color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                  name: 'Taxable',
                  animationDuration: 0, // no re-animation on rebuild
                ),
                StackedAreaSeries<WealthDataPoint, double>(
                  dataSource: _result?.standardResults ?? [],
                  xValueMapper: (WealthDataPoint data, _) =>
                      data.age.toDouble(),
                  yValueMapper: (WealthDataPoint data, _) =>
                      data.preTaxP1 + data.preTaxP2,
                  color: const Color(0xFF10B981).withValues(alpha: 0.7),
                  name: 'Tax-Deferred',
                  animationDuration: 0,
                ),
                StackedAreaSeries<WealthDataPoint, double>(
                  dataSource: _result?.standardResults ?? [],
                  xValueMapper: (WealthDataPoint data, _) =>
                      data.age.toDouble(),
                  yValueMapper: (WealthDataPoint data, _) =>
                      data.rothP1 + data.rothP2,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                  name: 'Roth',
                  animationDuration: 0,
                ),
              ],
            ),
          ),
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
      ),
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

  Widget _buildKeyTakeaways(BuildContext context) {
    if (_result == null) return const SizedBox.shrink();
    return FinSpanCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _result!.shortfallAge == null
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: _result!.shortfallAge == null
                  ? FinSpanTheme.primaryGreen
                  : Colors.orangeAccent,
            ),
            title: const Text('Projected Shortfall Age'),
            trailing: Text(
              _result!.shortfallAge == null
                  ? 'None'
                  : 'Age ${_result!.shortfallAge}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Ending Wealth'),
            trailing: Text(
              'LKR ${(_result!.endingWealth / 1000000).toStringAsFixed(1)}M',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Peak Wealth'),
            trailing: Text(
              'LKR ${(_result!.standardResults.map((y) => y.total).reduce((a, b) => a > b ? a : b) / 1000000).toStringAsFixed(1)}M',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
