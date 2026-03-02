import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import '../../widgets/life_bar.dart';
import '../../services/simulation_service.dart';
import '../../models/simulation_models.dart';
import '../dashboard/main_dashboard.dart';

class DetailedResultsScreen extends StatefulWidget {
  final OnboardingData data;
  const DetailedResultsScreen({super.key, required this.data});

  @override
  State<DetailedResultsScreen> createState() => _DetailedResultsScreenState();
}

class _DetailedResultsScreenState extends State<DetailedResultsScreen> {
  late SimulationResult _result;
  final SimulationService _simService = SimulationService();
  late List<LifeEvent> _displayEvents;
  late int _currentAge;
  bool _isCalculated = false;

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

  void _runSimulation() {
    setState(() {
      // Create a temporary data object with updated current age and events for simulation
      final tempData = widget.data.copyWith(
        currentAge: _currentAge,
        lifeEvents: _displayEvents,
      );
      _result = _simService.runSimulation(tempData);
      _isCalculated = true;
    });
  }

  void _onAgeChange(int newAge) {
    if (newAge != _currentAge) {
      setState(() {
        _currentAge = newAge;
      });
      _runSimulation();
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
      _runSimulation();
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
    for (var year in _result.years) {
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
              const SizedBox(height: 24),
              _buildKeyTakeaways(context),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWealthChart(BuildContext context, double dynamicMaxY) {
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
              const Icon(
                Icons.info_outline,
                size: 16,
                color: FinSpanTheme.bodyGray,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        FinSpanTheme.charcoal.withValues(alpha: 0.9),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'Age ${spot.x.toInt()}\nLKR ${(spot.y / 1000000).toStringAsFixed(2)}M',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: dynamicMaxY / 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: FinSpanTheme.dividerColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        if (value >= 1000000)
                          return Text(
                            '${(value / 1000000).toInt()}M',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: _currentAge.toDouble(),
                maxX: widget.data.lifeExpectancy.toDouble(),
                minY: 0,
                maxY: dynamicMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: _result.years
                        .map((y) => FlSpot(y.age.toDouble(), y.total))
                        .toList(),
                    isCurved: true,
                    color: FinSpanTheme.primaryGreen,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeaways(BuildContext context) {
    return FinSpanCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _result.shortfallAge == null
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: _result.shortfallAge == null
                  ? FinSpanTheme.primaryGreen
                  : Colors.orangeAccent,
            ),
            title: const Text('Projected Shortfall Age'),
            trailing: Text(
              _result.shortfallAge == null
                  ? 'None'
                  : 'Age ${_result.shortfallAge}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Ending Wealth'),
            trailing: Text(
              'LKR ${(_result.endingWealth / 1000000).toStringAsFixed(1)}M',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Peak Wealth'),
            trailing: Text(
              'LKR ${(_result.years.map((y) => y.total).reduce((a, b) => a > b ? a : b) / 1000000).toStringAsFixed(1)}M',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
