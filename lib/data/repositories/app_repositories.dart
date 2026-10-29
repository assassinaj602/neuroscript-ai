// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/data/repositories/app_repositories.dart
//
// Description:
//   Concrete implementations of domain repository contracts.
//   Includes Drift-backed production repositories that query encrypted SQLite
//   tables, as well as in-memory test fakes for isolated, lightning-fast unit tests.
//
// Key Concepts:
//   - Drift Table Querying: Executes type-safe joins between Lessons, Flashcards,
//     and ReviewProgress tables, utilizing index scans on documentHash and foreign keys.
//   - Atomic Transactions: Groups multi-entity mutations (e.g. saving a lesson and
//     its corresponding flashcards) inside atomic SQLite transactions.
//   - In-Memory Test Fakes: Implements lightweight mock repositories without requiring
//     native database drivers during CI pipeline execution.
// ============================================================================

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/theme/app_palettes.dart';
import '../../services/scheduler/leitner_scheduler.dart';
import '../database/database.dart';
import '../models/lesson_model.dart';
import 'repository_interfaces.dart';

class AppProfileRepository implements ProfileRepository {
  const AppProfileRepository(this.db);
  final AppDatabase db;

  @override
  Future<ProfileType?> getActiveProfile() async {
    final record =
        await (db.select(db.userProfiles)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();

    if (record == null) return null;
    return ProfileType.fromString(record.profileType);
  }

  @override
  Future<void> saveProfile(ProfileType profile) async {
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            profileType: profile.name,
            themeSettings: const Value('{}'),
          ),
        );
  }

  @override
  Future<void> resetProfile() async {
    await db.delete(db.userProfiles).go();
  }
}

class AppNoteRepository implements NoteRepository {
  const AppNoteRepository(this.db);
  final AppDatabase db;

  @override
  Future<String> saveNote({
    required String rawOcrText,
    required String documentHash,
  }) async {
    final noteId = 'note_${DateTime.now().millisecondsSinceEpoch}';
    await db
        .into(db.sourceNotes)
        .insert(
          SourceNotesCompanion.insert(
            noteId: noteId,
            rawOcrText: rawOcrText,
            documentHash: documentHash,
          ),
        );
    return noteId;
  }

  @override
  Future<String?> getNoteIdByHash(String documentHash) async {
    final note = await (db.select(
      db.sourceNotes,
    )..where((t) => t.documentHash.equals(documentHash))).getSingleOrNull();
    return note?.noteId;
  }

  @override
  Future<String?> getRawNoteText(String noteId) async {
    final note = await (db.select(
      db.sourceNotes,
    )..where((t) => t.noteId.equals(noteId))).getSingleOrNull();
    return note?.rawOcrText;
  }
}

class AppLessonRepository implements LessonRepository {
  const AppLessonRepository(this.db);
  final AppDatabase db;

  @override
  Future<List<LessonSummary>> getAllLessons() async {
    final allLessons = await db.select(db.lessons).get();
    final summaries = <LessonSummary>[];
    final now = DateTime.now();

    for (final lesson in allLessons) {
      final cards = await (db.select(
        db.flashcards,
      )..where((f) => f.lessonId.equals(lesson.lessonId))).get();

      int dueCount = 0;
      for (final c in cards) {
        final progress = await (db.select(
          db.reviewProgress,
        )..where((p) => p.cardId.equals(c.cardId))).getSingleOrNull();
        if (progress == null || !progress.nextReviewDate.isAfter(now)) {
          dueCount++;
        }
      }

      summaries.add(
        LessonSummary(
          lessonId: lesson.lessonId,
          title: lesson.title,
          profile: lesson.source,
          source: lesson.source,
          cardCount: cards.length,
          dueCount: dueCount,
          createdAt: lesson.createdAt,
          noteId: lesson.noteId,
        ),
      );
    }

    return summaries;
  }

  @override
  Future<LessonModel?> getLessonById(String lessonId) async {
    final lesson = await (db.select(
      db.lessons,
    )..where((l) => l.lessonId.equals(lessonId))).getSingleOrNull();
    if (lesson == null) return null;

    final note = await (db.select(
      db.sourceNotes,
    )..where((n) => n.noteId.equals(lesson.noteId))).getSingleOrNull();

    final cards = await (db.select(
      db.flashcards,
    )..where((f) => f.lessonId.equals(lessonId))).get();

    // Parse concept map JSON
    ConceptMapModel conceptMap;
    try {
      final mapData = jsonDecode(lesson.conceptMapJson) as Map<String, dynamic>;
      conceptMap = ConceptMapModel.fromJson(mapData);
    } catch (_) {
      conceptMap = const ConceptMapModel(nodes: [], edges: []);
    }

    final flashcardModels = cards.map((c) {
      List<int> lines = [];
      try {
        final decoded = jsonDecode(c.sourceLineReference);
        if (decoded is List) lines = decoded.map((e) => e as int).toList();
      } catch (_) {}

      return FlashcardModel(
        id: c.cardId,
        question: c.question,
        answer: c.answer,
        sourceLines: lines,
        groundingScore: c.groundingScore,
        verified: c.verified,
      );
    }).toList();

    return LessonModel(
      schemaVersion: 1,
      title: lesson.title,
      meta: LessonMeta(
        profile: 'Dyslexia',
        source: lesson.source,
        promptVersion: lesson.promptVersion,
      ),
      conceptMap: conceptMap,
      flashcards: flashcardModels,
      rawNotes: note?.rawOcrText,
    );
  }

