import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

class AccountsBreakdownScreen extends StatelessWidget {
  const AccountsBreakdownScreen({super.key});

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
          'Your Accounts',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: FinSpanTheme.primaryGreen),
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
              // Donut Chart Card
              FinSpanCard(
                child: Column(
                  children: [
                    Text(
                      'Asset Allocation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              sections: [
                                PieChartSectionData(
                                  color: FinSpanTheme.primaryGreen,
                                  value: 55,
                                  title: '55%',
                                  radius: 20,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: FinSpanTheme.primaryGreenDark,
                                  value: 30,
                                  title: '30%',
                                  radius: 20,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: FinSpanTheme.charcoal,
                                  value: 15,
                                  title: '15%',
                                  radius: 20,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Configured',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'LKR 45.2M',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegend(
                          context,
                          'Investments',
                          FinSpanTheme.primaryGreen,
                        ),
                        _buildLegend(
                          context,
                          'Cash',
                          FinSpanTheme.primaryGreenDark,
                        ),
                        _buildLegend(context, 'EPF/ETF', FinSpanTheme.charcoal),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Linked Accounts',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Cash Accounts
              Text(
                'Cash & Equivalents',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: FinSpanTheme.bodyGray),
              ),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildAccountRow(
                      context,
                      'Sampath Bank Checking',
                      'LKR 1,200,000',
                      '•••• 4521',
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildAccountRow(
                      context,
                      'Commercial Bank Savings',
                      'LKR 4,800,000',
                      '•••• 9932',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Investments
              Text(
                'Investments',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: FinSpanTheme.bodyGray),
              ),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildAccountRow(
                      context,
                      'NDB Wealth Growth Fund',
                      'LKR 18,000,000',
                      'Unit Trust',
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildAccountRow(
                      context,
                      'CSE Brokerage Acct',
                      'LKR 7,200,000',
                      'Direct Equity',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Retirement
              Text(
                'Retirement',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: FinSpanTheme.bodyGray),
              ),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildAccountRow(
                      context,
                      'Employees Provident Fund',
                      'LKR 12,000,000',
                      'EPF Baseline',
                    ),
                    const Divider(height: 1, color: FinSpanTheme.dividerColor),
                    _buildAccountRow(
                      context,
                      'Employees Trust Fund',
                      'LKR 2,000,000',
                      'ETF Baseline',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    String name,
    String balance,
    String subtitle,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: FinSpanTheme.charcoal,
        ),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(balance, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
