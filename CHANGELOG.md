# Changelog

All notable changes to the **NeuroScript AI** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0+2] - 2026-11-01

### Milestone 1 & Milestone 2 Evaluation Release (`v0.2.1-m2`)

#### Security & Cryptography
- **Migrated from EOL SQLCipher**: Removed deprecated `sqlcipher_flutter_libs ^0.7.0+eol` and migrated to `sqlite3` (3.x) with SQLite3MultipleCiphers (`sqlite3mc`).
- **Fail-Closed Cipher Runtime**: Validates active cipher status via `SELECT sqlite3mc_version();`. Throws typed `DatabaseEncryptionException` on failure; plaintext fallback is strictly prohibited.
- **Hardware-Backed Key Generation**: Automatically generates a 256-bit AES key via `Random.secure()` and stores it in `FlutterSecureStorage` (Android KeyStore / iOS Keychain).
- **Disk Header & Reopen Tests**: Added tests in `test/encryption_verification_test.dart` verifying that on-disk DB files do *not* contain the plaintext `"SQLite format 3\0"` header and that reopening with an incorrect key fails closed.
- **Android Backup Hardening**: Configured `android:allowBackup="false"` in `AndroidManifest.xml` to prevent ADB backup extraction.

#### Spaced Repetition (SRS) & Cognitive Accessibility
- **Pure-Dart 5-Box Leitner Engine**: Implemented `LeitnerScheduler` with intervals of 1, 3, 7, 14, and 30 days.
- **Profile-Driven Queue Capping**: Strictly caps review queues at 5 cards per session for ADHD learners to eliminate review anxiety; caps at 10 cards for Dyslexia and Autism.
- **Injected Clock Seam**: Abstracted `Clock` interface allows deterministic simulation of multi-day review schedules in unit tests.
- **Honest Attribution**: Set `groundingScore: null` for human-authored seed lessons and display "Seed lesson (author-written)" badge in provenance sheets.

#### Relational Database & Drift ORM
- **Foreign-Key Cascade Enforcement**: Foreign-key cascade constraints cleanly purge child flashcards and review progress records when parent lessons or notes are deleted.
- **Deterministic Deduplication**: Computes normalized SHA-256 `documentHash` on notes, preventing duplicate note insertion while returning canonical IDs.
- **Schema Migration Scaffold**: Migrated schema from version 1 to 2, introducing soft-delete (`is_deleted`) support for lessons.
- **Eliminated N+1 Queries**: Replaced sequential per-card progress lookups with batch SQL in-clause queries in `getReviewItemsForLesson`, `getAllLessons`, and `getDeletedLessons`.

#### User Interface & Multi-Profile Design Systems
- **WCAG 2.1 AA Compliance**: Engineered three independent color palettes for ADHD (dopamine anchors), Dyslexia (anti-glare warm cream #FBF8EE, soft charcoal #2B2D42), and Autism (calm sage, low sensory noise).
- **Responsive Text Scaling**: Verified zero `RenderFlex` overflows at 1.0x and 2.0x text scaling across all screens.
- **Flashcard Set Editor**: Added `/lesson/:id/edit` screen to edit set titles, update questions/answers, and add/remove cards.
- **Soft-Delete Trash & Recovery**: Implemented Recently Deleted bottom sheet with badge indicators, restoring lessons or permanently purging them.
- **Concept Map Graph**: Interactive node-edge visualization with pan/zoom (`InteractiveViewer`) and node provenance inspection.
- **Developer Paste-Text Importer**: Debug/demo tool to import lecture notes into encrypted SQLite without camera OCR, guarded behind `demoMode`.

#### Code Quality, Architecture & CI
- **Decoupled ProfileType**: Moved `ProfileType` from UI theme into core domain model `lib/core/models/profile_type.dart`.
- **Strict Linting**: Hardened `analysis_options.yaml` with `avoid_catches_without_on_clauses`, `unawaited_futures`, `require_trailing_commas`, and `prefer_const_constructors` with 0 analyzer issues.
- **Comprehensive Test Suite**: Expanded test coverage to 80 unit, widget, and integration tests with 100% pass rate.
- **Automated CI Workflow**: Configured GitHub Actions CI pipeline running formatting checks, static analysis, full test suite, and debug APK build.
- **Architecture Documentation**: Authored ADRs 001 through 004 and `docs/EVALUATION.md` requirement traceability matrix.
