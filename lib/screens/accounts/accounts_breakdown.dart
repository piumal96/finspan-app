import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccountsBreakdownScreen extends StatelessWidget {
  final OnboardingData? data;
  const AccountsBreakdownScreen({super.key, this.data});

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$ ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final d = data ?? OnboardingData();
    final double totalAssets = d.totalSavings;
    final double totalDebt =
        d.studentLoanBalance + d.carLoanBalance + d.creditCardBalance;
    final double netWorth = totalAssets - totalDebt;

    // Chart Data
    final double taxable =
        d.taxableSavings + (d.includePartner ? d.spouseTaxableSavings : 0);
    final double taxDeferred =
        d.taxDeferredSavings +
        (d.includePartner ? d.spouseTaxDeferredSavings : 0);
    final double taxFree =
        d.taxFreeSavings + (d.includePartner ? d.spouseTaxFreeSavings : 0);

    final List<_AssetData> chartData = [
      if (taxable > 0)
        _AssetData(
          'Taxable',
          taxable,
          FinSpanTheme.primaryGreen,
          '${((taxable / totalAssets) * 100).toStringAsFixed(0)}%',
        ),
      if (taxDeferred > 0)
        _AssetData(
          'Tax-Deferred',
          taxDeferred,
          FinSpanTheme.primaryGreenDark,
          '${((taxDeferred / totalAssets) * 100).toStringAsFixed(0)}%',
        ),
      if (taxFree > 0)
        _AssetData(
          'Tax-Free',
          taxFree,
          FinSpanTheme.charcoal,
          '${((taxFree / totalAssets) * 100).toStringAsFixed(0)}%',
        ),
    ];

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Net Worth Header
              Text(
                'Portfolio Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 16),

              FinSpanCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Net Worth',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _formatCurrency(netWorth),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: FinSpanTheme.primaryGreen,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: FinSpanTheme.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.trendingUp,
                            color: FinSpanTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          context,
                          'Total Assets',
                          _formatCurrency(totalAssets),
                        ),
                        _buildSummaryItem(
                          context,
                          'Total Debt',
                          _formatCurrency(totalDebt),
                          isNegative: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Asset Allocation Chart
              FinSpanCard(
                child: Column(
                  children: [
                    Text(
                      'Tax Bucket Allocation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries<_AssetData, String>>[
                          DoughnutSeries<_AssetData, String>(
                            dataSource: chartData,
                            xValueMapper: (_AssetData d, _) => d.x,
                            yValueMapper: (_AssetData d, _) => d.y,
                            pointColorMapper: (_AssetData d, _) => d.color,
                            dataLabelMapper: (_AssetData d, _) => d.label,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.inside,
                              textStyle: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            innerRadius: '70%',
                            radius: '100%',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Sections
              _buildSectionTitle(context, 'Personal Accounts'),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (d.taxableSavings > 0)
                      _buildAccountRow(
                        context,
                        'Taxable Brokerage',
                        _formatCurrency(d.taxableSavings),
                        'Standard Investing',
                        LucideIcons.wallet,
                      ),
                    if (d.taxableSavings > 0 &&
                        (d.taxDeferredSavings > 0 || d.taxFreeSavings > 0))
                      const Divider(height: 1),
                    if (d.taxDeferredSavings > 0)
                      _buildAccountRow(
                        context,
                        'Registered / Pre-Tax',
                        _formatCurrency(d.taxDeferredSavings),
                        'Tax-Deferred Savings',
                        LucideIcons.piggyBank,
                      ),
                    if (d.taxDeferredSavings > 0 && d.taxFreeSavings > 0)
                      const Divider(height: 1),
                    if (d.taxFreeSavings > 0)
                      _buildAccountRow(
                        context,
                        'Tax-Free / Roth',
                        _formatCurrency(d.taxFreeSavings),
                        'No tax on gains',
                        LucideIcons.star,
                      ),
                    if (d.taxableSavings == 0 &&
                        d.taxDeferredSavings == 0 &&
                        d.taxFreeSavings == 0)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No accounts configured yet.'),
                      ),
                  ],
                ),
              ),

              if (d.includePartner) ...[
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Partner Accounts'),
                const SizedBox(height: 8),
                FinSpanCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildAccountRow(
                        context,
                        'Partner Savings',
                        _formatCurrency(
                          d.spouseTaxableSavings +
                              d.spouseTaxDeferredSavings +
                              d.spouseTaxFreeSavings,
                        ),
                        'Spouse Balance',
                        Icons.people_outline,
                      ),
                    ],
                  ),
                ),
              ],

              if (totalDebt > 0) ...[
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Liabilities & Debts'),
                const SizedBox(height: 8),
                FinSpanCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      if (d.studentLoanBalance > 0)
                        _buildAccountRow(
                          context,
                          'Student Loan',
                          _formatCurrency(d.studentLoanBalance),
                          'Education Debt',
                          Icons.school_outlined,
                          isDebt: true,
                        ),
                      if (d.studentLoanBalance > 0 &&
                          (d.carLoanBalance > 0 || d.creditCardBalance > 0))
                        const Divider(height: 1),
                      if (d.carLoanBalance > 0)
                        _buildAccountRow(
                          context,
                          'Auto Loan',
                          _formatCurrency(d.carLoanBalance),
                          'Vehicle Financing',
                          Icons.directions_car_outlined,
                          isDebt: true,
                        ),
                      if (d.carLoanBalance > 0 && d.creditCardBalance > 0)
                        const Divider(height: 1),
                      if (d.creditCardBalance > 0)
                        _buildAccountRow(
                          context,
                          'Credit Cards',
                          _formatCurrency(d.creditCardBalance),
                          'Consumer Debt',
                          LucideIcons.creditCard,
                          isDebt: true,
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value, {
    bool isNegative = false,
  }) {
    return Column(
      crossAxisAlignment: isNegative
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red[400] : FinSpanTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: FinSpanTheme.bodyGray,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    String name,
    String balance,
    String subtitle,
    IconData icon, {
    bool isDebt = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDebt
              ? Colors.red.withValues(alpha: 0.05)
              : FinSpanTheme.primaryGreen.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDebt ? Colors.red[300] : FinSpanTheme.primaryGreen,
        ),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: FinSpanTheme.charcoal,
        ),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(
        balance,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDebt ? Colors.red[400] : FinSpanTheme.charcoal,
        ),
      ),
    );
  }
}

class _AssetData {
  _AssetData(this.x, this.y, this.color, this.label);
  final String x;
  final double y;
  final Color color;
  final String label;
}
