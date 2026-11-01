# ADR-001: Adoption of Drift ORM for Local Relational Persistence

## Status
Accepted

## Date
2026-10-28

## Context
NeuroScript AI requires a robust, privacy-preserving, on-device database layer to manage complex educational entities across Milestones 1 and 2:
- `SourceNotes`: Raw OCR lecture transcripts indexed deterministically by SHA-256 `documentHash`.
- `Lessons`: Compiled study units containing concept map JSON graphs and metadata.
- `Flashcards`: Atomic active-recall prompts citing source line references and verification metrics.
- `ReviewProgress`: Leitner spaced repetition system (SRS) tracking intervals, box levels, and review timestamps.
- `UserProfiles`: Neurodivergent learner profile configurations (ADHD, Dyslexia, Autism).

The persistence layer must enforce relational integrity (including foreign key cascades from `SourceNotes` $\to$ `Lessons` $\to$ `Flashcards` $\to$ `ReviewProgress`), guarantee compile-time SQL query safety, provide reactive stream subscriptions for UI widgets, and seamlessly integrate with encrypted SQLite engines.

## Decision
We adopted **Drift** (formerly Moor) as the primary Object-Relational Mapping (ORM) and persistence engine for NeuroScript AI.

Key architectural choices with Drift:
1. **Dart-First Declarative Schema**: Tables are defined as Dart classes (`SourceNotes`, `Lessons`, `Flashcards`, `ReviewProgress`, `UserProfiles`) with strict constraints (`customConstraint('REFERENCES ... ON DELETE CASCADE')`).
2. **Compile-Time Safety**: Code generation compiles Dart schemas into type-safe companions and data classes, preventing runtime SQL syntax errors.
3. **In-Memory Testing Seam**: `AppDatabase.memory()` utilizes `drift/native.dart` in-memory executors for fast, hermetic unit and widget tests without touching the disk.
4. **Encrypted SQLite Integration**: Drift's `LazyDatabase` setup connects directly to encrypted `sqlite3` handles with hardware-backed encryption keys.

## Consequences

### Positive
- **Guaranteed Foreign Key Cascades**: Deleting a source note or lesson cleanly cascades deletions to child flashcards and review progress records with zero orphaned data.
- **Type-Safe Queries**: All column selections, orderings, and filter conditions are validated by the Dart analyzer at compile time.
- **Zero Raw SQL Fragility**: Refactoring database columns automatically surfaces all impacted call sites across repositories.
- **Hermetic Testing**: Fast in-memory SQLite instances run in standard CI without needing physical device emulators.

### Negative / Trade-offs
- Requires `build_runner` code generation when modifying table definitions (`dart run build_runner build`).
- Slight build overhead during initial project configuration.

## Alternatives Considered
1. **Raw `sqflite`**:
   - *Rejected*: Raw string queries lack compile-time validation, making schema refactoring error-prone and tedious.
2. **Hive / Isar (NoSQL)**:
   - *Rejected*: NoSQL document stores lack native relational foreign-key cascades and ACID transaction semantics across interdependent study entities.
3. **ObjectBox**:
   - *Rejected*: C++ native dependency footprint is heavy and complicates custom multi-cipher database encryption hooks across platforms.
