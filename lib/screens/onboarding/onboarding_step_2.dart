import 'package:flutter/cupertino.dart';
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
  late final TextEditingController _nameController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.data.firstName.isNotEmpty ? widget.data.firstName : '',
    );
    _selectedGender = widget.data.gender.isNotEmpty
        ? widget.data.gender
        : 'Male';
    // Persist initial values in case user doesn't edit them
    _nameController.addListener(() {
      widget.data.firstName = _nameController.text.trim();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                      child: Container(
                        decoration: BoxDecoration(
                          color: FinSpanTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FinSpanTheme.dividerColor),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: "E.g. Alex",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth
                    GestureDetector(
                      onTap: () {
                        // Use a Cupertino date picker for easier year/month scrolling
                        DateTime tempPickedDate =
                            widget.data.birthDate ?? DateTime(1990, 1, 1);
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext builder) {
                            return Container(
                              height: 300,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CupertinoButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoButton(
                                        child: const Text('Done'),
                                        onPressed: () {
                                          setState(() {
                                            widget.data.birthDate =
                                                tempPickedDate;
                                            widget.data
                                                .updateAgeFromBirthDate();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: SafeArea(
                                      top: false,
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        initialDateTime: tempPickedDate,
                                        minimumDate: DateTime(1900),
                                        maximumDate: DateTime.now(),
                                        onDateTimeChanged: (DateTime newDate) {
                                          tempPickedDate = newDate;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: _buildInputCard(
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
                              widget.data.birthDate != null
                                  ? "${_monthName(widget.data.birthDate!.month)} ${widget.data.birthDate!.day}, ${widget.data.birthDate!.year}"
                                  : "Select your birthday",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.data.birthDate != null
                                        ? FinSpanTheme.charcoal
                                        : Colors.grey,
                                  ),
                            ),
                            const Spacer(),
                            if (widget.data.birthDate != null)
                              Chip(
                                label: Text("${widget.data.currentAge} yrs"),
                                backgroundColor: FinSpanTheme.primaryGreen
                                    .withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  color: FinSpanTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
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

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
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
      onTap: () => setState(() {
        _selectedGender = label;
        widget.data.gender = label;
      }),
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
