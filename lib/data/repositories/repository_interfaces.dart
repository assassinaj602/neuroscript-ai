// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/data/repositories/repository_interfaces.dart
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
import '../../services/scheduler/leitner_scheduler.dart';

/// Contract for managing learner profile persistence and preferences.
abstract class ProfileRepository {
  /// Retrieves the active learner profile, or null if onboarding is pending.
  Future<ProfileType?> getActiveProfile();

  /// Persists the selected learner profile (ADHD, Dyslexia, or Autism).
  Future<void> saveProfile(ProfileType profile);

  /// Clears stored profile data to reset onboarding state.
  Future<void> resetProfile();
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

  /// Deletes a lesson and cascades removal to all its flashcards and review metrics.
  Future<void> deleteLesson(String lessonId);
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
