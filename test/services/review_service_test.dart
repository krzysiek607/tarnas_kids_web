import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarnas_kids/services/review_service.dart';

void main() {
  // ============================================
  // Singleton pattern
  // ============================================
  group('ReviewService singleton', () {
    test('should always return the same instance', () {
      final instance1 = ReviewService.instance;
      final instance2 = ReviewService.instance;

      expect(identical(instance1, instance2), true);
    });
  });

  // ============================================
  // onGameCompleted - counter logic
  // ============================================
  group('onGameCompleted', () {
    setUp(() {
      // Initialize SharedPreferences with empty values for isolated test state
      SharedPreferences.setMockInitialValues({});
    });

    test('should increment games completed counter', () async {
      SharedPreferences.setMockInitialValues({});

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('review_games_completed');

      expect(count, 1);
    });

    test('should increment counter on each game completion', () async {
      SharedPreferences.setMockInitialValues({});

      await ReviewService.instance.onGameCompleted();
      await ReviewService.instance.onGameCompleted();
      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('review_games_completed');

      expect(count, 3);
    });

    test('should continue from existing counter value', () async {
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 3,
      });

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('review_games_completed');

      expect(count, 4);
    });

    test('should not increment counter when review already shown', () async {
      SharedPreferences.setMockInitialValues({
        'review_shown': true,
        'review_games_completed': 5,
      });

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      // Counter should NOT be incremented because review was already shown
      final count = prefs.getInt('review_games_completed');

      expect(count, 5);
    });

    test('should set review_shown to true after threshold reached', () async {
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 4,
        'review_shown': false,
      });

      // This is the 5th game - should trigger review
      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('review_shown');

      expect(shown, true);
    });

    test('should not trigger before threshold', () async {
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 2,
      });

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('review_shown');
      final count = prefs.getInt('review_games_completed');

      // Count should be incremented but review not shown yet
      expect(count, 3);
      expect(shown, isNull); // Not set yet
    });
  });

  // ============================================
  // Threshold behavior
  // ============================================
  group('threshold behavior', () {
    test('threshold is 5 games', () async {
      SharedPreferences.setMockInitialValues({});

      // Complete 4 games - should not trigger
      for (int i = 0; i < 4; i++) {
        await ReviewService.instance.onGameCompleted();
      }

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('review_shown'), isNull);

      // 5th game should trigger
      await ReviewService.instance.onGameCompleted();
      expect(prefs.getBool('review_shown'), true);
    });

    test('should only show review once', () async {
      SharedPreferences.setMockInitialValues({});

      // Complete 5 games to trigger review
      for (int i = 0; i < 5; i++) {
        await ReviewService.instance.onGameCompleted();
      }

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('review_shown'), true);
      expect(prefs.getInt('review_games_completed'), 5);

      // Complete more games - counter should NOT change
      await ReviewService.instance.onGameCompleted();
      await ReviewService.instance.onGameCompleted();

      // Counter stays at 5 because the method returns early when review_shown is true
      expect(prefs.getInt('review_games_completed'), 5);
    });

    test('counter at exactly threshold should trigger', () async {
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 4,
      });

      // This call will increment to 5 and trigger
      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('review_games_completed'), 5);
      expect(prefs.getBool('review_shown'), true);
    });

    test('counter above threshold should still trigger if not yet shown',
        () async {
      // Edge case: counter is already above threshold but review_shown is false
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 10,
        'review_shown': false,
      });

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('review_games_completed'), 11);
      // 11 >= 5, so review should trigger
      expect(prefs.getBool('review_shown'), true);
    });
  });

  // ============================================
  // SharedPreferences edge cases
  // ============================================
  group('SharedPreferences edge cases', () {
    test('should handle missing review_games_completed key', () async {
      SharedPreferences.setMockInitialValues({});

      // First call should start counter at 1 (0 + 1)
      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('review_games_completed'), 1);
    });

    test('should handle missing review_shown key', () async {
      SharedPreferences.setMockInitialValues({
        'review_games_completed': 3,
      });

      // review_shown defaults to false when not set
      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('review_games_completed'), 4);
    });

    test('should handle review_shown being false explicitly', () async {
      SharedPreferences.setMockInitialValues({
        'review_shown': false,
        'review_games_completed': 4,
      });

      await ReviewService.instance.onGameCompleted();

      final prefs = await SharedPreferences.getInstance();
      // Should have incremented and triggered
      expect(prefs.getInt('review_games_completed'), 5);
      expect(prefs.getBool('review_shown'), true);
    });
  });

  // ============================================
  // Error handling
  // ============================================
  group('error handling', () {
    test('onGameCompleted should not throw', () async {
      SharedPreferences.setMockInitialValues({});

      // Should complete without throwing
      expect(
        () async => await ReviewService.instance.onGameCompleted(),
        returnsNormally,
      );
    });

    test('multiple rapid calls should not crash', () async {
      SharedPreferences.setMockInitialValues({});

      // Simulate rapid game completions
      await Future.wait([
        ReviewService.instance.onGameCompleted(),
        ReviewService.instance.onGameCompleted(),
        ReviewService.instance.onGameCompleted(),
      ]);

      // Should not crash - test passes if no exception
      expect(true, true);
    });
  });

  // ============================================
  // Constants verification
  // ============================================
  group('constants', () {
    test('uses correct SharedPreferences keys', () {
      // Verify the keys are consistent (by testing the behavior)
      // The keys are:
      // - 'review_games_completed' for counter
      // - 'review_shown' for shown flag
      // We verify this by checking that the service reads/writes these keys

      SharedPreferences.setMockInitialValues({
        'review_games_completed': 42,
        'review_shown': true,
      });

      // If service reads 'review_shown' = true, it returns early
      // and doesn't change 'review_games_completed'
      ReviewService.instance.onGameCompleted().then((_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('review_games_completed'), 42);
      });
    });
  });
}
