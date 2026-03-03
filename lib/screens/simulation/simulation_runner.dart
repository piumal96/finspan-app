import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../onboarding/onboarding_data.dart';
import 'detailed_results.dart';
import '../../services/user_service.dart';
import 'dart:async';

class SimulationRunnerScreen extends StatefulWidget {
  final OnboardingData data;
  const SimulationRunnerScreen({super.key, required this.data});

  @override
  State<SimulationRunnerScreen> createState() => _SimulationRunnerScreenState();
}

class _SimulationRunnerScreenState extends State<SimulationRunnerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  final UserService _userService = UserService();

  int _currentStepIndex = 0;
  final List<String> _steps = [
    "Analyzing historical market data...",
    "Modeling inflation trajectories...",
    "Running 10,000 Monte Carlo simulations...",
    "Calculating probability of success...",
    "Finalizing your retirement plan...",
  ];

  @override
  void initState() {
    super.initState();

    // Save profile to Firestore in background
    _userService.saveUserProfile(widget.data).catchError((e) {
      print("Failed to save profile: $e");
    });

    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..forward().then((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailedResultsScreen(data: widget.data),
                ),
              );
            }
          });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startStepRotation();
  }

  void _startStepRotation() {
    Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted && _currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Visual
              Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: FinSpanTheme.primaryGreen,
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              const Text(
                "Calculating Your Future",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _steps[_currentStepIndex],
                    key: ValueKey(_steps[_currentStepIndex]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: FinSpanTheme.bodyGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Custom Progress Bar
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: FinSpanTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressController.value,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: FinSpanTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: FinSpanTheme.primaryGreen.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Text(
                    "${(_progressController.value * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: FinSpanTheme.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
