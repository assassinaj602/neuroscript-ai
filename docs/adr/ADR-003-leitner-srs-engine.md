# ADR-003: Pure-Dart 5-Box Leitner Spaced Repetition Engine with Neurodivergent Queue Capping

## Status
Accepted

## Date
2026-10-28

## Context
Active recall via spaced repetition is scientifically proven to enhance long-term memory retention. However, conventional algorithms like SuperMemo SM-2 or modern FSRS introduce significant drawbacks for neurodivergent learners:
1. **Exponential Overdue Backlogs ("Review Hell")**: Missing study days generates overwhelming queues of hundreds of pending cards, triggering acute task paralysis and executive dysfunction in ADHD learners.
2. **Subjective Rating Ambiguity**: Multi-button grading scales ("Again", "Hard", "Good", "Easy") require excessive metacognitive effort and induce decision fatigue.
3. **Punitive Failure Resets**: Abruptly multiplying penalty factors creates negative dopamine feedback loops.

## Decision
We engineered a **pure-Dart 5-Box Leitner Spaced Repetition System (SRS)** specifically adapted for neurodivergent cognitive profiles (WP2.2).

Key architectural specifications:
1. **Binary Feedback Cues**: Only two intuitive response actions:
   - *"Got it!"* (Correct): Advances the card up one box (Box 1 $\to$ Box 2 $\to$ Box 3 $\to$ Box 4 $\to$ Box 5).
   - *"Not yet"* (Incorrect): Safely resets the card to Box 1 for immediate consolidation without punitive permanent ease degradation.
2. **Empirical Review Intervals**:
   - Box 1: 1 day (new / recently missed)
   - Box 2: 3 days
   - Box 3: 7 days
   - Box 4: 14 days
   - Box 5: 30 days (mastered)
3. **Profile-Driven Cognitive Queue Caps**:
   - **ADHD Profile**: Strictly capped at **5 cards per review session** to sustain dopamine momentum and prevent executive exhaustion.
   - **Dyslexia & Autism Profiles**: Default cap of **10 cards per session** to preserve focus without visual fatigue.
4. **Deterministic Priority Queueing**: Overdue cards (ordered by most overdue first) precede newly introduced cards. Future non-due cards are strictly excluded from the review stream.
5. **Injected `Clock` Interface**: An abstract `Clock` interface (`SystemClock` in production, `MockClock` in unit tests) enables deterministic simulation of midnight boundaries, timezone transitions, and multi-day interval progressions.

## Consequences

### Positive
- **Zero Backlog Anxiety**: Capped micro-sessions guarantee that learners are never greeted with demoralizing queues of 100+ cards.
- **Pure-Dart Domain Portability**: The scheduler has zero UI or Flutter framework dependencies, executing instantaneously in pure Dart test runners.
- **Comprehensive Testability**: Verified by 15 dedicated unit test scenarios in `test/scheduler_test.dart` covering progression, resets, and queue caps.

### Negative / Trade-offs
- Less mathematical granularity in individual difficulty scaling compared to multi-variable SM-2.
- Mastered cards in Box 5 reappear after 30 days rather than extending to indefinite multi-month intervals.

## Alternatives Considered
1. **SuperMemo SM-2**:
   - *Rejected*: Ease factor multiplication and 4-tier ratings create cognitive friction and severe overdue queues for neurodivergent students.
2. **FSRS (Free Spaced Repetition Scheduler)**:
   - *Rejected*: Requires extensive parameter calibration (17+ weights) and complex statistical modeling unsuited for on-device, lightweight offline operation.
