// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: app/test/repository_test.dart
//
// Description:
//   Unit test suite verifying Drift database repository operations, foreign key
//   cascade deletes, and in-memory test mocks under WP2.1 specifications.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/lesson_model.dart';
import 'package:neuro_script/data/repositories/app_repositories.dart';

void main() {
  group('Repository & Drift Database Tests (WP2.1 Verification)', () {
    late AppDatabase db;
    late AppProfileRepository profileRepo;
    late AppNoteRepository noteRepo;
    late AppLessonRepository lessonRepo;
    late AppReviewRepository reviewRepo;

    setUp(() {
      db = AppDatabase.memory();
      profileRepo = AppProfileRepository(db);
      noteRepo = AppNoteRepository(db);
      lessonRepo = AppLessonRepository(db);
      reviewRepo = AppReviewRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Profile repository saves and retrieves active profile', () async {
      var profile = await profileRepo.getActiveProfile();
      expect(profile, isNull);

      await profileRepo.saveProfile(ProfileType.adhd);
      profile = await profileRepo.getActiveProfile();
      expect(profile, equals(ProfileType.adhd));

      await profileRepo.saveProfile(ProfileType.dyslexia);
      profile = await profileRepo.getActiveProfile();
      expect(profile, equals(ProfileType.dyslexia));
    });

    test(
      'Note repository stores raw OCR text and indexes by documentHash',
      () async {
        const text = '1: First line\n2: Second line';
        const hash =
            'a69f73cca23a9ac5c8b567dc185a756e97a9f8260d11a369d6e652fe2e33a4c4';

        final noteId = await noteRepo.saveNote(
          rawOcrText: text,
          documentHash: hash,
        );
        expect(noteId, startsWith('note_'));

        final foundId = await noteRepo.getNoteIdByHash(hash);
        expect(foundId, equals(noteId));

        final fetchedText = await noteRepo.getRawNoteText(noteId);
        expect(fetchedText, equals(text));
      },
    );

    test('Lesson repository saves lesson and queries summary', () async {
      final noteId = await noteRepo.saveNote(
        rawOcrText: 'Line 1\nLine 2',
        documentHash: 'fakehash123',
      );

      final lesson = const LessonModel(
        schemaVersion: 1,
        title: 'Test Lesson',
        meta: LessonMeta(profile: 'ADHD', source: 'seed', promptVersion: 'v1'),
        conceptMap: ConceptMapModel(
          nodes: [
            ConceptNodeModel(id: 'n1', label: 'Node 1', sourceLines: [1]),
          ],
          edges: [],
        ),
        flashcards: [
          FlashcardModel(
            id: 'c1',
            question: 'What is A?',
            answer: 'A is 1',
            sourceLines: [1],
          ),
          FlashcardModel(
            id: 'c2',
            question: 'What is B?',
            answer: 'B is 2',
            sourceLines: [2],
          ),
        ],
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);

      final lessons = await lessonRepo.getAllLessons();
      expect(lessons.length, equals(1));
      expect(lessons.first.title, equals('Test Lesson'));
      expect(lessons.first.cardCount, equals(2));
      expect(
        lessons.first.dueCount,
        equals(2),
      ); // All newly inserted cards are due

      // Check detailed fetch
      final fetchedLesson = await lessonRepo.getLessonById(
        lessons.first.lessonId,
      );
      expect(fetchedLesson, isNotNull);
      expect(fetchedLesson!.flashcards.length, equals(2));
      expect(fetchedLesson.flashcards.first.groundingScore, isNull);
      expect(fetchedLesson.flashcards.first.verified, isFalse);
      expect(fetchedLesson.conceptMap.nodes.length, equals(1));
    });

    test(
      'Review repository records correct answer and moves Leitner box',
      () async {
        final noteId = await noteRepo.saveNote(
          rawOcrText: 'Line 1',
          documentHash: 'hash321',
        );

        final lesson = const LessonModel(
          schemaVersion: 1,
          title: 'Review Test Lesson',
          meta: LessonMeta(
            profile: 'Dyslexia',
            source: 'seed',
            promptVersion: 'v1',
          ),
          conceptMap: ConceptMapModel(nodes: [], edges: []),
          flashcards: [
            FlashcardModel(
              id: 'c1',
              question: 'Question 1',
              answer: 'Answer 1',
              sourceLines: [1],
            ),
          ],
        );

        await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);
        final lessons = await lessonRepo.getAllLessons();
        final lessonId = lessons.first.lessonId;

        final reviewItemsBefore = await reviewRepo.getReviewItemsForLesson(
          lessonId,
        );
        expect(reviewItemsBefore.first.progress.box, equals(1));
        expect(reviewItemsBefore.first.progress.intervalDays, equals(1));

        // Record correct
        await reviewRepo.recordCardResult(
          cardId: reviewItemsBefore.first.card.id,
          wasCorrect: true,
        );

        final reviewItemsAfter = await reviewRepo.getReviewItemsForLesson(
          lessonId,
        );
        expect(reviewItemsAfter.first.progress.box, equals(2));
        expect(reviewItemsAfter.first.progress.intervalDays, equals(3));
      },
    );

    test('Foreign key cascade delete removes flashcards and progress when lesson is deleted', () async {
      final noteId = await noteRepo.saveNote(
        rawOcrText: 'Note',
        documentHash: 'delhash',
      );

      final lesson = const LessonModel(
        schemaVersion: 1,
        title: 'Delete Test',
        meta: LessonMeta(
          profile: 'Autism',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: ConceptMapModel(nodes: [], edges: []),
        flashcards: [
          FlashcardModel(
            id: 'del_c1',
            question: 'Q',
            answer: 'A',
            sourceLines: [1],
          ),
        ],
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);
      var lessons = await lessonRepo.getAllLessons();
      expect(lessons.length, equals(1));

      // Permanently delete the lesson to test foreign key cascade
      await lessonRepo.permanentlyDeleteLesson(lessons.first.lessonId);

      lessons = await lessonRepo.getAllLessons();
      expect(lessons, isEmpty);

      // Verify flashcards table is also empty (cascaded)
      final remainingCards = await db.select(db.flashcards).get();
      expect(remainingCards, isEmpty);

      final remainingProgress = await db.select(db.reviewProgress).get();
      expect(remainingProgress, isEmpty);
    });

    test('Soft delete and recovery workflow restores deleted lesson', () async {
      final noteId = await noteRepo.saveNote(
        rawOcrText: 'Line 1\nLine 2',
        documentHash: 'recover_hash',
      );

      final lesson = const LessonModel(
        schemaVersion: 1,
        title: 'Recoverable Lesson',
        meta: LessonMeta(profile: 'ADHD', source: 'seed', promptVersion: 'v1'),
        conceptMap: ConceptMapModel(nodes: [], edges: []),
        flashcards: [
          FlashcardModel(
            id: 'rec_c1',
            question: 'Question 1',
            answer: 'Answer 1',
            sourceLines: [1],
          ),
        ],
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);
      var activeLessons = await lessonRepo.getAllLessons();
      expect(activeLessons.length, equals(1));
      final lessonId = activeLessons.first.lessonId;

      // 1. Soft delete the lesson
      await lessonRepo.deleteLesson(lessonId);

      // Active library should be empty now
      activeLessons = await lessonRepo.getAllLessons();
      expect(activeLessons, isEmpty);

      // Trashed lessons should contain the lesson
      var deletedLessons = await lessonRepo.getDeletedLessons();
      expect(deletedLessons.length, equals(1));
      expect(deletedLessons.first.lessonId, equals(lessonId));

      // Review items should exclude deleted lessons
      final reviewItems = await reviewRepo.getAllReviewItems();
      expect(reviewItems, isEmpty);

      // 2. Restore the lesson
      await lessonRepo.restoreLesson(lessonId);

      // Active library should have the lesson back
      activeLessons = await lessonRepo.getAllLessons();
      expect(activeLessons.length, equals(1));
      expect(activeLessons.first.lessonId, equals(lessonId));

      // Trash should be empty
      deletedLessons = await lessonRepo.getDeletedLessons();
      expect(deletedLessons, isEmpty);
    });

    test('Update lesson modifies title and updates/adds/removes flashcards', () async {
      final noteId = await noteRepo.saveNote(
        rawOcrText: 'Line 1\nLine 2',
        documentHash: 'update_hash',
      );

      final lesson = const LessonModel(
        schemaVersion: 1,
        title: 'Original Title',
        meta: LessonMeta(
          profile: 'Dyslexia',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: ConceptMapModel(nodes: [], edges: []),
        flashcards: [
          FlashcardModel(
            id: 'c_keep',
            question: 'Original Q1',
            answer: 'Original A1',
            sourceLines: [1],
          ),
          FlashcardModel(
            id: 'c_remove',
            question: 'Q to remove',
            answer: 'A to remove',
            sourceLines: [2],
          ),
        ],
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);
      final active = await lessonRepo.getAllLessons();
      final lessonId = active.first.lessonId;

      // Update lesson: change title, modify c_keep, delete c_remove, add c_new
      final originalLesson = await lessonRepo.getLessonById(lessonId);
      expect(originalLesson, isNotNull);
      final keepCard = originalLesson!.flashcards.firstWhere(
        (c) => c.question == 'Original Q1',
      );

      await lessonRepo.updateLesson(
        lessonId: lessonId,
        title: 'Updated Title',
        flashcards: [
          FlashcardModel(
            id: keepCard.id,
            question: 'Updated Q1',
            answer: 'Updated A1',
            sourceLines: [1],
          ),
          const FlashcardModel(
            id: 'new_card_test',
            question: 'Brand New Q',
            answer: 'Brand New A',
            sourceLines: [1],
          ),
        ],
      );

      final updatedLesson = await lessonRepo.getLessonById(lessonId);
      expect(updatedLesson, isNotNull);
      expect(updatedLesson!.title, equals('Updated Title'));
      expect(updatedLesson.flashcards.length, equals(2));

      final updatedKeep = updatedLesson.flashcards.firstWhere(
        (c) => c.id == keepCard.id,
      );
      expect(updatedKeep.question, equals('Updated Q1'));
      expect(updatedKeep.answer, equals('Updated A1'));

      final newCard = updatedLesson.flashcards.firstWhere(
        (c) => c.question == 'Brand New Q',
      );
      expect(newCard.answer, equals('Brand New A'));
    });

    test('Duplicate documentHash in saveNote returns existing noteId idempotently', () async {
      const text1 =
          'Cell biology: mitochondria produce ATP via oxidative phosphorylation.';
      const hash1 = 'hash_biology_1234567890abcdef';

      final noteId1 = await noteRepo.saveNote(
        rawOcrText: text1,
        documentHash: hash1,
      );
      expect(noteId1, isNotEmpty);

      // Save again with the identical documentHash
      final noteId2 = await noteRepo.saveNote(
        rawOcrText: text1,
        documentHash: hash1,
      );
      expect(noteId2, equals(noteId1));

      // Verify only 1 row exists in source_notes
      final allNotes = await db.select(db.sourceNotes).get();
      expect(allNotes.length, equals(1));
    });

    test('Direct insert of duplicate documentHash into SourceNotes enforces UNIQUE constraint', () async {
      const hash = 'unique_constraint_enforcement_hash';
      await db
          .into(db.sourceNotes)
          .insert(
            SourceNotesCompanion.insert(
              noteId: 'note_first',
              rawOcrText: 'Original text',
              documentHash: hash,
            ),
          );

      expect(
        () async => db
            .into(db.sourceNotes)
            .insert(
              SourceNotesCompanion.insert(
                noteId: 'note_second',
                rawOcrText: 'Duplicate text with same hash',
                documentHash: hash,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'getLessonById dynamically retrieves active profile from userProfiles',
      () async {
        const lesson = LessonModel(
          schemaVersion: 1,
          title: 'Quantum Mechanics',
          meta: LessonMeta(
            profile: 'Dyslexia',
            source: 'seed',
            promptVersion: 'v1',
          ),
          conceptMap: ConceptMapModel(nodes: [], edges: []),
          flashcards: [
            FlashcardModel(
              id: 'qm_1',
              question: 'What is superposition?',
              answer: 'State where system exists in multiple states.',
              sourceLines: [1],
            ),
          ],
        );

        final noteId = await noteRepo.saveNote(
          rawOcrText: 'Quantum mechanics notes',
          documentHash: 'qm_doc_hash_1',
        );
        await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);

        final allLessons = await lessonRepo.getAllLessons();
        final lessonId = allLessons.first.lessonId;

        // When no profile is saved, falls back to 'Dyslexia'
        var loaded = await lessonRepo.getLessonById(lessonId);
        expect(loaded?.meta.profile, equals('Dyslexia'));

        // Save Autism profile
        await profileRepo.saveProfile(ProfileType.autism);
        loaded = await lessonRepo.getLessonById(lessonId);
        expect(loaded?.meta.profile, equals('Autism'));

        // Update to ADHD profile
        await profileRepo.saveProfile(ProfileType.adhd);
        loaded = await lessonRepo.getLessonById(lessonId);
        expect(loaded?.meta.profile, equals('ADHD'));

        // Verify getReviewItemsForLesson batches queries and retrieves cards with progress
        final reviewItems = await reviewRepo.getReviewItemsForLesson(lessonId);
        expect(reviewItems.length, equals(1));
        expect(
          reviewItems.first.card.question,
          equals('What is superposition?'),
        );
        expect(reviewItems.first.progress.box, equals(1));
        expect(reviewItems.first.progress.isNew, isFalse);
      },
    );
  });
}
