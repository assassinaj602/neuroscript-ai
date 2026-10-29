import '../models/lesson_model.dart';
import '../../core/theme/app_palettes.dart';
import '../../services/scheduler/leitner_scheduler.dart';

abstract class ProfileRepository {
  Future<ProfileType?> getActiveProfile();
  Future<void> saveProfile(ProfileType profile);
  Future<void> resetProfile();
}

abstract class NoteRepository {
  Future<String> saveNote({
    required String rawOcrText,
    required String documentHash,
  });
  Future<String?> getNoteIdByHash(String documentHash);
  Future<String?> getRawNoteText(String noteId);
}

abstract class LessonRepository {
  Future<List<LessonSummary>> getAllLessons();
  Future<LessonModel?> getLessonById(String lessonId);
  Future<void> saveLesson({
    required String noteId,
    required LessonModel lesson,
  });
  Future<void> deleteLesson(String lessonId);
}

abstract class ReviewRepository {
  Future<List<FlashcardReviewItem>> getReviewItemsForLesson(String lessonId);
  Future<List<FlashcardReviewItem>> getAllReviewItems();
  Future<void> recordCardResult({
    required String cardId,
    required bool wasCorrect,
  });
  Future<SchedulerMetrics> getMetrics();
}

class LessonSummary {
  const LessonSummary({
    required this.lessonId,
    required this.title,
    required this.profile,
    required this.source,
    required this.cardCount,
    required this.dueCount,
    required this.createdAt,
    required this.noteId,
  });

  final String lessonId;
  final String title;
  final String profile;
  final String source;
  final int cardCount;
  final int dueCount;
  final DateTime createdAt;
  final String noteId;
}

class FlashcardReviewItem {
  const FlashcardReviewItem({
    required this.card,
    required this.progress,
    required this.rawNoteLines,
  });

  final FlashcardModel card;
  final ReviewItem progress;
  final List<String> rawNoteLines;
}
