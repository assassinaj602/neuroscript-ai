import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';
import 'package:neuro_script/features/architecture/architecture_screen.dart';
import 'package:neuro_script/features/concept_map/concept_map_screen.dart';
import 'package:neuro_script/features/library/library_screen.dart';
import 'package:neuro_script/features/onboarding/onboarding_screen.dart';
import 'package:neuro_script/features/onboarding/profile_select_screen.dart';
import 'package:neuro_script/features/review/flashcard_review_screen.dart';
import 'package:neuro_script/features/splash/splash_screen.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/lesson_model.dart';
import 'package:neuro_script/data/repositories/repository_interfaces.dart';
import 'package:neuro_script/features/providers.dart';
import 'package:neuro_script/services/scheduler/leitner_scheduler.dart';

void main() {
  testWidgets('1. Onboarding screen renders title and get started button', (tester) async {
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

  testWidgets('2. Profile selection screen renders all 3 learner profiles', (tester) async {
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

  testWidgets('3. Library empty state renders illustration and friendly message', (tester) async {
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
  });

  testWidgets('4. Flashcard review screen renders card, flips, and records answer', (tester) async {
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
  });

  testWidgets('5. Concept map screen renders InteractiveViewer and canvas', (tester) async {
    const conceptMap = ConceptMapModel(
      nodes: [
        ConceptNodeModel(id: 'n1', label: 'Cell', sourceLines: [1]),
        ConceptNodeModel(id: 'n2', label: 'Mitochondria', sourceLines: [2]),
      ],
      edges: [
        ConceptEdgeModel(from: 'n1', to: 'n2', label: 'contains'),
      ],
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

  testWidgets('6. Architecture & Blueprint screen renders all 4 tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.getTheme(ProfileType.adhd),
          home: const ArchitectureScreen(),
        ),
      ),
    );

    expect(find.text('System Flow'), findsOneWidget);
    expect(find.text('ER Schemas'), findsOneWidget);
    expect(find.text('API Contracts'), findsOneWidget);
    expect(find.text('8 Demo Rules'), findsOneWidget);
  });

  testWidgets('7. Splash screen renders branding and loading indicator', (tester) async {
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
    expect(find.textContaining('Privacy-Preserving Study Platform'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    await db.close();
  });
}
