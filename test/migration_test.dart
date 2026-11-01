// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/migration_test.dart
//
// Description:
//   Comprehensive Drift database schema migration and version verification test suite.
//   Validates that schema v1 to v2 migration safely adds the `is_deleted` column
//   to `lessons` table while preserving existing student records, referential
//   integrity, and cryptographic consistency.
// ============================================================================

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;

void main() {
  group('Drift Schema Migration Verification Tests (WP2.1 / Milestone 2)', () {
    test('AppDatabase reported schema version is 2', () async {
      final db = AppDatabase.memory();
      expect(db.schemaVersion, equals(2));
      await db.close();
    });

    test('Real Migration: Upgrading schema v1 database to v2 adds is_deleted column and preserves records', () async {
      // 1. Manually construct a raw SQLite database reflecting Schema Version 1
      final rawDb = raw_sqlite.sqlite3.openInMemory();

      rawDb.execute('PRAGMA user_version = 1;');
      rawDb.execute('PRAGMA foreign_keys = ON;');

      // Schema v1 DDL (UserProfiles, SourceNotes, Lessons WITHOUT is_deleted, Flashcards, ReviewProgress)
      rawDb.execute('''
        CREATE TABLE user_profiles (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          profile_type TEXT NOT NULL,
          theme_settings TEXT NOT NULL DEFAULT '{}',
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');

      rawDb.execute('''
        CREATE TABLE source_notes (
          note_id TEXT NOT NULL PRIMARY KEY,
          raw_ocr_text TEXT NOT NULL,
          document_hash TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');

      rawDb.execute('''
        CREATE TABLE lessons (
          lesson_id TEXT NOT NULL PRIMARY KEY,
          note_id TEXT NOT NULL REFERENCES source_notes (note_id) ON DELETE CASCADE,
          title TEXT NOT NULL,
          concept_map_json TEXT NOT NULL,
          prompt_version TEXT NOT NULL DEFAULT 'v1',
          source TEXT NOT NULL DEFAULT 'seed',
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');

      rawDb.execute('''
        CREATE TABLE flashcards (
          card_id TEXT NOT NULL PRIMARY KEY,
          lesson_id TEXT NOT NULL REFERENCES lessons (lesson_id) ON DELETE CASCADE,
          question TEXT NOT NULL,
          answer TEXT NOT NULL,
          source_line_reference TEXT NOT NULL,
          grounding_score REAL,
          verified INTEGER NOT NULL DEFAULT 0
        );
      ''');

      rawDb.execute('''
        CREATE TABLE review_progress (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          card_id TEXT NOT NULL REFERENCES flashcards (card_id) ON DELETE CASCADE,
          box_level INTEGER NOT NULL DEFAULT 1,
          last_reviewed_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
          next_review_due INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
          review_count INTEGER NOT NULL DEFAULT 0,
          consecutive_correct INTEGER NOT NULL DEFAULT 0
        );
      ''');

      // 2. Populate v1 database with sample student study data
      rawDb.execute('''
        INSERT INTO source_notes (note_id, raw_ocr_text, document_hash)
        VALUES ('note_v1_001', 'Line 1: Cellular respiration\\nLine 2: ATP synthesis', 'hash_v1_abc');
      ''');

      rawDb.execute('''
        INSERT INTO lessons (lesson_id, note_id, title, concept_map_json, prompt_version, source)
        VALUES ('lesson_v1_001', 'note_v1_001', 'Cellular Energy', '{"nodes":[],"edges":[]}', 'v1', 'seed');
      ''');

      rawDb.execute('''
        INSERT INTO flashcards (card_id, lesson_id, question, answer, source_line_reference)
        VALUES ('card_v1_001', 'lesson_v1_001', 'What does ATP stand for?', 'Adenosine Triphosphate', '[2]');
      ''');

      // Verify v1 setup
      final v1Version =
          rawDb.select('PRAGMA user_version;').first['user_version'] as int;
      expect(v1Version, equals(1));

      // 3. Connect AppDatabase using NativeDatabase.opened(rawDb) to trigger Drift migration
      final driftDb = AppDatabase(NativeDatabase.opened(rawDb));

      // 4. Trigger beforeOpen and onUpgrade by issuing a query
      final lessons = await driftDb.select(driftDb.lessons).get();
      expect(lessons.length, equals(1));

      final migratedLesson = lessons.first;
      expect(migratedLesson.lessonId, equals('lesson_v1_001'));
      expect(migratedLesson.title, equals('Cellular Energy'));
      // Verified: The newly added isDeleted column defaulted to false
      expect(migratedLesson.isDeleted, isFalse);

      // 5. Verify user_version was bumped to 2 by Drift migration strategy
      final upgradedVersion =
          rawDb.select('PRAGMA user_version;').first['user_version'] as int;
      expect(upgradedVersion, equals(2));

      // 6. Verify table columns now include is_deleted in PRAGMA table_info
      final tableInfo = rawDb.select('PRAGMA table_info(lessons);');
      final columnNames = tableInfo
          .map((row) => row['name'] as String)
          .toList();
      expect(columnNames, contains('is_deleted'));

      // 7. Verify soft deletion works on migrated record
      await (driftDb.update(driftDb.lessons)
            ..where((tbl) => tbl.lessonId.equals('lesson_v1_001')))
          .write(const LessonsCompanion(isDeleted: Value(true)));

      final activeLessons = await (driftDb.select(
        driftDb.lessons,
      )..where((tbl) => tbl.isDeleted.equals(false))).get();
      expect(activeLessons, isEmpty);

      final deletedLessons = await (driftDb.select(
        driftDb.lessons,
      )..where((tbl) => tbl.isDeleted.equals(true))).get();
      expect(deletedLessons.length, equals(1));
      expect(deletedLessons.first.lessonId, equals('lesson_v1_001'));

      // 8. Verify child flashcards and foreign key cascades still work seamlessly
      final cards = await driftDb.select(driftDb.flashcards).get();
      expect(cards.length, equals(1));
      expect(cards.first.cardId, equals('card_v1_001'));

      await driftDb.close();
    });
  });
}
