import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

class DetailedResultsScreen extends StatelessWidget {
  const DetailedResultsScreen({super.key});

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
          'Simulation Results',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: FinSpanTheme.charcoal,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Gauge Card
              FinSpanCard(
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 70,
                              startDegreeOffset: 270,
                              sections: [
                                PieChartSectionData(
                                  color: FinSpanTheme.primaryGreen,
                                  value: 92,
                                  title: '',
                                  radius: 16,
                                ),
                                PieChartSectionData(
                                  color: FinSpanTheme.dividerColor,
                                  value: 8,
                                  title: '',
                                  radius: 12,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '92%',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: FinSpanTheme.primaryGreen,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'High Probability of Success',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on 10,000 market simulations',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chart Card
              FinSpanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected Wealth Trajectory',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
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
                          minX: 35,
                          maxX: 90,
                          minY: 0,
                          maxY: 150,
                          lineBarsData: [
                            // 90th percentile bounds (top)
                            LineChartBarData(
                              spots: const [
                                FlSpot(35, 45),
                                FlSpot(45, 60),
                                FlSpot(55, 90),
                                FlSpot(65, 120),
                                FlSpot(75, 140),
                                FlSpot(85, 130),
                                FlSpot(90, 120),
                              ],
                              isCurved: true,
                              color: FinSpanTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              barWidth: 0,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: FinSpanTheme.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            // Median line
                            LineChartBarData(
                              spots: const [
                                FlSpot(35, 45),
                                FlSpot(45, 55),
                                FlSpot(55, 75),
                                FlSpot(65, 100),
                                FlSpot(75, 120),
                                FlSpot(85, 100),
                                FlSpot(90, 85),
                              ],
                              isCurved: true,
                              color: FinSpanTheme.primaryGreen,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                            // 10th percentile bounds (bottom mask) - simple visual trick
                            LineChartBarData(
                              spots: const [
                                FlSpot(35, 45),
                                FlSpot(45, 50),
                                FlSpot(55, 60),
                                FlSpot(65, 75),
                                FlSpot(75, 80),
                                FlSpot(85, 40),
                                FlSpot(90, 15),
                              ],
                              isCurved: true,
                              color: FinSpanTheme.white,
                              barWidth: 0,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: FinSpanTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Key Takeaways
              FinSpanCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Key Takeaways',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: FinSpanTheme.primaryGreen,
                      ),
                      title: Text(
                        'Projected Shortfall Age',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Text(
                        'None',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FinSpanTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    ListTile(
                      leading: const Icon(
                        Icons.account_balance,
                        color: FinSpanTheme.bodyGray,
                      ),
                      title: Text(
                        'Median Ending Wealth',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Text(
                        'LKR 120M',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                      ),
                      title: Text(
                        'Worst Case (10th %ile)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Text(
                        'LKR 15M',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to dashboard conceptually
                  },
                  child: const Text('Save Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
