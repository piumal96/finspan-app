import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/finspan_card.dart';
import 'onboarding_step_2.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  int _selectedOption = 0; // 0: 5-15 yrs, 1: Already retired, 2: Exploring
  bool _includePartner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FinSpanProgressBar(totalSteps: 6, currentStep: 1),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Text(
                        'What brings you here\ntoday?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
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
                        subtitle: "Planning my exit strategy",
                      ),
                      const SizedBox(height: 16),
                      _buildOptionCard(
                        index: 1,
                        icon: Icons.umbrella_rounded,
                        title: "I'm already retired",
                        subtitle: "Managing my assets & income",
                      ),
                      const SizedBox(height: 16),
                      _buildOptionCard(
                        index: 2,
                        icon: Icons.explore_rounded,
                        title: "I'm just exploring",
                        subtitle: "Curious about my future",
                      ),
                      const SizedBox(height: 32),

                      // Partner Toggle Card
                      FinSpanCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Include Partner',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Plan for me and my partner',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _includePartner,
                              activeColor: FinSpanTheme.primaryGreen,
                              onChanged: (val) {
                                setState(() {
                                  _includePartner = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "We'll tailor your 60-second plan based on this choice.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FinSpanTheme.bodyGray.withValues(alpha: 0.7),
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
                        builder: (context) => const OnboardingStep2Screen(),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
          border: Border.all(
            color: isSelected ? FinSpanTheme.primaryGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? FinSpanTheme.primaryGreen.withValues(alpha: 0.1)
                  : FinSpanTheme.charcoal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: FinSpanTheme.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FinSpanTheme.charcoal,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
