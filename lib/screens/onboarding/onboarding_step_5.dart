import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';

import 'onboarding_data.dart';

class OnboardingStep5Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep5Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

  @override
  State<OnboardingStep5Screen> createState() => _OnboardingStep5ScreenState();
}

class _OnboardingStep5ScreenState extends State<OnboardingStep5Screen> {
  late TextEditingController _totalBalanceController;
  late TextEditingController _spouseTotalBalanceController;
  late TextEditingController _tradIRAController;
  late TextEditingController _rothIRAController;
  late TextEditingController _brokerageController;

  late TextEditingController _spouseTradIRAController;
  late TextEditingController _spouseRothIRAController;
  late TextEditingController _spouseBrokerageController;

  @override
  void initState() {
    super.initState();
    _totalBalanceController = TextEditingController(
      text:
          (widget.data.taxDeferredSavings +
                  widget.data.taxableSavings +
                  widget.data.taxFreeSavings)
              .toInt()
              .toString(),
    );
    _spouseTotalBalanceController = TextEditingController(
      text: widget.data.spouseTotalSavings.toInt().toString(),
    );
    _tradIRAController = TextEditingController(
      text: widget.data.taxDeferredSavings.toInt().toString(),
    );
    _rothIRAController = TextEditingController(
      text: widget.data.taxFreeSavings.toInt().toString(),
    );
    _brokerageController = TextEditingController(
      text: widget.data.taxableSavings.toInt().toString(),
    );

    _spouseTradIRAController = TextEditingController(
      text: widget.data.spouseTaxDeferredSavings.toInt().toString(),
    );
    _spouseRothIRAController = TextEditingController(
      text: widget.data.spouseTaxFreeSavings.toInt().toString(),
    );
    _spouseBrokerageController = TextEditingController(
      text: widget.data.spouseTaxableSavings.toInt().toString(),
    );

    // Listeners for simple mode
    _totalBalanceController.addListener(() {
      final total =
          double.tryParse(_totalBalanceController.text.replaceAll(',', '')) ??
          0;
      // Web logic: in simple mode, assume all is tax-deferred
      if (!widget.data.showDetailedBalances) {
        widget.data.taxDeferredSavings = total;
        widget.data.taxableSavings = 0;
        widget.data.taxFreeSavings = 0;
      }
    });

    _spouseTotalBalanceController.addListener(() {
      final total =
          double.tryParse(
            _spouseTotalBalanceController.text.replaceAll(',', ''),
          ) ??
          0;
      if (!widget.data.showDetailedBalances) {
        widget.data.spouseTaxDeferredSavings = total;
        widget.data.spouseTaxableSavings = 0;
        widget.data.spouseTaxFreeSavings = 0;
      }
    });
  }

