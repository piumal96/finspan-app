import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/progress_bar.dart';
import 'onboarding_step_1.dart';
import 'onboarding_step_2.dart';
import 'onboarding_step_3.dart';
import 'onboarding_step_4.dart';
import 'onboarding_step_5.dart';
import 'onboarding_step_6.dart';
import 'onboarding_data.dart';
import '../dashboard/main_dashboard.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 6;
  final OnboardingData _onboardingData = OnboardingData();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    } else {
      _navigateToSimulation();
    }
  }

  void _navigateToSimulation() {
    // Skip the API simulation runner — go directly to the dashboard.
    // The Simulator tab and Wealth Trajectory chart use LocalWealthCalculator
    // for instant, real-time results without any network call.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainDashboardScreen(
          data: _onboardingData,
          result: null,
          fromSim: false,
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        toolbarHeight: 44,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: FinSpanTheme.charcoal,
            size: 20,
          ),
          onPressed: _previousPage,
        ),
        title: null,
        bottom: FinSpanProgressBar(
          totalSteps: _totalSteps,
          currentStep: _currentPage + 1,
        ),
        actions: [
          TextButton(
            onPressed: _nextPage,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: FinSpanTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Control via buttons
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          OnboardingStep1Screen(onNext: _nextPage, data: _onboardingData),
          OnboardingStep2Screen(onNext: _nextPage, data: _onboardingData),
          OnboardingStep3Screen(onNext: _nextPage, data: _onboardingData),
          OnboardingStep4Screen(onNext: _nextPage, data: _onboardingData),
          OnboardingStep5Screen(onNext: _nextPage, data: _onboardingData),
          OnboardingStep6Screen(onNext: _nextPage, data: _onboardingData),
        ],
      ),
    );
  }
}
