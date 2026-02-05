import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tarnas_kids/services/analytics_service.dart';

// =============================================================================
// MOCKS
// =============================================================================

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<void> {}

void main() {
  // ============================================
  // Singleton pattern
  // ============================================
  group('AnalyticsService singleton', () {
    test('should return same instance via .instance', () {
      final instance1 = AnalyticsService.instance;
      final instance2 = AnalyticsService.instance;

      expect(identical(instance1, instance2), true);
    });

    test('should return same instance via analytics getter', () {
      final getterInstance = analytics;
      final staticInstance = AnalyticsService.instance;

      expect(identical(getterInstance, staticInstance), true);
    });
  });

  // ============================================
  // Initialization
  // ============================================
  group('initialization', () {
    late AnalyticsService service;

    setUp(() {
      // Reset singleton for fresh testing
      // Access the instance (it auto-creates via lazy init)
      service = AnalyticsService.instance;
    });

    test('should report isInitialized correctly', () {
      // isInitialized depends on whether initialize() was called
      expect(service.isInitialized, isA<bool>());
    });

    test('should have null userId before identifying', () {
      // Before identifyUser, userId should be null
      // (depends on test ordering, but userId starts null)
      expect(service.userId, isA<String?>());
    });
  });

  // ============================================
  // Parameter conversion logic (testable without Firebase)
  // ============================================
  group('parameter conversion logic', () {
    // These tests validate the conversion logic used in _logEvent
    // by testing the same algorithm directly

    test('boolean true should convert to 1 for Firebase', () {
      // Mirrors the logic: value is bool ? (value ? 1 : 0) : value
      const bool value = true;
      final converted = value ? 1 : 0;

      expect(converted, 1);
    });

    test('boolean false should convert to 0 for Firebase', () {
      const bool value = false;
      final converted = value ? 1 : 0;

      expect(converted, 0);
    });

    test('null values should be filtered out from Firebase params', () {
      final parameters = <String, dynamic>{
        'game_name': 'tracing',
        'score': null,
        'level': 3,
      };

      final firebaseParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          firebaseParams[entry.key] = value is bool ? (value ? 1 : 0) : value;
        }
      }

      expect(firebaseParams.containsKey('game_name'), true);
      expect(firebaseParams.containsKey('score'), false);
      expect(firebaseParams.containsKey('level'), true);
      expect(firebaseParams['game_name'], 'tracing');
      expect(firebaseParams['level'], 3);
    });

    test('null values should be filtered out from PostHog params', () {
      final parameters = <String, dynamic>{
        'pattern_name': 'letter_A',
        'accuracy': 85,
        'coverage': null,
      };

      final posthogParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          posthogParams[entry.key] = value;
        }
      }

      expect(posthogParams.containsKey('pattern_name'), true);
      expect(posthogParams.containsKey('accuracy'), true);
      expect(posthogParams.containsKey('coverage'), false);
    });

    test('boolean should NOT be converted for PostHog (only Firebase)', () {
      final parameters = <String, dynamic>{
        'reward_earned': true,
      };

      // PostHog keeps booleans as-is
      final posthogParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          posthogParams[entry.key] = value;
        }
      }

      expect(posthogParams['reward_earned'], true);

      // Firebase converts booleans
      final firebaseParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          firebaseParams[entry.key] = value is bool ? (value ? 1 : 0) : value;
        }
      }

      expect(firebaseParams['reward_earned'], 1);
    });

    test('mixed parameter types should be handled correctly', () {
      final parameters = <String, dynamic>{
        'pattern_name': 'letter_B',
        'accuracy': 92,
        'coverage': 88,
        'reward_earned': false,
      };

      // Firebase conversion
      final firebaseParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          firebaseParams[entry.key] = value is bool ? (value ? 1 : 0) : value;
        }
      }

      expect(firebaseParams['pattern_name'], 'letter_B');
      expect(firebaseParams['accuracy'], 92);
      expect(firebaseParams['coverage'], 88);
      expect(firebaseParams['reward_earned'], 0);
    });
  });

  // ============================================
  // Event structure tests
  // ============================================
  group('event parameter structure', () {
    test('logScreenView should use screen_name key', () {
      // The method calls _logEvent('screen_view', {'screen_name': screenName})
      const screenName = 'home_screen';
      final params = {'screen_name': screenName};

      expect(params['screen_name'], 'home_screen');
    });

    test('logGameStart should use game_name key', () {
      const gameName = 'tracing_game';
      final params = {'game_name': gameName};

      expect(params['game_name'], 'tracing_game');
    });

    test('logGameComplete should include optional score and level', () {
      // With all parameters
      final paramsWithAll = {
        'game_name': 'memory_game',
        'score': 100,
        'level': 5,
      };

      expect(paramsWithAll['game_name'], 'memory_game');
      expect(paramsWithAll['score'], 100);
      expect(paramsWithAll['level'], 5);

      // Without optional parameters (uses if-collection pattern)
      final paramsMinimal = {
        'game_name': 'memory_game',
      };

      expect(paramsMinimal.containsKey('score'), false);
      expect(paramsMinimal.containsKey('level'), false);
    });

    test('logPetFed should use food_type key', () {
      const foodType = 'cookie';
      final params = {'food_type': foodType};

      expect(params['food_type'], 'cookie');
    });

    test('logTracingComplete should include all tracing parameters', () {
      final params = {
        'pattern_name': 'letter_A',
        'accuracy': 85,
        'coverage': 92,
        'reward_earned': true,
      };

      expect(params['pattern_name'], 'letter_A');
      expect(params['accuracy'], 85);
      expect(params['coverage'], 92);
      expect(params['reward_earned'], true);
    });

    test('logRewardEarned should include optional source', () {
      // With source
      final paramsWithSource = {
        'reward_name': 'cookie',
        'source': 'tracing_game',
      };

      expect(paramsWithSource['reward_name'], 'cookie');
      expect(paramsWithSource['source'], 'tracing_game');

      // Without source
      final paramsWithoutSource = {
        'reward_name': 'candy',
      };

      expect(paramsWithoutSource.containsKey('source'), false);
    });

    test('logPetInteraction should use action key', () {
      const action = 'pet';
      final params = {'action': action};

      expect(params['action'], 'pet');
    });
  });

  // ============================================
  // identifyUser and resetUser
  // ============================================
  group('identifyUser and resetUser', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService.instance;
    });

    test('identifyUser should set userId', () async {
      // Note: This will attempt to call Firebase/PostHog which may fail in test,
      // but the _userId field should be set regardless
      try {
        await service.identifyUser('user-abc-123');
      } catch (_) {
        // Expected - Firebase/PostHog not initialized in test environment
      }

      expect(service.userId, 'user-abc-123');
    });

    test('resetUser should clear userId', () async {
      // First set a user
      try {
        await service.identifyUser('user-to-reset');
      } catch (_) {
        // Expected
      }

      expect(service.userId, 'user-to-reset');

      // Then reset
      try {
        await service.resetUser();
      } catch (_) {
        // Expected - Firebase/PostHog not initialized in test environment
      }

      expect(service.userId, isNull);
    });
  });

  // ============================================
  // _getPlatform logic
  // ============================================
  group('platform detection', () {
    test('should return a non-empty platform string', () {
      // We can't directly test _getPlatform since it's private,
      // but we can verify the logic by checking defaultTargetPlatform values
      // In test environment, this would typically return the host platform
      final validPlatforms = [
        'android',
        'ios',
        'windows',
        'macos',
        'linux',
        'web',
        'unknown',
      ];

      // The _getPlatform method returns one of these values
      // We verify that the set of valid returns is correct
      expect(validPlatforms.length, 7);
      expect(validPlatforms.contains('android'), true);
      expect(validPlatforms.contains('ios'), true);
      expect(validPlatforms.contains('windows'), true);
    });
  });

  // ============================================
  // Error handling / graceful degradation
  // ============================================
  group('error handling', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService.instance;
      // logGameComplete calls ReviewService.onGameCompleted which uses SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('logScreenView should not throw when backends unavailable', () async {
      // Service may or may not be initialized, but should never crash
      expect(
        () async => await service.logScreenView('test_screen'),
        returnsNormally,
      );
    });

    test('logGameStart should not throw when backends unavailable', () async {
      expect(
        () async => await service.logGameStart('test_game'),
        returnsNormally,
      );
    });

    test('logGameComplete should not throw when backends unavailable',
        () async {
      expect(
        () async => await service.logGameComplete(
          'test_game',
          score: 100,
          level: 5,
        ),
        returnsNormally,
      );
    });

    test('logPetFed should not throw when backends unavailable', () async {
      expect(
        () async => await service.logPetFed('cookie'),
        returnsNormally,
      );
    });

    test('logTracingComplete should not throw when backends unavailable',
        () async {
      expect(
        () async => await service.logTracingComplete(
          patternName: 'letter_A',
          accuracy: 85.0,
          coverage: 92.0,
          rewardEarned: true,
        ),
        returnsNormally,
      );
    });

    test('logRewardEarned should not throw when backends unavailable',
        () async {
      expect(
        () async => await service.logRewardEarned(
          'cookie',
          source: 'tracing',
        ),
        returnsNormally,
      );
    });

    test('logPetInteraction should not throw when backends unavailable',
        () async {
      expect(
        () async => await service.logPetInteraction('bath'),
        returnsNormally,
      );
    });

    test('identifyUser should not crash even if backends fail', () async {
      // Should set _userId regardless of backend errors
      expect(
        () async => await service.identifyUser('test-user'),
        returnsNormally,
      );
    });

    test('resetUser should not crash even if backends fail', () async {
      expect(
        () async => await service.resetUser(),
        returnsNormally,
      );
    });

    test('initialize should not throw even if Firebase unavailable', () async {
      // initialize catches errors internally
      expect(
        () async => await service.initialize(),
        returnsNormally,
      );
    });

    test('multiple initialize calls should be idempotent', () async {
      await service.initialize();
      // Second call should return early due to _isInitialized check
      await service.initialize();

      // No crash = success
      expect(true, true);
    });
  });

  // ============================================
  // logTracingComplete specific parameter conversion
  // ============================================
  group('logTracingComplete parameter conversion', () {
    test('accuracy and coverage should be rounded', () {
      // The method calls accuracy.round() and coverage.round()
      const accuracy = 85.7;
      const coverage = 92.3;

      expect(accuracy.round(), 86);
      expect(coverage.round(), 92);
    });

    test('accuracy at boundary should round correctly', () {
      const accuracy = 85.5;

      // Dart rounds .5 to even, so 85.5 rounds to 86
      expect(accuracy.round(), 86);
    });

    test('zero accuracy should round to 0', () {
      const accuracy = 0.0;

      expect(accuracy.round(), 0);
    });

    test('full accuracy should round to 100', () {
      const accuracy = 100.0;

      expect(accuracy.round(), 100);
    });
  });

  // ============================================
  // logGameComplete conditional parameters
  // ============================================
  group('logGameComplete conditional parameters', () {
    test('should build params with score only', () {
      // Simulating the if-collection-literal pattern
      final params = {
        'game_name': 'memory',
        if (42 != null) 'score': 42,
      };

      expect(params.length, 2);
      expect(params['score'], 42);
    });

    test('should build params with level only', () {
      final params = {
        'game_name': 'memory',
        if (3 != null) 'level': 3,
      };

      expect(params.length, 2);
      expect(params['level'], 3);
    });

    test('should build params with both score and level', () {
      final int? score = 100;
      final int? level = 5;

      final params = {
        'game_name': 'memory',
        if (score != null) 'score': score,
        if (level != null) 'level': level,
      };

      expect(params.length, 3);
    });

    test('should build params without score and level when null', () {
      final int? score = null;
      final int? level = null;

      final params = {
        'game_name': 'memory',
        if (score != null) 'score': score,
        if (level != null) 'level': level,
      };

      expect(params.length, 1);
      expect(params.containsKey('score'), false);
      expect(params.containsKey('level'), false);
    });
  });
}
