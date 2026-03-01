import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';

class FinSpanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasShadow;

  const FinSpanCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FinSpanTheme.white,
        borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
        // Use a very soft, elegant shadow instead of a hard border
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: FinSpanTheme.charcoal.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
