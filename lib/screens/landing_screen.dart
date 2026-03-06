import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        // TODO: Open Terms of Service URL
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        // TODO: Open Privacy Policy URL
      };
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Full-screen mint green gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAFAF0), Color(0xFFF5FDF8), Color(0xFFF4F6F8)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Top: Logo Only + Tagline ───────────────────
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            // Professional Text Logo
                            Text(
                              'FinSpan',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: FinSpanTheme.primaryGreen,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    fontSize: 32,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Your Financial Future, Visualized.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: FinSpanTheme.charcoal.withValues(
                                      alpha: 0.65,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                            ),
                          ],
                        ),

                        // ── Centre: Illustration ───────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Image.asset(
                              'assets/images/landing_illustration.png',
                              height:
                                  300, // Fixed max height to prevent unbounded expansion
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // ── Bottom: Buttons + Legal ───────────────────
                        Column(
                          children: [
                            // Get Started (filled green)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FinSpanTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Already have account (outlined)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: FinSpanTheme.primaryGreen,
                                  side: BorderSide(
                                    color: FinSpanTheme.primaryGreen.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'I already have an account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Legal text with links
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FinSpanTheme.bodyGray,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By continuing you agree to our ',
                                  ),
                                  TextSpan(
                                    text: 'Terms',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: _termsTap,
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: _privacyTap,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
