import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../../widgets/dashboard_alert_card.dart';
import '../simulation/simulation_runner.dart';
import '../accounts/accounts_breakdown.dart';
import '../onboarding/onboarding_data.dart';
import '../../models/simulation_models.dart';
import '../simulation/detailed_results.dart';

class MainDashboardScreen extends StatefulWidget {
  final SimulationResult? result;
  final OnboardingData? data;
  final bool fromSim;

  const MainDashboardScreen({
    super.key,
    this.result,
    this.data,
    this.fromSim = false,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  bool _showAlert = false;

  @override
  void initState() {
    super.initState();
    _showAlert = widget.fromSim && widget.result != null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate metrics from simulation or default
    final double currentWealth = widget.result?.years.first.total ?? 45200000;

    // 10 year projection
    double projected10Years = currentWealth * 1.5; // fallback
    if (widget.result != null && widget.result!.years.length > 10) {
      projected10Years = widget.result!.years[10].total;
    }

    final int retirementAge = widget.data?.retirementAge ?? 65;
    final int currentAge = widget.data?.currentAge ?? 35;
    final int yearsToRetirement = (retirementAge - currentAge).clamp(0, 50);

    final double annualContribution =
        (widget.data?.userFourOneKContrib ?? 0) +
        (widget.data?.userRothIRAContrib ?? 0) +
        (widget.data?.taxableSavings != null ? 150000 * 12 : 0);

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 12, bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'F',
                style: TextStyle(
                  color: FinSpanTheme.primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Hi, Welcome back 👋',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              backgroundColor: FinSpanTheme.dividerColor,
              child: const Icon(Icons.person, color: FinSpanTheme.bodyGray),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Redirection Alert (Mobile Match of Web Alert Card)
              if (_showAlert && widget.result != null) ...[
                DashboardAlertCard(
                  title: widget.result!.shortfallAge != null
                      ? "🎯 Optimization Needed"
                      : "✅ Great News!",
                  message: widget.result!.shortfallAge != null
                      ? "Your plan covers until age ${widget.result!.shortfallAge}. Let's optimize it for your target."
                      : "Your retirement plan is on track! Your savings should last through your target age.",
                  severity: widget.result!.shortfallAge != null
                      ? 'warning'
                      : 'success',
                  runwayAge: widget.result!.shortfallAge ?? 95,
                  targetAge: 95,
                  onAdjustPlan: () {
                    if (widget.data != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) =>
                              DetailedResultsScreen(data: widget.data!),
                        ),
                      );
                    }
                  },
                  onDismiss: () => setState(() => _showAlert = false),
                ),
                const SizedBox(height: 24),
              ],

              // 2. Main Stats Grid (Mobile Match of Web AnalyticsWidgetSummary)
              _buildStatsGrid(
                currentWealth,
                projected10Years,
                annualContribution,
                yearsToRetirement,
              ),

              const SizedBox(height: 24),

              // 3. Wealth Trajectory Preview
              _buildWealthPreview(),

              const SizedBox(height: 24),

              // 4. Portfolio Breakdown (New Piece from Web Dashboard)
              _buildPortfolioBreakdown(),

              const SizedBox(height: 24),

              // 5. Original Quick Action
              _buildSimulationBanner(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatsGrid(
    double current,
    double projected,
    double contribution,
    int years,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Current Savings',
                'LKR ${(current / 1000000).toStringAsFixed(1)}M',
                Icons.account_balance_wallet,
                FinSpanTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '10Y Projection',
                'LKR ${(projected / 1000000).toStringAsFixed(1)}M',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Annual Contrib.',
                'LKR ${(contribution / 1000).toStringAsFixed(0)}K',
                Icons.savings,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Years to Retire',
                '$years Years',
                Icons.event,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return FinSpanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FinSpanTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWealthPreview() {
    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wealth Trajectory',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  if (widget.data != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            DetailedResultsScreen(data: widget.data!),
                      ),
                    );
                  }
                },
                child: const Text('View Full', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: widget.result != null
                ? LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.result!.years
                              .map((y) => FlSpot(y.age.toDouble(), y.total))
                              .toList(),
                          isCurved: true,
                          color: FinSpanTheme.primaryGreen,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: FinSpanTheme.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      "Run simulation to see projection",
                      style: TextStyle(
                        fontSize: 12,
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioBreakdown() {
    return FinSpanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Allocation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: 45,
                        color: FinSpanTheme.primaryGreen,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        value: 35,
                        color: Colors.blue,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.orange,
                        title: '',
                        radius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildAllocationLegend(
                      'Dividend',
                      '45%',
                      FinSpanTheme.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildAllocationLegend('Growth', '35%', Colors.blue),
                    const SizedBox(height: 12),
                    _buildAllocationLegend(
                      'Fixed Income',
                      '20%',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationLegend(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: FinSpanTheme.bodyGray,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSimulationBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SimulationRunnerScreen(data: widget.data ?? OnboardingData()),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
          border: Border.all(
            color: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Simulation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Update your plan and see new results",
                    style: TextStyle(
                      fontSize: 12,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: FinSpanTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: FinSpanTheme.dividerColor, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountsBreakdownScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SimulationRunnerScreen(
                  data: widget.data ?? OnboardingData(),
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Simulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
