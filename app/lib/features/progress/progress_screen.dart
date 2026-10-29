import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/section_header.dart';
import '../providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metricsAsync = ref.watch(schedulerMetricsProvider);
    final lessonsAsync = ref.watch(allLessonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Progress')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            metricsAsync.when(
              data: (m) => Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProgressRing(
                        progress: m.masteryPercentage / 100,
                        centerText:
                            '${m.masteryPercentage.toStringAsFixed(0)}%',
                        subText: 'Mastery',
                        radius: 46,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statRow(
                            Icons.schedule,
                            '${m.dueToday} Due Today',
                            colorScheme.primary,
                            theme,
                          ),
                          const SizedBox(height: 10),
                          _statRow(
                            Icons.check_circle,
                            '${m.masteredCards} Mastered (Box 5)',
                            Colors.green,
                            theme,
                          ),
                          const SizedBox(height: 10),
                          _statRow(
                            Icons.refresh,
                            '${m.learningCards} In Progress',
                            Colors.orange,
                            theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: 16),

            const SectionHeader(title: 'Spaced Repetition (Leitner System)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'NeuroScript AI schedules active recall sessions on intervals of 1, 3, 7, 14, and 30 days to counter the Ebbinghaus forgetting curve.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _boxBadge('Box 1', '1 Day', colorScheme),
                        _boxBadge('Box 2', '3 Days', colorScheme),
                        _boxBadge('Box 3', '7 Days', colorScheme),
                        _boxBadge('Box 4', '14 Days', colorScheme),
                        _boxBadge(
                          'Box 5',
                          '30 Days',
                          colorScheme,
                          isMastered: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const SectionHeader(title: 'Per-Lesson Status'),
            lessonsAsync.when(
              data: (lessons) => Column(
                children: lessons.map((l) {
                  final duePct = l.cardCount > 0
                      ? (l.dueCount / l.cardCount)
                      : 0.0;
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
                              Text(l.title, style: theme.textTheme.titleMedium),
                              Text(
                                '${l.cardCount - l.dueCount}/${l.cardCount} reviewed',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 1.0 - duePct,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(4),
                            color: colorScheme.primary,
                            backgroundColor: colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String text, Color color, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _boxBadge(
    String box,
    String interval,
    ColorScheme colorScheme, {
    bool isMastered = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isMastered
                ? Colors.green.withValues(alpha: 0.18)
                : colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMastered
                  ? Colors.green
                  : colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            box,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isMastered ? Colors.green[800] : colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          interval,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
