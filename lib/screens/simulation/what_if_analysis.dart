import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

class WhatIfAnalysisScreen extends StatefulWidget {
  const WhatIfAnalysisScreen({super.key});

  @override
  State<WhatIfAnalysisScreen> createState() => _WhatIfAnalysisScreenState();
}

class _WhatIfAnalysisScreenState extends State<WhatIfAnalysisScreen> {
  double _retireAge = 60;
  double _monthlySavings = 100;
  double _postRetirementSpending = 200;

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
          'What-If Analysis',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: FinSpanTheme.charcoal),
            onPressed: () {
              setState(() {
                _retireAge = 60;
                _monthlySavings = 100;
                _postRetirementSpending = 200;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Half: Chart
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: FinSpanCard(
                  child: Column(
                    children: [
                      Text(
                        'Median Age of Depletion: 87',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: FinSpanTheme.primaryGreen),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 50,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: FinSpanTheme.dividerColor,
                                  strokeWidth: 1,
                                );
                              },
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
                                    if (value % 10 == 0 &&
                                        value >= 40 &&
                                        value <= 90) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          '${value.toInt()}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 50,
                                  reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0)
                                      return const SizedBox.shrink();
                                    return Text(
                                      '${value.toInt()}M',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 40,
                            maxX: 90,
                            minY: 0,
                            maxY: 150,
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: 40,
                                  color: FinSpanTheme.charcoal.withValues(
                                    alpha: 0.5,
                                  ),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                  label: HorizontalLineLabel(
                                    show: true,
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(
                                      right: 5,
                                      bottom: 5,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: FinSpanTheme.charcoal,
                                    ),
                                    labelResolver: (line) => 'Target Wealth',
                                  ),
                                ),
                              ],
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                // Very basic simulated curve that reacts slightly to the sliders
                                spots: [
                                  const FlSpot(40, 45),
                                  const FlSpot(50, 60),
                                  FlSpot(
                                    _retireAge,
                                    100 + (_monthlySavings * 0.1),
                                  ),
                                  const FlSpot(70, 110),
                                  const FlSpot(80, 70),
                                  FlSpot(
                                    87,
                                    0 +
                                        (_postRetirementSpending > 250
                                            ? -20
                                            : 0),
                                  ), // Depletes faster with higher spending
                                  const FlSpot(90, 0),
                                ],
                                isCurved: true,
                                color: FinSpanTheme.primaryGreen,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Half: Control Panel
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FinSpanTheme.charcoal.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handlebar
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: FinSpanTheme.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Adjust Variables',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildSlider(
                                'Retirement Age',
                                _retireAge,
                                55,
                                75,
                                (val) => setState(() => _retireAge = val),
                                '${_retireAge.toInt()}',
                              ),
                              _buildSlider(
                                'Monthly Savings',
                                _monthlySavings,
                                0,
                                500,
                                (val) => setState(() => _monthlySavings = val),
                                'LKR ${_monthlySavings.toInt()}K',
                              ),
                              _buildSlider(
                                'Post-Retirement Spending',
                                _postRetirementSpending,
                                50,
                                1000,
                                (val) => setState(
                                  () => _postRetirementSpending = val,
                                ),
                                'LKR ${_postRetirementSpending.toInt()}K',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Recalculate Scenarios →'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String valueDisplay,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: FinSpanTheme.charcoal),
              ),
              Text(
                valueDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FinSpanTheme.primaryGreenDark,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: FinSpanTheme.primaryGreen,
            inactiveColor: FinSpanTheme.dividerColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
