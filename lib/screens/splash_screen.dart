import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/finspan_theme.dart';
import 'landing_screen.dart';
import 'dashboard/main_dashboard.dart';
import 'onboarding/onboarding_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveStartScreen();
  }

  Future<void> _resolveStartScreen() async {
    // Minimum visible splash time for branding
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authService = AuthService();

    // If Firebase unavailable, go straight to landing
    if (!authService.isAvailable) {
      _goTo(const LandingScreen());
      return;
    }

    final User? user = authService.currentUser;

    if (user == null) {
      // Not logged in → show landing
      _goTo(const LandingScreen());
      return;
    }

    // User is logged in → check if onboarding is done
    try {
      final userService = UserService();
      final hasData = await userService.hasCompletedOnboarding();

      if (!mounted) return;

      if (hasData) {
        final userData = await userService.getUserProfile();
        if (!mounted) return;
        if (userData != null) {
          _goTo(MainDashboardScreen(data: userData));
        } else {
          _goTo(const OnboardingWrapper());
        }
      } else {
        _goTo(const OnboardingWrapper());
      }
    } catch (_) {
      if (mounted) _goTo(const LandingScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/full_logo.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Developed by FinSpan',
                  style: TextStyle(
                    fontSize: 14,
                    color: FinSpanTheme.bodyGray.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
