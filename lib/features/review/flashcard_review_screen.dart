// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/features/review/flashcard_review_screen.dart
//
// Description:
//   Active recall flashcard study interface (WP2.4).
//   Features 3D perspective flip card animations, Leitner self-assessment scoring
//   ("Got it" / "Not yet"), session progress bar, line-level source provenance sheet,
//   and end-of-session mastery summary.
//
// Key Concepts:
//   - 3D Matrix Transform: Utilizes `Transform` with matrix perspective projection
//     (0.001) to create an authentic, tactile card flip experience.
//   - Spaced Repetition Feedback: Tapping "Got it" advances the card's Leitner box;
//     tapping "Not yet" resets it to Box 1 for next-day review.
//   - Low-Stress Cognitive Pacing: Displays clear progress indicators ("Card 2 of 5")
//     and allows students to review source citations without leaving the session.
// ============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../data/repositories/repository_interfaces.dart';
import '../common/where_is_this_from_sheet.dart';

class FlashcardReviewScreen extends StatefulWidget {
  const FlashcardReviewScreen({
    super.key,
    required this.lessonTitle,
    required this.reviewItems,
    required this.onRecordResult,
  });

  final String lessonTitle;
  final List<FlashcardReviewItem> reviewItems;
  final Future<void> Function(String cardId, bool wasCorrect) onRecordResult;

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFront = true;
  int _correctCount = 0;
  int _incorrectCount = 0;
  bool _isSessionFinished = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  Future<void> _handleAnswer(bool gotIt) async {
    final currentItem = widget.reviewItems[_currentIndex];
    await widget.onRecordResult(currentItem.card.id, gotIt);

    if (gotIt) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }

    if (_currentIndex + 1 < widget.reviewItems.length) {
      // Move to next card
      _flipController.reset();
      setState(() {
        _currentIndex++;
        _isFront = true;
      });
    } else {
      // Session finished
      setState(() => _isSessionFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.reviewItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lessonTitle)),
        body: const Center(child: Text('No flashcards scheduled for review!')),
      );
    }

    if (_isSessionFinished) {
      return _buildSummaryScreen(theme, colorScheme);
    }

    final current = widget.reviewItems[_currentIndex];
    final total = widget.reviewItems.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Where is this from?',
            onPressed: () {
              WhereIsThisFromSheet.show(
                context,
                title: current.card.question,
                sourceLines: current.card.sourceLines,
                rawNoteLines: current.rawNoteLines,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar & Step Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card ${_currentIndex + 1} of $total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Box ${current.progress.box} (Next: ${current.progress.intervalDays}d)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Flippable Card Area
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isUnder = angle > pi / 2;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isUnder
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildCardFace(
                                  isFront: false,
                                  title: 'ANSWER',
                                  content: current.card.answer,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                  chunks: current.card.chunks,
                                  sourceLines: current.card.sourceLines,
                                  rawLines: current.rawNoteLines,
                                ),
                              )
                            : _buildCardFace(
                                isFront: true,
                                title: 'QUESTION',
                                content: current.card.question,
                                theme: theme,
                                colorScheme: colorScheme,
                                chunks: const [],
                                sourceLines: current.card.sourceLines,
                                rawLines: current.rawNoteLines,
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Not yet',
                      icon: Icons.replay,
                      isSecondary: true,
                      onPressed: () => _handleAnswer(false),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      label: 'Got it!',
                      icon: Icons.check,
                      onPressed: () => _handleAnswer(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
    );
  }

  Widget _buildCardFace({
    required bool isFront,
    required String title,
    required String content,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required List<String> chunks,
    required List<int> sourceLines,
    required List<String> rawLines,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isFront
              ? colorScheme.outline.withValues(alpha: 0.5)
              : colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isFront ? colorScheme.primary : colorScheme.secondary)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFront
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    WhereIsThisFromSheet.show(
                      context,
                      title: content,
                      sourceLines: sourceLines,
                      rawNoteLines: rawLines,
                    );
                  },
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text(
                    'Where from?',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            if (!isFront && chunks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: chunks.map((c) {
                  return Chip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    backgroundColor: colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap card to flip',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen(ThemeData theme, ColorScheme colorScheme) {
    final total = widget.reviewItems.length;
    final accuracy = total > 0 ? ((_correctCount / total) * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Complete')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
              const SizedBox(height: 24),
              Text(
                'Great Job!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You finished this study slice.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_correctCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text('Got It'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$_incorrectCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text('Review Again'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$accuracy%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text('Accuracy'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Back to Library',
                icon: Icons.check_circle_outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
