// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/common/where_is_this_from_sheet.dart
//
// Description:
//   Line-Level Grounding Provenance modal bottom sheet (WP2.4).
//   Displays the complete original handwritten note transcription lines,
//   visually highlighting the exact 1-based source lines cited by a flashcard
//   or concept map node.
//
// Key Concepts:
//   - Hallucination Auditing: Empowers students to immediately verify whether
//     a generated fact came from their own notes, establishing trust.
//   - Line Highlighting: Cited line numbers are rendered with a prominent outline
//     and tinted background, while non-cited lines remain legible in the background.
//   - High-Contrast Badging: Displays the calculated mathematical grounding score G
//     and verification status with clear explanation.
// ============================================================================

import 'package:flutter/material.dart';

class WhereIsThisFromSheet extends StatelessWidget {
  const WhereIsThisFromSheet({
    super.key,
    required this.title,
    required this.sourceLines,
    required this.rawNoteLines,
    this.source,
    this.groundingScore,
  });

  final String title;
  final List<int> sourceLines;
  final List<String> rawNoteLines;
  final String? source;
  final double? groundingScore;

  static void show(
    BuildContext context, {
    required String title,
    required List<int> sourceLines,
    required List<String> rawNoteLines,
    String? source,
    double? groundingScore,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhereIsThisFromSheet(
        title: title,
        sourceLines: sourceLines,
        rawNoteLines: rawNoteLines,
        source: source,
        groundingScore: groundingScore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final linesSet = sourceLines.toSet();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where is this from?',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Line-level grounding evidence from your original notes.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close sheet',
                    ),
                  ],
                ),
              ),

              // Citation chip banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 20,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sourceLines.isEmpty
                            ? 'General lesson reference'
                            : 'Derived from note ${sourceLines.length == 1 ? "line" : "lines"}: ${sourceLines.join(", ")}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (source == 'seed')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seed lesson (author-written)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (groundingScore != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Grounding Score: ${(groundingScore! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 24),

              // Note lines list
              Expanded(
                child: rawNoteLines.isEmpty
                    ? Center(
                        child: Text(
                          'No source note text available.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: rawNoteLines.length,
                        itemBuilder: (context, index) {
                          final lineNumber = index + 1;
                          final isCited = linesSet.contains(lineNumber);
                          final lineText = rawNoteLines[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCited
                                  ? colorScheme.primary.withValues(alpha: 0.12)
                                  : theme.cardTheme.color ?? Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCited
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(
                                        alpha: 0.3,
                                      ),
                                width: isCited ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$lineNumber',
                                    style: TextStyle(
                                      fontWeight: isCited
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isCited
                                          ? colorScheme.primary
                                          : colorScheme.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    lineText,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isCited
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isCited
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurface.withValues(
                                              alpha: 0.85,
                                            ),
                                    ),
                                  ),
                                ),
                                if (isCited) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
