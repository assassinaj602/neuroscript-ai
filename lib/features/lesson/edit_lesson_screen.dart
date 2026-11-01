// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/lesson/edit_lesson_screen.dart
//
// Description:
//   Interactive flashcard set editor. Allows learners to edit the lesson title,
//   modify question and answer text, delete cards, and add new flashcards.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
import '../providers.dart';

class EditLessonScreen extends ConsumerStatefulWidget {
  const EditLessonScreen({
    super.key,
    required this.lessonId,
    required this.lesson,
  });

  final String lessonId;
  final LessonModel lesson;

  @override
  ConsumerState<EditLessonScreen> createState() => _EditLessonScreenState();
}

class _EditableCard {
  _EditableCard({
    required this.id,
    required String question,
    required String answer,
    required this.sourceLines,
  }) : questionController = TextEditingController(text: question),
       answerController = TextEditingController(text: answer);

  final String id;
  final List<int> sourceLines;
  final TextEditingController questionController;
  final TextEditingController answerController;

  void dispose() {
    questionController.dispose();
    answerController.dispose();
  }
}

class _EditLessonScreenState extends ConsumerState<EditLessonScreen> {
  late final TextEditingController _titleController;
  final List<_EditableCard> _cards = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson.title);
    for (final card in widget.lesson.flashcards) {
      _cards.add(
        _EditableCard(
          id: card.id,
          question: card.question,
          answer: card.answer,
          sourceLines: card.sourceLines,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _cards) {
      c.dispose();
    }
    super.dispose();
  }

  void _addNewCard() {
    setState(() {
      _cards.add(
        _EditableCard(
          id: 'new_${DateTime.now().microsecondsSinceEpoch}',
          question: '',
          answer: '',
          sourceLines: const [1],
        ),
      );
    });
  }

  void _removeCard(int index) {
    if (_cards.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A flashcard set must contain at least 1 card.'),
        ),
      );
      return;
    }
    setState(() {
      final removed = _cards.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson title cannot be empty.')),
      );
      return;
    }

    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].questionController.text.trim().isEmpty ||
          _cards[i].answerController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Card ${i + 1} must have both a question and an answer.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final updatedCards = _cards.map((c) {
        return FlashcardModel(
          id: c.id,
          question: c.questionController.text.trim(),
          answer: c.answerController.text.trim(),
          sourceLines: c.sourceLines,
        );
      }).toList();

      await ref
          .read(lessonRepositoryProvider)
          .updateLesson(
            lessonId: widget.lessonId,
            title: title,
            flashcards: updatedCards,
          );

      ref.invalidate(allLessonsProvider);
      ref.invalidate(schedulerMetricsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson updated successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving changes: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Flashcard Set'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionHeader(title: 'Lesson Details'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Title',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Photosynthesis Fundamentals',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Flashcards (${_cards.length})',
                  actionText: '+ Add Card',
                  onAction: _addNewCard,
                ),
                ...List.generate(_cards.length, (index) {
                  final card = _cards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Card ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                tooltip: 'Remove Card',
                                onPressed: () => _removeCard(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Question (Prompt)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: card.questionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Enter question...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Answer',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: card.answerController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter answer...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Add Another Flashcard',
                  icon: Icons.add,
                  isSecondary: true,
                  onPressed: _addNewCard,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Save All Changes',
                  icon: Icons.check,
                  isLoading: _isSaving,
                  onPressed: _saveChanges,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
