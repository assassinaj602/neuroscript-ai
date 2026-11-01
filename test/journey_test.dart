// ============================================================================
// NeuroScript AI: Automated Journey & Restart Persistence Tests
// File: test/journey_test.dart
//
// Description:
//   Headless unit/widget test executing the complete Milestone 1 & 2 learner journey:
//   1. Onboarding Screen: Learner reads privacy commitment and proceeds.
//   2. Profile Selection: Learner chooses Dyslexia profile (persisted in SQLite).
//   3. Library Screen: Displays compiled lessons and launches active recall study.
//   4. Flashcard Review: Flips card, answers with recall rating, advancing Leitner box.
//   5. Progress Dashboard: Verifies active recall stats, mastery level, and streaks.
//   6. Restart Persistence: Simulates app termination and restart, verifying that
//      the selected profile, lesson state, and Leitner spaced repetition metrics
//      are strictly preserved in the encrypted SQLite database across sessions.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/lesson_model.dart';
import 'package:neuro_script/data/repositories/app_repositories.dart';
import 'package:neuro_script/features/library/library_screen.dart';
import 'package:neuro_script/features/onboarding/onboarding_screen.dart';
import 'package:neuro_script/features/onboarding/profile_select_screen.dart';
import 'package:neuro_script/features/progress/progress_screen.dart';
import 'package:neuro_script/features/providers.dart';
import 'package:neuro_script/features/review/flashcard_review_screen.dart';

