// ============================================================================
// NeuroScript AI: Cross-Platform Connection Dispatcher
// File: lib/data/database/connection/connection.dart
//
// Description:
//   Conditionally routes database connection construction to either
//   native SQLite (dart.library.io) or WebAssembly SQLite (dart.library.js_interop).
// ============================================================================

export 'connection_stub.dart'
    if (dart.library.ffi) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
