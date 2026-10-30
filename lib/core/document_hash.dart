// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/document_hash.dart
//
// Description:
//   Cryptographic content addressing utility. Computes a deterministic SHA-256
//   digest over raw OCR transcription text after text normalization.
//
// Key Concepts:
//   - DocumentHash Normalization: Converts to lowercase, trims lines, collapses
//     intra-line whitespace, removes empty lines, and joins with '\n'.
//   - Deduplication & Cache Lookup: Enables the local database and generation router
//     to determine if a scanned note has already been processed without re-querying
//     the cloud AI, guaranteeing zero duplicate entries and instant cache retrieval.
// ============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Computes SHA-256 of normalized note text for duplicate detection and caching.
class DocumentHash {
  DocumentHash._();

  /// Normalizes input text and returns its lowercase SHA-256 hex digest.
  static String compute(String text) {
    final normalized = normalize(text);
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Normalizes whitespace, trims lines, converts to lowercase, and strips blank lines.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .split('\n')
        .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((line) => line.isNotEmpty)
        .join('\n');
  }
}
