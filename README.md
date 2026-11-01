# NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners

[![CI](https://github.com/zaintahir2025/neuroscript-ai/actions/workflows/ci.yml/badge.svg?branch=fix%2Fm2-evaluation-readiness)](https://github.com/zaintahir2025/neuroscript-ai/actions/workflows/ci.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Release-v0.2.1--m2-orange.svg)](docs/EVALUATION.md)

A specialized, accessible study application engineered for students with Attention Deficit Hyperactivity Disorder (ADHD), Dyslexia, and Autism Spectrum Conditions. Built with Flutter and an encrypted local SQLite database (Drift + SQLite3MultipleCiphers), NeuroScript AI delivers an offline-first learning system featuring Leitner spaced repetition flashcards, 2D interactive concept maps, and neurodivergent-friendly UI/UX themes adhering strictly to WCAG 2.1 AA accessibility standards.

---

## Project Metadata

* **Institution:** Department of Computer Science, University of Engineering & Technology (UET) Taxila
* **Course:** CS-400 Final Year Project (Academic Year 2026–2027)
* **Supervisor:** Mr. Awais Mehmood
* **Engineering Team:**
  * **Zain Tahir** (Roll No. 23-CS-115) – Systems Architecture, Database Engineering, Frontend Implementation
  * **Ujala Sahar** (Roll No. 23-CS-135) – UI/UX Design System, Accessibility Auditing, User Acceptance Testing, Documentation
* **Delivery Scope:** **Milestone 1** (Project Planning, Contracts & System Design) and **Milestone 2** (Encrypted Local Storage, Study Engines & Multi-Profile UI) Complete and Verified.

---

## Documentation Index

Comprehensive, lightweight architecture, database, and milestone documentation:

* **[Evaluation Matrix & Traceability](docs/EVALUATION.md)**: Requirement-by-requirement mapping to tests and evidence files.
* **[Release Changelog](CHANGELOG.md)**: Version history, security migrations, and feature releases.
* **Architectural Decision Records (ADRs)**:
  * [`ADR-001: Adoption of Drift ORM`](docs/adr/ADR-001-drift-orm.md)
  * [`ADR-002: Adoption of Riverpod State Management`](docs/adr/ADR-002-riverpod-state-management.md)
  * [`ADR-003: Pure-Dart 5-Box Leitner Spaced Repetition Engine`](docs/adr/ADR-003-leitner-srs-engine.md)
  * [`ADR-004: Migration to SQLite3MultipleCiphers (sqlite3mc)`](docs/adr/ADR-004-sqlite3mc-encryption-migration.md)
* **Master Milestone Execution Plan:** [`docs/NeuroScript_AI_Milestone_Execution_Plan.pdf`](docs/NeuroScript_AI_Milestone_Execution_Plan.pdf)
* **Database Relational Schema & ER Diagram:** [`docs/diagrams/database_er.md`](docs/diagrams/database_er.md)
* **System Architecture & Component Diagrams:** [`docs/diagrams/architecture.md`](docs/diagrams/architecture.md)
* **Runtime Sequence Diagrams:** [`docs/diagrams/sequence_diagrams.md`](docs/diagrams/sequence_diagrams.md)
* **Data Contracts (Lesson Schema & OpenAPI):** [`docs/contracts/`](docs/contracts/)
* **Database Layer Documentation:** [`lib/data/database/README.md`](lib/data/database/README.md)

---

## Problem Statement and Motivation

Undergraduate students with learning differences encounter severe cognitive barriers when revising from lecture notes:

1. **Executive Dysfunction & Task Initiation (ADHD):** Confronting dense, unorganized notes causes task paralysis and cognitive overwhelm. Uncapped study queues of 100+ cards trigger focus fatigue and abandonment.
2. **Visual Stress & Scotopic Sensitivity (Dyslexia):** Harsh black text on pure white backgrounds produces visual glare, letter distortion ("dancing text"), and rapid eye strain. Crowded layouts impede phonological decoding.
3. **Sensory Sensitivity & Ambiguity (Autism):** Unpredictable navigation, gratuitous motion animations, and figurative language induce sensory overload and frustration.
4. **AI Hallucinations in Educational Tools:** Mainstream generative assistants routinely invent non-existent facts or extrapolate beyond provided lecture materials without verifiable source citations.
5. **Data Privacy Deficits:** Commercial flashcard tools store student notes in plaintext on cloud servers without end-to-end user encryption.

NeuroScript AI resolves these challenges through an accessibility-first client architecture, strict source-grounding verification, and a zero-retention, encrypted offline storage model.

---

## System Architecture

### 1. Implemented & Operational Features (Milestones 1 & 2)

The current release (`v0.2.1-m2`) delivers the complete client and database foundation:

```
+-------------------------------------------------------------------------+
|                    Client Layer (Flutter & Riverpod)                    |
|                                                                         |
|  [ Splash Screen ]  -------->  [ Onboarding ]  --->  [ Profile Select ] |
|                                                             |           |
|                                                             v           |
|  [ Library Dashboard ] <-------------------------> [ Lesson Overview ]  |
|     |                                                       |           |
|     +-- [ Active Recall Review (3D Flip) ] <----------------+           |
|     +-- [ Concept Map Graph (2D Interactive) ] <------------+           |
|     +-- [ Progress & Study Analytics ] <--------------------+           |
|     +-- [ Flashcard Set Editor (/lesson/:id/edit) ]                     |
|     +-- [ Recently Deleted Trash & Recovery Sheet ]                     |
|                                                                         |
|  [ "Where is this from?" Line-Level Source Provenance Modal ]           |
+-------------------------------------------------------------------------+
                                    |
                                    v (Reactive Streams & AES-256 Fail-Closed)
+-------------------------------------------------------------------------+
|               Local Encrypted Database Layer (Drift ORM)                |
|                                                                         |
|  - user_profiles (ADHD, Dyslexia, Autism configurations)                |
|  - source_notes (Raw text & unique SHA-256 documentHash index)          |
|  - lessons (Title, conceptMapJson, soft-delete is_deleted)              |
|  - flashcards (Question, answer, sourceLineReference citations)         |
|  - review_progress (5-Box Leitner interval, nextReviewDate, metrics)    |
|                                                                         |
|  Engine: sqlite3 3.x + SQLite3MultipleCiphers (sqlite3mc AES-256)       |
|  Keys: Hardware-backed 256-bit AES key via FlutterSecureStorage         |
+-------------------------------------------------------------------------+
```

* **Cryptographic Local Database (WP2.1):**
  - Drift ORM managing encrypted SQLite via SQLite3MultipleCiphers (`sqlite3mc`).
  - Hardware-backed 256-bit AES key generated via `Random.secure()` and persisted in `FlutterSecureStorage` (Android KeyStore / iOS Keychain).
  - **Fail-Closed Runtime**: Throws typed `DatabaseEncryptionException` if cipher is missing or inactive; unencrypted fallback is strictly prohibited.
  - Foreign-key cascade deletion across `source_notes` $\to$ `lessons` $\to$ `flashcards` $\to$ `review_progress`.
  - Android ADB backup disabled (`android:allowBackup="false"`).
  - Schema migration from v1 to v2 supporting soft-delete (`is_deleted`).
* **5-Box Leitner Spaced Repetition Engine (WP2.2):**
  - Pure-Dart scheduling algorithm with intervals: Box 1 (1 day), Box 2 (3 days), Box 3 (7 days), Box 4 (14 days), Box 5 (30 days).
  - **Profile-Driven Queue Capping**: Strictly capped at **5 cards per session** for ADHD learners to eliminate review anxiety; capped at **10 cards** for Dyslexia and Autism.
  - Injected `Clock` interface enabling deterministic time simulation in unit tests.
* **Idempotent Bundled Curriculum (WP2.3):**
  - Bundled seed curriculum JSON files loaded transactionally on initial launch.
  - Exactly 0 duplicate rows inserted on subsequent launches or re-imports.
  - **Honest Content Attribution**: Human-authored seed lessons have `groundingScore` set to `null` and display a clear "Seed lesson (author-written)" badge.
* **Study Dashboard & Library (WP2.4):**
  - Dynamic search filtering, multi-criteria sorting (Title, Due, Card Count), and study progress metrics.
  - Full provenance modal displaying note metadata, creation date, and SHA-256 document hash.
  - Recently Deleted trash sheet supporting instant set restoration or permanent cascading purge.
  - Flashcard Set Editor (`/lesson/:id/edit`) allowing users to edit titles, modify cards, or add new items.
  - Developer Paste-Text Importer available in debug/demo mode (`demoMode`).
* **Accessibility-First Study Modes (WP2.5):**
  - Interactive Flashcard Review with card flipping, box progression, and source line reference links.
  - Interactive Concept Map graph with pan/zoom (`InteractiveViewer`) and node line inspection.
  - Zero `RenderFlex` overflows verified at both standard 1.0x and high-contrast 2.0x text scaling.

---

### 2. Planned Architecture & Roadmap (Milestones 3 through 6)

The following components are designed in the architecture blueprints but belong to **Milestone 3 and beyond**; they are **NOT** present in the Milestone 1-2 evaluation release:

```
+-------------------------------------------------------------------------+
|                  PLANNED PIPELINE (Milestone 3+)                        |
|                                                                         |
|  [ Camera Capture ]  --->  [ OpenCV C++ ]  --->  [ Google ML Kit OCR ]  |
|   (Framing Guides)        (Bilateral Filter)      (Ordered Line Blocks) |
|                                                              |          |
|                                                              v          |
|  [ Local Encrypted DB ] <--- [ Closed-Book Gemini ] <--- [ Proxy Gate ] |
|   (Grounding Verified)        (Delimited Synthesis)       (ASP.NET Core)|
+-------------------------------------------------------------------------+
```

1. **Stage 1: Optical Acquisition (Milestone 3):** Camera capture with multi-page burst (1–5 pages), edge-detection framing guides, and ambient light metering. Flagged off via `enableCapture = false`.
2. **Stage 2: OpenCV Image Enhancement (Milestone 3):** Background-isolated C++ preprocessing pipeline executing CLAHE, bilateral filtering, and deskewing via Native Assets FFI.
3. **Stage 3: OCR Transcription (Milestone 3):** Transcribing notes into ordered, 1-based numbered lines via Google ML Kit / Tesseract. Benchmark dataset established in `docs/benchmarks/ocr_benchmark.csv`.
4. **Stage 4: ASP.NET Core Proxy Gateway (Milestone 3):** Rate-limited, authenticated API gateway proxying requests to Gemini models. Contract defined in `docs/contracts/proxy_api.yaml`.
5. **Stage 5: LLM Synthesis & MiniLM Grounding Verification (Milestone 4):** Closed-book prompt compilation with Google Gemini 2.5 Flash and all-MiniLM-L6-v2 semantic embeddings. Generator mode defaults to `GeneratorMode.seed`.
6. **Stage 6: Text-to-Speech (TTS) & Simplification (Milestone 5):** Auditory read-aloud engine with word-level highlight tracking and literal simplification mode for Autism. Flagged off via `enableTts = false` and `enableSimplify = false`.

---

## Neurodivergent Accessibility Profiles

NeuroScript AI provides three dedicated, WCAG 2.1 AA compliant design systems:

| Dimension | ADHD Profile | Dyslexia Profile | Autism Profile |
| :--- | :--- | :--- | :--- |
| **Cognitive Goal** | Dopamine feedback, minimal clutter | Scotopic sensitivity, anti-glare | Low sensory arousal, predictability |
| **Primary Color** | Deep Indigo (`#3F51B5`) | Slate Blue (`#1E3A8A`) | Muted Sage Teal (`#3D6B7A`) |
| **Accent Color** | Warm Amber (`#FF9800`) | Warm Amber (`#FF9800`) | Ice Mist Soft Slate (`#607D8B`) |
| **Canvas Background** | Clean Minimal Grey (`#F8F9FA`) | Anti-Glare Warm Cream (`#FBF8EE`) | Uniform Ice Mist (`#EEF3F4`) |
| **Body Text** | Dark Charcoal (`#1F2937`) | Soft Charcoal (`#2B2D42`) | Deep Slate (`#1A2E35`) |
| **Typography** | Crisp Sans-Serif | Relaxed line-height (1.6), tracking +0.6 | Predictable structure, tracking +0.2 |
| **Study Sizing** | **5 cards per session** (strict cap) | 10 cards per session | 10 cards per session |
| **Motion & Audio** | Engaging progress rings | Gentle cues, no glare | Zero autoplay motion, muted borders |

*All color combinations have been mathematically validated in `test/theme_wcag_test.dart` to exceed the WCAG 2.1 AA minimum contrast threshold of 4.5:1 for standard body text.*

---

## How to Verify & Reproduce

The application is accompanied by a comprehensive, fully automated test suite. You can verify the entire project locally using standard Flutter tools:

### 1. Static Analysis
Verify that zero warnings, errors, or lints exist under our hardened analysis rules:
```bash
flutter analyze
```

### 2. Code Formatting
Verify that all source and test files adhere strictly to standard Dart style guidelines:
```bash
dart format --output=none --set-exit-if-changed lib test integration_test
```

### 3. Automated Test Suite
Execute the full test suite (80 automated unit, widget, and integration tests):
```bash
flutter test
```

### 4. Code Coverage Report
Generate code coverage metrics:
```bash
flutter test --coverage
```

### 5. Build Debug APK
Build a reproducible debug Android application package:
```bash
flutter build apk --debug
```

---

## Current Scope Limitations

In alignment with university FYP Milestone 1 & 2 evaluation guidelines:
1. **Curriculum Source:** Study content in this release is loaded from pre-verified offline seed curriculum files (`assets/seed/*.json`) and developer test imports. Live camera capture and cloud LLM generation are scheduled for Milestones 3 and 4.
2. **Grounding Evaluation:** Because seed content is author-written, LLM hallucination scoring is not simulated; grounding scores are set to `null` and displayed honestly as human-authored.
3. **Audio / TTS:** Audio playback and Text-to-Speech engines are deferred to Milestone 5.
4. **Platform Scope:** Fully tested and operational on Android, Windows, and Linux local environments.
