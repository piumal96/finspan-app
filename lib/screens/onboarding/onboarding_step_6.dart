import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import '../dashboard/main_dashboard.dart';

class OnboardingStep6Screen extends StatefulWidget {
  const OnboardingStep6Screen({super.key});

  @override
  State<OnboardingStep6Screen> createState() => _OnboardingStep6ScreenState();
}

class _OnboardingStep6ScreenState extends State<OnboardingStep6Screen> {
  // Expansion states
  final Map<String, bool> _expansionStates = {
    'Debts': false,
    'Housing': false,
    'Medical': false,
    'Business': false,
    'Kids': false,
    'Social': false,
    'Pension': false,
    'Life': false,
    'Legacy': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FinSpanTheme.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your Future Factors",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FinSpanTheme.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToDashboard(),
            child: const Text(
              "Skip",
              style: TextStyle(
                color: FinSpanTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              const FinSpanProgressBar(
                totalSteps: 6,
                currentStep: 6,
                showHeader: false,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Your Future Factors",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 28,
                              height: 1.2,
                              color: FinSpanTheme.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Customize your projection by adding details that matter to your financial reality.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FinSpanTheme.bodyGray,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sections
                      _buildExpandableSection(
                        title: "Debts & Liabilities",
                        icon: Icons.account_balance_outlined,
                        id: 'Debts',
                        content: Column(
                          children: [
                            _buildSubHeader("Student Loans"),
                            _buildMiniInput("Total Balance", "\$ 0"),
                            _buildMiniInput("Monthly Payment", "\$ 0"),
                            _buildMiniInput("Interest Rate (%)", "0"),
                            const Divider(height: 32),
                            _buildSubHeader("Car Loans"),
                            _buildMiniInput("Total Balance", "\$ 0"),
                            _buildMiniInput("Monthly Payment", "\$ 0"),
                            _buildMiniInput("Years Remaining", "0"),
                            const Divider(height: 32),
                            _buildSubHeader("Credit Card Debt"),
                            _buildMiniInput("Total Balance", "\$ 0"),
                            _buildMiniInput("Monthly Payment", "\$ 0"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Housing & Real Estate",
                        icon: Icons.home_work_outlined,
                        id: 'Housing',
                        content: Column(
                          children: [
                            _buildHousingToggle(),
                            const SizedBox(height: 16),
                            _buildMiniInput("Monthly Rent", "\$ 2000"),
                            const Divider(height: 32),
                            _buildSubHeader("Rental Property Income"),
                            _buildMiniInput("Annual Rental Income", "\$ 0"),
                            _buildCaption(
                              "Net annual income from rental properties",
                            ),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Healthcare & Medical",
                        icon: Icons.medical_services_outlined,
                        id: 'Medical',
                        content: Column(
                          children: [
                            _buildMiniInput("Annual Medical Expenses", "\$ 0"),
                            _buildCaption(
                              "Out-of-pocket costs, premiums, prescriptions",
                            ),
                            const SizedBox(height: 16),
                            _buildMiniInput("Medical Inflation Rate (%)", "5"),
                            _buildCaption("Typically 5-7% annually"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Business Income",
                        icon: Icons.business_center_outlined,
                        id: 'Business',
                        content: Column(
                          children: [
                            _buildMiniInput("Annual Business Income", "\$ 0"),
                            _buildCaption("Net income from self-employment"),
                            const SizedBox(height: 16),
                            _buildMiniInput("Business Growth Rate (%)", "0"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Children & Education",
                        icon: Icons.school_outlined,
                        id: 'Kids',
                        content: Column(
                          children: [
                            _buildMiniInput("Number of Children", "0"),
                            _buildMiniInput(
                              "Monthly Spending Per Child",
                              "\$ 0",
                            ),
                            const SizedBox(height: 16),
                            _buildMiniInput(
                              "College Savings Goal (per child)",
                              "\$ 0",
                            ),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Social Security",
                        icon: Icons.security_outlined,
                        id: 'Social',
                        content: Column(
                          children: [
                            _buildMiniInput("Your Claiming Age", "67"),
                            _buildMiniInput("Your Annual Benefit", "\$ 2,500"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Pension & Passive Income",
                        icon: Icons.savings_outlined,
                        id: 'Pension',
                        content: Column(
                          children: [
                            _buildMiniInput("Annual Pension", "\$ 0"),
                            _buildMiniInput("Other Passive Income", "\$ 0"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Healthcare & Insurance",
                        icon: Icons.health_and_safety_outlined,
                        id: 'Life',
                        content: Column(
                          children: [
                            _buildLifeInsuranceToggle(),
                            const SizedBox(height: 16),
                            _buildMiniInput("Coverage Amount", "\$ 0"),
                          ],
                        ),
                      ),
                      _buildExpandableSection(
                        title: "Legacy Planning",
                        icon: Icons.favorite_border_outlined,
                        id: 'Legacy',
                        content: Column(
                          children: [
                            _buildMiniInput("Legacy Goal", "\$ 0"),
                            _buildCaption("Target amount to leave behind"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _navigateToDashboard(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Run Simulation'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _navigateToDashboard(),
                child: Text(
                  "Skip to Simulation",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: FinSpanTheme.bodyGray),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
      (route) => false,
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required String id,
    required Widget content,
  }) {
    bool isExpanded = _expansionStates[id] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? FinSpanTheme.primaryGreen
              : FinSpanTheme.dividerColor,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (val) =>
              setState(() => _expansionStates[id] = val),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: FinSpanTheme.primaryGreen, size: 22),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: FinSpanTheme.charcoal,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: FinSpanTheme.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInput(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: FinSpanTheme.bodyGray,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 36,
            decoration: BoxDecoration(
              color: FinSpanTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              initialValue: hint.replaceAll("\$ ", ""),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: hint.startsWith("\$") ? "\$ " : null,
                prefixStyle: const TextStyle(
                  color: FinSpanTheme.bodyGray,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: FinSpanTheme.bodyGray.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildHousingToggle() {
    return Row(
      children: [
        Expanded(child: _buildToggleOption("Rent", true)),
        const SizedBox(width: 12),
        Expanded(child: _buildToggleOption("Own", false)),
      ],
    );
  }

  Widget _buildLifeInsuranceToggle() {
    return Row(
      children: [
        Expanded(child: _buildToggleOption("None", true)),
        const SizedBox(width: 8),
        Expanded(child: _buildToggleOption("Term", false)),
        const SizedBox(width: 8),
        Expanded(child: _buildToggleOption("Whole", false)),
      ],
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? FinSpanTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? FinSpanTheme.primaryGreen
              : FinSpanTheme.dividerColor,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : FinSpanTheme.charcoal,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
