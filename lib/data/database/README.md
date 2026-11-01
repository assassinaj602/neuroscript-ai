# NeuroScript AI: Local Encrypted Database Architecture

Comprehensive technical documentation and architectural reference for the local, offline-first persistence layer of **NeuroScript AI**, implemented in accordance with **Milestone 2 (Frontend & Database Initialization)** of the CS-400 Final Year Project proposal.

---

## 1. Architectural Philosophy & Technology Stack

NeuroScript AI is engineered from the ground up as a **privacy-first, offline-first** study platform for neurodivergent learners. Students frequently record sensitive, personal handwritten lecture notes and study telemetry. Under no circumstances should raw notes or revision records reside unencrypted on third-party cloud servers or in plaintext on the device filesystem.

```
+--------------------------------------------------------------------------+
|                        Presentation & Riverpod UI                        |
+--------------------------------------------------------------------------+
                                    │
                                    ▼ (Domain Contracts)
+--------------------------------------------------------------------------+
|                         Abstract Repositories                            |
|        (ProfileRepository, NoteRepository, LessonRepository, etc.)       |
+--------------------------------------------------------------------------+
                                    │
                                    ▼ (Type-Safe Dart Operations)
+--------------------------------------------------------------------------+
|                        Drift ORM (AppDatabase)                           |
|             Schema versioning, relational joins, atomic transactions      |
+--------------------------------------------------------------------------+
                                    │
                 ┌──────────────────┴──────────────────┐
                 ▼ (Native FFI)                        ▼ (Web JS Interop)
+----------------------------------+  +------------------------------------+
|   SQLCipher AES-256 Engine       |  |   sqlite3 WebAssembly Dispatcher   |
|   (Android, iOS, Windows, macOS) |  |   (Browser OPFS / IndexedDB)       |
+----------------------------------+  +------------------------------------+
                 │                                     │
                 ▼                                     ▼
+----------------------------------+  +------------------------------------+
|  neuroscript_encrypted.db File   |  |   neuroscript_web_db Database      |
+----------------------------------+  +------------------------------------+
```

### Core Technologies
1. **SQLite:** The industry standard, highly reliable, ACID-compliant embedded relational database engine.
2. **Drift (formerly Moor):** A reactive persistence library for Dart and Flutter. Drift translates compile-time table definitions into type-safe queries, eliminating runtime syntax errors and providing compile-time verification for all data operations.
3. **SQLCipher (AES-256):** Transparent 256-bit AES encryption extension for SQLite. SQLCipher encrypts every page of the database file on disk, including data, schema, indexes, and journal files.
4. **WebAssembly (WASM):** Enables the identical relational database schema and query operations to run in web browsers using `sqlite3.wasm` and a dedicated Web Worker (`drift_worker.js`).

---

## 2. Relational Database Schema (5 Core Tables)

The database schema strictly adheres to **Appendix A** of the *Milestone Execution Plan* and **Section 5.3** of the *Project Proposal*. It comprises five interconnected tables:

```
[ UserProfiles ]
       │
[ SourceNotes ]
       │ 1-to-many
       ▼
   [ Lessons ]
       │ 1-to-many
       ▼
  [ Flashcards ]
       │ 1-to-1
       ▼
[ ReviewProgress ]
```

### 2.1. `UserProfiles` Table
Stores learner accessibility preferences and the active neurodivergent profile selection.
* **`id` (INTEGER, Primary Key, Auto-Increment):** Internal surrogate key.
* **`profileType` (TEXT, Not Null):** Active profile category (`'ADHD'`, `'Dyslexia'`, or `'Autism'`).
* **`themeSettings` (TEXT, Default `'{}'`):** JSON-encoded object storing learner customizations (e.g. typography scaling factor, text-to-speech speed, sensory toggles).
* **`createdAt` (DATETIME, Default `currentDateAndTime`):** Timestamp when the profile record was created.

### 2.2. `SourceNotes` Table
Stores the raw, unformatted OCR text transcribed from the student's handwritten lecture notes.
* **`noteId` (TEXT, Primary Key):** Unique string identifier (e.g., `'note_1730412345678'`).
* **`rawOcrText` (TEXT, Not Null):** Complete multi-line text extracted from optical note acquisition or manual input.
* **`documentHash` (TEXT, Not Null, Unique Index):** Deterministic SHA-256 digest of the normalized text.
  * *Deduplication Role:* If a student re-scans an existing note, the system matches the `documentHash` to instantly reopen the existing lesson rather than recompiling duplicates.
* **`createdAt` (DATETIME, Default `currentDateAndTime`):** Acquisition timestamp.

