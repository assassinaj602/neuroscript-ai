import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_palettes.dart';
import '../data/database/database.dart';
import '../data/repositories/app_repositories.dart';
import '../data/repositories/repository_interfaces.dart';
import '../services/scheduler/leitner_scheduler.dart';
import '../services/seed/seed_importer.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final seedImporterProvider = Provider<SeedImporter>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SeedImporter(db);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppProfileRepository(db);
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppNoteRepository(db);
});

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppLessonRepository(db);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppReviewRepository(db);
});

final activeProfileProvider = FutureProvider<ProfileType?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getActiveProfile();
});

final allLessonsProvider = FutureProvider<List<LessonSummary>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getAllLessons();
});

final schedulerMetricsProvider = FutureProvider<SchedulerMetrics>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getMetrics();
});
