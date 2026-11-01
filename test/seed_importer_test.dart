// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: app/test/seed_importer_test.dart
//
// Description:
//   Unit test suite verifying idempotent curriculum seed loading and transaction
//   safety under WP2.1 specifications.
// ============================================================================

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/services/seed_importer.dart';

class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;
  FakeAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    final bytes = utf8.encode(str);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

void main() {
  group('SeedImporter Unit Tests (WP2.1 Verification)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    final sampleLessonJson = jsonEncode({
      "schemaVersion": 1,
      "title": "Sample Seed Lesson",
      "meta": {"profile": "Dyslexia", "source": "seed", "promptVersion": "v1"},
      "rawNotes": "1: Line one\n2: Line two",
      "conceptMap": {
        "nodes": [
          {
            "id": "n1",
            "label": "Node 1",
            "sourceLines": [1],
          },
        ],
        "edges": [],
      },
      "flashcards": [
        {
          "id": "c1",
          "question": "Question 1",
          "answer": "Answer 1",
          "sourceLines": [1],
          "chunks": ["chunk 1"],
        },
      ],
    });

    test('SeedImporter imports lesson inside a transaction', () async {
      final fakeBundle = FakeAssetBundle({
        'assets/seed/photosynthesis.json': sampleLessonJson,
        'assets/seed/computer_architecture.json': sampleLessonJson,
        'assets/seed/algorithms.json': sampleLessonJson,
      });

      final importer = SeedImporter(db);
      final count = await importer.importSeedLessons(bundle: fakeBundle);

      // Only 1 is imported because all 3 have the identical documentHash (idempotency check)
      expect(count, equals(1));

      final allLessons = await db.select(db.lessons).get();
      expect(allLessons.length, equals(1));
      expect(allLessons.first.title, equals('Sample Seed Lesson'));

      final allCards = await db.select(db.flashcards).get();
      expect(allCards.length, equals(1));
      expect(allCards.first.groundingScore, isNull);
      expect(allCards.first.verified, isFalse);

      final allProgress = await db.select(db.reviewProgress).get();
      expect(allProgress.length, equals(1));
      expect(allProgress.first.box, equals(1));
    });

    test('SeedImporter is strictly idempotent when run repeatedly', () async {
      final fakeBundle = FakeAssetBundle({
        'assets/seed/photosynthesis.json': sampleLessonJson,
        'assets/seed/computer_architecture.json': sampleLessonJson,
        'assets/seed/algorithms.json': sampleLessonJson,
      });

      final importer = SeedImporter(db);
      final firstRun = await importer.importSeedLessons(bundle: fakeBundle);
      expect(firstRun, equals(1));

      // Second run must import 0 new lessons
      final secondRun = await importer.importSeedLessons(bundle: fakeBundle);
      expect(secondRun, equals(0));

      final allLessons = await db.select(db.lessons).get();
      expect(allLessons.length, equals(1));
    });

    test('SeedImporter rolls back transaction when a seed file is malformed', () async {
      final fakeBundle = FakeAssetBundle({
        'assets/seed/photosynthesis.json': sampleLessonJson,
        'assets/seed/computer_architecture.json': 'NOT_VALID_JSON{{[',
        'assets/seed/algorithms.json': sampleLessonJson,
      });

      final importer = SeedImporter(db);
      expect(
        () => importer.importSeedLessons(bundle: fakeBundle),
        throwsA(isA<SeedImportException>()),
      );

      // Verify transaction rollback: nothing was persisted, not even the first lesson
      final allLessons = await db.select(db.lessons).get();
      expect(allLessons, isEmpty);

      final allNotes = await db.select(db.sourceNotes).get();
      expect(allNotes, isEmpty);

      final allCards = await db.select(db.flashcards).get();
      expect(allCards, isEmpty);

      final allProgress = await db.select(db.reviewProgress).get();
      expect(allProgress, isEmpty);
    });
  });
}
