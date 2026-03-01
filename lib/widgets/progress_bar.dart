import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';

class FinSpanProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final bool showHeader;

  const FinSpanProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / totalSteps;
    int percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BackButton(color: FinSpanTheme.charcoal),
              Text(
                'Future Navigator',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP $currentStep OF $totalSteps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: FinSpanTheme.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: FinSpanTheme.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: FinSpanTheme.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(
              FinSpanTheme.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}
