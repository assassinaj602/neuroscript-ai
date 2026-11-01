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

/// Exception thrown when cryptographic key acquisition or database encryption fails.
class DatabaseEncryptionException implements Exception {
  final String message;
  final Object? cause;
  const DatabaseEncryptionException(this.message, [this.cause]);

  @override
  String toString() =>
      'DatabaseEncryptionException: $message${cause != null ? " (Cause: $cause)" : ""}';
}

/// Retrieves or securely generates a cryptographically random 256-bit AES key.
Future<String> getOrCreateEncryptionKey({
  FlutterSecureStorage? secureStorage,
}) async {
  final storage = secureStorage ?? const FlutterSecureStorage();
  try {
    String? key = await storage.read(key: 'neuroscript_master_aes_key');
    if (key == null || key.isEmpty) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Encode(keyBytes);
      await storage.write(key: 'neuroscript_master_aes_key', value: key);
    }
    return key;
  } catch (e) {
    throw DatabaseEncryptionException(
      'Failed to securely access or generate hardware-backed encryption key from FlutterSecureStorage.',
      e,
    );
  }
}

/// Opens the primary persistent encrypted database connection for native platforms.
QueryExecutor openConnection({String? overrideKey, File? overrideFile}) {
  return LazyDatabase(() async {
    final File file;
    if (overrideFile != null) {
      file = overrideFile;
    } else {
      final dbFolder = await getApplicationDocumentsDirectory();
      file = File(p.join(dbFolder.path, 'neuroscript_encrypted.db'));
    }

    final key = overrideKey ?? await getOrCreateEncryptionKey();

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // Enforce SQLCipher / SQLite3MultipleCiphers encryption
        // Fail closed if cipher is not active (no swallowed exception)
        try {
          rawDb.execute("PRAGMA key = '$key';");
          final res = rawDb.select('SELECT sqlite3mc_version();');
          if (res.isEmpty ||
              res.first.values.isEmpty ||
              res.first.values.first == null ||
              res.first.values.first.toString().isEmpty) {
            throw const DatabaseEncryptionException(
              'SQLite3MultipleCiphers is not active on native SQLite handle. Failing closed.',
            );
          }
        } on DatabaseEncryptionException {
          rethrow;
        } catch (e) {
          throw DatabaseEncryptionException(
            'Failed to configure or verify SQLCipher/SQLite3MultipleCiphers encryption key on native SQLite handle.',
            e,
          );
        }
      },
    );
  });
}

/// Deletes the master encryption key from hardware-backed secure storage.
Future<void> deleteDatabaseEncryptionKey({
  FlutterSecureStorage? secureStorage,
}) async {
  final storage = secureStorage ?? const FlutterSecureStorage();
  await storage.delete(key: 'neuroscript_master_aes_key');
}

/// Opens an isolated in-memory database connection for high-speed unit tests.
QueryExecutor openMemoryConnection() {
  return NativeDatabase.memory();
}
