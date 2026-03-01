import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import 'onboarding_step_6.dart';

class OnboardingStep5Screen extends StatefulWidget {
  const OnboardingStep5Screen({super.key});

  @override
  State<OnboardingStep5Screen> createState() => _OnboardingStep5ScreenState();
}

class _OnboardingStep5ScreenState extends State<OnboardingStep5Screen> {
  bool _detailedMode = true;
  double _expectedReturn = 7.5;

  // Controllers
  final TextEditingController _totalBalanceController = TextEditingController(
    text: "230,000",
  );
  final TextEditingController _401kController = TextEditingController(
    text: "150,000",
  );
  final TextEditingController _rothIRAController = TextEditingController(
    text: "30,000",
  );
  final TextEditingController _brokerageController = TextEditingController(
    text: "50,000",
  );

  final TextEditingController _401kContribController = TextEditingController(
    text: "20,000",
  );
  final TextEditingController _rothIRAContribController = TextEditingController(
    text: "6,000",
  );

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
          "Current Savings",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FinSpanTheme.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToStep6(),
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
                currentStep: 5,
                showHeader: false,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter your current account balances to project your retirement wealth.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FinSpanTheme.bodyGray,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Detailed Mode Toggle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FinSpanTheme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: FinSpanTheme.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: FinSpanTheme.primaryGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Detailed Mode",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Split by account types",
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: FinSpanTheme.bodyGray,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _detailedMode,
                              activeThumbColor: FinSpanTheme.primaryGreen,
                              activeTrackColor: FinSpanTheme.primaryGreen
                                  .withValues(alpha: 0.3),
                              onChanged: (val) =>
                                  setState(() => _detailedMode = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (!_detailedMode) ...[
                        _buildInputLabel("Current Balances (Estimate is fine)"),
                        _buildInputBox(
                          controller: _totalBalanceController,
                          prefix: "\$ ",
                          hint: "230,000",
                        ),
                      ] else ...[
                        _buildInputLabel("401(k) / 403(b) Balance"),
                        _buildInputBox(
                          controller: _401kController,
                          prefix: "\$ ",
                          hint: "150,000",
                          suffixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 24),
                        _buildInputLabel("Roth IRA"),
                        _buildInputBox(
                          controller: _rothIRAController,
                          prefix: "\$ ",
                          hint: "30,000",
                        ),
                        const SizedBox(height: 24),
                        _buildInputLabel("Taxable Brokerage"),
                        _buildInputBox(
                          controller: _brokerageController,
                          prefix: "\$ ",
                          hint: "50,000",
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Projected Returns Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Projected Returns"),
                          _buildGrowthBadge(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: FinSpanTheme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Average annual return",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: FinSpanTheme.bodyGray),
                                ),
                                Text(
                                  "${_expectedReturn.toStringAsFixed(1)}%",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: FinSpanTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSlider(
                              value: _expectedReturn,
                              min: 5,
                              max: 10,
                              onChanged: (val) =>
                                  setState(() => _expectedReturn = val),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Conservative (5%)",
                                  style: _sliderTextStyle,
                                ),
                                Text(
                                  "Aggressive (10%)",
                                  style: _sliderTextStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Annual Contributions Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Annual Contributions"),
                          _buildComingSoonBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildWarningBox(
                        "Annual contributions are not yet supported by the simulation engine. For now, enter your current balances above.",
                      ),
                      const SizedBox(height: 24),
                      _buildInputLabel("Your 401(k) Contribution"),
                      _buildInputBox(
                        controller: _401kContribController,
                        prefix: "\$ ",
                        hint: "20,000",
                        helper: "82% of limit",
                        suffixAction: "Max Out (\$24,500)",
                      ),
                      const SizedBox(height: 24),
                      _buildInputLabel("Your Roth IRA Contribution"),
                      _buildInputBox(
                        controller: _rothIRAContribController,
                        prefix: "\$ ",
                        hint: "6,000",
                        helper: "Annual contribution amount",
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Assets",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                  Text(
                    "\$${_calculateTotal()}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FinSpanTheme.charcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _navigateToStep6(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStep6() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingStep6Screen()),
    );
  }

  String _calculateTotal() {
    if (!_detailedMode) return _totalBalanceController.text;
    try {
      double total =
          (double.tryParse(_401kController.text.replaceAll(',', '')) ?? 0) +
          (double.tryParse(_rothIRAController.text.replaceAll(',', '')) ?? 0) +
          (double.tryParse(_brokerageController.text.replaceAll(',', '')) ?? 0);
      return total
          .toStringAsFixed(0)
          .replaceFirst(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
    } catch (e) {
      return "0";
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: FinSpanTheme.charcoal,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: FinSpanTheme.charcoal,
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    String? prefix,
    required String hint,
    IconData? suffixIcon,
    String? helper,
    String? suffixAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FinSpanTheme.dividerColor),
          ),
          child: TextFormField(
            controller: controller,
            onChanged: (val) => setState(() {}),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FinSpanTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        prefix,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: FinSpanTheme.bodyGray,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: FinSpanTheme.dividerColor, size: 20)
                  : (suffixAction != null
                        ? TextButton(
                            onPressed: () {},
                            child: Text(
                              suffixAction,
                              style: const TextStyle(
                                color: FinSpanTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              hintText: hint,
            ),
          ),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4),
            child: Text(
              helper,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FinSpanTheme.bodyGray,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: FinSpanTheme.primaryGreen,
        inactiveTrackColor: FinSpanTheme.dividerColor,
        thumbColor: Colors.white,
        overlayColor: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
        trackHeight: 12,
      ),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    );
  }

  Widget _buildGrowthBadge() {
    String label = "MODERATE GROWTH";
    if (_expectedReturn < 6.5) label = "CONSERVATIVE";
    if (_expectedReturn > 8.5) label = "AGGRESSIVE";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: FinSpanTheme.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "Coming Soon",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _sliderTextStyle => const TextStyle(
    fontSize: 11,
    color: FinSpanTheme.bodyGray,
    fontWeight: FontWeight.w600,
  );
}
