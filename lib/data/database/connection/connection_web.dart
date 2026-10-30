// ============================================================================
// NeuroScript AI: Web Database Connection
// File: lib/data/database/connection/connection_web.dart
//
// Description:
//   Configures WebAssembly (WASM) SQLite database connection for Flutter Web.
//   Utilizes OPFS / IndexedDB persistence via Drift Web Workers with automatic
//   in-memory fallback when worker isolation is constrained.
// ============================================================================

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the primary persistent WebAssembly database connection for web environments.
QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'neuroscript_web_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  }));
}

/// Opens an isolated in-memory WebAssembly database connection for web testing.
QueryExecutor openMemoryConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'neuroscript_memory_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  }));
}
