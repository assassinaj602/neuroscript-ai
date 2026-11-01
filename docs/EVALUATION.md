# NeuroScript AI — Milestone 1 & Milestone 2 Evaluation Matrix

This document provides a comprehensive, evidence-backed evaluation matrix mapping every requirement from the **NeuroScript AI Milestone Execution Plan** and **Project Proposal** to its concrete source implementation, automated tests, and verification status.

---

## 1. Evaluation Verification Summary

- **Target Scope**: Milestone 1 (Foundations & Architecture) & Milestone 2 (Encrypted Local Storage, Study Engines & Multi-Profile UI).
- **Branch**: `fix/m2-evaluation-readiness`
- **Release Version**: `v0.2.1-m2` (`pubspec.yaml` `version: 0.2.0+2`)
- **Automated Test Results**: **80 tests passed, 0 failures** (`flutter test`)
- **Static Analysis**: **0 issues found** (`flutter analyze` with hardened rules)
- **Code Formatting**: **100% compliant** (`dart format --output=none --set-exit-if-changed lib test integration_test`)
- **Continuous Integration**: Automated GitHub Actions workflow (`.github/workflows/ci.yml`)

---

## 2. Milestone 1 & 2 Requirement Traceability Matrix

| Requirement / WP | Description & Technical Criteria | Implementation Files | Automated Evidence & Tests | Evaluation Status |
| :--- | :--- | :--- | :--- | :---: |
| **WP1.1: WCAG 2.1 AA Themes** | Multi-profile design systems (ADHD, Dyslexia, Autism) with verified contrast ratios $\ge 4.5:1$, scotopic anti-glare warm backgrounds, zero vibrating colors, and minimum 48 dp touch targets. | [`lib/core/models/profile_type.dart`](file:///lib/core/models/profile_type.dart)<br>[`lib/core/theme/app_palettes.dart`](file:///lib/core/theme/app_palettes.dart)<br>[`lib/core/theme/app_theme.dart`](file:///lib/core/theme/app_theme.dart) | [`test/theme_wcag_test.dart`](file:///test/theme_wcag_test.dart)<br>(14 automated WCAG contrast tests) | **VERIFIED** |
| **WP1.2: System Architecture** | Formal declarative JSON schema contract for study units, unidirectional Riverpod state flow, declarative GoRouter navigation, and responsive layouts. | [`docs/contracts/lesson.schema.json`](file:///docs/contracts/lesson.schema.json)<br>[`lib/core/routing/app_router.dart`](file:///lib/core/routing/app_router.dart)<br>[`lib/features/providers.dart`](file:///lib/features/providers.dart) | [`test/seed_contract_test.dart`](file:///test/seed_contract_test.dart)<br>[`test/router_guard_test.dart`](file:///test/router_guard_test.dart) (13 tests) | **VERIFIED** |
| **WP1.3: Architectural Decisions** | Documented rationale for core architectural choices (Drift ORM, Riverpod DI, Leitner SRS, SQLite3MC encryption). | [`docs/adr/ADR-001-drift-orm.md`](file:///docs/adr/ADR-001-drift-orm.md)<br>[`docs/adr/ADR-002-riverpod-state-management.md`](file:///docs/adr/ADR-002-riverpod-state-management.md)<br>[`docs/adr/ADR-003-leitner-srs-engine.md`](file:///docs/adr/ADR-003-leitner-srs-engine.md)<br>[`docs/adr/ADR-004-sqlite3mc-encryption-migration.md`](file:///docs/adr/ADR-004-sqlite3mc-encryption-migration.md) | Architectural documentation suite | **VERIFIED** |
| **WP2.1: Fail-Closed Database Encryption** | AES-256 on-disk encryption via SQLite3MultipleCiphers (`sqlite3mc`). 256-bit cryptographically secure key in `FlutterSecureStorage`. Fail-closed exception (`DatabaseEncryptionException`) if cipher inactive. Disabled ADB backup. | [`lib/data/database/database.dart`](file:///lib/data/database/database.dart)<br>[`android/app/src/main/AndroidManifest.xml`](file:///android/app/src/main/AndroidManifest.xml) | [`test/encryption_verification_test.dart`](file:///test/encryption_verification_test.dart)<br>(Disk 16-byte header check, wrong-key rejection, secure wipe) | **VERIFIED** |
| **WP2.1: Relational Schema & Cascades** | Strict foreign-key cascade deletes across `SourceNotes` $\to$ `Lessons` $\to$ `Flashcards` $\to$ `ReviewProgress`. Unique index on `documentHash`. Schema migrations. | [`lib/data/database/database.dart`](file:///lib/data/database/database.dart)<br>[`lib/data/repositories/app_repositories.dart`](file:///lib/data/repositories/app_repositories.dart) | [`test/cascade_delete_test.dart`](file:///test/cascade_delete_test.dart)<br>[`test/migration_test.dart`](file:///test/migration_test.dart)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.1: Cryptographic Document Hashing** | SHA-256 normalization invariance (trimming, whitespace collapse, case invariance, line-ending normalization) preventing duplicate note ingestion. | [`lib/core/document_hash.dart`](file:///lib/core/document_hash.dart) | [`test/document_hash_test.dart`](file:///test/document_hash_test.dart)<br>(Whitespace, casing, determinism tests) | **VERIFIED** |
| **WP2.2: 5-Box Leitner SRS Engine** | Pure-Dart spaced repetition system with empirical intervals (1 $\to$ 3 $\to$ 7 $\to$ 14 $\to$ 30 days). Correct answers advance one box; incorrect answers reset to Box 1. Queue capped at 5 for ADHD and 10 for Dyslexia/Autism. | [`lib/services/leitner_scheduler.dart`](file:///lib/services/leitner_scheduler.dart) | [`test/scheduler_test.dart`](file:///test/scheduler_test.dart)<br>(15 unit test scenarios with `MockClock`) | **VERIFIED** |
| **WP2.3: Idempotent Seed Curriculum** | Automated seeding of curated curriculum JSON files from assets into encrypted database. Atomic transaction rollback on malformed JSON. Exactly 0 duplicates on subsequent runs. | [`lib/services/seed_importer.dart`](file:///lib/services/seed_importer.dart)<br>[`assets/seed/*.json`](file:///assets/seed/) | [`test/seed_importer_test.dart`](file:///test/seed_importer_test.dart)<br>[`test/seed_contract_test.dart`](file:///test/seed_contract_test.dart) | **VERIFIED** |
| **WP2.3: Honest Grounding Attribution** | Seed lessons explicitly authored by human subject experts have `groundingScore` set to `null` and render "Seed lesson (author-written)" badge, adhering to honest evaluation standards. | [`assets/seed/*.json`](file:///assets/seed/)<br>[`lib/features/common/where_is_this_from_sheet.dart`](file:///lib/features/common/where_is_this_from_sheet.dart)<br>[`lib/features/lesson/lesson_overview_screen.dart`](file:///lib/features/lesson/lesson_overview_screen.dart) | Verified in seed files and UI widgets | **VERIFIED** |
| **WP2.4: Study Dashboard & Library** | Study progress banner, due count metrics, search filtering, multi-criteria sorting, Note Transcript Details bottom sheet with SHA-256 hash inspection, and concept map launcher. | [`lib/features/library/library_screen.dart`](file:///lib/features/library/library_screen.dart)<br>[`lib/features/common/where_is_this_from_sheet.dart`](file:///lib/features/common/where_is_this_from_sheet.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart)<br>(Tests 3, 9, 10) | **VERIFIED** |
| **WP2.4: Soft-Delete Trash & Recovery** | Move study sets to Recently Deleted trash with instant badge counter update, full restore to active library, or permanent cryptographic cascading purge. | [`lib/features/library/library_screen.dart`](file:///lib/features/library/library_screen.dart)<br>[`lib/data/repositories/app_repositories.dart`](file:///lib/data/repositories/app_repositories.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 9)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.4: Flashcard Set Editor** | Full set editing interface: edit lesson title, modify existing card questions/answers, delete individual cards, add new cards, with validation and persistence. | [`lib/features/lesson/edit_lesson_screen.dart`](file:///lib/features/lesson/edit_lesson_screen.dart)<br>[`lib/core/routing/app_router.dart`](file:///lib/core/routing/app_router.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 8)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.5: Active Recall Review Session** | Interactive card flipping, visual box level indicator, dual response actions ("Not yet" / "Got it!"), Leitner progression, and provenance modal showing exact source line citations. | [`lib/features/review/flashcard_review_screen.dart`](file:///lib/features/review/flashcard_review_screen.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 4)<br>[`test/journey_test.dart`](file:///test/journey_test.dart) | **VERIFIED** |
| **WP2.5: Interactive Concept Map Graph** | CustomPainter rendering nodes and labelled directed edges, pinch-to-zoom and pan via `InteractiveViewer`, and tapping nodes to view line provenance. | [`lib/features/concept_map/concept_map_screen.dart`](file:///lib/features/concept_map/concept_map_screen.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 5) | **VERIFIED** |
| **WP2.5: Accessibility & Text Scaling** | Layout responsiveness: zero `RenderFlex` overflows at standard 1.0x and high-contrast 2.0x text scaling across all primary screens. | All screen files under [`lib/features/`](file:///lib/features/) | [`test/golden_test.dart`](file:///test/golden_test.dart)<br>(1.0x & 2.0x text scale verification) | **VERIFIED** |
| **WP2.6: End-to-End Learner Journey** | Complete automated journey verifying cold start $\to$ `/onboarding` $\to$ `/profile_select` $\to$ `/library` $\to$ `/review/:id` $\to$ `/progress` $\to$ app restart persistence. | [`test/journey_test.dart`](file:///test/journey_test.dart)<br>[`integration_test/app_journey_test.dart`](file:///integration_test/app_journey_test.dart) | [`test/journey_test.dart`](file:///test/journey_test.dart) | **VERIFIED** |

---

## 3. Scope Boundaries & Non-Implemented Features (M3+ Roadmap)

To maintain academic integrity and adhere strictly to the project execution plan, the following features belong to **Milestone 3 and beyond** and are **NOT** claimed as implemented in the Milestone 1-2 evaluation release:

| Post-M2 Planned Feature | Target Milestone | Current Status in Codebase |
| :--- | :---: | :--- |
| **Live Camera Capture & OpenCV Preprocessing** | Milestone 3 | Flagged off via `enableCapture = false` in `AppConfig`. |
| **On-Device Tesseract / ML Kit OCR Pipeline** | Milestone 3 | Ground truth dataset created in `docs/benchmarks/ocr_benchmark.csv` marked `NOT MEASURED YET`. |
| **ASP.NET Core Proxy Gateway & Rate Limiting** | Milestone 3 | Contract defined in `docs/contracts/proxy_api.yaml`; client routes point to offline seed/local DB. |
| **Live Google Gemini 1.5 Flash API Calls** | Milestone 4 | Generator mode defaults to `GeneratorMode.seed`. No live external LLM network requests made. |
| **Composite Grounding Evaluation (MiniLM Semantic)** | Milestone 4B | Grounding verification set to `GroundingMode.off`. Seed lessons attributed honestly as author-written. |
| **Text-to-Speech (TTS) Read-Aloud Engine** | Milestone 5 | Flagged off via `enableTts = false`. |
| **Literal Simplification Pipeline for Autism** | Milestone 5 | Flagged off via `enableSimplify = false`. |

---

## 4. How to Reproduce & Verify

All evaluation evidence is 100% reproducible on any machine with Flutter 3.24+ installed:

```bash
# 1. Verify static code analysis (0 issues)
flutter analyze

# 2. Verify code formatting (0 unformatted files)
dart format --output=none --set-exit-if-changed lib test integration_test

# 3. Execute the full test suite (80 tests pass)
flutter test

# 4. Execute test suite with coverage report
flutter test --coverage

# 5. Build reproducible debug Android APK
flutter build apk --debug
```
