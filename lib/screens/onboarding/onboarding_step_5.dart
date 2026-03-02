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
  late TextEditingController _tradIRAController;
  late TextEditingController _rothIRAController;
  late TextEditingController _brokerageController;

  late TextEditingController _spouseTradIRAController;
  late TextEditingController _spouseRothIRAController;
  late TextEditingController _spouseBrokerageController;

  late TextEditingController _fourOneKContribController;
  late TextEditingController _rothIRAContribController;

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

    _fourOneKContribController = TextEditingController(
      text: widget.data.userFourOneKContrib.toInt().toString(),
    );
    _rothIRAContribController = TextEditingController(
      text: widget.data.userRothIRAContrib.toInt().toString(),
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
    _fourOneKContribController.dispose();
    _rothIRAContribController.dispose();
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
                      subLabel: "Sum of your accounts below",
                    ),

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
                      "Annual Contributions",
                    ),
                    const SizedBox(height: 16),
                    _buildContribNotice(),
                    const SizedBox(height: 24),

                    _buildInputBox(
                      controller: _fourOneKContribController,
                      prefix: "\$ ",
                      hint: "20,000",
                      label: "Your 401(k) Contribution",
                      helper:
                          "${((widget.data.userFourOneKContrib / 24500) * 100).toInt()}% of limit",
                      onHelperAction: () {
                        setState(() {
                          widget.data.userFourOneKContrib = 24500;
                          _fourOneKContribController.text = "24,500";
                        });
                      },
                      helperAction: "Max Out (\$24,500)",
                      onChanged: (val) => widget.data.userFourOneKContrib = val,
                    ),
                    const SizedBox(height: 16),
                    _buildInputBox(
                      controller: _rothIRAContribController,
                      prefix: "\$ ",
                      hint: "6,000",
                      label: "Your Roth IRA Contribution",
                      subLabel: "Annual contribution amount",
                      onChanged: (val) => widget.data.userRothIRAContrib = val,
                    ),

                    if (widget.data.includePartner) ...[
                      const SizedBox(height: 24),
                      _buildSectionLabel("Spouse's Contributions"),
                      const SizedBox(height: 16),
                      _buildInputBox(
                        controller: TextEditingController(
                          text: widget.data.spouseFourOneKContrib
                              .toInt()
                              .toString(),
                        ),
                        prefix: "\$ ",
                        hint: "0",
                        label: "Spouse 401(k) Contribution",
                        onChanged: (val) =>
                            widget.data.spouseFourOneKContrib = val,
                      ),
                      const SizedBox(height: 16),
                      _buildInputBox(
                        controller: TextEditingController(
                          text: widget.data.spouseRothIRAContrib
                              .toInt()
                              .toString(),
                        ),
                        prefix: "\$ ",
                        hint: "0",
                        label: "Spouse Roth IRA Contribution",
                        onChanged: (val) =>
                            widget.data.spouseRothIRAContrib = val,
                      ),
                    ],

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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: FinSpanTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
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

  Widget _buildContribNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Coming Soon",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "Annual contributions are not yet supported by the simulation engine... for now, enter current balances.",
                  style: TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
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
}
