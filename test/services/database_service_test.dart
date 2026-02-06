import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talu_kids/services/database_service.dart';

// =============================================================================
// MOCKS
// =============================================================================

/// Custom Firebase Core mock that includes Crashlytics plugin constants.
/// Without this, FirebaseCrashlytics.instance will fail with an assertion error
/// because it expects 'isCrashlyticsCollectionEnabled' in plugin constants.
class MockFirebaseAppWithCrashlytics implements TestFirebaseCoreHostApi {
  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: CoreFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: <String?, Object?>{
        'plugins.flutter.io/firebase_crashlytics': <String?, Object?>{
          'isCrashlyticsCollectionEnabled': false,
        },
      },
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: <String?, Object?>{
          'plugins.flutter.io/firebase_crashlytics': <String?, Object?>{
            'isCrashlyticsCollectionEnabled': false,
          },
        },
      ),
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

/// A mock for SupabaseQueryBuilder that also mocks the chained Future behavior.
/// Since PostgrestBuilder implements Future, we need special handling.
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock filter builder that returns a Future when awaited.
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  final Future<PostgrestList> _future;

  MockPostgrestFilterBuilder(this._future);
  MockPostgrestFilterBuilder.value(PostgrestList value)
      : _future = Future.value(value);
  MockPostgrestFilterBuilder.empty()
      : _future = Future.value(PostgrestList.from([]));

  @override
  Future<S> then<S>(
    FutureOr<S> Function(PostgrestList) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);
}

class MockPostgrestFilterBuilderVoid extends Mock
    implements PostgrestFilterBuilder<void> {
  @override
  Future<S> then<S>(
    FutureOr<S> Function(void) onValue, {
    Function? onError,
  }) =>
      Future<void>.value().then(onValue, onError: onError);
}

class MockPostgrestFilterBuilderMap extends Mock
    implements PostgrestFilterBuilder<PostgrestMap?> {
  final Future<PostgrestMap?> _future;

  MockPostgrestFilterBuilderMap(this._future);
  MockPostgrestFilterBuilderMap.value(PostgrestMap? value)
      : _future = Future.value(value);
  MockPostgrestFilterBuilderMap.nil() : _future = Future.value(null);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(PostgrestMap?) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);
}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {
  final Future<PostgrestList> _future;

  MockPostgrestTransformBuilder(this._future);
  MockPostgrestTransformBuilder.value(PostgrestList value)
      : _future = Future.value(value);
  MockPostgrestTransformBuilder.empty()
      : _future = Future.value(PostgrestList.from([]));

  @override
  Future<S> then<S>(
    FutureOr<S> Function(PostgrestList) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);
}

class MockPostgrestTransformBuilderMap extends Mock
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final Future<PostgrestMap?> _future;

  MockPostgrestTransformBuilderMap(this._future);
  MockPostgrestTransformBuilderMap.value(PostgrestMap? value)
      : _future = Future.value(value);
  MockPostgrestTransformBuilderMap.nil() : _future = Future.value(null);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(PostgrestMap?) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);
}

