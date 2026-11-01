// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/document_hash_test.dart
//
// Description:
//   Unit test suite verifying cryptographic SHA-256 document hash normalization
//   under WP2.1 specifications.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/document_hash.dart';

void main() {
  group('DocumentHash Tests (WP2.1 Verification)', () {
    test('Identical text with different cases produces identical hash', () {
      const text1 = 'Photosynthesis Converts Light Energy';
      const text2 = 'photosynthesis converts light energy';

      final hash1 = DocumentHash.compute(text1);
      final hash2 = DocumentHash.compute(text2);

      expect(hash1, equals(hash2));
    });

    test('Extra whitespace and blank lines are normalized out', () {
      const text1 = 'Line 1: Item A\nLine 2: Item B';
      const text2 = '  Line 1:   Item A  \n\n\n  Line 2: Item B  \n';

      final hash1 = DocumentHash.compute(text1);
      final hash2 = DocumentHash.compute(text2);

      expect(hash1, equals(hash2));
    });

    test('Different texts produce distinct hashes', () {
      const text1 = 'Photosynthesis in plants';
      const text2 = 'Cellular respiration in mitochondria';

      final hash1 = DocumentHash.compute(text1);
      final hash2 = DocumentHash.compute(text2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('Hash is a 64-character lowercase hex string', () {
      final hash = DocumentHash.compute('Sample test note');
      expect(hash.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
    });
  });
}
