# ADR-002: Adoption of Riverpod for Reactive State Management & Dependency Injection

## Status
Accepted

## Date
2026-10-28

## Context
NeuroScript AI features asynchronous, user-adaptive workflows across multiple screens:
- Real-time learner profile switching (ADHD, Dyslexia, Autism) altering global typography, spacing, and palettes.
- Asynchronous database reads for study sets, active recall review queues, and Leitner progress metrics.
- Fine-grained cache invalidation when lessons are imported, updated, reviewed, soft-deleted, or permanently purged.
- High testability requirements: automated tests must inject fake repositories and in-memory databases without complex mocking machinery.

## Decision
We adopted **Flutter Riverpod (2.x)** (`flutter_riverpod`) as the core architectural framework for dependency injection and state management.

Key implementation patterns:
1. **Unidirectional Dataflow**: Presentation widgets (`ConsumerWidget`, `ConsumerStatefulWidget`) observe providers (`ref.watch(...)`) and dispatch side-effects through domain repositories (`ref.read(...)`).
2. **Asynchronous FutureProviders**: Database queries are exposed as `FutureProvider` streams (`allLessonsProvider`, `activeProfileProvider`, `schedulerMetricsProvider`), giving declarative loading/error/data UI states.
3. **Targeted Invalidation**: Completing a review card or modifying a lesson triggers specific invalidations (`ref.invalidate(allLessonsProvider); ref.invalidate(schedulerMetricsProvider);`) rather than broad screen rebuilds.
4. **Hermetic Test Overrides**: `ProviderScope(overrides: [...])` allows unit, golden, and integration tests to swap production database singletons and repositories with lightweight in-memory instances.

## Consequences

### Positive
- **Compile-Time Safety**: Providers are top-level constants, eliminating runtime `ProviderNotFoundException` errors.
- **Test Isolation**: Eliminates global mutable state singletons; every test runs inside an isolated `ProviderScope`.
- **Clean Separation of Concerns**: UI widgets never import database singletons or execute SQL directly; all operations pass through repository interfaces.

### Negative / Trade-offs
- Developers must understand Riverpod concepts (`watch` vs `read` vs `listen`, provider lifecycle).
- Care must be taken not to change the number of `overrides` dynamically across widget rebuilds in tests.

## Alternatives Considered
1. **Provider (`package:provider`)**:
   - *Rejected*: Inherits `BuildContext` coupling and runtime lookup exceptions; lacks convenient declarative async providers.
2. **BLoC / Cubit (`package:flutter_bloc`)**:
   - *Rejected*: High boilerplate for straightforward relational read queries and requires event/state mapping for simple asynchronous operations.
3. **GetX**:
   - *Rejected*: Bypasses Flutter's native widget tree and context, violates clean architecture principles, and complicates hermetic test isolation.
