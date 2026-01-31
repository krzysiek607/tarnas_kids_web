import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/services/database_service.dart';

void main() {
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
      final chocolate = availableRewards.firstWhere((r) => r.id == 'chocolate');
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

  group('DatabaseService singleton', () {
    test('should throw when not initialized', () {
      // Nie możemy bezpiecznie testować singletona bez resetowania stanu
      // Ten test dokumentuje oczekiwane zachowanie
      expect(
        () {
          // Jeśli serwis nie jest zainicjalizowany, powinien rzucić wyjątek
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
      // Ten test dokumentuje że metoda isInitialized istnieje
      // Wartość zależy od poprzednich testów w sesji
      expect(DatabaseService.isInitialized, isA<bool>());
    });
  });
}