### 2.3. `Lessons` Table
Contains structured, multi-modal study units compiled from a source note.
* **`lessonId` (TEXT, Primary Key):** Unique string identifier (e.g., `'lesson_1730412345678'`).
* **`noteId` (TEXT, Foreign Key $\rightarrow$ `SourceNotes.noteId`):** References parent source note with **cascading deletion**.
* **`title` (TEXT, Not Null):** Topic name (e.g., *"Photosynthesis and Cellular Respiration"*).
* **`conceptMapJson` (TEXT, Not Null):** JSON serialization of the 2D concept graph nodes, directed edges, and relationship labels.
* **`promptVersion` (TEXT, Default `'v1'`):** Version identifier of the compilation schema template.
* **`source` (TEXT, Default `'seed'`):** Generator origin (`'seed'`, `'mock'`, `'cloud'`, or `'device'`).
* **`createdAt` (DATETIME, Default `currentDateAndTime`):** Lesson creation timestamp.

### 2.4. `Flashcards` Table
Stores line-grounded active recall study cards synthesized for a lesson.
* **`cardId` (TEXT, Primary Key):** Unique string identifier (e.g., `'lesson_123_c1'`).
* **`lessonId` (TEXT, Foreign Key $\rightarrow$ `Lessons.lessonId`):** References parent lesson with **cascading deletion**.
* **`question` (TEXT, Not Null):** The prompt displayed on the front face of the 3D flip card.
* **`answer` (TEXT, Not Null):** The explanation revealed on the back face of the card.
* **`sourceLineReference` (TEXT, Not Null):** JSON array of 1-based source lines in the original lecture note that justify this card (e.g., `"[3, 4]"`).
* **`groundingScore` (REAL, Nullable):** Verification score $G \in [0.0, 1.0]$ quantifying lexical and semantic alignment with student notes.
* **`verified` (BOOLEAN, Default `TRUE`):** Boolean gate indicating whether the card satisfied grounding criteria.

### 2.5. `ReviewProgress` Table
Tracks Leitner Spaced Repetition System (SRS) state and longitudinal mastery metrics for each card.
* **`progressId` (INTEGER, Primary Key, Auto-Increment):** Internal tracking key.
* **`cardId` (TEXT, Foreign Key $\rightarrow$ `Flashcards.cardId`):** References parent card with **cascading deletion**.
* **`box` (INTEGER, Default `1`):** Current Leitner compartment level (1 through 5).
* **`spacedRepetitionInterval` (INTEGER, Default `1`):** Current review interval in days (`1`, `3`, `7`, `14`, or `30` days).
* **`nextReviewDate` (DATETIME, Not Null):** Precise UTC timestamp when this card becomes eligible for daily review.
* **`lastReviewedAt` (DATETIME, Nullable):** Timestamp of the most recent active recall attempt.
* **`consecutiveCorrect` (INTEGER, Default `0`):** Streak counter of consecutive "Got it" answers.

---

## 3. Referential Integrity & Cascading Deletions

Relational integrity is enforced at the SQLite engine level via `PRAGMA foreign_keys = ON`. All child relationships define cascading deletions:

```
SourceNotes (Parent)
    └── Lessons (onDelete: KeyAction.cascade)
            └── Flashcards (onDelete: KeyAction.cascade)
                    └── ReviewProgress (onDelete: KeyAction.cascade)
```

### Why Cascading Deletion is Essential:
1. **Zero Data Leakage:** Deleting a lecture note automatically purges all derived lessons, concept graphs, flashcards, and review progress records in a single atomic transaction.
2. **Orphan Prevention:** Eliminates disconnected records that would otherwise consume storage and skew mastery analytics.
3. **GDPR / Privacy Compliance:** When a user requests "Delete Note" or "Clear All Study Data", no fragmented user text remains stored in the database.

---

## 4. Cryptographic Security & Hardware Key Storage

Native database files (`neuroscript_encrypted.db`) are encrypted at rest using **SQLCipher AES-256 in CBC mode** with PBKDF2 key derivation.

```
+--------------------------------------------------------------------------+
| 1. App Launch: FlutterSecureStorage.read(key: 'neuroscript_db_key')       |
+--------------------------------------------------------------------------+
                                    │
                  ┌─────────────────┴─────────────────┐
                  ▼ (Key exists)                      ▼ (First Run / Key is null)
       [ Read 256-bit Key ]             [ Random.secure() generates 32 bytes ]
                  │                                   │
                  │                     [ FlutterSecureStorage.write(...) ]
                  │                                   │
                  └─────────────────┬─────────────────┘
                                    │
                                    ▼
+--------------------------------------------------------------------------+
| 2. NativeDatabase.createInBackground(...)                                |
|    setup: (rawDb) => rawDb.execute("PRAGMA key = '$keyBase64';");         |
+--------------------------------------------------------------------------+
                                    │
                                    ▼
+--------------------------------------------------------------------------+
| 3. SQLite Engine Validates Key & Decrypts Database Pages Transparently   |
+--------------------------------------------------------------------------+
```

