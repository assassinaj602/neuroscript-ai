// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/library/library_screen.dart
//
// Description:
//   Central study dashboard and lesson library screen (WP2.4).
//   Features comprehensive search, multi-criteria filtering, sorting,
//   review due metrics, note provenance & transcript details sheet,
//   concept map launcher, and soft-delete/recovery workflows.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/document_hash.dart';
import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/repository_interfaces.dart';
import '../providers.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Due Today', 'Mastered'
  String _selectedSort =
      'Default'; // 'Default', 'Title', 'Due Count', 'Card Count'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = ref.watch(appConfigProvider);
    final profileAsync = ref.watch(activeProfileProvider);
    final lessonsAsync = ref.watch(allLessonsProvider);
    final metricsAsync = ref.watch(schedulerMetricsProvider);
    final deletedAsync = ref.watch(deletedLessonsProvider);

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
              tooltip: 'Developer: Paste Test Note (Debug/Demo)',
              onPressed: () => _showPasteTestNoteDialog(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Concept Maps',
            onPressed: () => _showConceptMapPicker(context, ref),
          ),

          IconButton(
            icon: Badge(
              isLabelVisible: (deletedAsync.asData?.value.length ?? 0) > 0,
              label: Text('${deletedAsync.asData?.value.length ?? 0}'),
              child: const Icon(Icons.delete_sweep_outlined),
            ),
            tooltip: 'Recently Deleted Sets',
            onPressed: () => _showRecentlyDeletedSheet(
              context,
              ref,
              deletedAsync.asData?.value ?? [],
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
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

                  const SizedBox(height: 14),

                  // Search and Filter Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search lessons or topics...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() => _searchQuery = val.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<String>(
                        tooltip: 'Sort Lessons',
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.sort,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        onSelected: (val) =>
                            setState(() => _selectedSort = val),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'Default',
                            child: Text('Default Order'),
                          ),
                          const PopupMenuItem(
                            value: 'Title',
                            child: Text('Title (A-Z)'),
                          ),
                          const PopupMenuItem(
                            value: 'Due Count',
                            child: Text('Due Cards (Highest First)'),
                          ),
                          const PopupMenuItem(
                            value: 'Card Count',
                            child: Text('Total Cards (Highest First)'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Filter Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedFilter == 'All',
                        onSelected: (_) =>
                            setState(() => _selectedFilter = 'All'),
                      ),
                      FilterChip(
                        label: const Text('Due Today'),
                        selected: _selectedFilter == 'Due Today',
                        onSelected: (_) =>
                            setState(() => _selectedFilter = 'Due Today'),
                      ),
                      FilterChip(
                        label: const Text('Mastered'),
                        selected: _selectedFilter == 'Mastered',
                        onSelected: (_) =>
                            setState(() => _selectedFilter = 'Mastered'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

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
                                  'Sample study lessons load automatically on startup.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Apply search filter
                      var filtered = lessons.where((l) {
                        if (_searchQuery.isNotEmpty &&
                            !l.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            )) {
                          return false;
                        }
                        if (_selectedFilter == 'Due Today' && l.dueCount == 0) {
                          return false;
                        }
                        if (_selectedFilter == 'Mastered' && l.dueCount > 0) {
                          return false;
                        }
                        return true;
                      }).toList();

                      // Apply sorting
                      if (_selectedSort == 'Title') {
                        filtered.sort((a, b) => a.title.compareTo(b.title));
                      } else if (_selectedSort == 'Due Count') {
                        filtered.sort(
                          (a, b) => b.dueCount.compareTo(a.dueCount),
                        );
                      } else if (_selectedSort == 'Card Count') {
                        filtered.sort(
                          (a, b) => b.cardCount.compareTo(a.cardCount),
                        );
                      }

                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.filter_list_off,
                                  size: 48,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No lessons match "$_searchQuery"',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedFilter = 'All';
                                    });
                                  },
                                  child: const Text('Reset Search & Filters'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final textScale = MediaQuery.textScalerOf(context)
                              .scale(1.0);
                          final isWide =
                              constraints.maxWidth >= 640 && textScale < 1.4;
                          if (isWide) {
                            final extent = (148.0 * textScale).clamp(
                              148.0,
                              320.0,
                            );
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: extent,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final l = filtered[index];
                                return CardTile(
                                  margin: EdgeInsets.zero,
                                  title: l.title,
                                  subtitle:
                                      '${l.cardCount} cards • Concept Map • ${l.dueCount} due',
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.menu_book,
                                      color: colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  trailing: _buildLessonCardTrailing(
                                    context,
                                    ref,
                                    l,
                                    colorScheme,
                                  ),
                                  onTap: () {
                                    context.push('/lesson/${l.lessonId}');
                                  },
                                );
                              },
                            );
                          }

                          return Column(
                            children: filtered.map((l) {
                              return CardTile(
                                title: l.title,
                                subtitle:
                                    '${l.cardCount} cards • Concept Map • ${l.dueCount} due',
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                trailing: _buildLessonCardTrailing(
                                  context,
                                  ref,
                                  l,
                                  colorScheme,
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
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Database connection error: $err',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref.invalidate(allLessonsProvider);
                                    ref.invalidate(deletedLessonsProvider);
                                    ref.invalidate(schedulerMetricsProvider);
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry Connection'),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(appDatabaseProvider)
                                          .clearAllData();
                                      await ref
                                          .read(seedImporterProvider)
                                          .importSeedLessons();
                                    } on Exception catch (e, st) {
                                      debugPrint(
                                        'Failed to reset and re-load seeds: $e\n$st',
                                      );
                                    }
                                    ref.invalidate(allLessonsProvider);
                                    ref.invalidate(deletedLessonsProvider);
                                    ref.invalidate(schedulerMetricsProvider);
                                  },
                                  icon: const Icon(Icons.restart_alt),
                                  label: const Text(
                                    'Reset & Re-load Seed Lessons',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildLessonCardTrailing(
    BuildContext context,
    WidgetRef ref,
    LessonSummary l,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.account_tree_outlined, size: 20),
          tooltip: 'Concept Map',
          onPressed: () => context.push('/concept_map/${l.lessonId}'),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          tooltip: 'Lesson Options',
          onSelected: (val) {
            if (val == 'study') {
              context.push('/lesson/${l.lessonId}');
            } else if (val == 'edit') {
              context.push('/lesson/${l.lessonId}/edit');
            } else if (val == 'concept_map') {
              context.push('/concept_map/${l.lessonId}');
            } else if (val == 'note_details') {
              _showNoteDetailsSheet(context, ref, l);
            } else if (val == 'delete') {
              _confirmDeleteLesson(context, ref, l.lessonId, l.title);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'study',
              child: Row(
                children: [
                  Icon(Icons.play_arrow_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Study Lesson'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Edit Set'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'concept_map',
              child: Row(
                children: [
                  Icon(Icons.account_tree_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Concept Map'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'note_details',
              child: Row(
                children: [
                  Icon(Icons.description_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Note Transcript & Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete Set',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Displays the full original handwritten lecture note transcript, SHA-256 hash, and provenance.
  void _showNoteDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    LessonSummary l,
  ) async {
    final note = await ref.read(noteRepositoryProvider).getNoteById(l.noteId);
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Source Note Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fingerprint, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'SHA-256: ${note?.documentHash ?? "Unknown"}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: 'Copy Hash',
                            onPressed: () {
                              if (note != null) {
                                Clipboard.setData(
                                  ClipboardData(text: note.documentHash),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Document Hash copied to clipboard',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Note ID: ${l.noteId} • ${l.cardCount} Flashcards Linked',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Original OCR Lecture Transcript:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        note?.rawOcrText.trim().isNotEmpty == true
                            ? note!.rawOcrText
                            : 'No raw transcript recorded for this note.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.account_tree_outlined),
                        label: const Text('Concept Map'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/concept_map/${l.lessonId}');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Study Now'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/lesson/${l.lessonId}');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteLesson(
    BuildContext context,
    WidgetRef ref,
    String lessonId,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard Set?'),
        content: Text(
          'Are you sure you want to delete "$title"?\n\nYou can recover it anytime from Recently Deleted.',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "$title"'),
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

  void _showRecentlyDeletedSheet(
    BuildContext context,
    WidgetRef ref,
    List<LessonSummary> deletedLessons,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return Consumer(
          builder: (context, ref, _) {
            final currentDeleted =
                ref.watch(deletedLessonsProvider).asData?.value ??
                deletedLessons;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.delete_sweep_outlined,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Recently Deleted (${currentDeleted.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (currentDeleted.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.restore, size: 16),
                            label: const Text('Restore All'),
                            onPressed: () async {
                              for (final l in currentDeleted) {
                                await ref
                                    .read(lessonRepositoryProvider)
                                    .restoreLesson(l.lessonId);
                              }
                              ref.invalidate(allLessonsProvider);
                              ref.invalidate(deletedLessonsProvider);
                              ref.invalidate(schedulerMetricsProvider);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'All sets restored to library.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deleted flashcard sets can be recovered back to your study library or permanently deleted.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (currentDeleted.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Trash is empty.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: currentDeleted.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final l = currentDeleted[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.menu_book,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                l.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('${l.cardCount} cards in set'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore),
                                    tooltip: 'Restore to Library',
                                    color: colorScheme.primary,
                                    onPressed: () async {
                                      await ref
                                          .read(lessonRepositoryProvider)
                                          .restoreLesson(l.lessonId);
                                      ref.invalidate(allLessonsProvider);
                                      ref.invalidate(deletedLessonsProvider);
                                      ref.invalidate(schedulerMetricsProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Restored "${l.title}"',
                                                ),
                                              ),
                                            );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever),
                                    tooltip: 'Delete Permanently',
                                    color: colorScheme.error,
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: const Text(
                                            'Delete Permanently?',
                                          ),
                                          content: Text(
                                            'This will permanently delete "${l.title}" and its review progress. This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(c).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    colorScheme.error,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(c).pop(true),
                                              child: const Text(
                                                'Delete Permanently',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ref
                                            .read(lessonRepositoryProvider)
                                            .permanentlyDeleteLesson(
                                              l.lessonId,
                                            );
                                        ref.invalidate(allLessonsProvider);
                                        ref.invalidate(deletedLessonsProvider);
                                        ref.invalidate(
                                          schedulerMetricsProvider,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Quick concept map picker allowing direct exploration from the dashboard.
  void _showConceptMapPicker(BuildContext context, WidgetRef ref) async {
    final lessons = await ref.read(lessonRepositoryProvider).getAllLessons();
    if (!context.mounted) return;
    if (lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No lessons available to display concept maps.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Explore Concept Maps',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a lesson to explore its interactive visual graph and note grounding:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: lessons.map((l) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.hub_outlined,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          l.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${l.cardCount} cards • Interactive graph',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          context.push('/concept_map/${l.lessonId}');
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Milestone 2 developer utility: paste raw test note text to import cards
  /// into the local encrypted SQLite database without needing camera OCR.
  /// Guarded so it is accessible only in demoMode / debug mode.
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
              final noteId =
                  existingNoteId ??
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
                    groundingScore: null,
                    verified: false,
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

              final activeProf = await ref
                  .read(profileRepositoryProvider)
                  .getActiveProfile();
              final lessonModel = LessonModel(
                schemaVersion: 1,
                title: title,
                meta: LessonMeta(
                  profile: activeProf?.displayName ?? 'Dyslexia',
                  source: 'custom_import',
                  promptVersion: 'v1',
                ),
                conceptMap: ConceptMapModel(nodes: nodes, edges: edges),
                flashcards: flashcards,
                rawNotes: rawText,
              );

              await lessonRepo.saveLesson(noteId: noteId, lesson: lessonModel);

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
