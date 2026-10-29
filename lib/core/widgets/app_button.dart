// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/core/widgets/app_button.dart
//
// Description:
//   Reusable accessible button component fulfilling WP2.5 specifications.
//   Enforces WCAG 2.1 AA minimum touch targets (>= 48 dp height and width)
//   and wraps interactive controls in screen-reader Semantics.
//
// Key Concepts:
//   - Touch Target Guarantee: Wraps controls in [ConstrainedBox] with a minimum
//     height and width of 48dp to eliminate tap frustration for motor/sensory learners.
//   - Screen Reader Accessibility: Emits [Semantics] tags with explicit button
//     labels and disabled states.
//   - Sensory State Handling: Renders a smooth, low-contrast loading indicator
//     when [isLoading] is active, preventing duplicate rapid taps.
// ============================================================================

import 'package:flutter/material.dart';

/// An accessible button that satisfies WCAG touch-target and contrast standards.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isLoading = false,
  });

  /// The text displayed inside the button and announced by screen readers.
  final String label;

  /// Callback executed when tapped; if null or [isLoading] is true, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon preceding the text label.
  final IconData? icon;

  /// If true, renders as an [OutlinedButton]; otherwise renders as an [ElevatedButton].
  final bool isSecondary;

  /// If true, replaces content with a spinner and ignores tap events.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: isSecondary
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: colorScheme.primary,
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                child: child,
              ),
      ),
    );
  }
}
