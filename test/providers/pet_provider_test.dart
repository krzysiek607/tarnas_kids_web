import 'package:flutter_test/flutter_test.dart';
import 'package:talu_kids/providers/pet_provider.dart';

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

    group('domyslne wartosci konstruktora', () {
      test('powinien miec domyslne wartosci statystyk 80', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        expect(state.hunger, 80.0);
        expect(state.happiness, 80.0);
        expect(state.energy, 80.0);
        expect(state.hygiene, 80.0);
      });

      test('powinien nie spac domyslnie', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        expect(state.isSleeping, false);
        expect(state.sleepStartTime, isNull);
      });

      test('powinien miec domyslny nastroj happy', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        expect(state.currentMood, 'happy');
      });

      test('powinien miec 0 punktow ewolucji domyslnie', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        expect(state.evolutionPoints, 0);
      });

      test('powinien nie miec ustawinego ranAwayAt domyslnie', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        expect(state.ranAwayAt, isNull);
        expect(state.hasRunAway, false);
      });
    });

    group('minutesSleeping', () {
      test('powinien zwrocic 0 gdy sleepStartTime jest null', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: null,
        );

        expect(state.minutesSleeping, 0);
      });

      test('powinien zwrocic 0 gdy dopiero zaczal spac', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now(),
        );

        // Dopiero zaczal - 0 minut
        expect(state.minutesSleeping, 0);
      });

      test('powinien zwrocic poprawna liczbe minut', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Powinno byc okolo 30 minut (moze byc 29 lub 30 przez czas wykonania)
        expect(state.minutesSleeping, greaterThanOrEqualTo(29));
        expect(state.minutesSleeping, lessThanOrEqualTo(31));
      });

      test('powinien zwrocic duza wartosc dla dlugiego snu', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now().subtract(const Duration(hours: 2)),
        );

        // 2 godziny = 120 minut
        expect(state.minutesSleeping, greaterThanOrEqualTo(119));
        expect(state.minutesSleeping, lessThanOrEqualTo(121));
      });
    });

    group('overallHealth - dodatkowe przypadki', () {
      test('powinien obliczyc dla niesymetrycznych statystyk', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 10,
          happiness: 30,
          energy: 50,
          hygiene: 70,
        );

        // (10 + 30 + 50 + 70) / 4 = 40
        expect(state.overallHealth, 40.0);
      });

      test('powinien obliczyc dla domyslnych statystyk', () {
        final state = PetState(lastUpdateTime: DateTime.now());

        // (80 + 80 + 80 + 80) / 4 = 80
        expect(state.overallHealth, 80.0);
      });
    });

    group('evolutionStage - dodatkowe testy graniczne', () {
      test('powinien zwrocic egg dla ujemnych punktow (edge case)', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          evolutionPoints: -10,
        );

        expect(state.evolutionStage, EvolutionStage.egg);
      });

      test('powinien przejsc przez wszystkie etapy sekwencyjnie', () {
        final points = [0, 100, 150, 151, 200, 350, 351, 500, 600, 601, 1000];
        final expectedStages = [
          EvolutionStage.egg,       // 0
          EvolutionStage.egg,       // 100
          EvolutionStage.egg,       // 150
          EvolutionStage.firstCrack, // 151
          EvolutionStage.firstCrack, // 200
          EvolutionStage.firstCrack, // 350
          EvolutionStage.secondCrack, // 351
          EvolutionStage.secondCrack, // 500
          EvolutionStage.secondCrack, // 600
          EvolutionStage.hatched,    // 601
          EvolutionStage.hatched,    // 1000
        ];

        for (int i = 0; i < points.length; i++) {
          final state = PetState(
            lastUpdateTime: DateTime.now(),
            evolutionPoints: points[i],
          );
          expect(
            state.evolutionStage,
            expectedStages[i],
            reason: 'Dla ${points[i]} punktow oczekiwano ${expectedStages[i]}',
          );
        }
      });
    });

    group('calculateMood - priorytet nastrojow', () {
      test('sleeping ma najwyzszy priorytet (nawet jesli zdrowie < 20)', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          isSleeping: true,
          hunger: 0,
          happiness: 0,
          energy: 0,
          hygiene: 0,
        );

        expect(state.calculateMood(), 'sleeping');
      });

      test('sad ma wyzszy priorytet niz hungry', () {
        // overallHealth < 20, hunger < 30
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 10,
          happiness: 10,
          energy: 10,
          hygiene: 10,
        );

        expect(state.calculateMood(), 'sad');
      });

      test('hungry ma wyzszy priorytet niz tired', () {
        // hunger < 30, energy < 30, ale overallHealth >= 20
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 25,
          happiness: 60,
          energy: 25,
          hygiene: 60,
        );

        expect(state.calculateMood(), 'hungry');
      });

      test('tired ma wyzszy priorytet niz dirty', () {
        // energy < 30, hygiene < 30, ale hunger >= 30
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 60,
          happiness: 60,
          energy: 25,
          hygiene: 25,
        );

        expect(state.calculateMood(), 'tired');
      });

      test('overallHealth rowno 20 daje hungry (nie sad)', () {
        // overallHealth = 20, hunger = 20 < 30
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 20,
          happiness: 20,
          energy: 20,
          hygiene: 20,
        );

        // overallHealth = 20, nie < 20, wiec nie sad
        // hunger = 20 < 30 -> hungry
        expect(state.calculateMood(), 'hungry');
      });

      test('overallHealth rowno 70 daje neutral (nie happy)', () {
        // overallHealth = 70, nie > 70
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 70,
          happiness: 70,
          energy: 70,
          hygiene: 70,
        );

        expect(state.calculateMood(), 'neutral');
      });

      test('overallHealth 71 daje happy', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 72,
          happiness: 72,
          energy: 72,
          hygiene: 68,
        );

        // (72 + 72 + 72 + 68) / 4 = 71
        expect(state.overallHealth, 71.0);
        expect(state.calculateMood(), 'happy');
      });
    });

    group('copyWith - rozszerzone testy', () {
      test('powinien skopiowac wszystkie pola naraz', () {
        final now = DateTime.now();
        final original = PetState(lastUpdateTime: now);
        final sleepTime = DateTime.now().subtract(const Duration(minutes: 10));
        final runTime = DateTime.now().subtract(const Duration(hours: 1));

        final copied = original.copyWith(
          hunger: 50,
          happiness: 60,
          energy: 70,
          hygiene: 40,
          isSleeping: true,
          currentMood: 'sleeping',
          lastUpdateTime: now.add(const Duration(minutes: 1)),
          sleepStartTime: sleepTime,
          evolutionPoints: 200,
          ranAwayAt: runTime,
        );

        expect(copied.hunger, 50);
        expect(copied.happiness, 60);
        expect(copied.energy, 70);
        expect(copied.hygiene, 40);
        expect(copied.isSleeping, true);
        expect(copied.currentMood, 'sleeping');
        expect(copied.sleepStartTime, sleepTime);
        expect(copied.evolutionPoints, 200);
        expect(copied.ranAwayAt, runTime);
      });

      test('powinien zachowac sleepStartTime gdy nie podano i nie clearowane', () {
        final sleepTime = DateTime.now();
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: sleepTime,
        );
        final copied = original.copyWith(hunger: 50);

        expect(copied.sleepStartTime, sleepTime);
      });

      test('powinien ustawic nowy sleepStartTime', () {
        final newSleepTime = DateTime.now();
        final original = PetState(lastUpdateTime: DateTime.now());
        final copied = original.copyWith(sleepStartTime: newSleepTime);

        expect(copied.sleepStartTime, newSleepTime);
      });

      test('powinien zachowac ranAwayAt gdy nie podano i nie clearowane', () {
        final runTime = DateTime.now();
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          ranAwayAt: runTime,
        );
        final copied = original.copyWith(hunger: 50);

        expect(copied.ranAwayAt, runTime);
      });

      test('clearSleepStartTime i clearRanAwayAt dzialaja niezaleznie', () {
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now(),
          ranAwayAt: DateTime.now(),
        );

        // Czyscimy tylko sleep, nie ran away
        final copied1 = original.copyWith(clearSleepStartTime: true);
        expect(copied1.sleepStartTime, isNull);
        expect(copied1.ranAwayAt, isNotNull);

        // Czyscimy tylko ran away, nie sleep
        final copied2 = original.copyWith(clearRanAwayAt: true);
        expect(copied2.sleepStartTime, isNotNull);
        expect(copied2.ranAwayAt, isNull);
      });

      test('niemutowalnosc - oryginalny stan nie zmieniony', () {
        final original = PetState(
          lastUpdateTime: DateTime.now(),
          hunger: 80,
          happiness: 80,
          energy: 80,
          hygiene: 80,
          evolutionPoints: 100,
        );

        original.copyWith(
          hunger: 50,
          happiness: 50,
          energy: 50,
          hygiene: 50,
          evolutionPoints: 500,
        );

        expect(original.hunger, 80);
        expect(original.happiness, 80);
        expect(original.energy, 80);
        expect(original.hygiene, 80);
        expect(original.evolutionPoints, 100);
      });
    });

    group('JSON serialization - rozszerzone testy', () {
      test('toJson powinien zawierac lastUpdateTime jako ISO string', () {
        final now = DateTime(2025, 6, 15, 12, 30, 0);
        final state = PetState(
          lastUpdateTime: now,
        );

        final json = state.toJson();
        expect(json['lastUpdateTime'], now.toIso8601String());
      });

      test('toJson nie powinien zawierac sleepStartTime ani ranAwayAt', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          sleepStartTime: DateTime.now(),
          ranAwayAt: DateTime.now(),
        );

        final json = state.toJson();
        expect(json.containsKey('sleepStartTime'), false);
        expect(json.containsKey('ranAwayAt'), false);
      });

      test('fromJson z wartosciami int zamiast double', () {
        final json = {
          'hunger': 75,
          'happiness': 80,
          'energy': 65,
          'hygiene': 90,
          'lastUpdateTime': '2024-01-15T10:30:00.000',
          'evolutionPoints': 200,
        };

        final state = PetState.fromJson(json);

        expect(state.hunger, 75.0);
        expect(state.happiness, 80.0);
        expect(state.energy, 65.0);
        expect(state.hygiene, 90.0);
      });

      test('fromJson roundtrip - serialize i deserialize', () {
        final original = PetState(
          lastUpdateTime: DateTime(2025, 1, 1, 12, 0, 0),
          hunger: 55,
          happiness: 65,
          energy: 75,
          hygiene: 85,
          evolutionPoints: 300,
        );

        final json = original.toJson();
        final restored = PetState.fromJson(json);

        expect(restored.hunger, original.hunger);
        expect(restored.happiness, original.happiness);
        expect(restored.energy, original.energy);
        expect(restored.hygiene, original.hygiene);
        expect(restored.evolutionPoints, original.evolutionPoints);
      });

      test('fromJson z null wartosciami uzywa domyslnych', () {
        final json = <String, dynamic>{
          'hunger': null,
          'happiness': null,
          'energy': null,
          'hygiene': null,
          'isSleeping': null,
          'evolutionPoints': null,
        };

        final state = PetState.fromJson(json);

        expect(state.hunger, 80.0);
        expect(state.happiness, 80.0);
        expect(state.energy, 80.0);
        expect(state.hygiene, 80.0);
        expect(state.isSleeping, false);
        expect(state.evolutionPoints, 0);
      });
    });

    group('hasRunAway - rozszerzone testy', () {
      test('powinien zwrocic false po copyWith z clearRanAwayAt', () {
        final state = PetState(
          lastUpdateTime: DateTime.now(),
          ranAwayAt: DateTime.now(),
        );
        expect(state.hasRunAway, true);

        final cleared = state.copyWith(clearRanAwayAt: true);
        expect(cleared.hasRunAway, false);
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

    test('should have exactly 4 stages', () {
      expect(EvolutionStage.values.length, 4);
    });

    test('each stage should have a unique index', () {
      final indices = EvolutionStage.values.map((e) => e.index).toSet();
      expect(indices.length, 4);
    });

    test('stages should progress: egg < firstCrack < secondCrack < hatched', () {
      expect(EvolutionStage.egg.index < EvolutionStage.firstCrack.index, true);
      expect(EvolutionStage.firstCrack.index < EvolutionStage.secondCrack.index, true);
      expect(EvolutionStage.secondCrack.index < EvolutionStage.hatched.index, true);
    });
  });

  group('PetNotifier stale konfiguracyjne', () {
    test('tickDecayRate powinien byc 0.5', () {
      expect(PetNotifier.tickDecayRate, 0.5);
    });

    test('tickIntervalSeconds powinien byc 10', () {
      expect(PetNotifier.tickIntervalSeconds, 10);
    });

    test('offlineDecayPerHour powinien byc 2.0', () {
      expect(PetNotifier.offlineDecayPerHour, 2.0);
    });

    test('sleepDurationSeconds powinien byc 15', () {
      expect(PetNotifier.sleepDurationSeconds, 15);
    });

    test('runAwayThresholdHours powinien byc 72 (3 dni)', () {
      expect(PetNotifier.runAwayThresholdHours, 72);
    });
  });
}
