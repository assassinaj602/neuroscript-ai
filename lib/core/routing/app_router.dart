// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/routing/app_router.dart
//
// Description:
//   Declarative routing configuration built upon GoRouter and Riverpod.
//   Handles URL-based navigation across mobile, web, and desktop targets,
//   enforcing onboarding guards, managing route parameters, and providing
//   deep-link stability.
//
// Key Concepts:
//   - Route Guards & Redirection: Prevents learners from accessing study modules
//     before completing the initial onboarding and learner profiling flow.
//   - Reactive Navigation: Watches [activeProfileProvider] so that profile state
//     changes seamlessly trigger route re-evaluation.
//   - Declarative Path Arguments: Extracts route variables (e.g., `:id` in `/lesson/:id`)
//     and asynchronously binds them to local Drift repositories.
//   - Screen Separation: Decouples navigation transitions from screen widgets.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/concept_map/concept_map_screen.dart';
import '../../features/lesson/edit_lesson_screen.dart';
import '../../features/lesson/lesson_overview_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/profile_select_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/providers.dart';
import '../../features/review/flashcard_review_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Pure route guard evaluation function, decoupling redirection business logic
/// from widget lifecycle and enabling deterministic unit testing.
String? evaluateAppRouteGuard({
  required bool isLoading,
  required dynamic profile,
  required String matchedLocation,
}) {
  // Do not redirect while the database is still being read during cold-start
  if (isLoading) return null;

  final isSplash = matchedLocation == '/splash';
  if (isSplash) return null;

  final isGoingToOnboarding =
      matchedLocation == '/onboarding' || matchedLocation == '/profile_select';

  // Guard 1: First-time user with no profile -> Force redirection to Onboarding
  if (profile == null) {
    return isGoingToOnboarding ? null : '/onboarding';
  }

  // Guard 2: Existing learner attempting to navigate to onboarding -> Route to Library
  if (isGoingToOnboarding) {
    return '/library';
  }

  return null;
}

/// Riverpod provider delivering the global [GoRouter] instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch profile state to dynamically redirect based on learner setup status
  final activeProfileAsync = ref.watch(activeProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => evaluateAppRouteGuard(
      isLoading: activeProfileAsync.isLoading,
      profile: activeProfileAsync.value,
      matchedLocation: state.matchedLocation,
    ),
    routes: [
      // 1. Cold-start branding & seed loader screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. First-run introduction & privacy commitment
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Learner profiling: ADHD, Dyslexia, Autism selection
      GoRoute(
        path: '/profile_select',
        builder: (context, state) => const ProfileSelectScreen(),
      ),

      // 4. Central study library and lesson dashboard
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),

      // 5. Individual lesson overview and study mode launcher
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
              if (snapshot.hasError) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load lesson: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/library'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Library'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final lesson = snapshot.data;
              if (lesson == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Not Found')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Lesson not found.'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/library'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Library'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return LessonOverviewScreen(lessonId: id, lesson: lesson);
            },
          );
        },
      ),

      // 5b. Edit flashcard set / lesson
      GoRoute(
        path: '/lesson/:id/edit',
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
                return Scaffold(
                  appBar: AppBar(title: const Text('Not Found')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Lesson not found.'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/library'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Library'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return EditLessonScreen(lessonId: id, lesson: lesson);
            },
          );
        },
      ),

      // 6. Active recall flashcard review session (Leitner Spaced Repetition)
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
              if (snapshot.hasError) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load review cards: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/library'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Library'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final results = snapshot.data;
              if (results == null || results[0] == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Not Found')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Review cards not found.'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/library'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Library'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final lesson = results[0] as dynamic;
              final items = results[1] as dynamic;

              return FlashcardReviewScreen(
                lessonTitle: lesson.title as String,
                reviewItems: items,
                onRecordResult: (cardId, wasCorrect) async {
                  await ref
                      .read(reviewRepositoryProvider)
                      .recordCardResult(cardId: cardId, wasCorrect: wasCorrect);
                  ref.invalidate(allLessonsProvider);
                  ref.invalidate(schedulerMetricsProvider);
                },
              );
            },
          );
        },
      ),

      // 7. Interactive visual concept map with pan/zoom and line provenance
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
              if (snapshot.hasError) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load concept map: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/library'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Library'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final lesson = snapshot.data;
              if (lesson == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Not Found')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Lesson not found.'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/library'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Library'),
                        ),
                      ],
                    ),
                  ),
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

      // 8. Quantitative progress statistics, streaks, and Leitner box metrics
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),

      // 9. Application settings, accessibility fine-tuning, and data deletion
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
