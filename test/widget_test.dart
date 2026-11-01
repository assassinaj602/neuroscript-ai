// ============================================================================
// NeuroScript AI: Automated Widget Tests
// File: app/test/widget_test.dart
//
// Description:
//   Component and end-to-end flow verification tests across all primary screens.
//
// Verification Scope:
//   1. Onboarding Screen: Renders title, subtitle, and "Get Started" button.
//   2. Profile Select Screen: Renders all three learner profiles (ADHD, Dyslexia, Autism).
//   3. Library Screen: Displays empty state with friendly illustration and guidance.
//   4. Flashcard Review Screen: Renders question, executes 3D flip, and records result.
//   5. Concept Map Screen: Renders InteractiveViewer pan/zoom canvas and nodes.
//   6. Lesson Overview Screen: Renders dual study paths and flashcards preview.
//   7. Splash Screen: Renders branding, loading indicator, and executes bootstrap.
//   8. Edit Lesson Screen: Renders fields and allows editing and adding cards.
//   9. Recently Deleted: Renders trash badge and recovery bottom sheet.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';
import 'package:neuro_script/features/concept_map/concept_map_screen.dart';
import 'package:neuro_script/features/lesson/edit_lesson_screen.dart';
import 'package:neuro_script/features/lesson/lesson_overview_screen.dart';
import 'package:neuro_script/features/library/library_screen.dart';
import 'package:neuro_script/features/onboarding/onboarding_screen.dart';
import 'package:neuro_script/features/onboarding/profile_select_screen.dart';
import 'package:neuro_script/features/review/flashcard_review_screen.dart';
import 'package:neuro_script/features/splash/splash_screen.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/lesson_model.dart';
import 'package:neuro_script/data/repositories/repository_interfaces.dart';
import 'package:neuro_script/features/providers.dart';
import 'package:neuro_script/services/leitner_scheduler.dart';

