import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import 'onboarding_step_3.dart';

class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  String _gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              const FinSpanProgressBar(totalSteps: 6, currentStep: 2),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Let's start with the\nbasics.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 28,
                              height: 1.2,
                              color: FinSpanTheme.charcoal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'To build your retirement simulation, we need to know who you are and establish your financial timeline.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FinSpanTheme.bodyGray,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name
                      _buildInputField(
                        label: "Full Name",
                        required: true,
                        icon: Icons.person_outline,
                        placeholder: "e.g. Jonathan Doe",
                        helper: "Used for your personalized report header.",
                      ),
                      const SizedBox(height: 24),

                      // Date of Birth
                      _buildInputField(
                        label: "Date of Birth",
                        required: true,
                        icon: Icons.calendar_today_outlined,
                        placeholder: "mm/dd/yyyy",
                        helper:
                            "Determines your retirement horizon and social security.",
                        suffixIcon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Gender Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: FinSpanTheme.charcoal,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderCard(
                                  label: "Male",
                                  icon: Icons.male,
                                  isSelected: _gender == 'Male',
                                  onTap: () => setState(() => _gender = 'Male'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGenderCard(
                                  label: "Female",
                                  icon: Icons.female,
                                  isSelected: _gender == 'Female',
                                  onTap: () =>
                                      setState(() => _gender = 'Female'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Required for life expectancy calculations.",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: FinSpanTheme.bodyGray),
                          ),
                        ],
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
                        builder: (context) => const OnboardingStep3Screen(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required bool required,
    required IconData icon,
    required String placeholder,
    required String helper,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: FinSpanTheme.charcoal,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: FinSpanTheme.primaryGreen),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FinSpanTheme.dividerColor),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: Icon(icon, color: FinSpanTheme.bodyGray, size: 20),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: FinSpanTheme.charcoal, size: 18)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FinSpanTheme.bodyGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? FinSpanTheme.primaryGreen.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? FinSpanTheme.primaryGreen
                : FinSpanTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? FinSpanTheme.primaryGreen
                  : FinSpanTheme.bodyGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? FinSpanTheme.charcoal
                    : FinSpanTheme.bodyGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
