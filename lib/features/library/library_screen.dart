// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/library/library_screen.dart
//
// Description:
//   Central study dashboard and lesson library screen (WP2.4).
//   Displays the active learner profile tag, daily review metrics banner,
//   lesson cards with due counts, and quick navigation actions to Progress,
//   Architecture Blueprints, and Settings.
//
// Key Concepts:
//   - Study Dashboard Banner: Prominently highlights cards due for review today
//     and total cards mastered, providing immediate task focus and positive motivation.
//   - Empty State Grace: If no lessons exist, displays a friendly, non-threatening
//     illustration and instructions rather than a blank screen.
//   - Feature Flag Isolation: The note capture camera button is hidden when
//     [enableCapture] is false, honoring Rule 5 ("Feature flags manage demos").
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = ref.watch(appConfigProvider);
    final profileAsync = ref.watch(activeProfileProvider);
    final lessonsAsync = ref.watch(allLessonsProvider);
    final metricsAsync = ref.watch(schedulerMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroScript AI'),
        actions: [
          profileAsync.when(
            data: (p) => p == null
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        p.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Architecture & Specifications',
            onPressed: () => context.push('/architecture'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Progress & Stats',
            onPressed: () => context.push('/progress'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allLessonsProvider);
                ref.invalidate(schedulerMetricsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
              // Study Dashboard Banner
              metricsAsync.when(
                data: (metrics) => Card(
                  color: colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${metrics.dueToday} Cards Due Today',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${metrics.masteredCards} of ${metrics.totalCards} cards mastered with spaced repetition',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.alarm_on,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox(height: 90),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              const SectionHeader(title: 'My Study Lessons'),

              // Lessons List
              lessonsAsync.when(
                data: (lessons) {
                  if (lessons.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 64,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lessons found in library.',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seed sample lessons load automatically on first run.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: lessons.map((l) {
                      return CardTile(
                        title: l.title,
                        subtitle:
                            '${l.cardCount} flashcards • ${l.dueCount} due for review',
                        badgeText: l.source.toUpperCase(),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        onTap: () {
                          context.push('/lesson/${l.lessonId}');
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) =>
                    Center(child: Text('Error loading lessons: $err')),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
      // Capture button: hidden in M1-M2 via enableCapture flag
      floatingActionButton: config.enableCapture
          ? FloatingActionButton.extended(
              onPressed: () {
                // Arrives in M3
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Note'),
            )
          : null,
    );
  }
}
