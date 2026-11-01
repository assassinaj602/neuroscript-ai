// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/data/repositories/app_repositories.dart
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
import 'package:flutter/foundation.dart';

import '../../core/models/profile_type.dart';

import '../../services/leitner_scheduler.dart';
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
    // Check if a note with this exact document hash already exists (deduplication)
    final existingId = await getNoteIdByHash(documentHash);
    if (existingId != null) {
      return existingId;
    }

    final noteId = 'note_${DateTime.now().millisecondsSinceEpoch}';
    try {
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
    } on Exception catch (e) {
      debugPrint('saveNote collision or database error: $e');
      // If a concurrent insert occurred and hit the UNIQUE constraint on documentHash,
      // return the canonical existing noteId gracefully.
      final fallback = await getNoteIdByHash(documentHash);
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
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

  @override
  Future<NoteDetails?> getNoteById(String noteId) async {
    final note = await (db.select(
      db.sourceNotes,
    )..where((t) => t.noteId.equals(noteId))).getSingleOrNull();
    if (note == null) return null;
    return NoteDetails(
      noteId: note.noteId,
      rawOcrText: note.rawOcrText,
      documentHash: note.documentHash,
      createdAt: note.createdAt,
    );
  }
}

class AppLessonRepository implements LessonRepository {
  const AppLessonRepository(this.db);
  final AppDatabase db;

