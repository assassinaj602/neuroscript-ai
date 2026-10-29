import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../core/utils/document_hash.dart';
import '../../data/models/lesson_model.dart';
import '../../data/database/database.dart';

class SeedImporter {
  const SeedImporter(this.db);

  final AppDatabase db;

  static const List<String> seedAssetPaths = [
    'assets/seed/photosynthesis.json',
    'assets/seed/computer_architecture.json',
    'assets/seed/algorithms.json',
  ];

  /// Loads bundled seed lessons inside a single transaction idempotently.
  Future<int> importSeedLessons({AssetBundle? bundle}) async {
    final assetBundle = bundle ?? rootBundle;
    int importedCount = 0;

    await db.transaction(() async {
      for (final assetPath in seedAssetPaths) {
        try {
          final jsonString = await assetBundle.loadString(assetPath);
          final lessonModel = LessonModel.fromRawJson(jsonString);

          final rawText = lessonModel.rawNotes ?? lessonModel.title;
          final hash = DocumentHash.compute(rawText);

          // Idempotency check: see if note with identical documentHash already exists
          final existing = await (db.select(
            db.sourceNotes,
          )..where((tbl) => tbl.documentHash.equals(hash))).getSingleOrNull();

          if (existing != null) {
            continue; // Already seeded
          }

          final noteId =
              'seed_note_${lessonModel.title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
          final lessonId =
              'seed_lesson_${lessonModel.title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';

          // 1. Insert SourceNote
          await db
              .into(db.sourceNotes)
              .insert(
                SourceNotesCompanion.insert(
                  noteId: noteId,
                  rawOcrText: rawText,
                  documentHash: hash,
                ),
              );

          // 2. Insert Lesson
          await db
              .into(db.lessons)
              .insert(
                LessonsCompanion.insert(
                  lessonId: lessonId,
                  noteId: noteId,
                  title: lessonModel.title,
                  conceptMapJson: lessonModel.conceptMap.toJson().toString(),
                  promptVersion: Value(lessonModel.meta.promptVersion),
                  source: Value(lessonModel.meta.source),
                ),
              );

          // 3. Insert Flashcards & initial ReviewProgress
          final now = DateTime.now();
          for (final card in lessonModel.flashcards) {
            final cardPk = '${lessonId}_${card.id}';
            await db
                .into(db.flashcards)
                .insert(
                  FlashcardsCompanion.insert(
                    cardId: cardPk,
                    lessonId: lessonId,
                    question: card.question,
                    answer: card.answer,
                    sourceLineReference: card.sourceLines.toString(),
                    groundingScore: Value(card.groundingScore ?? 0.95),
                    verified: Value(card.verified),
                  ),
                );

            await db
                .into(db.reviewProgress)
                .insert(
                  ReviewProgressCompanion.insert(
                    cardId: cardPk,
                    box: const Value(1),
                    spacedRepetitionInterval: const Value(1),
                    nextReviewDate: now,
                    consecutiveCorrect: const Value(0),
                  ),
                );
          }

          importedCount++;
        } catch (e) {
          // Log or handle individual seed file parsing failure
        }
      }
    });

    return importedCount;
  }
}
