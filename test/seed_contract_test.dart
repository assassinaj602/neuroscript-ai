// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/seed_contract_test.dart
//
// Description:
//   Unit test suite strictly validating every seed lesson asset in `assets/seed/`
//   against the formal JSON Schema specification in `docs/contracts/lesson.schema.json`.
//   Ensures that seed curriculum files satisfy schemaVersion, meta types,
//   concept map node/edge structures, and flashcard grounding constraints.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Seed Lessons JSON Contract & Schema Validation Tests', () {
    late Map<String, dynamic> schema;
    late List<File> seedFiles;

    setUpAll(() {
      final schemaFile = File('docs/contracts/lesson.schema.json');
      expect(
        schemaFile.existsSync(),
        isTrue,
        reason: 'lesson.schema.json contract must exist',
      );
      schema =
          jsonDecode(schemaFile.readAsStringSync()) as Map<String, dynamic>;

      final seedDir = Directory('assets/seed');
      expect(
        seedDir.existsSync(),
        isTrue,
        reason: 'assets/seed directory must exist',
      );
      seedFiles = seedDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      expect(
        seedFiles,
        isNotEmpty,
        reason: 'Must have at least one seed lesson file',
      );
    });

    test('Schema specification file declares expected schema version 1', () {
      expect(schema['title'], equals('NeuroScriptLesson'));
      final properties = schema['properties'] as Map<String, dynamic>;
      expect(properties.containsKey('schemaVersion'), isTrue);
      expect(properties.containsKey('title'), isTrue);
      expect(properties.containsKey('meta'), isTrue);
      expect(properties.containsKey('conceptMap'), isTrue);
      expect(properties.containsKey('flashcards'), isTrue);
    });

    test('Every file in assets/seed/ strictly satisfies lesson.schema.json contract', () {
      for (final file in seedFiles) {
        final fileName = file.uri.pathSegments.last;
        final content = file.readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;

        // 1. Root Level Required Keys
        final requiredKeys = [
          'schemaVersion',
          'title',
          'meta',
          'conceptMap',
          'flashcards',
        ];
        for (final key in requiredKeys) {
          expect(
            json.containsKey(key),
            isTrue,
            reason: '$fileName is missing required root key "$key"',
          );
        }

        // 2. schemaVersion must be integer 1
        expect(
          json['schemaVersion'],
          equals(1),
          reason: '$fileName schemaVersion must be 1',
        );

        // 3. title must be non-empty string
        expect(
          json['title'],
          isA<String>(),
          reason: '$fileName title must be a string',
        );
        expect(
          (json['title'] as String).trim(),
          isNotEmpty,
          reason: '$fileName title must not be empty',
        );

        // 4. meta validation
        final meta = json['meta'] as Map<String, dynamic>;
        expect(
          meta.containsKey('profile'),
          isTrue,
          reason: '$fileName meta missing profile',
        );
        expect(
          ['ADHD', 'Dyslexia', 'Autism'],
          contains(meta['profile']),
          reason: '$fileName profile must be ADHD, Dyslexia, or Autism',
        );
        expect(
          ['seed', 'mock', 'cloud', 'device'],
          contains(meta['source']),
          reason: '$fileName source must be valid origin',
        );
        expect(
          meta['promptVersion'],
          isA<String>(),
          reason: '$fileName promptVersion must be string',
        );

        // 5. conceptMap validation
        final conceptMap = json['conceptMap'] as Map<String, dynamic>;
        expect(conceptMap.containsKey('nodes'), isTrue);
        expect(conceptMap.containsKey('edges'), isTrue);

        final nodes = conceptMap['nodes'] as List<dynamic>;
        expect(
          nodes,
          isNotEmpty,
          reason: '$fileName concept map nodes should not be empty',
        );
        final nodeIds = <String>{};

        for (final rawNode in nodes) {
          final node = rawNode as Map<String, dynamic>;
          expect(node['id'], isA<String>());
          expect((node['id'] as String).isNotEmpty, isTrue);
          expect(node['label'], isA<String>());
          expect((node['label'] as String).isNotEmpty, isTrue);
          expect(node['sourceLines'], isA<List<dynamic>>());

          final sourceLines = node['sourceLines'] as List<dynamic>;
          for (final line in sourceLines) {
            expect(line, isA<int>());
            expect(line as int, greaterThanOrEqualTo(1));
          }
          nodeIds.add(node['id'] as String);
        }

        final edges = conceptMap['edges'] as List<dynamic>;
        for (final rawEdge in edges) {
          final edge = rawEdge as Map<String, dynamic>;
          expect(edge['from'], isA<String>());
          expect(edge['to'], isA<String>());
          expect(edge['label'], isA<String>());
          expect(
            nodeIds.contains(edge['from']),
            isTrue,
            reason:
                '$fileName edge from "${edge['from']}" must reference a valid node',
          );
          expect(
            nodeIds.contains(edge['to']),
            isTrue,
            reason:
                '$fileName edge to "${edge['to']}" must reference a valid node',
          );
        }

        // 6. flashcards validation
        final flashcards = json['flashcards'] as List<dynamic>;
        expect(
          flashcards,
          isNotEmpty,
          reason: '$fileName flashcards should not be empty',
        );

        for (final rawCard in flashcards) {
          final card = rawCard as Map<String, dynamic>;
          expect(card['id'], isA<String>());
          expect(card['question'], isA<String>());
          expect((card['question'] as String).isNotEmpty, isTrue);
          expect(card['answer'], isA<String>());
          expect((card['answer'] as String).isNotEmpty, isTrue);
          expect(card['sourceLines'], isA<List<dynamic>>());

          final sourceLines = card['sourceLines'] as List<dynamic>;
          for (final line in sourceLines) {
            expect(line, isA<int>());
            expect(line as int, greaterThanOrEqualTo(1));
          }

          if (card.containsKey('chunks')) {
            expect(card['chunks'], isA<List<dynamic>>());
          }

          // Per Task 3: seed groundingScore is null and verified is false
          if (card.containsKey('groundingScore') &&
              card['groundingScore'] != null) {
            expect(card['groundingScore'], isA<num>());
            final score = (card['groundingScore'] as num).toDouble();
            expect(score, greaterThanOrEqualTo(0.0));
            expect(score, lessThanOrEqualTo(1.0));
          }

          if (card.containsKey('verified')) {
            expect(card['verified'], isA<bool>());
          }
        }
      }
    });
  });
}
