import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardAlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String severity; // 'success' or 'warning'
  final int? runwayAge;
  final int? targetAge;
  final VoidCallback? onAdjustPlan;
  final VoidCallback? onViewOptions;
  final VoidCallback? onDismiss;

  const DashboardAlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.severity,
    this.runwayAge,
    this.targetAge,
    this.onAdjustPlan,
    this.onViewOptions,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWarning = severity == 'warning';
    final Color baseColor = isWarning
        ? Colors.orange
        : FinSpanTheme.primaryGreen;
    final IconData icon = isWarning
        ? Icons.warning_amber_rounded
        : LucideIcons.checkCircle2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: baseColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: baseColor.withValues(alpha: 0.9),
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(LucideIcons.x, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: FinSpanTheme.charcoal,
              height: 1.4,
            ),
          ),
          if (isWarning && runwayAge != null && targetAge != null) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (runwayAge! / targetAge!).clamp(0.0, 1.0),
              backgroundColor: baseColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(baseColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current: Age $runwayAge',
                  style: const TextStyle(
                    fontSize: 11,
                    color: FinSpanTheme.bodyGray,
                  ),
                ),
                Text(
                  'Target: Age $targetAge',
                  style: const TextStyle(
                    fontSize: 11,
                    color: FinSpanTheme.bodyGray,
                  ),
                ),
              ],
            ),
          ],
          if (onAdjustPlan != null || onViewOptions != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onAdjustPlan != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAdjustPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: baseColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Adjust Plan'),
                    ),
                  ),
                if (onAdjustPlan != null && onViewOptions != null)
                  const SizedBox(width: 12),
                if (onViewOptions != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewOptions,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Options'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