  @override
  void dispose() {
    _totalBalanceController.dispose();
    _tradIRAController.dispose();
    _rothIRAController.dispose();
    _brokerageController.dispose();
    _spouseTradIRAController.dispose();
    _spouseRothIRAController.dispose();
    _spouseBrokerageController.dispose();
    super.dispose();
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
                  children: [
                    Text(
                      "Current Savings",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: FinSpanTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your current retirement account balances (Estimate is fine)",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Total Balances Section
                    _buildSectionLabel("Current Balances"),
                    const SizedBox(height: 12),
                    _buildInputBox(
                      controller: _totalBalanceController,
                      prefix: "\$ ",
                      hint: "230,000",
                      label: "Your Total Savings",
                      subLabel: "All your retirement accounts combined",
                    ),

                    if (widget.data.includePartner) ...[
                      const SizedBox(height: 16),
                      _buildInputBox(
                        controller: _spouseTotalBalanceController,
                        prefix: "\$ ",
                        hint: "0",
                        label: "Spouse Total Savings",
                        subLabel: "All spouse's retirement accounts combined",
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildToggleTile(
                      "I want to specify individual account balances (401k, Roth IRA, etc.)",
                      widget.data.showDetailedBalances,
                      (val) => setState(
                        () => widget.data.showDetailedBalances = val,
                      ),
                    ),

                    if (widget.data.showDetailedBalances) ...[
                      const SizedBox(height: 16),
                      _buildDetailedInput(
                        "401(k) / Traditional IRA",
                        _tradIRAController,
                        (val) => widget.data.taxDeferredSavings = val,
                      ),
                      _buildDetailedInput(
                        "Roth IRA / Roth 401(k)",
                        _rothIRAController,
                        (val) => widget.data.taxFreeSavings = val,
                      ),
                      _buildDetailedInput(
                        "Taxable/Brokerage Account",
                        _brokerageController,
                        (val) => widget.data.taxableSavings = val,
                      ),
                      if (widget.data.includePartner) ...[
                        const SizedBox(height: 24),
                        _buildSectionLabel("Spouse's Balances"),
                        const SizedBox(height: 12),
                        _buildDetailedInput(
                          "401(k) / Traditional IRA",
                          _spouseTradIRAController,
                          (val) => widget.data.spouseTaxDeferredSavings = val,
                        ),
                        _buildDetailedInput(
                          "Roth IRA / Roth 401(k)",
                          _spouseRothIRAController,
                          (val) => widget.data.spouseTaxFreeSavings = val,
                        ),
                        _buildDetailedInput(
                          "Taxable/Brokerage Account",
                          _spouseBrokerageController,
                          (val) => widget.data.spouseTaxableSavings = val,
                        ),
                      ],
                    ],

                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      Icons.trending_up,
                      "Annual 401(k) Contributions",
                      badge: "✨ NEW",
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Set your contribution rates. The system will automatically optimize Roth vs. Traditional based on your tax bracket.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSmartOptimizationCard(),
                    const SizedBox(height: 24),

                    // User Contributions
                    _buildPersonContributions(
                      title: "Your 401(k) Contributions",
                      salary: widget.data.currentSalary,
                      contribRate: widget.data.userContribRate,
                      matchRate: widget.data.userEmployerMatchRate,
                      contribType: widget.data.userContribType,
                      onContribRateChanged: (val) {
                        setState(() => widget.data.userContribRate = val);
                      },
                      onMatchRateChanged: (val) {
                        setState(() => widget.data.userEmployerMatchRate = val);
                      },
                      onContribTypeChanged: (val) {
                        setState(() => widget.data.userContribType = val);
                      },
                    ),

                    if (widget.data.includePartner) ...[
                      const SizedBox(height: 24),
                      _buildPersonContributions(
                        title: "Spouse 401(k) Contributions",
                        salary: widget.data.spouseSalary,
                        contribRate: widget.data.spouseContribRate,
                        matchRate: widget.data.spouseEmployerMatchRate,
                        contribType: widget.data.spouseContribType,
                        onContribRateChanged: (val) {
                          setState(() => widget.data.spouseContribRate = val);
                        },
                        onMatchRateChanged: (val) {
                          setState(
                            () => widget.data.spouseEmployerMatchRate = val,
                          );
                        },
                        onContribTypeChanged: (val) {
                          setState(() => widget.data.spouseContribType = val);
                        },
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildCombinedSummary(),

                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.bar_chart, "Investment Returns"),
                    const SizedBox(height: 16),
                    _buildReturnTip(),
                    const SizedBox(height: 24),
                    _buildReturnSlider(),
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

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: FinSpanTheme.primaryGreen,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {String? badge}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: FinSpanTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade900,
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
    required String hint,
    required String label,
    String? subLabel,
    String? helper,
    String? helperAction,
    VoidCallback? onHelperAction,
    Function(double)? onChanged,
  }) {
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (helperAction != null)
                GestureDetector(
                  onTap: onHelperAction,
                  child: Text(
                    helperAction,
                    style: const TextStyle(
                      color: FinSpanTheme.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (subLabel != null)
            Text(
              subLabel,
              style: TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (prefix != null)
                Text(
                  prefix,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (val) {
                    if (onChanged != null) {
                      final dVal =
                          double.tryParse(val.replaceAll(',', '')) ?? 0;
                      onChanged(dVal);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (helper != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    helper,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String text, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: FinSpanTheme.charcoal),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: FinSpanTheme.primaryGreen,
          activeTrackColor: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDetailedInput(
    String label,
    TextEditingController controller,
    Function(double) onUpdate,
  ) {
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
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: FinSpanTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: FinSpanTheme.dividerColor),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "\$ ",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    onChanged: (val) {
                      final dVal =
                          double.tryParse(val.replaceAll(',', '')) ?? 0;
                      onUpdate(dVal);
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(right: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Historical Annual Returns",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildTipRow("Stocks (S&P 500)", "~10%"),
          _buildTipRow("Bonds", "~5-6%"),
          _buildTipRow("60/40 Portfolio", "~8%"),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "💡 Tip: Use 7% for balanced approach, 6% for conservative, 8-9% for aggressive.",
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: FinSpanTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Expected Annual Return",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "${widget.data.expectedReturn.toInt()}%",
              style: const TextStyle(
                color: FinSpanTheme.primaryGreen,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Slider(
          value: widget.data.expectedReturn,
          min: 4,
          max: 12,
          divisions: 8,
          activeColor: FinSpanTheme.primaryGreen,
          inactiveColor: FinSpanTheme.dividerColor,
          onChanged: (val) => setState(() => widget.data.expectedReturn = val),
        ),
      ],
    );
  }

  Widget _buildSmartOptimizationCard() {
    final isSmart = widget.data.smartTaxOptimization;
    return GestureDetector(
      onTap: () {
        setState(() => widget.data.smartTaxOptimization = !isSmart);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSmart
              ? FinSpanTheme.primaryGreen.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSmart
                ? FinSpanTheme.primaryGreen.withValues(alpha: 0.2)
                : FinSpanTheme.dividerColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome,
              color: isSmart ? FinSpanTheme.primaryGreen : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Smart Tax Optimization",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSmart ? Colors.black : Colors.grey.shade700,
                        ),
                      ),
                      Switch(
                        value: isSmart,
                        activeTrackColor: FinSpanTheme.primaryGreen,
                        onChanged: (val) {
                          setState(
                            () => widget.data.smartTaxOptimization = val,
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    isSmart
                        ? "✓ System will choose Roth vs Traditional based on your tax bracket"
                        : "Manual mode: You control Roth vs Traditional selection below",
                    style: TextStyle(
                      fontSize: 11,
                      color: isSmart ? FinSpanTheme.bodyGray : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonContributions({
    required String title,
    required double salary,
    required double contribRate,
    required double matchRate,
    required String contribType,
    required Function(double) onContribRateChanged,
    required Function(double) onMatchRateChanged,
    required Function(String) onContribTypeChanged,
  }) {
    const double limit = 24500;
    final contribDollar = salary * (contribRate / 100);
    final matchDollar = salary * (matchRate / 100);
    final totalDollar = contribDollar + matchDollar;
    final limitPercent = ((contribDollar / limit) * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinSpanTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinSpanTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 16),

          if (!widget.data.smartTaxOptimization) ...[
            _buildTypeSelector(contribType, onContribTypeChanged),
            const SizedBox(height: 24),
          ],

          // Contribution Rate
          _buildRateSliderRow(
            label: "Your Contribution Rate",
            value: contribRate,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: onContribRateChanged,
          ),
          Text(
            "Annual contribution: \$${_formatC(contribDollar)} ($limitPercent% of \$24,500 limit)",
            style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
          ),
          const SizedBox(height: 24),

          // Employer Match Rate
          _buildRateSliderRow(
            label: "Employer Match Rate",
            value: matchRate,
            min: 0,
            max: 15,
            divisions: 15,
            onChanged: onMatchRateChanged,
          ),
          Text(
            "Employer match: \$${_formatC(matchDollar)}/year 💰",
            style: TextStyle(fontSize: 12, color: FinSpanTheme.bodyGray),
          ),

          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Annual Contribution:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "= \$${_formatC(contribDollar)} (your) + \$${_formatC(matchDollar)} (match)",
                    style: TextStyle(
                      fontSize: 11,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
              Text(
                "\$${_formatC(totalDollar)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: FinSpanTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: FinSpanTheme.primaryGreen,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${value.toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: FinSpanTheme.primaryGreen,
            inactiveTrackColor: FinSpanTheme.dividerColor,
            thumbColor: Colors.white,
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(String currentType, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contribution Type",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: FinSpanTheme.dividerColor),
          ),
          child: Row(
            children: [
              _buildTypeOption(
                "Traditional",
                "Pre-tax",
                currentType == "Traditional",
                () => onChanged("Traditional"),
              ),
              Container(width: 1, color: FinSpanTheme.dividerColor),
              _buildTypeOption(
                "Roth",
                "After-tax",
                currentType == "Roth",
                () => onChanged("Roth"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currentType == "Traditional"
              ? "Tax deduction now, pay taxes later"
              : "Pay taxes now, tax-free growth and withdrawals",
          style: TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    String title,
    String sub,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? FinSpanTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedSummary() {
    final double totalHousehold = widget.data.totalHouseholdContribPerYear;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinSpanTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Combined Household Contributions",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${_formatC(totalHousehold)}",
            style: const TextStyle(
              color: FinSpanTheme.vibrantGreen,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "per year going into retirement accounts",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatC(double val) {
    return val.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