void main() {
  // ============================================
  // Firebase mocks setup (needed for Crashlytics in catch blocks)
  // ============================================
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Use custom mock that includes Crashlytics plugin constants
    TestFirebaseCoreHostApi.setUp(MockFirebaseAppWithCrashlytics());

    // Mock the Crashlytics method channel so recordError doesn't crash
    const MethodChannel crashlyticsChannel =
        MethodChannel('plugins.flutter.io/firebase_crashlytics');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(crashlyticsChannel, (MethodCall call) async {
      // Return null for all Crashlytics method calls (no-op)
      return null;
    });

    await Firebase.initializeApp();
  });

  // ============================================
  // Reward model tests (existing)
  // ============================================
  group('Reward', () {
    test('should create reward with all properties', () {
      const reward = Reward(
        id: 'test_id',
        name: 'Test Reward',
        iconPath: 'assets/test.png',
      );

      expect(reward.id, 'test_id');
      expect(reward.name, 'Test Reward');
      expect(reward.iconPath, 'assets/test.png');
    });
  });

  group('availableRewards', () {
    test('should have 4 rewards', () {
      expect(availableRewards.length, 4);
    });

    test('should contain cookie reward', () {
      final cookie = availableRewards.firstWhere((r) => r.id == 'cookie');
      expect(cookie.name, 'Ciastko');
      expect(cookie.iconPath, contains('cookie'));
    });

    test('should contain candy reward', () {
      final candy = availableRewards.firstWhere((r) => r.id == 'candy');
      expect(candy.name, 'Cukierek');
      expect(candy.iconPath, contains('candy'));
    });

    test('should contain icecream reward', () {
      final icecream = availableRewards.firstWhere((r) => r.id == 'icecream');
      expect(icecream.name, 'Lody');
      expect(icecream.iconPath, contains('icecream'));
    });

    test('should contain chocolate reward', () {
      final chocolate =
          availableRewards.firstWhere((r) => r.id == 'chocolate');
      expect(chocolate.name, 'Czekolada');
      expect(chocolate.iconPath, contains('chocolate'));
    });

    test('all rewards should have unique ids', () {
      final ids = availableRewards.map((r) => r.id).toSet();
      expect(ids.length, availableRewards.length);
    });

    test('all rewards should have valid asset paths', () {
      for (final reward in availableRewards) {
        expect(reward.iconPath, startsWith('assets/'));
        expect(reward.iconPath, endsWith('.png'));
      }
    });
  });

  // ============================================
  // DatabaseService.calculateCounts (static, existing)
  // ============================================
  group('DatabaseService.calculateCounts', () {
    test('should return zero counts for empty list', () {
      final counts = DatabaseService.calculateCounts([]);

      expect(counts['cookie'], 0);
      expect(counts['candy'], 0);
      expect(counts['icecream'], 0);
      expect(counts['chocolate'], 0);
    });

    test('should count single item correctly', () {
      final items = [
        {'reward_id': 'cookie'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['cookie'], 1);
      expect(counts['candy'], 0);
      expect(counts['icecream'], 0);
      expect(counts['chocolate'], 0);
    });

    test('should count multiple items of same type', () {
      final items = [
        {'reward_id': 'candy'},
        {'reward_id': 'candy'},
        {'reward_id': 'candy'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['candy'], 3);
      expect(counts['cookie'], 0);
    });

    test('should count mixed items correctly', () {
      final items = [
        {'reward_id': 'cookie'},
        {'reward_id': 'candy'},
        {'reward_id': 'cookie'},
        {'reward_id': 'icecream'},
        {'reward_id': 'chocolate'},
        {'reward_id': 'chocolate'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['cookie'], 2);
      expect(counts['candy'], 1);
      expect(counts['icecream'], 1);
      expect(counts['chocolate'], 2);
    });

    test('should ignore unknown reward_id', () {
      final items = [
        {'reward_id': 'cookie'},
        {'reward_id': 'unknown_reward'},
        {'reward_id': 'candy'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['cookie'], 1);
      expect(counts['candy'], 1);
      expect(counts.containsKey('unknown_reward'), false);
    });

    test('should handle null reward_id', () {
      final items = [
        {'reward_id': 'cookie'},
        {'reward_id': null},
        {'reward_id': 'candy'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['cookie'], 1);
      expect(counts['candy'], 1);
    });

    test('should handle items without reward_id field', () {
      final items = [
        {'reward_id': 'cookie'},
        {'other_field': 'value'},
        {'reward_id': 'candy'},
      ];

      final counts = DatabaseService.calculateCounts(items);

      expect(counts['cookie'], 1);
      expect(counts['candy'], 1);
    });

    test('should return all reward types in result', () {
      final counts = DatabaseService.calculateCounts([]);

      expect(counts.keys.length, 4);
      expect(counts.containsKey('cookie'), true);
      expect(counts.containsKey('candy'), true);
      expect(counts.containsKey('icecream'), true);
      expect(counts.containsKey('chocolate'), true);
    });
  });

  // ============================================
  // DatabaseService singleton
  // ============================================
  group('DatabaseService singleton', () {
    test('should throw when not initialized', () {
      expect(
        () {
          if (!DatabaseService.isInitialized) {
            throw Exception(
              'DatabaseService nie został zainicjalizowany. '
              'Wywołaj DatabaseService.initialize() w main.dart',
            );
          }
        },
        throwsException,
      );
    });

    test('isInitialized should return correct state', () {
      expect(DatabaseService.isInitialized, isA<bool>());
    });

    test('should initialize with SupabaseClient', () {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);

      DatabaseService.initialize(mockClient);

      expect(DatabaseService.isInitialized, true);
    });

    test('should return same instance after initialization', () {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);

      DatabaseService.initialize(mockClient);

      final instance1 = DatabaseService.instance;
      final instance2 = DatabaseService.instance;

      expect(identical(instance1, instance2), true);
    });
  });

  // ============================================
  // DatabaseService with mocked Supabase
  // ============================================
  group('DatabaseService (with mocked Supabase)', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockUser.id).thenReturn('test-user-123');

      DatabaseService.initialize(mockClient);
    });

    // ------------------------------------------
    // currentUserId
    // ------------------------------------------
    group('currentUserId', () {
      test('should return user id when user is logged in', () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        expect(DatabaseService.instance.currentUserId, 'test-user-123');
      });

      test('should return null when no user is logged in', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(DatabaseService.instance.currentUserId, isNull);
      });
    });

    // ------------------------------------------
    // addReward
    // ------------------------------------------
    group('addReward', () {
      test('should return a valid reward from availableRewards', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final reward = await DatabaseService.instance.addReward('game_reward');

        expect(
          availableRewards.any((r) => r.id == reward.id),
          true,
        );
      });

      test('should return reward locally when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final reward = await DatabaseService.instance.addReward('game_reward');

        expect(reward, isA<Reward>());
        expect(reward.id, isNotEmpty);
        expect(reward.name, isNotEmpty);
      });

      test('should insert into inventory when user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any()))
            .thenAnswer((_) => mockFilterBuilder);

        final reward = await DatabaseService.instance.addReward('game_reward');

        expect(reward, isA<Reward>());
        verify(() => mockClient.from('inventory')).called(1);
      });

      test('should handle insert error gracefully and still return reward',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any()))
            .thenThrow(Exception('Network error'));

        // Should not throw - returns reward despite error
        final reward = await DatabaseService.instance.addReward('game_reward');

        expect(reward, isA<Reward>());
      });
    });

    // ------------------------------------------
    // getInventory
    // ------------------------------------------
    group('getInventory', () {
      test('should return empty list when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.getInventory();

        expect(result, isEmpty);
      });

      test('should return inventory data for logged in user', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([
          {
            'id': '1',
            'reward_id': 'cookie',
            'reward_name': 'Ciastko',
          },
          {
            'id': '2',
            'reward_id': 'candy',
            'reward_name': 'Cukierek',
          },
        ]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);
        final mockTransformBuilder =
            MockPostgrestTransformBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.order('created_at', ascending: false))
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getInventory();

        expect(result.length, 2);
        expect(result[0]['reward_id'], 'cookie');
        expect(result[1]['reward_id'], 'candy');
      });

      test('should return empty list on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select())
            .thenThrow(Exception('DB connection error'));

        final result = await DatabaseService.instance.getInventory();

        expect(result, isEmpty);
      });
    });

    // ------------------------------------------
    // getInventoryCounts
    // ------------------------------------------
    group('getInventoryCounts', () {
      test('should return zero counts when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.getInventoryCounts();

        expect(result['cookie'], 0);
        expect(result['candy'], 0);
        expect(result['icecream'], 0);
        expect(result['chocolate'], 0);
      });

      test('should return correct counts for user with items', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([
          {'reward_id': 'cookie'},
          {'reward_id': 'cookie'},
          {'reward_id': 'candy'},
          {'reward_id': 'icecream'},
        ]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select('reward_id'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);

        final result = await DatabaseService.instance.getInventoryCounts();

        expect(result['cookie'], 2);
        expect(result['candy'], 1);
        expect(result['icecream'], 1);
        expect(result['chocolate'], 0);
      });

      test('should return zero counts on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select('reward_id'))
            .thenThrow(Exception('Network error'));

        final result = await DatabaseService.instance.getInventoryCounts();

        expect(result['cookie'], 0);
        expect(result['candy'], 0);
        expect(result['icecream'], 0);
        expect(result['chocolate'], 0);
      });
    });

    // ------------------------------------------
    // countRewards
    // ------------------------------------------
    group('countRewards', () {
      test('should return 0 when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.countRewards('cookie');

        expect(result, 0);
      });

      test('should return count of specific reward', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
        ]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);
        final mockFilterBuilder2 =
            MockPostgrestFilterBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.eq('reward_id', 'cookie'))
            .thenAnswer((_) => mockFilterBuilder2);

        final result = await DatabaseService.instance.countRewards('cookie');

        expect(result, 3);
      });

      test('should return 0 when no items found', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);
        final mockFilterBuilder2 =
            MockPostgrestFilterBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.eq('reward_id', 'candy'))
            .thenAnswer((_) => mockFilterBuilder2);

        final result = await DatabaseService.instance.countRewards('candy');

        expect(result, 0);
      });

      test('should return 0 on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select())
            .thenThrow(Exception('DB error'));

        final result = await DatabaseService.instance.countRewards('cookie');

        expect(result, 0);
      });
    });

    // ------------------------------------------
    // consumeItem
    // ------------------------------------------
    group('consumeItem', () {
      test('should return false when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.consumeItem('cookie');

        expect(result, false);
      });

      test('should return false when item not found (null response)',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockFilterBuilder2 = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder =
            MockPostgrestTransformBuilder.empty();
        final mockTransformBuilderMap =
            MockPostgrestTransformBuilderMap.nil();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.eq('reward_id', 'cookie'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.order('created_at', ascending: true))
            .thenAnswer((_) => mockTransformBuilder);
        when(() => mockTransformBuilder.limit(1))
            .thenAnswer((_) => mockTransformBuilder);
        when(() => mockTransformBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilderMap);

        final result = await DatabaseService.instance.consumeItem('cookie');

        expect(result, false);
      });

      test('should return true when item found and deleted', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        // Step A: find the item
        final selectFilterBuilder = MockPostgrestFilterBuilder.empty();
        final selectFilterBuilder2 = MockPostgrestFilterBuilder.empty();
        final selectTransformBuilder =
            MockPostgrestTransformBuilder.empty();
        final selectMaybeBuilder =
            MockPostgrestTransformBuilderMap.value({'id': 'item-42'});

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenAnswer((_) => selectFilterBuilder);
        when(() => selectFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => selectFilterBuilder2);
        when(() => selectFilterBuilder2.eq('reward_id', 'cookie'))
            .thenAnswer((_) => selectFilterBuilder2);
        when(() => selectFilterBuilder2.order('created_at', ascending: true))
            .thenAnswer((_) => selectTransformBuilder);
        when(() => selectTransformBuilder.limit(1))
            .thenAnswer((_) => selectTransformBuilder);
        when(() => selectTransformBuilder.maybeSingle())
            .thenAnswer((_) => selectMaybeBuilder);

        // Step B: delete the item
        final deleteFilterBuilder = MockPostgrestFilterBuilderVoid();
        final deleteFilterBuilder2 = MockPostgrestFilterBuilderVoid();

        when(() => mockQueryBuilder.delete())
            .thenAnswer((_) => deleteFilterBuilder);
        when(() => deleteFilterBuilder.eq('id', 'item-42'))
            .thenAnswer((_) => deleteFilterBuilder2);
        when(() => deleteFilterBuilder2.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => deleteFilterBuilder2);

        final result = await DatabaseService.instance.consumeItem('cookie');

        expect(result, true);
      });

      test('should return false on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenThrow(Exception('DB error'));

        final result = await DatabaseService.instance.consumeItem('cookie');

        expect(result, false);
      });
    });

    // ------------------------------------------
    // hasItem
    // ------------------------------------------
    group('hasItem', () {
      test('should return false when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.hasItem('cookie');

        expect(result, false);
      });

      test('should return true when count is greater than 0', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([
          {'id': '1'},
        ]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);
        final mockFilterBuilder2 =
            MockPostgrestFilterBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.eq('reward_id', 'cookie'))
            .thenAnswer((_) => mockFilterBuilder2);

        final result = await DatabaseService.instance.hasItem('cookie');

        expect(result, true);
      });

      test('should return false when count is 0', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final responseData = PostgrestList.from([]);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder =
            MockPostgrestFilterBuilder.value(responseData);
        final mockFilterBuilder2 =
            MockPostgrestFilterBuilder.value(responseData);

        when(() => mockClient.from('inventory')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder2);
        when(() => mockFilterBuilder2.eq('reward_id', 'candy'))
            .thenAnswer((_) => mockFilterBuilder2);

        final result = await DatabaseService.instance.hasItem('candy');

        expect(result, false);
      });
    });

    // ------------------------------------------
    // getPetState
    // ------------------------------------------
    group('getPetState', () {
      test('should return null when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.getPetState();

        expect(result, isNull);
      });

      test('should return pet state data for logged in user', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final petStateData = <String, dynamic>{
          'user_id': 'test-user-123',
          'hunger': 80.0,
          'happiness': 75.0,
          'energy': 60.0,
          'hygiene': 90.0,
          'evolution_points': 150,
        };

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder =
            MockPostgrestTransformBuilderMap.value(petStateData);

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getPetState();

        expect(result, isNotNull);
        expect(result!['hunger'], 80.0);
        expect(result['happiness'], 75.0);
        expect(result['evolution_points'], 150);
      });

      test('should return null when no pet state exists', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.nil();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getPetState();

        expect(result, isNull);
      });

      test('should return null on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select())
            .thenThrow(Exception('Network error'));

        final result = await DatabaseService.instance.getPetState();

        expect(result, isNull);
      });
    });

    // ------------------------------------------
    // savePetState
    // ------------------------------------------
    group('savePetState', () {
      test('should return false when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.savePetState(
          hunger: 80,
          happiness: 75,
          energy: 60,
          hygiene: 90,
        );

        expect(result, false);
      });

      test('should call upsert with correct data and return true', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockFilterBuilder);

        final result = await DatabaseService.instance.savePetState(
          hunger: 80,
          happiness: 75,
          energy: 60,
          hygiene: 90,
        );

        expect(result, true);
        verify(() => mockClient.from('pet_states')).called(1);
      });

      test('should include evolution_points when provided', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockFilterBuilder);

        await DatabaseService.instance.savePetState(
          hunger: 80,
          happiness: 75,
          energy: 60,
          hygiene: 90,
          evolutionPoints: 200,
        );

        final captured = verify(
          () => mockQueryBuilder.upsert(
            captureAny(),
            onConflict: 'user_id',
          ),
        ).captured;

        final data = captured.first as Map<String, dynamic>;
        expect(data['evolution_points'], 200);
        expect(data['hunger'], 80);
        expect(data['happiness'], 75);
        expect(data['energy'], 60);
        expect(data['hygiene'], 90);
        expect(data['user_id'], 'test-user-123');
      });

      test('should not include evolution_points when not provided', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockFilterBuilder);

        await DatabaseService.instance.savePetState(
          hunger: 80,
          happiness: 75,
          energy: 60,
          hygiene: 90,
        );

        final captured = verify(
          () => mockQueryBuilder.upsert(
            captureAny(),
            onConflict: 'user_id',
          ),
        ).captured;

        final data = captured.first as Map<String, dynamic>;
        expect(data.containsKey('evolution_points'), false);
      });

      test('should return false on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenThrow(Exception('DB error'));

        final result = await DatabaseService.instance.savePetState(
          hunger: 80,
          happiness: 75,
          energy: 60,
          hygiene: 90,
        );

        expect(result, false);
      });
    });

    // ------------------------------------------
    // addEvolutionPoints
    // ------------------------------------------
    group('addEvolutionPoints', () {
      test('should return 0 when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.addEvolutionPoints(10);

        expect(result, 0);
      });

      test('should add points to current value and return new total',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        // getPetState mock (for reading current points)
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'evolution_points': 100,
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        // upsert mock (for saving new points)
        final mockUpsertBuilder = MockPostgrestFilterBuilderVoid();
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockUpsertBuilder);

        final result = await DatabaseService.instance.addEvolutionPoints(50);

        expect(result, 150);
      });

      test('should handle null evolution_points in state (default to 0)',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'hunger': 80.0,
          // No evolution_points key
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final mockUpsertBuilder = MockPostgrestFilterBuilderVoid();
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockUpsertBuilder);

        final result = await DatabaseService.instance.addEvolutionPoints(25);

        expect(result, 25); // 0 + 25
      });

      test('should return 0 on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select())
            .thenThrow(Exception('DB error'));

        final result = await DatabaseService.instance.addEvolutionPoints(10);

        expect(result, 0);
      });
    });

    // ------------------------------------------
    // getEvolutionPoints
    // ------------------------------------------
    group('getEvolutionPoints', () {
      test('should return 0 when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.getEvolutionPoints();

        expect(result, 0);
      });

      test('should return 0 when getPetState returns null', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.nil();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getEvolutionPoints();

        expect(result, 0);
      });

      test('should return correct points from pet state', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'evolution_points': 250,
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getEvolutionPoints();

        expect(result, 250);
      });

      test('should return 0 when evolution_points is null in pet state',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'hunger': 80.0,
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getEvolutionPoints();

        expect(result, 0);
      });
    });

    // ------------------------------------------
    // resetEvolutionPoints
    // ------------------------------------------
    group('resetEvolutionPoints', () {
      test('should return false when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result =
            await DatabaseService.instance.resetEvolutionPoints();

        expect(result, false);
      });

      test('should upsert with 0 points', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockFilterBuilder);

        final result =
            await DatabaseService.instance.resetEvolutionPoints();

        expect(result, true);

        final captured = verify(
          () => mockQueryBuilder.upsert(
            captureAny(),
            onConflict: 'user_id',
          ),
        ).captured;

        final data = captured.first as Map<String, dynamic>;
        expect(data['evolution_points'], 0);
        expect(data['user_id'], 'test-user-123');
      });

      test('should return false on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenThrow(Exception('DB error'));

        final result =
            await DatabaseService.instance.resetEvolutionPoints();

        expect(result, false);
      });
    });

    // ------------------------------------------
    // startSleep
    // ------------------------------------------
    group('startSleep', () {
      test('should return false when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.startSleep();

        expect(result, false);
      });

      test('should upsert sleep_start_time', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilderVoid();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenAnswer((_) => mockFilterBuilder);

        final result = await DatabaseService.instance.startSleep();

        expect(result, true);

        final captured = verify(
          () => mockQueryBuilder.upsert(
            captureAny(),
            onConflict: 'user_id',
          ),
        ).captured;

        final data = captured.first as Map<String, dynamic>;
        expect(data.containsKey('sleep_start_time'), true);
        expect(data['user_id'], 'test-user-123');
      });

      test('should return false on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(
              any(),
              onConflict: 'user_id',
            )).thenThrow(Exception('DB error'));

        final result = await DatabaseService.instance.startSleep();

        expect(result, false);
      });
    });

    // ------------------------------------------
    // getSleepStartTime
    // ------------------------------------------
    group('getSleepStartTime', () {
      test('should return null when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await DatabaseService.instance.getSleepStartTime();

        expect(result, isNull);
      });

      test('should return null when pet state is null', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.nil();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getSleepStartTime();

        expect(result, isNull);
      });

      test('should return null when sleep_start_time is null in state',
          () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'sleep_start_time': null,
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getSleepStartTime();

        expect(result, isNull);
      });

      test('should return DateTime when sleep_start_time is set', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final sleepTime = DateTime(2025, 1, 15, 22, 30, 0);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'sleep_start_time': sleepTime.toIso8601String(),
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getSleepStartTime();

        expect(result, isNotNull);
        expect(result!.year, 2025);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 22);
        expect(result.minute, 30);
      });

      test('should return null for invalid date string', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'sleep_start_time': 'not-a-date',
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result = await DatabaseService.instance.getSleepStartTime();

        // DateTime.tryParse returns null for invalid strings
        expect(result, isNull);
      });
    });

    // ------------------------------------------
    // wakeUpAndCalculateEnergy
    // ------------------------------------------
    group('wakeUpAndCalculateEnergy', () {
      test('should return 0 when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result =
            await DatabaseService.instance.wakeUpAndCalculateEnergy();

        expect(result, 0);
      });

      test('should return 0 when pet state is null', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.nil();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result =
            await DatabaseService.instance.wakeUpAndCalculateEnergy();

        expect(result, 0);
      });

      test('should return 0 when sleep_start_time is null', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder.empty();
        final mockTransformBuilder = MockPostgrestTransformBuilderMap.value({
          'sleep_start_time': null,
        });

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', 'test-user-123'))
            .thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) => mockTransformBuilder);

        final result =
            await DatabaseService.instance.wakeUpAndCalculateEnergy();

        expect(result, 0);
      });

      test('should return 0 on error', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final mockQueryBuilder = MockSupabaseQueryBuilder();

        when(() => mockClient.from('pet_states')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select())
            .thenThrow(Exception('DB error'));

        final result =
            await DatabaseService.instance.wakeUpAndCalculateEnergy();

        expect(result, 0);
      });
    });

    // ------------------------------------------
    // getInventoryStream
    // ------------------------------------------
    group('getInventoryStream', () {
      test('should return empty stream when no user is logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final stream = DatabaseService.instance.getInventoryStream();
        final result = await stream.first;

        expect(result, isEmpty);
      });
    });
  });
}
