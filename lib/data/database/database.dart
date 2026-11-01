// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/data/database/database.dart
//
// Description:
//   Cross-platform database management layer built with Drift, SQLCipher, and WASM.
//   Enforces WP2.1 privacy-by-design requirements by encrypting all student notes,
//   lessons, and review histories at rest on mobile/desktop, and provides WASM
//   persistence with in-memory execution for web environments.
//
// Key Concepts:
//   - Multi-Platform Support: Dispatches connection initialization via
//     [openConnection] and [openMemoryConnection] to native SQLite or WebAssembly SQLite.
//   - SQLCipher AES-256 Encryption: Secures native databases on device storage.
//   - Foreign Key Cascades: Enforces `PRAGMA foreign_keys = ON` in the connection
//     hook so that data hierarchy cleanups remain perfectly synchronized.
//   - Migration Scaffold: Implements [MigrationStrategy] with [schemaVersion] = 1,
//     providing a safe seam for adding future tables (e.g. PendingJobs in Milestone 4C).
// ============================================================================

import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables.dart';

part 'database.g.dart';

/// Central Drift database instance managing local encrypted persistence.
@DriftDatabase(
  tables: [UserProfiles, SourceNotes, Lessons, Flashcards, ReviewProgress],
)
class AppDatabase extends _$AppDatabase {
  /// Default constructor opening the database on device storage or web storage.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  /// In-memory constructor utilized for high-speed, isolated automated unit tests.
  AppDatabase.memory([QueryExecutor? executor])
    : super(executor ?? openMemoryConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Create all tables on initial database instantiation
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(lessons, lessons.isDeleted);
      }
    },
    beforeOpen: (details) async {
      // Explicitly activate SQLite foreign key enforcement
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Atomic transaction that purges all user data and encryption keys from the local device.
  /// Triggered via Settings -> "Clear All Study Data" with user confirmation.
  Future<void> clearAllData({dynamic secureStorage}) async {
    await transaction(() async {
      await delete(reviewProgress).go();
      await delete(flashcards).go();
      await delete(lessons).go();
      await delete(sourceNotes).go();
      await delete(userProfiles).go();
    });
    await deleteDatabaseEncryptionKey(secureStorage: secureStorage);
  }
}
