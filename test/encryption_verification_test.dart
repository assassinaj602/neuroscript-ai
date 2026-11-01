// ============================================================================
// NeuroScript AI: Native Database Encryption Verification Test
// File: test/encryption_verification_test.dart
//
// Description:
//   Validates the SQLCipher / SQLite3MultipleCiphers native encryption
//   pipeline, cryptographically secure 256-bit key generation, secure storage
//   integration, and fail-fast exception handling without silent catch fallbacks.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_script/data/database/connection/connection_native.dart';
import 'package:neuro_script/data/database/database.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('Database Encryption & Cryptographic Security Tests (WP2.1)', () {
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
    });

    test('1. getOrCreateEncryptionKey generates and stores a 256-bit base64 key when none exists', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final key = await getOrCreateEncryptionKey(secureStorage: mockStorage);

      expect(key, isNotEmpty);
      final decodedBytes = base64Decode(key);
      expect(
        decodedBytes.length,
        equals(32),
        reason: 'Cryptographic key must be exactly 256 bits (32 bytes)',
      );

      verify(
        () => mockStorage.write(key: 'neuroscript_master_aes_key', value: key),
      ).called(1);
    });

    test('2. getOrCreateEncryptionKey returns existing stored key without regenerating', () async {
      const existingKey = 'dGhpc19pc19hXzMyX2J5dGVfZXhpc3Rpbmdfa2V5IQ==';
      when(() => mockStorage.read(key: 'neuroscript_master_aes_key'))
          .thenAnswer((_) async => existingKey);

      final key = await getOrCreateEncryptionKey(secureStorage: mockStorage);

      expect(key, equals(existingKey));
      verifyNever(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
    });

    test('3. getOrCreateEncryptionKey throws DatabaseEncryptionException when storage access fails', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenThrow(Exception('Hardware keystore unavailable'));

      expect(
        () => getOrCreateEncryptionKey(secureStorage: mockStorage),
        throwsA(isA<DatabaseEncryptionException>()),
      );
    });

    test('4. (a) DB on disk is encrypted: first 16 bytes do NOT equal "SQLite format 3\\0"', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'neuroscript_enc_test_',
      );
      final testDbFile = File('${tempDir.path}/test_encrypted.db');

      try {
        final executor = openConnection(
          overrideKey: 'test_crypto_key_256_bit_hash_abc_123',
          overrideFile: testDbFile,
        );
        final db = AppDatabase(executor);

        // Verify write operations work through encrypted connection
        await db
            .into(db.userProfiles)
            .insert(UserProfilesCompanion.insert(profileType: 'ADHD'));

        final profiles = await db.select(db.userProfiles).get();
        expect(profiles.length, equals(1));
        expect(profiles.first.profileType, equals('ADHD'));

        await db.close();

        final bytes = await testDbFile.readAsBytes();
        expect(bytes.length, greaterThanOrEqualTo(16));
        final header = String.fromCharCodes(bytes.take(16));
        expect(
          header,
          isNot(equals('SQLite format 3\x00')),
          reason: 'Encrypted DB file must never begin with plaintext SQLite header',
        );
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('5. (b) Reopening an encrypted database with a wrong key fails', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'neuroscript_wrong_key_test_',
      );
      final testDbFile = File('${tempDir.path}/test_wrong_key.db');

      try {
        // Step 1: Create and populate with correct key
        final executorCorrect = openConnection(
          overrideKey: 'correct_key_256_bit_abc_xyz_001',
          overrideFile: testDbFile,
        );
        final dbCorrect = AppDatabase(executorCorrect);
        await dbCorrect
            .into(dbCorrect.userProfiles)
            .insert(UserProfilesCompanion.insert(profileType: 'Dyslexia'));
        await dbCorrect.close();

        // Step 2: Attempt to reopen with an incorrect key
        final executorWrong = openConnection(
          overrideKey: 'wrong_key_different_bit_abc_xyz_999',
          overrideFile: testDbFile,
        );
        final dbWrong = AppDatabase(executorWrong);

        // Querying with wrong key must fail closed
        expect(
          () => dbWrong.select(dbWrong.userProfiles).get(),
          throwsA(anything),
          reason: 'Attempting to query an encrypted database with wrong key must fail',
        );
        await dbWrong.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('6. clearAllData() deletes all database records and purges master encryption key', () async {
      when(() => mockStorage.delete(key: 'neuroscript_master_aes_key'))
          .thenAnswer((_) async {});

      final db = AppDatabase.memory();
      await db
          .into(db.userProfiles)
          .insert(UserProfilesCompanion.insert(profileType: 'Autism'));
      expect((await db.select(db.userProfiles).get()).length, equals(1));

      await db.clearAllData(secureStorage: mockStorage);

      expect((await db.select(db.userProfiles).get()).length, equals(0));
      verify(() => mockStorage.delete(key: 'neuroscript_master_aes_key')).called(1);
      await db.close();
    });
  });
}

