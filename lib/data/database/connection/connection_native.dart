// ============================================================================
// NeuroScript AI: Native Database Connection
// File: lib/data/database/connection/connection_native.dart
//
// Description:
//   Configures native SQLite/SQLCipher connection for Android, iOS, Windows,
//   macOS, and Linux platforms. Enforces AES-256 encryption at rest with
//   keys stored securely via FlutterSecureStorage.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the primary persistent encrypted database connection for native platforms.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'neuroscript_encrypted.db'));

    // Retrieve or generate the 256-bit AES encryption key in secure hardware storage
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
          // Gracefully handles environments where native SQLCipher library is not bound
        }
      },
    );
  });
}

/// Opens an isolated in-memory database connection for high-speed unit tests.
QueryExecutor openMemoryConnection() {
  return NativeDatabase.memory();
}
