// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/data/database/tables.dart
//
// Description:
//   Drift table schema definitions adhering strictly to Appendix A of the
//   Milestone Execution Plan and Section 5.3 of the Project Proposal.
//
// Key Concepts:
//   - Drift (Moor): A reactive, type-safe persistence library for Dart & SQLite.
//   - Relational Schemata:
//     * UserProfiles: Stores the active neurodivergent profile (ADHD, Dyslexia, Autism).
//     * SourceNotes: Stores raw OCR transcripts and cryptographic SHA-256 document hashes.
//     * Lessons: Contains lesson metadata, concept graph JSON, and synthesis source.
//     * Flashcards: Stores question/answer pairs, source lines, and grounding scores.
//     * ReviewProgress: Tracks the Leitner spaced repetition box (1-5) and next review dates.
//   - Referential Integrity: Configured with [KeyAction.cascade] foreign keys so that
//     deleting a note or lesson automatically cleans up child cards and review metrics,
//     preventing orphaned data and ensuring zero data leakage.
// ============================================================================

import 'package:drift/drift.dart';

/// Table storing learner accessibility preferences and active profile selection.
class UserProfiles extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Profile type identifier: 'ADHD', 'Dyslexia', or 'Autism'.
  TextColumn get profileType => text()();

  /// JSON string containing profile-specific fine-tuning (e.g. textScale, speechSpeed).
  TextColumn get themeSettings => text().withDefault(const Constant('{}'))();

  /// Timestamp when the profile was chosen or created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Table storing raw OCR text transcribed from handwritten student lecture notes.
class SourceNotes extends Table {
  /// Unique identifier (PK) for the source note.
  TextColumn get noteId => text()();

  /// The raw, unformatted OCR text extracted from the handwritten note pages.
  TextColumn get rawOcrText => text()();

  /// Deterministic SHA-256 hash of normalized note text, used for on-device caching.
  TextColumn get documentHash => text()();

  /// Timestamp of optical acquisition or note creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {noteId};
}

/// Table storing structured lessons compiled from source notes.
class Lessons extends Table {
  /// Unique identifier (PK) for the lesson.
  TextColumn get lessonId => text()();

  /// Foreign key referencing the parent note in [SourceNotes], with cascade delete.
  TextColumn get noteId =>
      text().references(SourceNotes, #noteId, onDelete: KeyAction.cascade)();

  /// The topic or title of the lesson (e.g., 'Photosynthesis and Cellular Respiration').
  TextColumn get title => text()();

  /// JSON representation of the visual concept map graph (nodes, edges, and citations).
  TextColumn get conceptMapJson => text()();

  /// Version of the prompt engineering template used for compilation (e.g., 'v1').
  TextColumn get promptVersion => text().withDefault(const Constant('v1'))();

  /// Origin of the lesson content: 'seed', 'mock', 'cloud', or 'device'.
  TextColumn get source => text().withDefault(const Constant('seed'))();

  /// Timestamp when the lesson was generated and stored.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {lessonId};
}

/// Table storing line-grounded study flashcards generated for a lesson.
class Flashcards extends Table {
  /// Unique identifier (PK) for the flashcard.
  TextColumn get cardId => text()();

  /// Foreign key referencing the parent lesson in [Lessons], with cascade delete.
  TextColumn get lessonId =>
      text().references(Lessons, #lessonId, onDelete: KeyAction.cascade)();

  /// Prompt / Question displayed on the front of the active recall card.
  TextColumn get question => text()();

  /// Answer revealed on the back of the card after learner interaction.
  TextColumn get answer => text()();

  /// JSON-encoded array of 1-based source OCR line numbers supporting this card (e.g., '[3, 4]').
  TextColumn get sourceLineReference => text()();

  /// Mathematical grounding verification score G (normalized 0.0 to 1.0).
  RealColumn get groundingScore => real().nullable()();

  /// Boolean flag indicating whether this card passed the grounding verification gate.
  BoolColumn get verified => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Table tracking the Leitner Spaced Repetition state and learning metrics per card.
class ReviewProgress extends Table {
  /// Auto-incrementing primary key.
  IntColumn get progressId => integer().autoIncrement()();

  /// Foreign key referencing the associated [Flashcards] row, with cascade delete.
  TextColumn get cardId =>
      text().references(Flashcards, #cardId, onDelete: KeyAction.cascade)();

  /// Current Leitner Box level (1 through 5).
  IntColumn get box => integer().withDefault(const Constant(1))();

  /// Interval in days before this card is due for review again (1, 3, 7, 14, 30 days).
  IntColumn get spacedRepetitionInterval =>
      integer().withDefault(const Constant(1))();

  /// Precise calendar date and time when the card becomes due for review.
  DateTimeColumn get nextReviewDate => dateTime()();

  /// Timestamp of the most recent review session for this card.
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  /// Number of consecutive times this card has been answered correctly.
  IntColumn get consecutiveCorrect =>
      integer().withDefault(const Constant(0))();
}