### Key Management Rules:
* **No Hardcoded Keys:** Encryption keys are never compiled into the APK, source code, or configuration files.
* **Hardware-Backed Keystores:** The key is persisted using `FlutterSecureStorage` (backed by Android Keystore on Android and iOS Keychain on iOS).
* **Disk Extraction Immunity:** If a bad actor extracts the `.db` file via Android Debug Bridge (`adb backup` / root access), opening the file in SQLite tools yields: `Error: file is encrypted or is not a database`.

---

## 5. Multiplatform Connection Dispatching

Cross-platform compilation requires isolating native C-FFI libraries from web JavaScript runtimes. This is achieved via Dart conditional exports in `lib/data/database/connection/`:

* **`connection.dart`:** Dispatches to `connection_native.dart` if `dart.library.ffi` is present, or to `connection_web.dart` if `dart.library.js_interop` is present.
* **`connection_native.dart`:** Instantiates `NativeDatabase.createInBackground` targeting `neuroscript_encrypted.db` in the application documents directory, executing the `PRAGMA key` SQLCipher initialization.
* **`connection_web.dart`:** Instantiates `WasmDatabase.open` with `sqlite3.wasm` and `drift_worker.js`, providing asynchronous persistence via the browser Origin Private File System (OPFS) or IndexedDB.

---

## 6. Repository Pattern & Clean Architecture

The database layer adheres to the **Dependency Inversion Principle (DIP)**. UI screens and Riverpod state controllers never import Drift or execute SQL queries directly.

```
Presentation Layer (UI Screens & Widgets)
          │
          ▼
Riverpod Providers (allLessonsProvider, schedulerMetricsProvider)
          │
          ▼
Domain Repository Interfaces (LessonRepository, NoteRepository, ReviewRepository)
          │
          ▼
Concrete Implementations (AppLessonRepository, AppNoteRepository, AppReviewRepository)
          │
          ▼
Drift ORM & SQLCipher Engine (AppDatabase)
```

### Benefits:
* **Testability:** Automated widget tests substitute the persistent database with `AppDatabase.memory()` in seconds without writing to disk.
* **Maintenance:** Schema modifications or SQL optimizations remain isolated within `lib/data/repositories/` without cascading changes into presentation widgets.

---

## 7. Atomic Transactions & Idempotent Seeding

### Transactional Guarantees
Multi-step database updates are wrapped in `db.transaction(() async { ... })`:
* **Lesson Import:** Saving a note, lesson, flashcard set, and initial review progress records executes atomically. If an exception occurs on card 5 of 10, the entire transaction rolls back, preventing corrupt partial lessons.
* **Clear All Data:** Purging learner history executes across all five tables within an atomic transaction.

### Idempotent Seed Loader
On cold-start, `SeedImporter` inspects `assets/seed/*.json`. Before inserting, it verifies whether a record with the computed `DocumentHash` already exists in `SourceNotes`. If found, insertion is safely bypassed, guaranteeing zero duplicate lessons across repeated application launches.

---

## 8. Verification & Test Suite

The database layer is verified by dedicated automated tests in the `/test` directory:

| Test Suite | File | Focus Areas Verified |
| :--- | :--- | :--- |
| **Repository CRUD & Cascades** | `test/repository_test.dart` | Note creation, document hash lookup, unique constraint enforcement, duplicate deduplication, lesson retrieval, review answer updates, soft delete/recovery, and foreign key cascade deletion of flashcards and progress records. |
| **Schema Migration Scaffold** | `test/migration_test.dart` | Verifies `schemaVersion == 2` and confirms migration scaffold handles table creation and column addition (`isDeleted`) cleanly. |
| **Cryptographic Encryption** | `test/encryption_verification_test.dart` | Hardware key acquisition via `FlutterSecureStorage`, 256-bit AES generation, fail-fast `DatabaseEncryptionException`, and PRAGMA key disk verification. |
| **Cryptographic Hashing** | `test/document_hash_test.dart` | Normalization invariance (case, whitespace, line endings) and deterministic SHA-256 output. |
| **Idempotent Seed Seeding** | `test/seed_importer_test.dart` | Verifies transactional seed loading and tests that duplicate runs produce zero duplicated database rows. |
| **Spaced Repetition Scheduler** | `test/scheduler_test.dart` | 15 test scenarios verifying Leitner interval progression (1 $\rightarrow$ 3 $\rightarrow$ 7 $\rightarrow$ 14 $\rightarrow$ 30 days), Box 1 resets, and ADHD 5-card queue capping. |

All database tests execute against isolated in-memory instances (`AppDatabase.memory()`), passing with 100% green status in under 4 seconds.
