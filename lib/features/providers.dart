// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/features/providers.dart
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

import '../core/config/app_config.dart';
import '../core/theme/app_palettes.dart';
import '../data/database/database.dart';
import '../data/repositories/app_repositories.dart';
import '../data/repositories/repository_interfaces.dart';
import '../services/scheduler/leitner_scheduler.dart';
import '../services/seed/seed_importer.dart';

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

/// FutureProvider computing active recall study metrics and daily review counts.
final schedulerMetricsProvider = FutureProvider<SchedulerMetrics>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getMetrics();
});
