import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          margin: EdgeInsets.zero,
                          primaryXAxis: NumericAxis(
                            minimum: 40,
                            maximum: 90,
                            interval: 10,
                            majorGridLines: const MajorGridLines(width: 0),
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 150,
                            interval: 50,
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                            axisLabelFormatter:
                                (AxisLabelRenderDetails details) {
                                  return ChartAxisLabel(
                                    '${details.value.toInt()}M',
                                    null,
                                  );
                                },
                          ),
                          annotations: <CartesianChartAnnotation>[
                            CartesianChartAnnotation(
                              widget: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: FinSpanTheme.charcoal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Target Wealth',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: FinSpanTheme.charcoal,
                                  ),
                                ),
                              ),
                              coordinateUnit: CoordinateUnit.point,
                              x: 80,
                              y: 45,
                            ),
                          ],
                          series: <CartesianSeries<_ChartData, double>>[
                            SplineSeries<_ChartData, double>(
                              dataSource: [
                                _ChartData(40, 45),
                                _ChartData(50, 60),
                                _ChartData(
                                  _retireAge,
                                  100 + (_monthlySavings * 0.1),
                                ),
                                _ChartData(70, 110),
                                _ChartData(80, 70),
                                _ChartData(
                                  87,
                                  _postRetirementSpending > 250 ? -20 : 0,
                                ),
                                _ChartData(90, 0),
                              ],
                              xValueMapper: (_ChartData data, _) => data.x,
                              yValueMapper: (_ChartData data, _) => data.y,
                              color: FinSpanTheme.primaryGreen,
                              width: 3,
                            ),
                          ],
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
                                '\$${_monthlySavings.toInt()}K',
                              ),
                              _buildSlider(
                                'Post-Retirement Spending',
                                _postRetirementSpending,
                                50,
                                1000,
                                (val) => setState(
                                  () => _postRetirementSpending = val,
                                ),
                                '\$${_postRetirementSpending.toInt()}K',
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

class _ChartData {
  _ChartData(this.x, this.y);
  final double x;
  final double y;
}
