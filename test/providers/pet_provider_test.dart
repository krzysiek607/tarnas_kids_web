import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/providers/pet_provider.dart';

void main() {
  group('PetState', () {
    group('evolutionStage', () {
      test('should return egg for 0 points', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 0,
        );
        expect(state.evolutionStage, EvolutionStage.egg);
      });

      test('should return egg for 150 points (boundary)', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 150,
        );
        expect(state.evolutionStage, EvolutionStage.egg);
      });

      test('should return firstCrack for 151 points', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 151,
        );
        expect(state.evolutionStage, EvolutionStage.firstCrack);
      });

      test('should return firstCrack for 350 points (boundary)', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 350,
        );
        expect(state.evolutionStage, EvolutionStage.firstCrack);
      });

      test('should return secondCrack for 351 points', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 351,
        );
        expect(state.evolutionStage, EvolutionStage.secondCrack);
      });

      test('should return secondCrack for 600 points (boundary)', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 600,
        );
        expect(state.evolutionStage, EvolutionStage.secondCrack);
      });

      test('should return hatched for 601 points', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 601,
        );
        expect(state.evolutionStage, EvolutionStage.hatched);
      });

      test('should return hatched for 1000 points', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: 1000,
        );
        expect(state.evolutionStage, EvolutionStage.hatched);
      });
    });

    group('overallHealth', () {
      test('should calculate average of all stats', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 100,
          happiness: 80,
          energy: 60,
          hygiene: 40,
        );
        expect(state.overallHealth, 70.0);
      });

      test('should return 0 when all stats are 0', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 0,
          happiness: 0,
          energy: 0,
          hygiene: 0,
        );
        expect(state.overallHealth, 0.0);
      });

      test('should return 100 when all stats are 100', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 100,
          happiness: 100,
          energy: 100,
          hygiene: 100,
        );
        expect(state.overallHealth, 100.0);
      });
    });

    group('calculateMood', () {
      test('should return sleeping when isSleeping is true', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          isSleeping: true,
          hunger: 100,
          happiness: 100,
          energy: 100,
          hygiene: 100,
        );
        expect(state.calculateMood(), 'sleeping');
      });

      test('should return sad when overallHealth < 20', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 10,
          happiness: 10,
          energy: 10,
          hygiene: 10,
        );
        expect(state.calculateMood(), 'sad');
      });

      test('should return hungry when hunger < 30', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 25,
          happiness: 80,
          energy: 80,
          hygiene: 80,
        );
        expect(state.calculateMood(), 'hungry');
      });

      test('should return tired when energy < 30', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 80,
          happiness: 80,
          energy: 25,
          hygiene: 80,
        );
        expect(state.calculateMood(), 'tired');
      });

      test('should return dirty when hygiene < 30', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 80,
          happiness: 80,
          energy: 80,
          hygiene: 25,
        );
        expect(state.calculateMood(), 'dirty');
      });

      test('should return happy when overallHealth > 70', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 80,
          happiness: 80,
          energy: 80,
          hygiene: 80,
        );
        expect(state.calculateMood(), 'happy');
      });

      test('should return neutral for moderate stats', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 50,
          happiness: 50,
          energy: 50,
          hygiene: 50,
        );
        expect(state.calculateMood(), 'neutral');
      });
    });

    group('hasRunAway', () {
      test('should return false when ranAwayAt is null', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          ranAwayAt: null,
        );
        expect(state.hasRunAway, false);
      });

      test('should return true when ranAwayAt is set', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          ranAwayAt: DateTime.now(),
        );
        expect(state.hasRunAway, true);
      });
    });

    group('copyWith', () {
      test('should copy with new hunger value', () {
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 50,
        );
        final copied = original.copyWith(hunger: 75);

        expect(copied.hunger, 75);
        expect(copied.happiness, original.happiness);
      });

      test('should clear sleepStartTime when clearSleepStartTime is true', () {
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now(),
        );
        final copied = original.copyWith(clearSleepStartTime: true);

        expect(copied.sleepStartTime, null);
      });

      test('should clear ranAwayAt when clearRanAwayAt is true', () {
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          ranAwayAt: DateTime.now(),
        );
        final copied = original.copyWith(clearRanAwayAt: true);

        expect(copied.ranAwayAt, null);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final now = DateTime.now();
        final state = PetState(
          lastUpdateTime: now,
          hunger: 75,
          happiness: 80,
          energy: 65,
          hygiene: 90,
          isSleeping: false,
          evolutionPoints: 100,
        );

        final json = state.toJson();

        expect(json['hunger'], 75);
        expect(json['happiness'], 80);
        expect(json['energy'], 65);
        expect(json['hygiene'], 90);
        expect(json['isSleeping'], false);
        expect(json['evolutionPoints'], 100);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'hunger': 75.0,
          'happiness': 80.0,
          'energy': 65.0,
          'hygiene': 90.0,
          'isSleeping': true,
          'lastUpdateTime': '2024-01-15T10:30:00.000',
          'evolutionPoints': 200,
        };

        final state = PetState.fromJson(json);

        expect(state.hunger, 75.0);
        expect(state.happiness, 80.0);
        expect(state.energy, 65.0);
        expect(state.hygiene, 90.0);
        expect(state.isSleeping, true);
        expect(state.evolutionPoints, 200);
      });

      test('should use defaults for missing JSON fields', () {
        final json = <String, dynamic>{};

        final state = PetState.fromJson(json);

        expect(state.hunger, 80.0);
        expect(state.happiness, 80.0);
        expect(state.energy, 80.0);
        expect(state.hygiene, 80.0);
        expect(state.isSleeping, false);
        expect(state.evolutionPoints, 0);
      });
    });
  });

  group('EvolutionStage', () {
    test('should have correct order in enum', () {
      expect(EvolutionStage.values.indexOf(EvolutionStage.egg), 0);
      expect(EvolutionStage.values.indexOf(EvolutionStage.firstCrack), 1);
      expect(EvolutionStage.values.indexOf(EvolutionStage.secondCrack), 2);
      expect(EvolutionStage.values.indexOf(EvolutionStage.hatched), 3);
    });

    test('should be comparable by index for evolution detection', () {
      final oldStage = EvolutionStage.egg;
      final newStage = EvolutionStage.firstCrack;

      final oldIndex = EvolutionStage.values.indexOf(oldStage);
      final newIndex = EvolutionStage.values.indexOf(newStage);

      expect(newIndex > oldIndex, true);
    });
  });
}
