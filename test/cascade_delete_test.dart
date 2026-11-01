// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/cascade_delete_test.dart
//
// Description:
//   Unit test suite verifying SQLite foreign key referential integrity and
//   automatic cascade deletions across the entire entity hierarchy:
//   SourceNotes -> Lessons -> Flashcards -> ReviewProgress.
//   Guarantees WP2.1 privacy-by-design requirement: no orphaned records remain.
// ============================================================================

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('Foreign Key Cascade Delete & Referential Integrity Tests (WP2.1)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'SQLite foreign_keys PRAGMA is enabled by default in AppDatabase',
      () async {
        final result = await db
            .customSelect('PRAGMA foreign_keys;')
            .getSingle();
        final foreignKeys = result.data['foreign_keys'];
        expect(foreignKeys, equals(1));
      },
    );

    test('Deleting a Lesson cascades deletion to its child Flashcards and ReviewProgress', () async {
      // 1. Insert a parent source note
      await db
          .into(db.sourceNotes)
          .insert(
            SourceNotesCompanion.insert(
              noteId: 'note_cascade_01',
              rawOcrText: 'Line 1: Photosynthesis\nLine 2: Chloroplasts',
              documentHash: 'hash_cascade_01',
            ),
          );

      // 2. Insert two lessons referencing the note
      await db
          .into(db.lessons)
          .insert(
            LessonsCompanion.insert(
              lessonId: 'lesson_cascade_01',
              noteId: 'note_cascade_01',
              title: 'Lesson to Delete',
              conceptMapJson: '{"nodes":[],"edges":[]}',
            ),
          );
      await db
          .into(db.lessons)
          .insert(
            LessonsCompanion.insert(
              lessonId: 'lesson_cascade_02',
              noteId: 'note_cascade_01',
              title: 'Lesson to Keep',
              conceptMapJson: '{"nodes":[],"edges":[]}',
            ),
          );

      // 3. Insert flashcards for each lesson
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              cardId: 'card_del_01',
              lessonId: 'lesson_cascade_01',
              question: 'Question Del 1',
              answer: 'Answer Del 1',
              sourceLineReference: '[1]',
            ),
          );
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              cardId: 'card_del_02',
              lessonId: 'lesson_cascade_01',
              question: 'Question Del 2',
              answer: 'Answer Del 2',
              sourceLineReference: '[2]',
            ),
          );
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              cardId: 'card_keep_01',
              lessonId: 'lesson_cascade_02',
              question: 'Question Keep 1',
              answer: 'Answer Keep 1',
              sourceLineReference: '[1]',
            ),
          );

      // 4. Insert review progress for the cards
      await db
          .into(db.reviewProgress)
          .insert(
            ReviewProgressCompanion.insert(
              cardId: 'card_del_01',
              box: const Value(2),
              nextReviewDate: DateTime.now(),
            ),
          );
      await db
          .into(db.reviewProgress)
          .insert(
            ReviewProgressCompanion.insert(
              cardId: 'card_del_02',
              box: const Value(3),
              nextReviewDate: DateTime.now(),
            ),
          );
      await db
          .into(db.reviewProgress)
          .insert(
            ReviewProgressCompanion.insert(
              cardId: 'card_keep_01',
              box: const Value(1),
              nextReviewDate: DateTime.now(),
            ),
          );

      // Verify initial counts
      expect((await db.select(db.lessons).get()).length, equals(2));
      expect((await db.select(db.flashcards).get()).length, equals(3));
      expect((await db.select(db.reviewProgress).get()).length, equals(3));

      // 5. Delete lesson_cascade_01 directly from lessons table
      final deletedRows = await (db.delete(
        db.lessons,
      )..where((tbl) => tbl.lessonId.equals('lesson_cascade_01'))).go();
      expect(deletedRows, equals(1));

      // 6. Verify cascade: child flashcards of deleted lesson are gone
      final remainingCards = await db.select(db.flashcards).get();
      expect(remainingCards.length, equals(1));
      expect(remainingCards.first.cardId, equals('card_keep_01'));

      // 7. Verify cascade: child review progress of deleted cards are gone
      final remainingProgress = await db.select(db.reviewProgress).get();
      expect(remainingProgress.length, equals(1));
      expect(remainingProgress.first.cardId, equals('card_keep_01'));

      // 8. Verify the note itself is untouched
      final remainingNotes = await db.select(db.sourceNotes).get();
      expect(remainingNotes.length, equals(1));
      expect(remainingNotes.first.noteId, equals('note_cascade_01'));
    });

    test('Deleting a SourceNote cascades deletion down through Lessons, Flashcards, and ReviewProgress', () async {
      // 1. Insert note
      await db
          .into(db.sourceNotes)
          .insert(
            SourceNotesCompanion.insert(
              noteId: 'note_root_01',
              rawOcrText: 'Lecture text',
              documentHash: 'hash_root_01',
            ),
          );

      // 2. Insert lesson
      await db
          .into(db.lessons)
          .insert(
            LessonsCompanion.insert(
              lessonId: 'lesson_root_01',
              noteId: 'note_root_01',
              title: 'Lesson under Root Note',
              conceptMapJson: '{"nodes":[],"edges":[]}',
            ),
          );

      // 3. Insert card
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              cardId: 'card_root_01',
              lessonId: 'lesson_root_01',
              question: 'Q Root',
              answer: 'A Root',
              sourceLineReference: '[1]',
            ),
          );

      // 4. Insert progress
      await db
          .into(db.reviewProgress)
          .insert(
            ReviewProgressCompanion.insert(
              cardId: 'card_root_01',
              box: const Value(4),
              nextReviewDate: DateTime.now(),
            ),
          );

      // 5. Delete the parent SourceNote
      await (db.delete(
        db.sourceNotes,
      )..where((tbl) => tbl.noteId.equals('note_root_01'))).go();

      // 6. Verify entire hierarchy was cascade-purged
      expect(await db.select(db.sourceNotes).get(), isEmpty);
      expect(await db.select(db.lessons).get(), isEmpty);
      expect(await db.select(db.flashcards).get(), isEmpty);
      expect(await db.select(db.reviewProgress).get(), isEmpty);
    });

    test('Foreign key constraint prevents inserting child records without existing parent', () async {
      // Attempting to insert a lesson for non-existent note should throw SqliteException
      expect(
        () async => await db
            .into(db.lessons)
            .insert(
              LessonsCompanion.insert(
                lessonId: 'orphan_lesson',
                noteId: 'non_existent_note',
                title: 'Orphan Lesson',
                conceptMapJson: '{}',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );

      // Attempting to insert a card for non-existent lesson should throw SqliteException
      expect(
        () async => await db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                cardId: 'orphan_card',
                lessonId: 'non_existent_lesson',
                question: 'Orphan Q',
                answer: 'Orphan A',
                sourceLineReference: '[]',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
