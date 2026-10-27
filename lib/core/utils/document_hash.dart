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

  /// Normalizes whitespace, trims lines, and converts to lowercase.
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
