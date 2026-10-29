import 'package:drift/drift.dart';

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileType => text()(); // 'ADHD' | 'Dyslexia' | 'Autism'
  TextColumn get themeSettings => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SourceNotes extends Table {
  TextColumn get noteId => text()();
  TextColumn get rawOcrText => text()();
  TextColumn get documentHash => text()(); // SHA-256
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {noteId};
}

class Lessons extends Table {
  TextColumn get lessonId => text()();
  TextColumn get noteId =>
      text().references(SourceNotes, #noteId, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get conceptMapJson => text()();
  TextColumn get promptVersion => text().withDefault(const Constant('v1'))();
  TextColumn get source => text().withDefault(const Constant('seed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {lessonId};
}

class Flashcards extends Table {
  TextColumn get cardId => text()();
  TextColumn get lessonId =>
      text().references(Lessons, #lessonId, onDelete: KeyAction.cascade)();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  TextColumn get sourceLineReference =>
      text()(); // JSON array of ints e.g. [1, 2]
  RealColumn get groundingScore => real().nullable()();
  BoolColumn get verified => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {cardId};
}

class ReviewProgress extends Table {
  IntColumn get progressId => integer().autoIncrement()();
  TextColumn get cardId =>
      text().references(Flashcards, #cardId, onDelete: KeyAction.cascade)();
  IntColumn get box =>
      integer().withDefault(const Constant(1))(); // Leitner box 1..5
  IntColumn get spacedRepetitionInterval =>
      integer().withDefault(const Constant(1))(); // 1, 3, 7, 14, 30
  DateTimeColumn get nextReviewDate => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get consecutiveCorrect =>
      integer().withDefault(const Constant(0))();
}