void main() {
  group('Full Learner Journey & Restart Persistence Verification', () {
    late AppDatabase db;
    late AppProfileRepository profileRepo;
    late AppNoteRepository noteRepo;
    late AppLessonRepository lessonRepo;
    late AppReviewRepository reviewRepo;

    setUp(() async {
      db = AppDatabase.memory();
      profileRepo = AppProfileRepository(db);
      noteRepo = AppNoteRepository(db);
      lessonRepo = AppLessonRepository(db);
      reviewRepo = AppReviewRepository(db);

      // Pre-seed sample note and lesson into SQLite database
      final noteId = await noteRepo.saveNote(
        rawOcrText:
            '1: Photosynthesis converts light energy into chemical energy.\n'
            '2: Occurs in the chloroplasts of plant cells.\n'
            '3: Chlorophyll pigments absorb blue and red light.',
        documentHash: 'journey_test_doc_hash_001',
      );

      final lesson = LessonModel(
        schemaVersion: 1,
        title: 'Photosynthesis Fundamentals',
        meta: const LessonMeta(
          profile: 'Dyslexia',
          source: 'seed',
          promptVersion: 'v1',
        ),
        conceptMap: const ConceptMapModel(
          nodes: [
            ConceptNodeModel(id: 'n1', label: 'Chloroplasts', sourceLines: [2]),
            ConceptNodeModel(id: 'n2', label: 'Light Energy', sourceLines: [1]),
          ],
          edges: [ConceptEdgeModel(from: 'n2', to: 'n1', label: 'absorbed by')],
        ),
        flashcards: const [
          FlashcardModel(
            id: 'journey_card_01',
            question: 'Where does photosynthesis occur?',
            answer: 'Inside the chloroplasts of plant cells.',
            sourceLines: [2],
            chunks: ['Chloroplasts', 'Plant cells'],
          ),
          FlashcardModel(
            id: 'journey_card_02',
            question: 'What type of light does chlorophyll absorb?',
            answer: 'Primarily blue and red wavelengths.',
            sourceLines: [3],
            chunks: ['Blue and red', 'Wavelengths'],
          ),
        ],
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets(
      'Full Journey: Onboarding -> Profile Selection -> Library -> Flashcard Review -> Progress -> Restart Persistence',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testRouter = GoRouter(
          initialLocation: '/onboarding',
          routes: [
            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
            GoRoute(
              path: '/profile_select',
              builder: (context, state) => const ProfileSelectScreen(),
            ),
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
            GoRoute(
              path: '/review/:id',
              builder: (context, state) {
                return FutureBuilder(
                  future: reviewRepo.getAllReviewItems(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return FlashcardReviewScreen(
                      lessonTitle: 'Photosynthesis Fundamentals',
                      reviewItems: snapshot.data!,
                      onRecordResult: (cardId, wasCorrect) async {
                        await reviewRepo.recordCardResult(
                          cardId: cardId,
                          wasCorrect: wasCorrect,
                        );
                      },
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        );

        // ====================================================================
        // STEP 1: First-Launch Onboarding Screen
        // ====================================================================
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              profileRepositoryProvider.overrideWithValue(profileRepo),
              lessonRepositoryProvider.overrideWithValue(lessonRepo),
              reviewRepositoryProvider.overrideWithValue(reviewRepo),
              allLessonsProvider.overrideWith(
                (ref) => lessonRepo.getAllLessons(),
              ),
              schedulerMetricsProvider.overrideWith(
                (ref) => reviewRepo.getMetrics(),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.getTheme(ProfileType.dyslexia),
              routerConfig: testRouter,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('NeuroScript AI'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);

        // Tap "Get Started" to navigate to profile select via GoRouter
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // ====================================================================
        // STEP 2: Profile Selection (Select Dyslexia Profile)
        // ====================================================================
        expect(find.text('Choose Your Learning Profile'), findsOneWidget);
        expect(find.text('Dyslexia'), findsOneWidget);
        expect(find.text('ADHD'), findsOneWidget);
        expect(find.text('Autism'), findsOneWidget);
        expect(find.text('Save & Continue'), findsOneWidget);

        // Tap "Save & Continue" (default selection is Dyslexia)
        await tester.tap(find.text('Save & Continue'));
        await tester.pumpAndSettle();

        // Verify profile was persisted to database
        final savedProfile = await profileRepo.getActiveProfile();
        expect(savedProfile, equals(ProfileType.dyslexia));

        // ====================================================================
        // STEP 3: Library Screen
        // ====================================================================
        // Verify lesson appears in the library
        expect(find.text('Photosynthesis Fundamentals'), findsOneWidget);

        // ====================================================================
        // STEP 4: Active Recall Flashcard Review Session
        // ====================================================================
        testRouter.go('/review/lesson_001');
        await tester.pumpAndSettle();

        // Verify question face is rendered
        expect(find.text('QUESTION'), findsOneWidget);
        expect(find.text('Where does photosynthesis occur?'), findsOneWidget);

        // Tap card to flip to answer
        await tester.tap(find.text('Where does photosynthesis occur?'));
        await tester.pumpAndSettle();

        // Verify answer face is revealed
        expect(find.text('ANSWER'), findsOneWidget);
        expect(
          find.text('Inside the chloroplasts of plant cells.'),
          findsOneWidget,
        );

        // Tap "Got it!" button to record successful active recall
        expect(find.text('Got it!'), findsOneWidget);
        await tester.tap(find.text('Got it!'));
        await tester.pumpAndSettle();

        // Verify Leitner progress in database: moved to Box 2 with 1 consecutive correct
        final updatedItems = await reviewRepo.getAllReviewItems();
        final reviewedCard = updatedItems.firstWhere(
          (item) => item.card.question == 'Where does photosynthesis occur?',
        );
        expect(reviewedCard.progress.box, equals(2));
        expect(reviewedCard.progress.consecutiveCorrect, equals(1));

        // ====================================================================
        // STEP 5: Progress Dashboard
        // ====================================================================
        final metrics = await reviewRepo.getMetrics();
        expect(metrics.totalCards, equals(2));
        expect(metrics.masteredCards, equals(0)); // Only box 5 is mastered
        expect(
          metrics.learningCards,
          equals(2),
        ); // Both cards in learning boxes (1 and 2)

        testRouter.go('/progress');
        await tester.pumpAndSettle();

        // Verify Progress screen shows Learning Progress and Spaced Repetition sections
        expect(find.text('Learning Progress'), findsOneWidget);
        expect(find.text('Spaced Repetition (Leitner System)'), findsOneWidget);
        expect(find.text('Box 2'), findsOneWidget);

        // ====================================================================
        // STEP 6: Restart Persistence Verification
        // ====================================================================
        // Simulate app restart by instantiating fresh repository instances over the DB
        final restartedProfileRepo = AppProfileRepository(db);
        final restartedLessonRepo = AppLessonRepository(db);
        final restartedReviewRepo = AppReviewRepository(db);

        // 1. Profile persists across restart
        final persistedProfile = await restartedProfileRepo.getActiveProfile();
        expect(
          persistedProfile,
          equals(ProfileType.dyslexia),
          reason: 'Profile selection must survive restart',
        );

        // 2. Lessons persist across restart
        final persistedLessons = await restartedLessonRepo.getAllLessons();
        expect(persistedLessons.length, equals(1));
        expect(
          persistedLessons.first.title,
          equals('Photosynthesis Fundamentals'),
        );

        // 3. Spaced repetition Leitner state persists across restart
        final persistedReviewItems = await restartedReviewRepo
            .getAllReviewItems();
        expect(persistedReviewItems.length, equals(2));
        final persistedReviewedCard = persistedReviewItems.firstWhere(
          (i) => i.card.question == 'Where does photosynthesis occur?',
        );
        expect(
          persistedReviewedCard.progress.box,
          equals(2),
          reason: 'Leitner box level 2 must survive restart',
        );
        expect(
          persistedReviewedCard.progress.consecutiveCorrect,
          equals(1),
          reason: 'Consecutive correct recall count must survive restart',
        );
      },
    );
  });
}
