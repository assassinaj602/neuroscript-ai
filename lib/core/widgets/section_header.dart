// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/core/widgets/section_header.dart
//
// Description:
//   Section header widget providing predictable semantic milestones and visual
//   hierarchy across all feature screens.
//
// Key Concepts:
//   - Visual Anchoring: Breaks down long scrollable pages into easily scannable,
//     predictable chunks for learners with executive dysfunction or ADHD.
//   - Heading Semantics: Formats titles with bold typography and accessibility
//     labels so screen readers recognize content sections.
// ============================================================================

import 'package:flutter/material.dart';

/// A standard section header widget with optional trailing action button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  /// The section header title text.
  final String title;

  /// Optional text for an action button on the far right.
  final String? actionText;

  /// Callback executed when the trailing action button is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          if (actionText != null && onAction != null) ...[
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(48, 48), // WCAG touch target
              ),
              child: Text(
                actionText!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
