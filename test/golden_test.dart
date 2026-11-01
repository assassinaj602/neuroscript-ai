// ============================================================================
// NeuroScript AI: Automated Widget & Layout Overflow Tests
// File: test/golden_test.dart
//
// Description:
//   Golden and responsive accessibility layout tests verifying that Library,
//   Review, and Concept Map screens render without overflow at TextScaler 1.0x
//   and large accessible TextScaler 2.0x (WP2.5 Verification).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/lesson_model.dart';
import 'package:neuro_script/data/repositories/repository_interfaces.dart';
import 'package:neuro_script/features/concept_map/concept_map_screen.dart';
import 'package:neuro_script/features/library/library_screen.dart';
import 'package:neuro_script/features/providers.dart';
import 'package:neuro_script/features/review/flashcard_review_screen.dart';
import 'package:neuro_script/services/leitner_scheduler.dart';

void main() {
  group('Accessibility & Text Scale Overflow Verification (1.0x & 2.0x)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets('Library screen renders at text scale ${scale}x without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              allLessonsProvider.overrideWith(
                (ref) => Future.value([
                  LessonSummary(
                    lessonId: 'l1',
                    noteId: 'n1',
                    title: 'Photosynthesis Fundamentals and Chloroplast Biology',
                    profile: 'Dyslexia',
                    source: 'seed',
                    createdAt: DateTime.now(),
                    cardCount: 5,
                    dueCount: 3,
                  ),
                ]),
              ),
            ],
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: MaterialApp(
                theme: AppTheme.getTheme(ProfileType.dyslexia),
                home: const LibraryScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('My Study Lessons'), findsOneWidget);
        expect(
          find.text('Photosynthesis Fundamentals and Chloroplast Biology'),
          findsOneWidget,
        );
      });

      testWidgets('Flashcard review screen renders at text scale ${scale}x without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final items = [
          FlashcardReviewItem(
            card: const FlashcardModel(
              id: 'c1',
              question: 'What primary pigment absorbs light energy in chloroplasts?',
              answer: 'Chlorophyll, which absorbs red and blue light wavelengths.',
              sourceLines: [2],
              chunks: ['Chlorophyll absorbs red and blue', 'Reflects green'],
            ),
            progress: ReviewItem(
              cardId: 'c1',
              box: 1,
              intervalDays: 1,
              nextReviewDate: DateTime.now(),
            ),
            rawNoteLines: ['1: Notes', '2: Chlorophyll absorbs red and blue light.'],
          ),
        ];

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: MaterialApp(
              theme: AppTheme.getTheme(ProfileType.adhd),
              home: FlashcardReviewScreen(
                lessonTitle: 'Photosynthesis',
                reviewItems: items,
                onRecordResult: (_, _) async {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('What primary pigment absorbs light energy in chloroplasts?'), findsOneWidget);
        expect(find.text('Card 1 of 1'), findsOneWidget);
        expect(find.text('Got it!'), findsOneWidget);
        expect(find.text('Not yet'), findsOneWidget);
      });

      testWidgets('Concept map screen renders at text scale ${scale}x without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const conceptMap = ConceptMapModel(
          nodes: [
            ConceptNodeModel(id: 'n1', label: 'Photosynthesis', sourceLines: [1]),
            ConceptNodeModel(id: 'n2', label: 'Light Reactions', sourceLines: [2]),
          ],
          edges: [ConceptEdgeModel(from: 'n1', to: 'n2', label: 'powers')],
        );

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: MaterialApp(
              theme: AppTheme.getTheme(ProfileType.autism),
              home: const ConceptMapScreen(
                title: 'Photosynthesis Map',
                conceptMap: conceptMap,
                rawNoteLines: ['1: Photosynthesis', '2: Light Reactions'],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.text('Photosynthesis Map – Map'), findsOneWidget);
      });
    }
  });
}
