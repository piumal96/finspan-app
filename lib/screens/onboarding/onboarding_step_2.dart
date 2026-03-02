import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';

import 'onboarding_data.dart';

class OnboardingStep2Screen extends StatefulWidget {
  final VoidCallback onNext;
  final OnboardingData data;
  const OnboardingStep2Screen({
    super.key,
    required this.onNext,
    required this.data,
  });

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen> {
  final TextEditingController _nameController = TextEditingController(
    text: "Yasantha",
  );
  String _selectedGender = "Male";

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
                  children: [
                    Text(
                      "The Basics",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: FinSpanTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hi there! Let's get to know you a bit better.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FinSpanTheme.bodyGray,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Input
                    _buildInputCard(
                      label: "What should we call you?",
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter your name",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth - Simpler Version
                    _buildInputCard(
                      label: "When is your birthday?",
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: FinSpanTheme.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "October 24, 1992",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gender Selection
                    _buildInputCard(
                      label: "How do you identify?",
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption(
                              "Male",
                              Icons.male_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption(
                              "Female",
                              Icons.female_rounded,
                            ),
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
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FinSpanTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: FinSpanTheme.bodyGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    bool isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? FinSpanTheme.primaryGreen.withValues(alpha: 0.1)
              : FinSpanTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? FinSpanTheme.primaryGreen : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? FinSpanTheme.primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? FinSpanTheme.primaryGreen : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
