// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/lesson/lesson_overview_screen.dart
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
import '../common/where_is_this_from_sheet.dart';
import '../providers.dart';

class LessonOverviewScreen extends ConsumerWidget {
  const LessonOverviewScreen({
    super.key,
    required this.lessonId,
    required this.lesson,
  });

  final String lessonId;
  final LessonModel lesson;

  Future<void> _confirmDeleteLesson(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard Set?'),
        content: Text(
          'Are you sure you want to delete "${lesson.title}"?\n\nYou can recover it anytime from Recently Deleted in the Library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(lessonRepositoryProvider).deleteLesson(lessonId);
      ref.invalidate(allLessonsProvider);
      ref.invalidate(deletedLessonsProvider);
      ref.invalidate(schedulerMetricsProvider);

      if (context.mounted) {
        context.go('/library');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${lesson.title}"'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await ref
                    .read(lessonRepositoryProvider)
                    .restoreLesson(lessonId);
                ref.invalidate(allLessonsProvider);
                ref.invalidate(deletedLessonsProvider);
                ref.invalidate(schedulerMetricsProvider);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rawLines = lesson.rawNotes?.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Flashcards',
            onPressed: () async {
              final updated = await context.push<bool>(
                '/lesson/$lessonId/edit',
              );
              if (updated == true && context.mounted) {
                ref.invalidate(allLessonsProvider);
                context.go('/lesson/$lessonId');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Flashcards',
            onPressed: () => _confirmDeleteLesson(context, ref),
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
                          'Adaptive Active Recall & Concept Map Study Module',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (lesson.meta.source == 'seed')
                              _infoBadge(
                                Icons.edit_note,
                                'Seed lesson (author-written)',
                                colorScheme,
                              ),
                            _infoBadge(
                              Icons.style_outlined,
                              '${lesson.flashcards.length} Flashcards',
                              colorScheme,
                            ),
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

                // Main Action Buttons (Responsive Layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    if (isNarrow) {
                      return Column(
                        children: [
                          AppButton(
                            label: 'Review Now',
                            icon: Icons.play_arrow,
                            onPressed: () {
                              context.push('/review/$lessonId');
                            },
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            label: 'Concept Map',
                            icon: Icons.account_tree_outlined,
                            isSecondary: true,
                            onPressed: () {
                              context.push('/concept_map/$lessonId');
                            },
                          ),
                        ],
                      );
                    }
                    return Row(
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
                    );
                  },
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
                              Row(
                                children: [
                                  Text(
                                    'Card $idx',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (lesson.meta.source == 'seed')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Seed lesson (author-written)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else if (card.groundingScore != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Grounding: ${(card.groundingScore! * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
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
                                    source: lesson.meta.source,
                                    groundingScore: card.groundingScore,
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
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
