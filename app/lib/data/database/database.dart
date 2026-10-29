import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [UserProfiles, SourceNotes, Lessons, Flashcards, ReviewProgress],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.memory([QueryExecutor? executor])
    : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Future migrations (e.g. PendingJobs in M4C) will go here.
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Deletes all user data (used in Settings -> Clear All Data)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(reviewProgress).go();
      await delete(flashcards).go();
      await delete(lessons).go();
      await delete(sourceNotes).go();
      await delete(userProfiles).go();
    });
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'neuroscript_encrypted.db'));

      // Retrieve or generate 256-bit encryption key stored in secure storage
      const storage = FlutterSecureStorage();
      var keyBase64 = await storage.read(key: 'neuroscript_db_key');
      if (keyBase64 == null) {
        final random = Random.secure();
        final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
        keyBase64 = base64Encode(keyBytes);
        await storage.write(key: 'neuroscript_db_key', value: keyBase64);
      }

      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          try {
            // Apply PRAGMA key for SQLCipher-backed builds
            rawDb.execute("PRAGMA key = '$keyBase64';");
          } catch (_) {
            // Falls back gracefully if SQLCipher native dynamic library is omitted on host desktop
          }
        },
      );
    });
  }
}
