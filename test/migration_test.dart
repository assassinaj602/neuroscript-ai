// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: app/test/migration_test.dart
//
// Description:
//   Unit test suite verifying Drift database schema versioning and migration strategy
//   under WP2.1 specifications.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/data/database/database.dart';

void main() {
  group('Database Schema & Migration Scaffold Tests (WP2.1 Verification)', () {
    test('Database schema version is 1', () async {
      final db = AppDatabase.memory();

      expect(db.schemaVersion, equals(1));

      // Verify that all 5 required tables exist and can be queried without error
      final profiles = await db.select(db.userProfiles).get();
      final notes = await db.select(db.sourceNotes).get();
      final lessons = await db.select(db.lessons).get();
      final cards = await db.select(db.flashcards).get();
      final progress = await db.select(db.reviewProgress).get();

      expect(profiles, isEmpty);
      expect(notes, isEmpty);
      expect(lessons, isEmpty);
      expect(cards, isEmpty);
      expect(progress, isEmpty);

      await db.close();
    });
  });
}
