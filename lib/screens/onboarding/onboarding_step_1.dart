import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';

import 'onboarding_data.dart';

class OnboardingStep1Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep1Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  int _selectedOption = 0; // 0: 5-15 yrs, 1: Already retired, 2: Exploring

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Text(
                      'What brings you here\ntoday?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        height: 1.2,
                        color: FinSpanTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select the option that best describes your current situation so we can personalize your path.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    _buildOptionCard(
                      index: 0,
                      icon: Icons.rocket_launch_rounded,
                      title: "I'm 5–15 years away",
                      subtitle: "Planning for the home stretch",
                    ),
                    _buildOptionCard(
                      index: 1,
                      icon: Icons.beach_access_rounded,
                      title: "I'm already retired",
                      subtitle: "Optimizing my withdrawal strategy",
                    ),
                    _buildOptionCard(
                      index: 2,
                      icon: Icons.search_rounded,
                      title: "Just exploring",
                      subtitle: "Seeing how the math works",
                    ),

                    const SizedBox(height: 32),
                    FinSpanCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            color: FinSpanTheme.primaryGreen,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Include a partner?",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Plan for two people together",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: FinSpanTheme.bodyGray),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: widget.data.includePartner,
                            activeColor: FinSpanTheme.primaryGreen,
                            onChanged: (val) {
                              setState(() => widget.data.includePartner = val);
                            },
                          ),
                        ],
                      ),
                    ),
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
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    bool isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? FinSpanTheme.primaryGreen
                : FinSpanTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? FinSpanTheme.primaryGreen : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? FinSpanTheme.primaryGreen
                          : FinSpanTheme.charcoal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: FinSpanTheme.primaryGreen,
              ),
          ],
        ),
      ),
    );
  }
}
