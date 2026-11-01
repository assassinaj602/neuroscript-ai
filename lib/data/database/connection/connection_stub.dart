// ============================================================================
// NeuroScript AI: Cross-Platform Connection Stub
// File: lib/data/database/connection/connection_stub.dart
//
// Description:
//   Fallback stub for platforms unsupported by native and web connections.
// ============================================================================

import 'package:drift/drift.dart';

/// Opens the primary persistent database connection.
QueryExecutor openConnection() {
  throw UnsupportedError('Platform database connection is not supported.');
}

/// Opens an isolated in-memory database connection for testing.
QueryExecutor openMemoryConnection() {
  throw UnsupportedError(
    'Platform in-memory database connection is not supported.',
  );
}

/// Stub for deleting the encryption key.
Future<void> deleteDatabaseEncryptionKey({Object? secureStorage}) async {}
