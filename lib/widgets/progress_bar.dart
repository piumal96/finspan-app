import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';

class FinSpanProgressBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int totalSteps;
  final int currentStep;

  const FinSpanProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / totalSteps;

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: FinSpanTheme.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(
              FinSpanTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(3);
}
