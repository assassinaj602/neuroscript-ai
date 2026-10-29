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

      final lesson = LessonModel(
        schemaVersion: 1,
        title: 'Test Lesson',
        meta: const LessonMeta(
          profile: 'ADHD',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: const ConceptMapModel(
          nodes: [
            ConceptNodeModel(id: 'n1', label: 'Node 1', sourceLines: [1]),
          ],
          edges: [],
        ),
        flashcards: const [
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
      expect(fetchedLesson.conceptMap.nodes.length, equals(1));
    });

    test(
      'Review repository records correct answer and moves Leitner box',
      () async {
        final noteId = await noteRepo.saveNote(
          rawOcrText: 'Line 1',
          documentHash: 'hash321',
        );

        final lesson = LessonModel(
          schemaVersion: 1,
          title: 'Review Test Lesson',
          meta: const LessonMeta(
            profile: 'Dyslexia',
            source: 'seed',
            promptVersion: 'v1',
          ),
          conceptMap: const ConceptMapModel(nodes: [], edges: []),
          flashcards: const [
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

      final lesson = LessonModel(
        schemaVersion: 1,
        title: 'Delete Test',
        meta: const LessonMeta(
          profile: 'Autism',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: const ConceptMapModel(nodes: [], edges: []),
        flashcards: const [
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

      // Delete the lesson
      await lessonRepo.deleteLesson(lessons.first.lessonId);

      lessons = await lessonRepo.getAllLessons();
      expect(lessons, isEmpty);

      // Verify flashcards table is also empty (cascaded)
      final remainingCards = await db.select(db.flashcards).get();
      expect(remainingCards, isEmpty);

      final remainingProgress = await db.select(db.reviewProgress).get();
      expect(remainingProgress, isEmpty);
    });
  });
}
