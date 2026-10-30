// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/leitner_scheduler.dart
//
// Description:
//   Pure-Dart implementation of the 5-box Leitner Spaced Repetition System (SRS).
//   Strictly adheres to WP2.2 specifications in the Milestone Execution Plan.
//
// Key Concepts:
//   - 5-Box Leitner Scheduling Intervals:
//     * Box 1: 1 day interval (Newly introduced or recently missed cards)
//     * Box 2: 3 days interval
//     * Box 3: 7 days interval
//     * Box 4: 14 days interval
//     * Box 5: 30 days interval (Mastered cards)
//   - Active Recall Transitions:
//     * Answering "Got it" (Correct): Moves card up one box (capped at Box 5).
//     * Answering "Not yet" (Incorrect): Resets card back to Box 1 with a 1-day interval.
//   - Profile-Driven Cognitive Queue Caps:
//     * ADHD Profile: Strictly capped at 5 cards per session to prevent cognitive
//       overwhelm and task fatigue.
//     * Dyslexia / Autism Profiles: Default cap of 10 cards per session.
//   - Priority Ordering: Overdue cards (sorted by most overdue first) are reviewed
//     first, followed by newly introduced cards. Future cards are excluded.
//   - Injected Clock Interface: Allows unit tests to simulate advancing days,
//     midnight boundaries, and time-zone shifts deterministically.
// ============================================================================

import 'dart:math';

import '../core/theme/app_palettes.dart';

/// Abstract clock to allow unit tests to simulate advancing days or time-zones.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

/// A Leitner card representation containing current interval and box state.
class ReviewItem {
  const ReviewItem({
    required this.cardId,
    required this.box,
    required this.intervalDays,
    required this.nextReviewDate,
    this.lastReviewedAt,
    this.consecutiveCorrect = 0,
    this.isNew = false,
  });

  final String cardId;
  final int box; // 1 to 5
  final int intervalDays; // 1, 3, 7, 14, 30
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;
  final int consecutiveCorrect;
  final bool isNew;

  ReviewItem copyWith({
    int? box,
    int? intervalDays,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    int? consecutiveCorrect,
    bool? isNew,
  }) {
    return ReviewItem(
      cardId: cardId,
      box: box ?? this.box,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      isNew: isNew ?? this.isNew,
    );
  }
}

/// Pure-Dart Leitner spaced-repetition scheduler.
///
/// Follows WP2.2 specifications: intervals: 1, 3, 7, 14, 30 days.
class LeitnerScheduler {
  const LeitnerScheduler({this.clock = const SystemClock()});

  final Clock clock;

  static const List<int> boxIntervals = [1, 3, 7, 14, 30];

  /// Calculates the next review state when a student answers 'Got it' (correct).
  ReviewItem recordCorrect(ReviewItem item) {
    final now = clock.now();
    final nextBox = min(5, item.box + 1);
    final interval = boxIntervals[nextBox - 1];
    final nextReview = now.add(Duration(days: interval));

    return item.copyWith(
      box: nextBox,
      intervalDays: interval,
      nextReviewDate: nextReview,
      lastReviewedAt: now,
      consecutiveCorrect: item.consecutiveCorrect + 1,
      isNew: false,
    );
  }

  /// Calculates the next review state when a student answers 'Not yet' (incorrect).
  ReviewItem recordIncorrect(ReviewItem item) {
    final now = clock.now();
    const nextBox = 1; // Resets to box 1
    const interval = 1; // 1 day interval
    final nextReview = now.add(const Duration(days: interval));

    return item.copyWith(
      box: nextBox,
      intervalDays: interval,
      nextReviewDate: nextReview,
      lastReviewedAt: now,
      consecutiveCorrect: 0,
      isNew: false,
    );
  }

  /// Builds the daily study queue: due cards first, followed by unreviewed cards.
  ///
  /// Capped by session size based on user profile (ADHD = 5, default = 10).
  List<ReviewItem> buildDailyQueue({
    required List<ReviewItem> allItems,
    required ProfileType profile,
    int? customCap,
  }) {
    final now = clock.now();
    final cap = customCap ?? (profile == ProfileType.adhd ? 5 : 10);

    final dueCards = <ReviewItem>[];
    final newCards = <ReviewItem>[];

    for (final item in allItems) {
      if (item.isNew) {
        newCards.add(item);
      } else if (!item.nextReviewDate.isAfter(now)) {
        dueCards.add(item);
      }
    }

    // Sort due cards by most overdue first
    dueCards.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

    final combined = [...dueCards, ...newCards];
    return combined.take(cap).toList();
  }

  /// Calculates progress summary metrics.
  SchedulerMetrics calculateMetrics(List<ReviewItem> allItems) {
    final now = clock.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    int dueToday = 0;
    int mastered = 0;
    int learning = 0;

    for (final item in allItems) {
      if (item.box >= 5) {
        mastered++;
      } else if (!item.isNew) {
        learning++;
      }

      if (item.isNew || !item.nextReviewDate.isAfter(endOfDay)) {
        dueToday++;
      }
    }

    final total = allItems.length;
    final masteryPercentage = total > 0 ? (mastered / total) * 100 : 0.0;

    return SchedulerMetrics(
      totalCards: total,
      dueToday: dueToday,
      masteredCards: mastered,
      learningCards: learning,
      masteryPercentage: masteryPercentage,
    );
  }
}

class SchedulerMetrics {
  const SchedulerMetrics({
    required this.totalCards,
    required this.dueToday,
    required this.masteredCards,
    required this.learningCards,
    required this.masteryPercentage,
  });

  final int totalCards;
  final int dueToday;
  final int masteredCards;
  final int learningCards;
  final double masteryPercentage;
}
