// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/providers.dart
//
// Description:
//   Application-wide Riverpod dependency injection and reactive state providers.
//   Orchestrates configuration, encrypted database singletons, domain repositories,
//   and asynchronous state streams driving the user interface.
//
// Key Concepts:
//   - Riverpod Unidirectional Dataflow: Decouples UI presentation from business
//     logic and data access, automatically propagating state changes to listening widgets.
//   - FutureProvider Caching & Invalidation: Caches asynchronous queries (e.g. lesson
//     summaries, scheduler metrics) and allows fine-grained cache invalidation
//     via `ref.invalidate(...)` after review sessions or settings changes.
//   - Dependency Injection: Enables automated widget tests to override production
//     providers (such as `appDatabaseProvider` or `lessonRepositoryProvider`) with
//     in-memory mocks using ProviderScope overrides.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../core/theme/app_palettes.dart';
import '../data/database/database.dart';
import '../data/repositories/app_repositories.dart';
import '../data/repositories/repository_interfaces.dart';
import '../services/leitner_scheduler.dart';
import '../services/seed_importer.dart';

/// Provider exposing compile-time configuration and runtime feature flags.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

/// Provider delivering the encrypted Drift database singleton.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provider delivering the idempotent offline seed curriculum importer.
final seedImporterProvider = Provider<SeedImporter>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SeedImporter(db);
});

/// Repository provider for managing learner profiles.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppProfileRepository(db);
});

/// Repository provider for storing and querying raw OCR student notes.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppNoteRepository(db);
});

/// Repository provider for managing compiled lesson entities and concept maps.
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppLessonRepository(db);
});

/// Repository provider for managing Leitner spaced repetition reviews and metrics.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppReviewRepository(db);
});

/// FutureProvider reading the currently active learner profile from persistent storage.
final activeProfileProvider = FutureProvider<ProfileType?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getActiveProfile();
});

/// FutureProvider loading the list of all available lessons for the study library.
final allLessonsProvider = FutureProvider<List<LessonSummary>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getAllLessons();
});

/// FutureProvider loading the list of soft-deleted lessons in trash.
final deletedLessonsProvider = FutureProvider<List<LessonSummary>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getDeletedLessons();
});

/// FutureProvider computing active recall study metrics and daily review counts.
final schedulerMetricsProvider = FutureProvider<SchedulerMetrics>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getMetrics();
});

/// Accessibility preference state (text scaling, reduced motion, high contrast).
class AccessibilityPreferences {
  final double textScale;
  final bool reducedMotion;
  final bool highContrast;

  const AccessibilityPreferences({
    this.textScale = 1.0,
    this.reducedMotion = false,
    this.highContrast = false,
  });

  AccessibilityPreferences copyWith({
    double? textScale,
    bool? reducedMotion,
    bool? highContrast,
  }) {
    return AccessibilityPreferences(
      textScale: textScale ?? this.textScale,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

class AccessibilityPreferencesNotifier
    extends Notifier<AccessibilityPreferences> {
  @override
  AccessibilityPreferences build() {
    return const AccessibilityPreferences();
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }

  void setReducedMotion(bool val) {
    state = state.copyWith(reducedMotion: val);
  }

  void setHighContrast(bool val) {
    state = state.copyWith(highContrast: val);
  }
}

final accessibilityPreferencesProvider =
    NotifierProvider<
      AccessibilityPreferencesNotifier,
      AccessibilityPreferences
    >(AccessibilityPreferencesNotifier.new);
