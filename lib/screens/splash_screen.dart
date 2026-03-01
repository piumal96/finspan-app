import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';
import 'onboarding/onboarding_step_1.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Subtle green gradient glow at the top
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FinSpanTheme.primaryGreen.withValues(alpha: 0.2),
                    FinSpanTheme.primaryGreen.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  // Logo Placeholder (Stylized F)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'F',
                        style: TextStyle(
                          color: FinSpanTheme.primaryGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text(
                    'FinSpan',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Your Financial Future, Visualized.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: FinSpanTheme.bodyGray,
                    ),
                  ),

                  const Spacer(),

                  // Central Illustration Placeholder
                  Icon(
                    Icons.trending_up_rounded,
                    size: 120,
                    color: FinSpanTheme.primaryGreen.withValues(alpha: 0.8),
                  ),

                  const Spacer(),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingStep1Screen(),
                          ),
                        );
                      },
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('I already have an account'),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Terms
                  Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FinSpanTheme.bodyGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