void main() {
  testWidgets('1. Onboarding screen renders title and get started button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getTheme(ProfileType.dyslexia),
        home: const OnboardingScreen(),
      ),
    );

    expect(find.text('NeuroScript AI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Grounded Active Recall'), findsOneWidget);
  });

  testWidgets('2. Profile selection screen renders all 3 learner profiles', (
    tester,
  ) async {
    final db = AppDatabase.memory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.getTheme(ProfileType.adhd),
          home: const ProfileSelectScreen(),
        ),
      ),
    );

    expect(find.text('ADHD'), findsOneWidget);
    expect(find.text('Dyslexia'), findsOneWidget);
    expect(find.text('Autism'), findsOneWidget);
    expect(find.text('Save & Continue'), findsOneWidget);

    await db.close();
  });

  testWidgets(
    '3. Library empty state renders illustration and friendly message',
    (tester) async {
      final db = AppDatabase.memory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            allLessonsProvider.overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.getTheme(ProfileType.dyslexia),
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Study Lessons'), findsOneWidget);
      expect(find.text('No lessons found in library.'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    '4. Flashcard review screen renders card, flips, and records answer',
    (tester) async {
      final items = [
        FlashcardReviewItem(
          card: const FlashcardModel(
            id: 'test_c1',
            question: 'What is Mitochondria?',
            answer: 'Powerhouse of the cell.',
            sourceLines: [1],
            chunks: ['Powerhouse of the cell'],
          ),
          progress: ReviewItem(
            cardId: 'test_c1',
            box: 1,
            intervalDays: 1,
            nextReviewDate: DateTime.now(),
          ),
          rawNoteLines: ['1: Mitochondria is the powerhouse of the cell.'],
        ),
      ];

      String? recordedCardId;
      bool? recordedWasCorrect;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(ProfileType.dyslexia),
          home: FlashcardReviewScreen(
            lessonTitle: 'Cell Biology',
            reviewItems: items,
            onRecordResult: (cardId, wasCorrect) async {
              recordedCardId = cardId;
              recordedWasCorrect = wasCorrect;
            },
          ),
        ),
      );

      expect(find.text('What is Mitochondria?'), findsOneWidget);
      expect(find.text('Card 1 of 1'), findsOneWidget);
      expect(find.text('Got it!'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);

      // Tap card to flip
      await tester.tap(find.text('What is Mitochondria?'));
      await tester.pumpAndSettle();

      // Verify answer is revealed
      expect(find.text('Powerhouse of the cell.'), findsOneWidget);

      // Tap Got it!
      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(recordedCardId, equals('test_c1'));
      expect(recordedWasCorrect, isTrue);

      // Summary screen displayed
      expect(find.text('Session Complete'), findsOneWidget);
      expect(find.text('Back to Library'), findsOneWidget);
    },
  );

  testWidgets('5. Concept map screen renders InteractiveViewer and canvas', (
    tester,
  ) async {
    const conceptMap = ConceptMapModel(
      nodes: [
        ConceptNodeModel(id: 'n1', label: 'Cell', sourceLines: [1]),
        ConceptNodeModel(id: 'n2', label: 'Mitochondria', sourceLines: [2]),
      ],
      edges: [ConceptEdgeModel(from: 'n1', to: 'n2', label: 'contains')],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getTheme(ProfileType.autism),
        home: const ConceptMapScreen(
          title: 'Cell Map',
          conceptMap: conceptMap,
          rawNoteLines: ['1: Cells', '2: Mitochondria'],
        ),
      ),
    );

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Cell Map – Map'), findsOneWidget);
    expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
  });

  testWidgets(
    '6. Lesson overview screen renders dual study paths and flashcards preview',
    (tester) async {
      const lesson = LessonModel(
        schemaVersion: 1,
        title: 'Photosynthesis Fundamentals',
        meta: LessonMeta(
          profile: 'Dyslexia',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: ConceptMapModel(
          nodes: [
            ConceptNodeModel(id: 'n1', label: 'Chloroplast', sourceLines: [1]),
          ],
          edges: [],
        ),
        flashcards: [
          FlashcardModel(
            id: 'fc_1',
            question: 'What is Chlorophyll?',
            answer: 'Light-absorbing pigment.',
            sourceLines: [1],
          ),
        ],
        rawNotes: '1: Chlorophyll absorbs sunlight inside chloroplasts.',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.getTheme(ProfileType.dyslexia),
            home: const LessonOverviewScreen(
              lessonId: 'lesson_photo',
              lesson: lesson,
            ),
          ),
        ),
      );

      expect(find.text('Photosynthesis Fundamentals'), findsWidgets);
      expect(find.text('Review Now'), findsOneWidget);
      expect(find.text('Concept Map'), findsOneWidget);
      expect(find.text('What is Chlorophyll?'), findsOneWidget);
      expect(find.text('Light-absorbing pigment.'), findsOneWidget);
      expect(find.text('Source Lines'), findsOneWidget);
    },
  );

  testWidgets('7. Splash screen renders branding and loading indicator', (
    tester,
  ) async {
    final db = AppDatabase.memory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeProfileProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.getTheme(ProfileType.dyslexia),
          home: SplashScreen(
            minimumDuration: Duration.zero,
            onComplete: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('NeuroScript AI'), findsOneWidget);
    expect(
      find.textContaining('Privacy-Preserving Study Platform'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    await db.close();
  });

  testWidgets('8. Edit lesson screen renders fields and allows adding card', (
    tester,
  ) async {
    const lesson = LessonModel(
      schemaVersion: 1,
      title: 'Operating Systems',
      meta: LessonMeta(
        profile: 'Dyslexia',
        source: 'seed',
        promptVersion: 'v1',
      ),
      conceptMap: ConceptMapModel(nodes: [], edges: []),
      flashcards: [
        FlashcardModel(
          id: 'os_1',
          question: 'What is a process?',
          answer: 'A program in execution.',
          sourceLines: [1],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.getTheme(ProfileType.dyslexia),
          home: const EditLessonScreen(lessonId: 'lesson_os', lesson: lesson),
        ),
      ),
    );

    expect(find.text('Edit Flashcard Set'), findsOneWidget);
    expect(find.text('Operating Systems'), findsOneWidget);
    expect(find.text('What is a process?'), findsOneWidget);
    expect(find.text('A program in execution.'), findsOneWidget);

    // Tap Add Card
    await tester.tap(find.text('+ Add Card'));
    await tester.pumpAndSettle();

    expect(find.text('Card 2', skipOffstage: false), findsOneWidget);
  });

  testWidgets(
    '9. Library screen renders recently deleted trash badge and sheet',
    (tester) async {
      final db = AppDatabase.memory();
      final deletedSummary = LessonSummary(
        lessonId: 'del_1',
        title: 'Deleted Lesson',
        profile: 'seed',
        source: 'seed',
        cardCount: 3,
        dueCount: 0,
        createdAt: DateTime.now(),
        noteId: 'note_1',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            allLessonsProvider.overrideWith((ref) => Future.value([])),
            deletedLessonsProvider.overrideWith(
              (ref) => Future.value([deletedSummary]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.getTheme(ProfileType.adhd),
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Recently Deleted button has badge with '1'
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap Recently Deleted
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Recently Deleted (1)'), findsOneWidget);
      expect(find.text('Deleted Lesson'), findsOneWidget);
      expect(find.byIcon(Icons.restore), findsWidgets);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);

      await db.close();
    },
  );

  testWidgets(
    '10. Library search bar filters lessons dynamically and handles no results',
    (tester) async {
      final db = AppDatabase.memory();

      final lessonA = LessonSummary(
        lessonId: 'l_algo',
        title: 'Algorithms & Data Structures',
        profile: 'seed',
        source: 'seed',
        cardCount: 10,
        dueCount: 2,
        createdAt: DateTime.now(),
        noteId: 'note_algo',
      );

      final lessonB = LessonSummary(
        lessonId: 'l_bio',
        title: 'Photosynthesis & Cellular Respiration',
        profile: 'seed',
        source: 'seed',
        cardCount: 8,
        dueCount: 0,
        createdAt: DateTime.now(),
        noteId: 'note_bio',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            allLessonsProvider.overrideWith(
              (ref) => Future.value([lessonA, lessonB]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.getTheme(ProfileType.adhd),
            home: const LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Algorithms & Data Structures'), findsOneWidget);
      expect(
        find.text('Photosynthesis & Cellular Respiration'),
        findsOneWidget,
      );

      // Enter search query "Algo"
      await tester.enterText(find.byType(TextField), 'Algo');
      await tester.pumpAndSettle();

      expect(find.text('Algorithms & Data Structures'), findsOneWidget);
      expect(find.text('Photosynthesis & Cellular Respiration'), findsNothing);

      // Enter search query with no matches
      await tester.enterText(find.byType(TextField), 'QuantumPhysics');
      await tester.pumpAndSettle();

      expect(find.text('No lessons match "QuantumPhysics"'), findsOneWidget);
      expect(find.text('Reset Search & Filters'), findsOneWidget);

      // Tap reset
      await tester.tap(find.text('Reset Search & Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Algorithms & Data Structures'), findsOneWidget);
      expect(
        find.text('Photosynthesis & Cellular Respiration'),
        findsOneWidget,
      );

      await db.close();
    },
  );
}
