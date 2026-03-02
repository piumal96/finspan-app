import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

import 'onboarding_data.dart';

class OnboardingStep3Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep3Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  // Using widget.data directly

  final List<String> _states = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
    'District of Columbia',
  ];

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: FinSpanTheme.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Tax Residency",
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: FinSpanTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: widget.data.stateOfResidence,
                                hint: const Text("Select State"),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _states.map((String state) {
                                  return DropdownMenuItem<String>(
                                    value: state,
                                    child: Text(state),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(
                                      () => widget.data.stateOfResidence =
                                          newValue,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Retirement Age Card
                    FinSpanCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timer_rounded,
                                color: FinSpanTheme.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Target Retirement Age",
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                "${widget.data.retirementAge}",
                                style: const TextStyle(
                                  color: FinSpanTheme.primaryGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: FinSpanTheme.primaryGreen,
                              inactiveTrackColor: FinSpanTheme.dividerColor,
                              thumbColor: Colors.white,
                              overlayColor: FinSpanTheme.primaryGreen
                                  .withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                                elevation: 4,
                              ),
                            ),
                            child: Slider(
                              value: widget.data.retirementAge.toDouble(),
                              min: 50,
                              max: 80,
                              onChanged: (val) {
                                setState(
                                  () => widget.data.retirementAge = val.toInt(),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAgeLabel("Early", "50"),
                              _buildAgeLabel("Standard", "65"),
                              _buildAgeLabel("Late", "80"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Plan Until Age (Life Expectancy) Card
                    FinSpanCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.hourglass_bottom_rounded,
                                color: FinSpanTheme.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Plan Until Age",
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                "${widget.data.lifeExpectancy}",
                                style: const TextStyle(
                                  color: FinSpanTheme.primaryGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: FinSpanTheme.primaryGreen,
                              inactiveTrackColor: FinSpanTheme.dividerColor,
                              thumbColor: Colors.white,
                              overlayColor: FinSpanTheme.primaryGreen
                                  .withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                                elevation: 4,
                              ),
                            ),
                            child: Slider(
                              value: widget.data.lifeExpectancy.toDouble(),
                              min: 50,
                              max: 110,
                              onChanged: (val) {
                                setState(
                                  () =>
                                      widget.data.lifeExpectancy = val.toInt(),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAgeLabel("Standard", "80"),
                              _buildAgeLabel("Long", "95"),
                              _buildAgeLabel("Extreme", "110"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (widget.data.includePartner) ...[
                      const SizedBox(height: 16),
                      // Spouse Age Card
                      FinSpanCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: FinSpanTheme.primaryGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Spouse's Age",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  "${widget.data.spouseAge ?? widget.data.currentAge}",
                                  style: const TextStyle(
                                    color: FinSpanTheme.primaryGreen,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: FinSpanTheme.primaryGreen,
                                inactiveTrackColor: FinSpanTheme.dividerColor,
                                thumbColor: Colors.white,
                                overlayColor: FinSpanTheme.primaryGreen
                                    .withValues(alpha: 0.2),
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                  elevation: 4,
                                ),
                              ),
                              child: Slider(
                                value:
                                    (widget.data.spouseAge ??
                                            widget.data.currentAge)
                                        .toDouble(),
                                min: 18,
                                max: 100,
                                onChanged: (val) {
                                  setState(
                                    () => widget.data.spouseAge = val.toInt(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildAgeLabel(String label, String age) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: FinSpanTheme.bodyGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          age,
          style: TextStyle(
            fontSize: 10,
            color: FinSpanTheme.bodyGray.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
