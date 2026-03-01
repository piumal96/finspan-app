import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import 'onboarding_step_5.dart';

class OnboardingStep4Screen extends StatefulWidget {
  const OnboardingStep4Screen({super.key});

  @override
  State<OnboardingStep4Screen> createState() => _OnboardingStep4ScreenState();
}

class _OnboardingStep4ScreenState extends State<OnboardingStep4Screen> {
  double _workUntilAge = 69;
  final TextEditingController _salaryController = TextEditingController(
    text: "100,000",
  );
  final TextEditingController _spendingController = TextEditingController(
    text: "75,000",
  );
  final TextEditingController _inflationController = TextEditingController(
    text: "2.5",
  );
  String _selectedTaxBracket = "10%";

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
          "Employment & Income",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FinSpanTheme.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingStep5Screen(),
                ),
              );
            },
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
                currentStep: 4,
                showHeader: false,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Your Employment Section
                      _buildSectionHeader("Your Employment"),
                      const SizedBox(height: 16),
                      _buildInputLabel("Annual Salary"),
                      _buildInputBox(
                        controller: _salaryController,
                        prefix: "\$ ",
                        hint: "100,000",
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInputLabel("Work Until Age"),
                          Text(
                            "Age ${_workUntilAge.toInt()}",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: FinSpanTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      _buildSlider(
                        value: _workUntilAge,
                        min: 50,
                        max: 80,
                        onChanged: (val) => setState(() => _workUntilAge = val),
                      ),
                      Text(
                        "Retire at age ${_workUntilAge.toInt()}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FinSpanTheme.bodyGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Spending Goals Section
                      _buildSectionHeader("Spending Goals"),
                      const SizedBox(height: 16),
                      _buildInputLabel("Annual Spending Goal"),
                      _buildInputBox(
                        controller: _spendingController,
                        prefix: "\$ ",
                        hint: "75,000",
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel("Expected Inflation Rate"),
                      _buildInputBox(
                        controller: _inflationController,
                        suffix: "%",
                        hint: "2.5",
                      ),
                      const SizedBox(height: 32),

                      // Tax Strategy Section
                      _buildSectionHeader("Tax Strategy"),
                      const SizedBox(height: 16),
                      _buildInputLabel("Target Tax Bracket Rate"),
                      _buildTaxBracketSelector(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FinSpanTheme.primaryGreen.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Auto-calculated based on your income and spending. Current bracket: $_selectedTaxBracket",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: FinSpanTheme.charcoal.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingStep5Screen(),
                      ),
                    );
                  },
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    String? suffix,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinSpanTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: FinSpanTheme.charcoal.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: FinSpanTheme.charcoal,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    prefix,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: FinSpanTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Text(
                    suffix,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          hintText: hint,
        ),
      ),
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
        thumbColor: FinSpanTheme.primaryGreen,
        overlayColor: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        trackHeight: 4,
      ),
      child: Slider(value: value, min: min, max: max, onChanged: onChanged),
    );
  }

  Widget _buildTaxBracketSelector() {
    final List<String> brackets = ["10%", "12%", "22%", "24%", "32%"];
    return Row(
      children: brackets.map((bracket) {
        final isSelected = _selectedTaxBracket == bracket;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTaxBracket = bracket),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? FinSpanTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? FinSpanTheme.primaryGreen
                      : FinSpanTheme.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  bracket,
                  style: TextStyle(
                    color: isSelected ? Colors.white : FinSpanTheme.charcoal,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
