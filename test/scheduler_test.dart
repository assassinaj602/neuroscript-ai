import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/services/scheduler/leitner_scheduler.dart';

class MockClock implements Clock {
  MockClock(this.currentTime);
  DateTime currentTime;

  @override
  DateTime now() => currentTime;

  void advanceDays(int days) {
    currentTime = currentTime.add(Duration(days: days));
  }
}

void main() {
  group('LeitnerScheduler Unit Tests (WP2.2 Verification)', () {
    late MockClock mockClock;
    late LeitnerScheduler scheduler;
    final baseTime = DateTime(2026, 10, 28, 12, 0);

    setUp(() {
      mockClock = MockClock(baseTime);
      scheduler = LeitnerScheduler(clock: mockClock);
    });

    test('1. New card starting state', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 1,
        intervalDays: 1,
        nextReviewDate: baseTime,
        isNew: true,
      );

      expect(item.box, equals(1));
      expect(item.intervalDays, equals(1));
      expect(item.isNew, isTrue);
    });

    test('2. Correct answer moves card from Box 1 to Box 2 (interval 3 days)', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 1,
        intervalDays: 1,
        nextReviewDate: baseTime,
      );

      final next = scheduler.recordCorrect(item);
      expect(next.box, equals(2));
      expect(next.intervalDays, equals(3));
      expect(next.nextReviewDate, equals(baseTime.add(const Duration(days: 3))));
      expect(next.consecutiveCorrect, equals(1));
    });

    test('3. Correct answer moves card from Box 2 to Box 3 (interval 7 days)', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 2,
        intervalDays: 3,
        nextReviewDate: baseTime,
        consecutiveCorrect: 1,
      );

      final next = scheduler.recordCorrect(item);
      expect(next.box, equals(3));
      expect(next.intervalDays, equals(7));
      expect(next.nextReviewDate, equals(baseTime.add(const Duration(days: 7))));
      expect(next.consecutiveCorrect, equals(2));
    });

    test('4. Correct answer moves card from Box 3 to Box 4 (interval 14 days)', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 3,
        intervalDays: 7,
        nextReviewDate: baseTime,
        consecutiveCorrect: 2,
      );

      final next = scheduler.recordCorrect(item);
      expect(next.box, equals(4));
      expect(next.intervalDays, equals(14));
      expect(next.nextReviewDate, equals(baseTime.add(const Duration(days: 14))));
      expect(next.consecutiveCorrect, equals(3));
    });

    test('5. Correct answer moves card from Box 4 to Box 5 (interval 30 days - Mastered)', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 4,
        intervalDays: 14,
        nextReviewDate: baseTime,
        consecutiveCorrect: 3,
      );

      final next = scheduler.recordCorrect(item);
      expect(next.box, equals(5));
      expect(next.intervalDays, equals(30));
      expect(next.nextReviewDate, equals(baseTime.add(const Duration(days: 30))));
      expect(next.consecutiveCorrect, equals(4));
    });

    test('6. Correct answer on Box 5 card stays in Box 5 (capped at 30 days)', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 5,
        intervalDays: 30,
        nextReviewDate: baseTime,
        consecutiveCorrect: 4,
      );

      final next = scheduler.recordCorrect(item);
      expect(next.box, equals(5));
      expect(next.intervalDays, equals(30));
      expect(next.consecutiveCorrect, equals(5));
    });

    test('7. Wrong answer on Box 4 card returns card to Box 1 with 1 day interval', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 4,
        intervalDays: 14,
        nextReviewDate: baseTime,
        consecutiveCorrect: 3,
      );

      final next = scheduler.recordIncorrect(item);
      expect(next.box, equals(1));
      expect(next.intervalDays, equals(1));
      expect(next.nextReviewDate, equals(baseTime.add(const Duration(days: 1))));
      expect(next.consecutiveCorrect, equals(0));
    });

    test('8. Wrong answer on Box 5 card resets to Box 1', () {
      final item = ReviewItem(
        cardId: 'c1',
        box: 5,
        intervalDays: 30,
        nextReviewDate: baseTime,
        consecutiveCorrect: 5,
      );

      final next = scheduler.recordIncorrect(item);
      expect(next.box, equals(1));
      expect(next.intervalDays, equals(1));
      expect(next.consecutiveCorrect, equals(0));
    });

    test('9. Queue builder prioritizes due cards over unreviewed cards', () {
      final items = [
        ReviewItem(
          cardId: 'new_1',
          box: 1,
          intervalDays: 1,
          nextReviewDate: baseTime,
          isNew: true,
        ),
        ReviewItem(
          cardId: 'due_1',
          box: 2,
          intervalDays: 3,
          nextReviewDate: baseTime.subtract(const Duration(hours: 2)),
          isNew: false,
        ),
      ];

      final queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.dyslexia,
      );

      expect(queue.first.cardId, equals('due_1'));
      expect(queue.last.cardId, equals('new_1'));
    });

    test('10. ADHD profile strictly caps daily queue at 5 cards', () {
      final items = List.generate(
        12,
        (i) => ReviewItem(
          cardId: 'card_$i',
          box: 1,
          intervalDays: 1,
          nextReviewDate: baseTime.subtract(const Duration(days: 1)),
        ),
      );

      final queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.adhd,
      );

      expect(queue.length, equals(5));
    });

    test('11. Dyslexia profile caps daily queue at default 10 cards', () {
      final items = List.generate(
        15,
        (i) => ReviewItem(
          cardId: 'card_$i',
          box: 1,
          intervalDays: 1,
          nextReviewDate: baseTime.subtract(const Duration(days: 1)),
        ),
      );

      final queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.dyslexia,
      );

      expect(queue.length, equals(10));
    });

    test('12. Cards not yet due are excluded from the review queue', () {
      final items = [
        ReviewItem(
          cardId: 'future_card',
          box: 3,
          intervalDays: 7,
          nextReviewDate: baseTime.add(const Duration(days: 3)),
          isNew: false,
        ),
      ];

      final queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.autism,
      );

      expect(queue, isEmpty);
    });

    test('13. Simulating midnight boundary makes future cards due', () {
      final items = [
        ReviewItem(
          cardId: 'midnight_card',
          box: 2,
          intervalDays: 3,
          nextReviewDate: baseTime.add(const Duration(hours: 12)),
          isNew: false,
        ),
      ];

      // Before midnight: not due
      var queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.dyslexia,
      );
      expect(queue, isEmpty);

      // Advance clock by 1 day
      mockClock.advanceDays(1);

      // After midnight: due!
      queue = scheduler.buildDailyQueue(
        allItems: items,
        profile: ProfileType.dyslexia,
      );
      expect(queue.length, equals(1));
      expect(queue.first.cardId, equals('midnight_card'));
    });

    test('14. Progress metrics calculation', () {
      final items = [
        ReviewItem(cardId: 'c1', box: 5, intervalDays: 30, nextReviewDate: baseTime),
        ReviewItem(cardId: 'c2', box: 5, intervalDays: 30, nextReviewDate: baseTime),
        ReviewItem(cardId: 'c3', box: 2, intervalDays: 3, nextReviewDate: baseTime),
        ReviewItem(cardId: 'c4', box: 1, intervalDays: 1, nextReviewDate: baseTime.add(const Duration(days: 5))),
      ];

      final metrics = scheduler.calculateMetrics(items);

      expect(metrics.totalCards, equals(4));
      expect(metrics.masteredCards, equals(2));
      expect(metrics.masteryPercentage, equals(50.0));
      expect(metrics.dueToday, equals(3));
    });

    test('15. Zero cards handled safely in metrics without NaN or division by zero', () {
      final metrics = scheduler.calculateMetrics([]);
      expect(metrics.totalCards, equals(0));
      expect(metrics.masteryPercentage, equals(0.0));
    });
  });
}
