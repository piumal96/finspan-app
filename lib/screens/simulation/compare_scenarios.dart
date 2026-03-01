import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
                                      padding: const EdgeInsets.only(top: 8.0),
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
                          lineBarsData: [
                            // Current Plan (Gray)
                            LineChartBarData(
                              spots: const [
                                FlSpot(40, 45),
                                FlSpot(50, 60),
                                FlSpot(65, 90),
                                FlSpot(75, 110),
                                FlSpot(85, 80),
                                FlSpot(90, 40),
                              ],
                              isCurved: true,
                              color: FinSpanTheme.bodyGray.withValues(
                                alpha: 0.5,
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              dashArray: [5, 5],
                            ),
                            // Proposed Scenario (Green)
                            LineChartBarData(
                              spots: const [
                                FlSpot(40, 45),
                                FlSpot(50, 65),
                                FlSpot(65, 110),
                                FlSpot(75, 140),
                                FlSpot(85, 120),
                                FlSpot(90, 100),
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
