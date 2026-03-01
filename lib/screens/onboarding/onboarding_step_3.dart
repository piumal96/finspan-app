import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/finspan_card.dart';
import 'onboarding_step_4.dart';

class OnboardingStep3Screen extends StatefulWidget {
  const OnboardingStep3Screen({super.key});

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  double _retirementAge = 65;
  String? _selectedState;

  final List<String> _states = [
    'California',
    'New York',
    'Texas',
    'Florida',
    'Illinois',
    // Add more as needed or keep as placeholder for demo
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              const FinSpanProgressBar(totalSteps: 6, currentStep: 3),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Identity & Timeline",
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 28,
                                color: FinSpanTheme.charcoal,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Let's start with the basics to calibrate your retirement trajectory.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: FinSpanTheme.bodyGray),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tax Residency Card
                      FinSpanCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: FinSpanTheme.primaryGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: FinSpanTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Tax Residency",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: FinSpanTheme.charcoal,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "STATE OF RESIDENCE",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: FinSpanTheme.bodyGray,
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: FinSpanTheme.backgroundLight.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: FinSpanTheme.dividerColor,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedState,
                                  hint: Text(
                                    "Select State",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: FinSpanTheme.charcoal,
                                        ),
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: FinSpanTheme.bodyGray,
                                  ),
                                  items: _states.map((state) {
                                    return DropdownMenuItem(
                                      value: state,
                                      child: Text(state),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedState = val),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Required for state income tax projections.",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: FinSpanTheme.bodyGray,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Retirement Age Card
                      FinSpanCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Target Retirement Age",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: FinSpanTheme.charcoal,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Standard is 65 years old.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: FinSpanTheme.bodyGray,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FinSpanTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: FinSpanTheme.dividerColor,
                                    ),
                                  ),
                                  child: Text(
                                    _retirementAge.toInt().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: FinSpanTheme.charcoal,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: FinSpanTheme.primaryGreen,
                                inactiveTrackColor: FinSpanTheme.dividerColor,
                                thumbColor: FinSpanTheme.primaryGreen,
                                overlayColor: FinSpanTheme.primaryGreen
                                    .withValues(alpha: 0.1),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                                trackHeight: 6,
                              ),
                              child: Slider(
                                value: _retirementAge,
                                min: 50,
                                max: 80,
                                onChanged: (val) =>
                                    setState(() => _retirementAge = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSliderLabel("50"),
                                  _buildSliderLabel("EARLY"),
                                  _buildSliderLabel("STANDARD"),
                                  _buildSliderLabel("LATE"),
                                  _buildSliderLabel("80"),
                                ],
                              ),
                            ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingStep4Screen(),
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

  Widget _buildSliderLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFFC0CCD4), // Similar to the light blue-gray in image
      ),
    );
  }
}
