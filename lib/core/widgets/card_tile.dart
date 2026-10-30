// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/widgets/card_tile.dart
//
// Description:
//   Structured information chunking card tile component.
//   Follows cognitive load reduction principles for neurodivergent learners by
//   encapsulating individual lessons, metrics, and options into distinct,
//   high-contrast visual blocks.
//
// Key Concepts:
//   - Visual Information Chunking: Prevents cognitive overload (especially for
//     ADHD and Autistic students) by isolating complex datasets into bite-sized cards.
//   - Accessible InkWell: Provides tactile, visible ripple feedback on tap while
//     maintaining the card's rounded border radius.
//   - Badge Annotation: Displays verification statuses (e.g., 'Verified', 'Seed')
//     using high-contrast tags with border outlines.
// ============================================================================

import 'package:flutter/material.dart';

/// A reusable card tile offering clean visual chunking and interactive tap states.
class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  /// The primary header text of the card.
  final String title;

  /// Optional descriptive text placed directly beneath the title.
  final String? subtitle;

  /// Optional trailing widget (e.g. chevron or count indicator) on the far right.
  final Widget? trailing;

  /// Optional leading icon or avatar on the far left.
  final Widget? leading;

  /// Callback executed when the card is tapped.
  final VoidCallback? onTap;

  /// Optional status tag text displayed above the title.
  final String? badgeText;

  /// Background and border tint for the badge tag.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: onTap != null,
      label: title,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? colorScheme.secondary)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: badgeColor ?? colorScheme.secondary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor ?? colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 10), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
