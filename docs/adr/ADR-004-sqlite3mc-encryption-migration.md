# ADR-004: Migration to SQLite3MultipleCiphers (sqlite3mc) & Fail-Closed Cryptographic Security

## Status
Accepted

## Date
2026-10-31

## Context
NeuroScript AI is architected around strict privacy preservation (Rule 1: "Student lecture notes and personal flashcards never leave the device unencrypted"). In earlier prototypes, the project depended on `sqlcipher_flutter_libs ^0.7.0+eol`. This dependency is explicitly marked End-Of-Life (EOL), unmaintained, and silently functioned as an unencrypted plaintext no-op on modern SQLite binaries.

To deliver verifiable cryptographic assurance and protect student data against local file extraction, forensic inspection, and unauthorized backup extraction, the encryption layer required complete architectural remediation.

## Decision
We removed `sqlcipher_flutter_libs` and migrated to **`sqlite3` (3.x)** combined with **SQLite3MultipleCiphers (`sqlite3mc`)** and fail-closed cryptographic runtime enforcement.

Key architectural implementation details:
1. **Hardware-Backed Key Generation**:
   - Generates a 256-bit AES encryption key using `Random.secure()`.
   - Stores and retrieves the master key via `FlutterSecureStorage` (hardware KeyStore on Android, Keychain on iOS/macOS).
2. **Fail-Closed Cipher Verification**:
   - Upon opening an encrypted connection, the database executes `PRAGMA key = '<256-bit-key>';` and queries `SELECT sqlite3mc_version();`.
   - If `sqlite3mc` is missing, inactive, or fails to initialize, the factory **fails closed** by throwing a strongly typed `DatabaseEncryptionException`. Unencrypted fallback is strictly prohibited in production and release builds.
3. **Android Backup Hardening**:
   - Enforced `android:allowBackup="false"` in `AndroidManifest.xml` to prevent ADB backup extraction of local databases and keys.
4. **Comprehensive Cryptographic Verification**:
   - `test/encryption_verification_test.dart` executes real on-disk tests:
     - **Binary Header Inspection**: Verifies that the first 16 bytes of the on-disk database file do *not* equal the standard plaintext `"SQLite format 3\0"` header.
     - **Wrong-Key Rejection**: Confirms that attempting to reopen an existing encrypted database file with an incorrect key throws an error and rejects queries.
     - **Secure Data Purge**: Confirms that `clearAllData()` purges all local tables and invokes `secureStorage.delete(key: 'neuroscript_master_aes_key')`.

## Consequences

### Positive
- **True AES-256 On-Disk Encryption**: Database files cannot be read with standard SQLite viewers or forensic extraction tools without the hardware-stored key.
- **Fail-Closed Security Posture**: A broken cipher configuration halts application startup rather than silently compromising user privacy.
- **Evidence-Backed Compliance**: Automated unit and disk verification tests provide concrete, reproducible evidence for academic FYP evaluation.

### Negative / Trade-offs
- Native ciphers require platform-specific C toolchain compilation hooks.
- Forgetting or losing the hardware encryption key makes local data unrecoverable by design.

## Alternatives Considered
1. **Retaining `sqlcipher_flutter_libs ^0.7.0+eol`**:
   - *Rejected*: Insecure; unmaintained EOL package silently created unencrypted SQLite files.
2. **Application-Level Column Encryption**:
   - *Rejected*: Encrypting individual fields introduces immense ORM complexity, disables SQLite indexing, and leaves metadata and table schemas exposed in plaintext.