  @override
  Future<List<LessonSummary>> getAllLessons() async {
    final allLessons = await (db.select(
      db.lessons,
    )..where((l) => l.isDeleted.equals(false))).get();
    if (allLessons.isEmpty) return [];

    final allCards = await db.select(db.flashcards).get();
    final allProgress = await db.select(db.reviewProgress).get();
    final progressMap = {for (final p in allProgress) p.cardId: p};
    final cardsByLesson = <String, List<Flashcard>>{};
    for (final c in allCards) {
      cardsByLesson.putIfAbsent(c.lessonId, () => []).add(c);
    }

    final summaries = <LessonSummary>[];
    final now = DateTime.now();

    for (final lesson in allLessons) {
      final cards = cardsByLesson[lesson.lessonId] ?? [];
      int dueCount = 0;
      for (final c in cards) {
        final progress = progressMap[c.cardId];
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
    } on Exception catch (e) {
      debugPrint('Failed to parse concept map JSON for ${lesson.lessonId}: $e');
      conceptMap = const ConceptMapModel(nodes: [], edges: []);
    }

    final flashcardModels = cards.map((c) {
      List<int> lines = [];
      try {
        final decoded = jsonDecode(c.sourceLineReference);
        if (decoded is List) lines = decoded.map((e) => e as int).toList();
      } on Exception catch (e) {
        debugPrint('Failed to parse sourceLineReference for ${c.cardId}: $e');
      }

      return FlashcardModel(
        id: c.cardId,
        question: c.question,
        answer: c.answer,
        sourceLines: lines,
        groundingScore: c.groundingScore,
        verified: c.verified,
      );
    }).toList();

    final activeProfileRecord =
        await (db.select(db.userProfiles)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();

    final activeProfile = activeProfileRecord != null
        ? ProfileType.fromString(activeProfileRecord.profileType).displayName
        : 'Dyslexia';

    return LessonModel(
      schemaVersion: 1,
      title: lesson.title,
      meta: LessonMeta(
        profile: activeProfile,
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
                groundingScore: Value(card.groundingScore),
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
  Future<List<LessonSummary>> getDeletedLessons() async {
    final trashedLessons = await (db.select(
      db.lessons,
    )..where((l) => l.isDeleted.equals(true))).get();
    if (trashedLessons.isEmpty) return [];

    final allCards = await db.select(db.flashcards).get();
    final cardsByLesson = <String, List<Flashcard>>{};
    for (final c in allCards) {
      cardsByLesson.putIfAbsent(c.lessonId, () => []).add(c);
    }

    final summaries = <LessonSummary>[];
    for (final lesson in trashedLessons) {
      final cards = cardsByLesson[lesson.lessonId] ?? [];
      summaries.add(
        LessonSummary(
          lessonId: lesson.lessonId,
          title: lesson.title,
          profile: lesson.source,
          source: lesson.source,
          cardCount: cards.length,
          dueCount: 0,
          createdAt: lesson.createdAt,
          noteId: lesson.noteId,
        ),
      );
    }
    return summaries;
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await (db.update(db.lessons)..where((l) => l.lessonId.equals(lessonId)))
        .write(const LessonsCompanion(isDeleted: Value(true)));
  }

  @override
  Future<void> restoreLesson(String lessonId) async {
    await (db.update(db.lessons)..where((l) => l.lessonId.equals(lessonId)))
        .write(const LessonsCompanion(isDeleted: Value(false)));
  }

  @override
  Future<void> permanentlyDeleteLesson(String lessonId) async {
    await (db.delete(
      db.lessons,
    )..where((l) => l.lessonId.equals(lessonId))).go();
  }

  @override
  Future<void> updateLesson({
    required String lessonId,
    required String title,
    required List<FlashcardModel> flashcards,
  }) async {
    await db.transaction(() async {
      // 1. Update lesson title
      await (db.update(db.lessons)..where((l) => l.lessonId.equals(lessonId)))
          .write(LessonsCompanion(title: Value(title)));

      // 2. Fetch existing cards in DB
      final existingDbCards = await (db.select(
        db.flashcards,
      )..where((f) => f.lessonId.equals(lessonId))).get();
      final existingIds = existingDbCards.map((c) => c.cardId).toSet();
      final incomingIds = flashcards.map((c) => c.id).toSet();

      // 3. Delete cards that were removed
      for (final existing in existingDbCards) {
        if (!incomingIds.contains(existing.cardId)) {
          await (db.delete(
            db.flashcards,
          )..where((f) => f.cardId.equals(existing.cardId))).go();
        }
      }

      // 4. Update existing or insert new cards
      final now = DateTime.now();
      for (final card in flashcards) {
        if (existingIds.contains(card.id)) {
          // Update existing card
          await (db.update(
            db.flashcards,
          )..where((f) => f.cardId.equals(card.id))).write(
            FlashcardsCompanion(
              question: Value(card.question),
              answer: Value(card.answer),
              sourceLineReference: Value(jsonEncode(card.sourceLines)),
            ),
          );
        } else {
          // Insert new card
          final newCardId = card.id.isNotEmpty && !card.id.startsWith('new_')
              ? card.id
              : '${lessonId}_c_${DateTime.now().microsecondsSinceEpoch}_${card.hashCode.abs()}';
          await db
              .into(db.flashcards)
              .insert(
                FlashcardsCompanion.insert(
                  cardId: newCardId,
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
                  cardId: newCardId,
                  box: const Value(1),
                  spacedRepetitionInterval: const Value(1),
                  nextReviewDate: now,
                ),
              );
        }
      }
    });
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

    final cardIds = cards.map((c) => c.cardId).toList();
    final progressList = cardIds.isEmpty
        ? <ReviewProgressData>[]
        : await (db.select(
            db.reviewProgress,
          )..where((rp) => rp.cardId.isIn(cardIds))).get();
    final progressMap = {for (final p in progressList) p.cardId: p};

    final result = <FlashcardReviewItem>[];
    for (final c in cards) {
      final p = progressMap[c.cardId];

      List<int> lines = [];
      try {
        final decoded = jsonDecode(c.sourceLineReference);
        if (decoded is List) lines = decoded.map((e) => e as int).toList();
      } on Exception catch (e) {
        debugPrint('Failed to decode sourceLineReference for ${c.cardId}: $e');
      }

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
    final allLessons = await (db.select(
      db.lessons,
    )..where((l) => l.isDeleted.equals(false))).get();
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
