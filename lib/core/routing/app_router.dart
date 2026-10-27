import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/architecture/architecture_screen.dart';
import '../../features/concept_map/concept_map_screen.dart';
import '../../features/lesson/lesson_overview_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/profile_select_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/providers.dart';
import '../../features/review/flashcard_review_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final activeProfileAsync = ref.watch(activeProfileProvider);

  return GoRouter(
    initialLocation: '/library',
    redirect: (context, state) {
      final isLoading = activeProfileAsync.isLoading;
      final profile = activeProfileAsync.value;

      if (isLoading) return null; // Wait for initial profile read

      final isGoingToOnboarding = state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/profile_select';

      // Guard: No profile selected yet -> redirect to onboarding
      if (profile == null) {
        return isGoingToOnboarding ? null : '/onboarding';
      }

      // If user already has profile and tries to go to onboarding, send to library
      if (isGoingToOnboarding) {
        return '/library';
      }

      return null;
    },
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
        path: '/lesson/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder(
            future: ref.read(lessonRepositoryProvider).getLessonById(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final lesson = snapshot.data;
              if (lesson == null) {
                return const Scaffold(
                  body: Center(child: Text('Lesson not found.')),
                );
              }
              return LessonOverviewScreen(lessonId: id, lesson: lesson);
            },
          );
        },
      ),
      GoRoute(
        path: '/review/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder(
            future: Future.wait([
              ref.read(lessonRepositoryProvider).getLessonById(id),
              ref.read(reviewRepositoryProvider).getReviewItemsForLesson(id),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final results = snapshot.data;
              if (results == null || results[0] == null) {
                return const Scaffold(
                  body: Center(child: Text('Lesson not found.')),
                );
              }
              final lesson = results[0] as dynamic;
              final items = results[1] as dynamic;

              return FlashcardReviewScreen(
                lessonTitle: lesson.title as String,
                reviewItems: items,
                onRecordResult: (cardId, wasCorrect) async {
                  await ref.read(reviewRepositoryProvider).recordCardResult(
                        cardId: cardId,
                        wasCorrect: wasCorrect,
                      );
                  ref.invalidate(allLessonsProvider);
                  ref.invalidate(schedulerMetricsProvider);
                },
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/concept_map/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder(
            future: ref.read(lessonRepositoryProvider).getLessonById(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final lesson = snapshot.data;
              if (lesson == null) {
                return const Scaffold(
                  body: Center(child: Text('Lesson not found.')),
                );
              }
              return ConceptMapScreen(
                title: lesson.title,
                conceptMap: lesson.conceptMap,
                rawNoteLines: lesson.rawNotes?.split('\n') ?? [],
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/architecture',
        builder: (context, state) => const ArchitectureScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
