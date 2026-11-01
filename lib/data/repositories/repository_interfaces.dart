// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/data/repositories/repository_interfaces.dart
//
// Description:
//   Abstract domain repository interfaces adhering to WP2.1 and the
//   Dependency Inversion Principle (DIP).
//
// Architectural Concepts:
//   - UI / Persistence Decoupling: UI widgets and Riverpod state controllers
//     interact strictly through these abstract contracts, ensuring that presentation
//     logic never imports Drift, SQLite, or raw SQL queries directly.
//   - In-Memory Test Seams: Enables lightning-fast unit tests to inject mock
//     or in-memory repository implementations without touching the local device disk.
// ============================================================================

import '../models/lesson_model.dart';
import '../../core/theme/app_palettes.dart';
import '../../services/leitner_scheduler.dart';

/// Contract for managing learner profile persistence and preferences.
abstract class ProfileRepository {
  /// Retrieves the active learner profile, or null if onboarding is pending.
  Future<ProfileType?> getActiveProfile();

  /// Persists the selected learner profile (ADHD, Dyslexia, or Autism).
  Future<void> saveProfile(ProfileType profile);

  /// Clears stored profile data to reset onboarding state.
  Future<void> resetProfile();
}

/// Full metadata and raw OCR transcript for a source lecture note.
class NoteDetails {
  final String noteId;
  final String rawOcrText;
  final String documentHash;
  final DateTime createdAt;

  const NoteDetails({
    required this.noteId,
    required this.rawOcrText,
    required this.documentHash,
    required this.createdAt,
  });
}

/// Contract for persisting raw OCR student lecture transcripts.
abstract class NoteRepository {
  /// Stores a new raw note transcript and returns the generated noteId.
  Future<String> saveNote({
    required String rawOcrText,
    required String documentHash,
  });

  /// Looks up an existing noteId by its deterministic SHA-256 document hash.
  Future<String?> getNoteIdByHash(String documentHash);

  /// Retrieves the raw transcript lines for a specific note.
  Future<String?> getRawNoteText(String noteId);

  /// Retrieves full note metadata including document hash and creation timestamp.
  Future<NoteDetails?> getNoteById(String noteId);
}

/// Contract for managing compiled lesson entities and concept maps.
abstract class LessonRepository {
  /// Fetches a summary list of all available lessons in the library.
  Future<List<LessonSummary>> getAllLessons();

  /// Loads full details (concept map, flashcards, metadata) for a single lesson.
  Future<LessonModel?> getLessonById(String lessonId);

  /// Saves a newly synthesized lesson into storage linked to its parent noteId.
  Future<void> saveLesson({
    required String noteId,
    required LessonModel lesson,
  });

  /// Deletes a lesson by moving it to recently deleted trash (soft delete).
  Future<void> deleteLesson(String lessonId);

  /// Restores a recently deleted lesson back to the active library.
  Future<void> restoreLesson(String lessonId);

  /// Permanently removes a lesson and cascades removal to all flashcards and progress.
  Future<void> permanentlyDeleteLesson(String lessonId);

  /// Fetches a list of all soft-deleted lessons currently in trash.
  Future<List<LessonSummary>> getDeletedLessons();

  /// Updates a lesson's title and its set of flashcards (edit questions, answers, add/remove cards).
  Future<void> updateLesson({
    required String lessonId,
    required String title,
    required List<FlashcardModel> flashcards,
  });
}

/// Contract for Leitner review tracking and spaced repetition scheduling.
abstract class ReviewRepository {
  /// Retrieves flashcards and spaced repetition states for a specific lesson.
  Future<List<FlashcardReviewItem>> getReviewItemsForLesson(String lessonId);

  /// Retrieves all review items across the entire library.
  Future<List<FlashcardReviewItem>> getAllReviewItems();

  /// Records learner recall outcome ("Got it" vs "Not yet") and recalculates Leitner box.
  Future<void> recordCardResult({
    required String cardId,
    required bool wasCorrect,
  });

  /// Computes cumulative mastery metrics across all decks.
  Future<SchedulerMetrics> getMetrics();
}

/// Lightweight summary representation of a lesson displayed in the library view.
class LessonSummary {
  const LessonSummary({
    required this.lessonId,
    required this.title,
    required this.profile,
    required this.source,
    required this.cardCount,
    required this.dueCount,
    required this.createdAt,
    required this.noteId,
  });

  final String lessonId;
  final String title;
  final String profile;
  final String source;
  final int cardCount;
  final int dueCount;
  final DateTime createdAt;
  final String noteId;
}

/// Composite item combining card content, Leitner progress, and source lines.
class FlashcardReviewItem {
  const FlashcardReviewItem({
    required this.card,
    required this.progress,
    required this.rawNoteLines,
  });

  final FlashcardModel card;
  final ReviewItem progress;
  final List<String> rawNoteLines;
}
