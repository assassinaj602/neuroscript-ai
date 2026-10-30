// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/widgets/progress_ring.dart
//
// Description:
//   Custom circular progress indicator delivering immediate visual mastery feedback.
//   Follows WP2.5 specifications for neurodivergent motivation and dopamine loops
//   (specifically ADHD learners), rendering percentage completion and status metrics.
//
// Key Concepts:
//   - Visual Feedback Loop: Renders a smooth, rounded circular arc providing
//     unambiguous task completion awareness.
//   - Accessible Semantics: Wraps the graphical ring in screen-reader announcements
//     so non-visual or TalkBack users receive the exact numeric progress.
//   - Constrained Dimensions: Clamps progress values between 0.0 and 1.0 to prevent
//     rendering glitches on divide-by-zero or edge cases.
// ============================================================================

import 'package:flutter/material.dart';

/// An accessible circular progress ring displaying progress and center metrics.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress, // Normalized 0.0 to 1.0
    required this.centerText,
    this.subText,
    this.radius = 42,
    this.strokeWidth = 7,
  });

  /// The completion ratio, clamped internally between 0.0 and 1.0.
  final double progress;

  /// The prominent numerical or textual indicator centered inside the ring.
  final String centerText;

  /// Optional secondary label positioned below [centerText].
  final String? subText;

  /// The outer radius of the circular indicator in logical pixels.
  final double radius;

  /// The thickness of the progress stroke.
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
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
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
