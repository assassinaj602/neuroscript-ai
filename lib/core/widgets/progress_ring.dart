import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress, // 0.0 to 1.0
    required this.centerText,
    this.subText,
    this.radius = 42,
    this.strokeWidth = 7,
  });

  final double progress;
  final String centerText;
  final String? subText;
  final double radius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Progress indicator: $centerText ${subText ?? ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: strokeWidth,
                  backgroundColor: colorScheme.outline.withOpacity(0.3),
                  color: colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subText != null) ...[
                    Text(
                      subText!,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
