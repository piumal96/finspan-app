import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';

import 'onboarding_data.dart';

class OnboardingStep4Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep4Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

  @override
  State<OnboardingStep4Screen> createState() => _OnboardingStep4ScreenState();
}

class _OnboardingStep4ScreenState extends State<OnboardingStep4Screen> {
  late TextEditingController _salaryController;
  late TextEditingController _spouseSalaryController;
  late TextEditingController _spendingController;
  late TextEditingController _inflationController;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController(
      text: widget.data.currentSalary.toInt().toString(),
    );
    _spouseSalaryController = TextEditingController(
      text: widget.data.spouseSalary.toInt().toString(),
    );
    _spendingController = TextEditingController(
      text: widget.data.currentExpenses.toInt().toString(),
    );
    _inflationController = TextEditingController(
      text: widget.data.generalInflation.toString(),
    );

    _salaryController.addListener(_onIncomeChanged);
    _spouseSalaryController.addListener(_onIncomeChanged);
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _spouseSalaryController.dispose();
    _spendingController.dispose();
    _inflationController.dispose();
    super.dispose();
  }

  void _onIncomeChanged() {
    final salary =
        double.tryParse(_salaryController.text.replaceAll(',', '')) ?? 0;
    final spouseSalary =
        double.tryParse(_spouseSalaryController.text.replaceAll(',', '')) ?? 0;
    widget.data.currentSalary = salary;
    widget.data.spouseSalary = spouseSalary;

    // Web Auto-calc: 75% of total household income
    final totalIncome = salary + spouseSalary;
    final recommendedSpending = totalIncome * 0.75;

    setState(() {
      _spendingController.text = recommendedSpending.toInt().toString();
      widget.data.currentExpenses = recommendedSpending;

      // Basic Tax Recommendation Logic (Mocking web logic)
      if (totalIncome > 400000)
        widget.data.taxTargetBracket = "35%";
      else if (totalIncome > 200000)
        widget.data.taxTargetBracket = "24%";
      else if (totalIncome > 100000)
        widget.data.taxTargetBracket = "22%";
      else
        widget.data.taxTargetBracket = "12%";
    });
  }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Employment & Income",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 28,
                              color: FinSpanTheme.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      Icons.work_outline_rounded,
                      "Your Employment",
                    ),
                    _buildInputBox(
                      controller: _salaryController,
                      prefix: "\$ ",
                      hint: "100,000",
                      label: "Annual Salary",
                    ),
                    const SizedBox(height: 16),
                    _buildAgeSlider(
                      "Your Work Until Age",
                      widget.data.retirementAge.toDouble(),
                      (val) => setState(
                        () => widget.data.retirementAge = val.toInt(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.data.includePartner) ...[
                      _buildInputBox(
                        controller: _spouseSalaryController,
                        prefix: "\$ ",
                        hint: "80,000",
                        label: "Spouse Annual Salary",
                      ),
                      const SizedBox(height: 16),
                      _buildAgeSlider(
                        "Spouse Work Until Age",
                        (widget.data.spouseRetirementAge ??
                                widget.data.retirementAge)
                            .toDouble(),
                        (val) => setState(
                          () => widget.data.spouseRetirementAge = val.toInt(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      Icons.shopping_bag_outlined,
                      "Spending Goals",
                    ),
                    _buildInputBox(
                      controller: _spendingController,
                      prefix: "\$ ",
                      hint: "75,000",
                      label: "Annual Spending Goal",
                    ),
                    const SizedBox(height: 16),
                    _buildInputBox(
                      controller: _inflationController,
                      suffix: " %",
                      hint: "2.5",
                      label: "Expected Inflation Rate",
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      Icons.percent_rounded,
                      "Tax Strategy",
                      trailing: widget.data.taxTargetBracket,
                    ),
                    _buildTaxBracketSelector(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4),
                      child: Text(
                        "Auto-calculated based on your income and spending. Current bracket: ${widget.data.taxTargetBracket}",
                        style: TextStyle(
                          fontSize: 11,
                          color: FinSpanTheme.bodyGray,
                          fontStyle: FontStyle.italic,
                        ),
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
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {String? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: FinSpanTheme.primaryGreen),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Target : $trailing",
              style: const TextStyle(
                fontSize: 10,
                color: FinSpanTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    required String hint,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinSpanTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (prefix != null)
                Text(
                  prefix,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinSpanTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
              ),
              Text(
                "Age ${value.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 50,
            max: 85,
            activeColor: FinSpanTheme.primaryGreen,
            inactiveColor: FinSpanTheme.dividerColor,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Retire at age ${value.toInt()}",
                style: TextStyle(fontSize: 10, color: FinSpanTheme.bodyGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBracketSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ["10%", "12%", "22%", "24%", "32%", "35%", "37%"].map((rate) {
          bool isSelected = widget.data.taxTargetBracket == rate;
          return GestureDetector(
            onTap: () => setState(() => widget.data.taxTargetBracket = rate),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? FinSpanTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: FinSpanTheme.dividerColor),
              ),
              child: Center(
                child: Text(
                  rate,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