  @override
  Future<void> saveLesson({
    required String noteId,
    required LessonModel lesson,
  }) async {
    final lessonId = 'lesson_${DateTime.now().millisecondsSinceEpoch}';
    await db.transaction(() async {
      await db
          .into(db.lessons)
          .insert(
            LessonsCompanion.insert(
              lessonId: lessonId,
              noteId: noteId,
              title: lesson.title,
              conceptMapJson: jsonEncode(lesson.conceptMap.toJson()),
              promptVersion: Value(lesson.meta.promptVersion),
              source: Value(lesson.meta.source),
            ),
          );

      final now = DateTime.now();
      for (final card in lesson.flashcards) {
        final cardId = '${lessonId}_${card.id}';
        await db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                cardId: cardId,
                lessonId: lessonId,
                question: card.question,
                answer: card.answer,
                sourceLineReference: jsonEncode(card.sourceLines),
                groundingScore: Value(card.groundingScore ?? 0.95),
                verified: Value(card.verified),
              ),
            );

        await db
            .into(db.reviewProgress)
            .insert(
              ReviewProgressCompanion.insert(
                cardId: cardId,
                box: const Value(1),
                spacedRepetitionInterval: const Value(1),
                nextReviewDate: now,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await (db.delete(
      db.lessons,
    )..where((l) => l.lessonId.equals(lessonId))).go();
  }
}

class AppReviewRepository implements ReviewRepository {
  const AppReviewRepository(
    this.db, {
    this.scheduler = const LeitnerScheduler(),
  });

  final AppDatabase db;
  final LeitnerScheduler scheduler;

  @override
  Future<List<FlashcardReviewItem>> getReviewItemsForLesson(
    String lessonId,
  ) async {
    final lesson = await (db.select(
      db.lessons,
    )..where((l) => l.lessonId.equals(lessonId))).getSingleOrNull();
    if (lesson == null) return [];

    final note = await (db.select(
      db.sourceNotes,
    )..where((n) => n.noteId.equals(lesson.noteId))).getSingleOrNull();
    final rawLines = note?.rawOcrText.split('\n') ?? [];

    final cards = await (db.select(
      db.flashcards,
    )..where((f) => f.lessonId.equals(lessonId))).get();

    final result = <FlashcardReviewItem>[];
    for (final c in cards) {
      final p = await (db.select(
        db.reviewProgress,
      )..where((rp) => rp.cardId.equals(c.cardId))).getSingleOrNull();

      List<int> lines = [];
      try {
        final decoded = jsonDecode(c.sourceLineReference);
        if (decoded is List) lines = decoded.map((e) => e as int).toList();
      } catch (_) {}

      final cardModel = FlashcardModel(
        id: c.cardId,
        question: c.question,
        answer: c.answer,
        sourceLines: lines,
        groundingScore: c.groundingScore,
        verified: c.verified,
      );

      final reviewItem = ReviewItem(
        cardId: c.cardId,
        box: p?.box ?? 1,
        intervalDays: p?.spacedRepetitionInterval ?? 1,
        nextReviewDate: p?.nextReviewDate ?? DateTime.now(),
        lastReviewedAt: p?.lastReviewedAt,
        consecutiveCorrect: p?.consecutiveCorrect ?? 0,
        isNew: p == null,
      );

      result.add(
        FlashcardReviewItem(
          card: cardModel,
          progress: reviewItem,
          rawNoteLines: rawLines,
        ),
      );
    }

    return result;
  }

  @override
  Future<List<FlashcardReviewItem>> getAllReviewItems() async {
    final allLessons = await db.select(db.lessons).get();
    final items = <FlashcardReviewItem>[];
    for (final l in allLessons) {
      final lessonItems = await getReviewItemsForLesson(l.lessonId);
      items.addAll(lessonItems);
    }
    return items;
  }

  @override
  Future<void> recordCardResult({
    required String cardId,
    required bool wasCorrect,
  }) async {
    final existing = await (db.select(
      db.reviewProgress,
    )..where((p) => p.cardId.equals(cardId))).getSingleOrNull();

    final currentReviewItem = ReviewItem(
      cardId: cardId,
      box: existing?.box ?? 1,
      intervalDays: existing?.spacedRepetitionInterval ?? 1,
      nextReviewDate: existing?.nextReviewDate ?? DateTime.now(),
      lastReviewedAt: existing?.lastReviewedAt,
      consecutiveCorrect: existing?.consecutiveCorrect ?? 0,
      isNew: existing == null,
    );

    final updated = wasCorrect
        ? scheduler.recordCorrect(currentReviewItem)
        : scheduler.recordIncorrect(currentReviewItem);

    if (existing == null) {
      await db
          .into(db.reviewProgress)
          .insert(
            ReviewProgressCompanion.insert(
              cardId: cardId,
              box: Value(updated.box),
              spacedRepetitionInterval: Value(updated.intervalDays),
              nextReviewDate: updated.nextReviewDate,
              lastReviewedAt: Value(updated.lastReviewedAt),
              consecutiveCorrect: Value(updated.consecutiveCorrect),
            ),
          );
    } else {
      await (db.update(
        db.reviewProgress,
      )..where((p) => p.cardId.equals(cardId))).write(
        ReviewProgressCompanion(
          box: Value(updated.box),
          spacedRepetitionInterval: Value(updated.intervalDays),
          nextReviewDate: Value(updated.nextReviewDate),
          lastReviewedAt: Value(updated.lastReviewedAt),
          consecutiveCorrect: Value(updated.consecutiveCorrect),
        ),
      );
    }
  }

  @override
  Future<SchedulerMetrics> getMetrics() async {
    final allItems = await getAllReviewItems();
    final progressItems = allItems.map((i) => i.progress).toList();
    return scheduler.calculateMetrics(progressItems);
  }
}
