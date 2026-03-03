import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

class CompareScenariosScreen extends StatelessWidget {
  const CompareScenariosScreen({super.key});

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
          'Compare Scenarios',
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
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    context,
                    'Current Plan',
                    FinSpanTheme.bodyGray,
                  ),
                  const SizedBox(width: 24),
                  _buildLegendItem(
                    context,
                    'Proposed Scenario',
                    FinSpanTheme.primaryGreen,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dual Chart
              FinSpanCard(
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
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
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              '${details.value.toInt()}M',
                              null,
                            );
                          },
                        ),
                        series: <CartesianSeries<_ChartData, double>>[
                          // Current Plan (Gray)
                          SplineSeries<_ChartData, double>(
                            dataSource: const [
                              _ChartData(40, 45),
                              _ChartData(50, 60),
                              _ChartData(65, 90),
                              _ChartData(75, 110),
                              _ChartData(85, 80),
                              _ChartData(90, 40),
                            ],
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            color: FinSpanTheme.bodyGray.withOpacity(0.5),
                            width: 3,
                            dashArray: const <double>[5, 5],
                          ),
                          // Proposed Scenario (Green)
                          SplineSeries<_ChartData, double>(
                            dataSource: const [
                              _ChartData(40, 45),
                              _ChartData(50, 65),
                              _ChartData(65, 110),
                              _ChartData(75, 140),
                              _ChartData(85, 120),
                              _ChartData(90, 100),
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
              const SizedBox(height: 32),

              Text(
                'Metric Comparison',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Comparison Table
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildTableRow(
                      context,
                      'Metric',
                      'Current',
                      'Proposed',
                      isHeader: true,
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildTableRow(
                      context,
                      'Success Probability',
                      '82%',
                      '95%',
                      isPositive: true,
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildTableRow(
                      context,
                      'Median Ending Wealth',
                      'LKR 40M',
                      'LKR 100M',
                      isPositive: true,
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildTableRow(
                      context,
                      'Monthly Contribution',
                      'LKR 50K',
                      'LKR 120K',
                      isWarning: true,
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildTableRow(
                      context,
                      'Effective Retirement Age',
                      '65',
                      '60',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Adopt Proposed Scenario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    String label,
    String current,
    String proposed, {
    bool isHeader = false,
    bool isPositive = false,
    bool isWarning = false,
  }) {
    final textStyle = isHeader
        ? Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodySmall;

    Color proposedColor = FinSpanTheme.charcoal;
    if (isPositive) proposedColor = FinSpanTheme.primaryGreenDark;
    if (isWarning) proposedColor = Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: textStyle)),
          Expanded(
            flex: 1,
            child: Text(current, style: textStyle, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 1,
            child: Text(
              proposed,
              style: textStyle?.copyWith(
                color: isHeader ? FinSpanTheme.charcoal : proposedColor,
                fontWeight: isHeader || isPositive || isWarning
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  const _ChartData(this.x, this.y);
  final double x;
  final double y;
}
