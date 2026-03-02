import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';

import 'onboarding_data.dart';

class OnboardingStep6Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep6Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Your Future Factors",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
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
                          _buildMiniInput(
                            "Total Balance",
                            widget.data.studentLoanBalance.toInt().toString(),
                            (val) => widget.data.studentLoanBalance = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Monthly Payment",
                            widget.data.studentLoanMonthly.toInt().toString(),
                            (val) => widget.data.studentLoanMonthly = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Interest Rate (%)",
                            widget.data.studentLoanRate.toString(),
                            (val) => widget.data.studentLoanRate = val,
                          ),
                          const Divider(height: 32),
                          _buildSubHeader("Car Loans"),
                          _buildMiniInput(
                            "Total Balance",
                            widget.data.carLoanBalance.toInt().toString(),
                            (val) => widget.data.carLoanBalance = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Monthly Payment",
                            widget.data.carLoanMonthly.toInt().toString(),
                            (val) => widget.data.carLoanMonthly = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Years Remaining",
                            widget.data.carLoanYears.toString(),
                            (val) => widget.data.carLoanYears = val
                                .toInt()
                                .toDouble(),
                          ),
                          const Divider(height: 32),
                          _buildSubHeader("Credit Card Debt"),
                          _buildMiniInput(
                            "Total Balance",
                            widget.data.creditCardBalance.toInt().toString(),
                            (val) => widget.data.creditCardBalance = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Monthly Payment",
                            widget.data.creditCardMonthly.toInt().toString(),
                            (val) => widget.data.creditCardMonthly = val,
                            isCurrency: true,
                          ),
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
                          if (widget.data.housingStatus == "Rent")
                            _buildMiniInput(
                              "Monthly Rent",
                              widget.data.monthlyRent.toInt().toString(),
                              (val) => widget.data.monthlyRent = val,
                              isCurrency: true,
                            )
                          else
                            _buildMiniInput(
                              "Monthly Mortgage",
                              widget.data.monthlyMortgage.toInt().toString(),
                              (val) => widget.data.monthlyMortgage = val,
                              isCurrency: true,
                            ),
                          const Divider(height: 32),
                          _buildSubHeader("Rental Property Income"),
                          _buildMiniInput(
                            "Annual Rental Income",
                            widget.data.rentalIncome.toInt().toString(),
                            (val) => widget.data.rentalIncome = val,
                            isCurrency: true,
                          ),
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
                          _buildMiniInput(
                            "Annual Medical Expenses",
                            widget.data.medicalExpenses.toInt().toString(),
                            (val) => widget.data.medicalExpenses = val,
                            isCurrency: true,
                          ),
                          _buildCaption(
                            "Out-of-pocket costs, premiums, prescriptions",
                          ),
                          const SizedBox(height: 16),
                          _buildMiniInput(
                            "Medical Inflation Rate (%)",
                            widget.data.medicalInflation.toString(),
                            (val) => widget.data.medicalInflation = val,
                          ),
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
                          _buildMiniInput(
                            "Annual Business Income",
                            widget.data.businessIncome.toInt().toString(),
                            (val) => widget.data.businessIncome = val,
                            isCurrency: true,
                          ),
                          _buildCaption("Net income from self-employment"),
                          const SizedBox(height: 16),
                          _buildMiniInput(
                            "Business Growth Rate (%)",
                            widget.data.businessGrowth.toString(),
                            (val) => widget.data.businessGrowth = val,
                          ),
                        ],
                      ),
                    ),
                    _buildExpandableSection(
                      title: "Children & Education",
                      icon: Icons.school_outlined,
                      id: 'Kids',
                      content: Column(
                        children: [
                          _buildMiniInput(
                            "Number of Children",
                            widget.data.numChildren.toString(),
                            (val) => widget.data.numChildren = val.toInt(),
                          ),
                          _buildMiniInput(
                            "Monthly Spending Per Child",
                            widget.data.childMonthlySpending.toInt().toString(),
                            (val) => widget.data.childMonthlySpending = val,
                            isCurrency: true,
                          ),
                          const SizedBox(height: 16),
                          _buildMiniInput(
                            "College Savings Goal (per child)",
                            widget.data.collegeGoal.toInt().toString(),
                            (val) => widget.data.collegeGoal = val,
                            isCurrency: true,
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
                          _buildMiniInput(
                            "Your Claiming Age",
                            widget.data.socialSecurityAge.toString(),
                            (val) =>
                                widget.data.socialSecurityAge = val.toInt(),
                          ),
                          _buildMiniInput(
                            "Your Annual Benefit",
                            widget.data.socialSecurityBenefit
                                .toInt()
                                .toString(),
                            (val) => widget.data.socialSecurityBenefit = val,
                            isCurrency: true,
                          ),
                        ],
                      ),
                    ),
                    _buildExpandableSection(
                      title: "Pension & Passive Income",
                      icon: Icons.savings_outlined,
                      id: 'Pension',
                      content: Column(
                        children: [
                          _buildMiniInput(
                            "Annual Pension",
                            widget.data.pensionIncome.toInt().toString(),
                            (val) => widget.data.pensionIncome = val,
                            isCurrency: true,
                          ),
                          _buildMiniInput(
                            "Other Passive Income",
                            widget.data.otherPassiveIncome.toInt().toString(),
                            (val) => widget.data.otherPassiveIncome = val,
                            isCurrency: true,
                          ),
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
                          _buildMiniInput(
                            "Coverage Amount",
                            widget.data.insuranceCoverage.toInt().toString(),
                            (val) => widget.data.insuranceCoverage = val,
                            isCurrency: true,
                          ),
                        ],
                      ),
                    ),
                    _buildExpandableSection(
                      title: "Legacy Planning",
                      icon: Icons.favorite_border_outlined,
                      id: 'Legacy',
                      content: Column(
                        children: [
                          _buildMiniInput(
                            "Legacy Goal",
                            widget.data.legacyGoal.toInt().toString(),
                            (val) => widget.data.legacyGoal = val,
                            isCurrency: true,
                          ),
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
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('Run Simulation'),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildMiniInput(
    String label,
    String value,
    Function(double) onChanged, {
    bool isCurrency = false,
  }) {
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
              initialValue: value,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final dVal = double.tryParse(val.replaceAll(',', '')) ?? 0;
                onChanged(dVal);
              },
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: isCurrency ? "\$ " : null,
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
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => widget.data.housingStatus = "Rent"),
            child: _buildToggleOption(
              "Rent",
              widget.data.housingStatus == "Rent",
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => widget.data.housingStatus = "Own"),
            child: _buildToggleOption(
              "Own",
              widget.data.housingStatus == "Own",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifeInsuranceToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => widget.data.insuranceType = "none"),
            child: _buildToggleOption(
              "None",
              widget.data.insuranceType == "none",
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => widget.data.insuranceType = "term"),
            child: _buildToggleOption(
              "Term",
              widget.data.insuranceType == "term",
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => widget.data.insuranceType = "whole"),
            child: _buildToggleOption(
              "Whole",
              widget.data.insuranceType == "whole",
            ),
          ),
        ),
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
