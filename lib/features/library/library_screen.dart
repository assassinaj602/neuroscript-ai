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

import '../../core/document_hash.dart';
import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
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
          if (config.demoMode)
            IconButton(
              icon: const Icon(Icons.note_add_outlined),
              tooltip: 'Developer: Paste Test Note (Debug)',
              onPressed: () => _showPasteTestNoteDialog(context, ref),
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 640;
                      if (isWide) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 115,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            final l = lessons[index];
                            return CardTile(
                              title: l.title,
                              subtitle:
                                  '${l.cardCount} flashcards • ${l.dueCount} due for review',
                              badgeText: l.source.toUpperCase(),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.1),
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
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              onTap: () {
                                context.push('/lesson/${l.lessonId}');
                              },
                            );
                          },
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
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            onTap: () {
                              context.push('/lesson/${l.lessonId}');
                            },
                          );
                        }).toList(),
                      );
                    },
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

  /// Milestone 2 developer utility: paste raw test note text to import cards
  /// into the local encrypted SQLite database without needing camera OCR.
  void _showPasteTestNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.developer_mode, size: 20),
            SizedBox(width: 8),
            Text('Paste Test Note (Debug)'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Milestone 2 test note importer: parses lines into study flashcards and persists them into the encrypted database.',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Title',
                  hintText: 'e.g., Computer Operating Systems',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Lecture Note Text',
                  hintText: 'Operating systems manage hardware resources.\nVirtual memory provides process isolation.\nContext switching swaps CPU state.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final rawText = noteController.text.trim();
              if (rawText.isEmpty) return;

              final title = titleController.text.trim().isNotEmpty
                  ? titleController.text.trim()
                  : rawText.split('\n').first;

              final docHash = DocumentHash.compute(rawText);
              final noteRepo = ref.read(noteRepositoryProvider);
              final lessonRepo = ref.read(lessonRepositoryProvider);

              final existingNoteId = await noteRepo.getNoteIdByHash(docHash);
              final noteId = existingNoteId ??
                  await noteRepo.saveNote(
                    rawOcrText: rawText,
                    documentHash: docHash,
                  );

              final lines = rawText
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .toList();

              final flashcards = <FlashcardModel>[];
              final nodes = <ConceptNodeModel>[];

              for (var i = 0; i < lines.length; i++) {
                final lineNum = i + 1;
                final textLine = lines[i];
                final parts = textLine.contains(':')
                    ? textLine.split(':')
                    : textLine.contains(' - ')
                        ? textLine.split(' - ')
                        : [textLine, textLine];

                final q = parts[0].trim();
                final a = parts.length > 1 ? parts[1].trim() : textLine;

                flashcards.add(
                  FlashcardModel(
                    id: 'c$lineNum',
                    question: q,
                    answer: a,
                    sourceLines: [lineNum],
                    chunks: [q, a],
                    groundingScore: 1.0,
                    verified: true,
                  ),
                );

                nodes.add(
                  ConceptNodeModel(
                    id: 'n$lineNum',
                    label: q,
                    sourceLines: [lineNum],
                  ),
                );
              }

              final edges = <ConceptEdgeModel>[];
              for (var i = 0; i < nodes.length - 1; i++) {
                edges.add(
                  ConceptEdgeModel(
                    from: nodes[i].id,
                    to: nodes[i + 1].id,
                    label: 'leads to',
                  ),
                );
              }

              final lessonModel = LessonModel(
                schemaVersion: 1,
                title: title,
                meta: const LessonMeta(
                  profile: 'ADHD',
                  source: 'seed',
                  promptVersion: 'v1',
                ),
                conceptMap: ConceptMapModel(nodes: nodes, edges: edges),
                flashcards: flashcards,
                rawNotes: rawText,
              );

              await lessonRepo.saveLesson(
                noteId: noteId,
                lesson: lessonModel,
              );

              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                ref.invalidate(allLessonsProvider);
                ref.invalidate(schedulerMetricsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Imported "$title" with ${flashcards.length} cards into encrypted DB!',
                    ),
                  ),
                );
              }
            },
            child: const Text('Import Note'),
          ),
        ],
      ),
    );
  }
}
