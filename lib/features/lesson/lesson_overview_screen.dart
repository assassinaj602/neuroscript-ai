// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/features/lesson/lesson_overview_screen.dart
//
// Description:
//   Lesson overview and dual-mode study launcher (WP2.4).
//   Provides learners with a structured summary of the synthesized topic,
//   offering dual revision paths: Active Recall Flashcards and Concept Map Exploration.
//
// Key Concepts:
//   - Multi-Modal Revision: Neurodivergent students benefit from engaging with
//     material through both sequential active recall (flashcards) and spatial/relational
//     exploration (concept maps).
//   - Provenance Visibility: Displays cited line numbers and compiler metadata
//     (seed, mock, or cloud source) up front for academic transparency.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
import '../common/where_is_this_from_sheet.dart';

class LessonOverviewScreen extends StatelessWidget {
  const LessonOverviewScreen({
    super.key,
    required this.lessonId,
    required this.lesson,
  });

  final String lessonId;
  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rawLines = lesson.rawNotes?.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              lesson.meta.source.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
            // Title & Meta card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optimized for: ${lesson.meta.profile} profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _infoBadge(
                          Icons.style_outlined,
                          '${lesson.flashcards.length} Flashcards',
                          colorScheme,
                        ),
                        const SizedBox(width: 12),
                        _infoBadge(
                          Icons.account_tree_outlined,
                          '${lesson.conceptMap.nodes.length} Concept Nodes',
                          colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Main Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Review Now',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      context.push('/review/$lessonId');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Concept Map',
                    icon: Icons.account_tree_outlined,
                    isSecondary: true,
                    onPressed: () {
                      context.push('/concept_map/$lessonId');
                    },
                  ),
                ),
              ],
            ),

            const SectionHeader(title: 'Included Flashcards'),

            // Flashcards preview list
            ...lesson.flashcards.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final card = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card $idx',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            onPressed: () {
                              WhereIsThisFromSheet.show(
                                context,
                                title: card.question,
                                sourceLines: card.sourceLines,
                                rawNoteLines: rawLines,
                              );
                            },
                            icon: const Icon(Icons.help_outline, size: 16),
                            label: const Text(
                              'Source Lines',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.answer,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _infoBadge(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.outline.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
