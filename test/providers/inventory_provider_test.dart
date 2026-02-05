import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/providers/inventory_provider.dart';
import 'package:tarnas_kids/services/database_service.dart';

void main() {
  group('InventoryState', () {
    group('konstruktor domyslny', () {
      test('powinien miec puste counts', () {
        const state = InventoryState();

        expect(state.counts, isEmpty);
      });

      test('powinien nie byc w trakcie ladowania', () {
        const state = InventoryState();

        expect(state.isLoading, false);
      });

      test('powinien nie miec bledu', () {
        const state = InventoryState();

        expect(state.error, isNull);
      });
    });

    group('isEmpty', () {
      test('powinien zwrocic true gdy counts jest pusta mapa', () {
        const state = InventoryState(counts: {});

        expect(state.isEmpty, true);
      });

      test('powinien zwrocic true gdy wszystkie wartosci sa 0', () {
        const state = InventoryState(counts: {
          'cookie': 0,
          'candy': 0,
          'icecream': 0,
          'chocolate': 0,
        });

        expect(state.isEmpty, true);
      });

      test('powinien zwrocic false gdy jest jakikolwiek przedmiot', () {
        const state = InventoryState(counts: {
          'cookie': 1,
          'candy': 0,
          'icecream': 0,
          'chocolate': 0,
        });

        expect(state.isEmpty, false);
      });

      test('powinien zwrocic false gdy jest wiele przedmiotow', () {
        const state = InventoryState(counts: {
          'cookie': 3,
          'candy': 2,
          'icecream': 1,
          'chocolate': 5,
        });

        expect(state.isEmpty, false);
      });
    });

    group('totalItems', () {
      test('powinien zwrocic 0 dla pustej mapy', () {
        const state = InventoryState(counts: {});

        expect(state.totalItems, 0);
      });

      test('powinien zwrocic 0 gdy wszystkie wartosci sa 0', () {
        const state = InventoryState(counts: {
          'cookie': 0,
          'candy': 0,
        });

        expect(state.totalItems, 0);
      });

      test('powinien zsumowac wszystkie przedmioty', () {
        const state = InventoryState(counts: {
          'cookie': 3,
          'candy': 2,
          'icecream': 1,
          'chocolate': 4,
        });

        expect(state.totalItems, 10);
      });

      test('powinien zwrocic poprawna sume z jednym typem', () {
        const state = InventoryState(counts: {
          'cookie': 5,
        });

        expect(state.totalItems, 5);
      });
    });

    group('countOf', () {
      test('powinien zwrocic 0 dla nieistniejacego przedmiotu', () {
        const state = InventoryState(counts: {
          'cookie': 3,
        });

        expect(state.countOf('candy'), 0);
      });

      test('powinien zwrocic poprawna liczbe', () {
        const state = InventoryState(counts: {
          'cookie': 3,
          'candy': 7,
        });

        expect(state.countOf('cookie'), 3);
        expect(state.countOf('candy'), 7);
      });

      test('powinien zwrocic 0 dla pustej mapy', () {
        const state = InventoryState(counts: {});

        expect(state.countOf('cookie'), 0);
      });
    });

    group('hasItem', () {
      test('powinien zwrocic false dla nieistniejacego przedmiotu', () {
        const state = InventoryState(counts: {
          'cookie': 3,
        });

        expect(state.hasItem('candy'), false);
      });

      test('powinien zwrocic false gdy count to 0', () {
        const state = InventoryState(counts: {
          'cookie': 0,
        });

        expect(state.hasItem('cookie'), false);
      });

      test('powinien zwrocic true gdy count > 0', () {
        const state = InventoryState(counts: {
          'cookie': 1,
        });

        expect(state.hasItem('cookie'), true);
      });

      test('powinien zwrocic true gdy count jest duzy', () {
        const state = InventoryState(counts: {
          'cookie': 99,
        });

        expect(state.hasItem('cookie'), true);
      });
    });

    group('copyWith', () {
      test('powinien skopiowac z nowymi counts', () {
        const original = InventoryState(counts: {'cookie': 1});
        final copied = original.copyWith(counts: {'cookie': 5, 'candy': 3});

        expect(copied.counts['cookie'], 5);
        expect(copied.counts['candy'], 3);
      });

      test('powinien zachowac oryginalne counts gdy nie podano nowych', () {
        const original = InventoryState(counts: {'cookie': 1});
        final copied = original.copyWith(isLoading: true);

        expect(copied.counts['cookie'], 1);
        expect(copied.isLoading, true);
      });

      test('powinien skopiowac z nowym isLoading', () {
        const original = InventoryState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('powinien skopiowac z nowym error', () {
        const original = InventoryState();
        final copied = original.copyWith(error: 'Blad polaczenia');

        expect(copied.error, 'Blad polaczenia');
      });

      test('powinien wyczyScic error gdy nie podano', () {
        // copyWith ustawia error = null domyslnie (nie zachowuje starego)
        const original = InventoryState(error: 'Stary blad');
        final copied = original.copyWith(isLoading: false);

        // error jest nullable i w copyWith jest: error: error (bez ?? this.error)
        // wiec jesli nie podamy error, bedzie null
        expect(copied.error, isNull);
      });

      test('powinien zachowac niemutowalnosc - oryginalny stan nie zmieniony', () {
        const original = InventoryState(counts: {'cookie': 1});
        final newCounts = Map<String, int>.from(original.counts);
        newCounts['cookie'] = 5;
        final copied = original.copyWith(counts: newCounts);

        expect(original.counts['cookie'], 1);
        expect(copied.counts['cookie'], 5);
      });
    });

    group('niemutowalnosc stanu', () {
      test('counts sa niemutowalne w const constructor', () {
        const state = InventoryState(counts: {'cookie': 1, 'candy': 2});

        // Mapa z const jest niemutowalna - proba modyfikacji rzuca wyjatek
        expect(() {
          (state.counts as Map<String, int>)['cookie'] = 99;
        }, throwsUnsupportedError);
      });

      test('tworzenie nowego stanu nie modyfikuje starego', () {
        const state1 = InventoryState(counts: {'cookie': 1});
        final newCounts = Map<String, int>.from(state1.counts);
        newCounts['cookie'] = 5;
        final state2 = state1.copyWith(counts: newCounts);

        expect(state1.counts['cookie'], 1);
        expect(state2.counts['cookie'], 5);
      });
    });
  });

  group('InventoryNotifier (lokalne operacje)', () {
    late InventoryNotifier notifier;

    setUp(() {
      // InventoryNotifier wymaga DatabaseService, ktory nie jest zainicjalizowany w testach.
      // Konstruktor sprawdza DatabaseService.isInitialized i jesli false,
      // tworzy lokalny stan z zerami.
      notifier = InventoryNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('inicjalizacja bez bazy danych', () {
      test('powinien nie byc w trakcie ladowania po inicjalizacji', () {
        expect(notifier.state.isLoading, false);
      });

      test('powinien miec zerowe liczniki dla kazdej nagrody', () {
        for (final reward in availableRewards) {
          expect(notifier.state.countOf(reward.id), 0);
        }
      });

      test('powinien byc pusty', () {
        expect(notifier.state.isEmpty, true);
      });

      test('powinien miec totalItems rowny 0', () {
        expect(notifier.state.totalItems, 0);
      });
    });

    group('addItemLocally', () {
      test('powinien dodac przedmiot', () {
        notifier.addItemLocally('cookie');

        expect(notifier.state.countOf('cookie'), 1);
        expect(notifier.state.isEmpty, false);
      });

      test('powinien dodac wiele przedmiotow tego samego typu', () {
        notifier.addItemLocally('cookie');
        notifier.addItemLocally('cookie');
        notifier.addItemLocally('cookie');

        expect(notifier.state.countOf('cookie'), 3);
      });

      test('powinien dodac rozne typy przedmiotow', () {
        notifier.addItemLocally('cookie');
        notifier.addItemLocally('candy');
        notifier.addItemLocally('icecream');

        expect(notifier.state.countOf('cookie'), 1);
        expect(notifier.state.countOf('candy'), 1);
        expect(notifier.state.countOf('icecream'), 1);
        expect(notifier.state.totalItems, 3);
      });

      test('powinien zwiekszyc totalItems', () {
        notifier.addItemLocally('cookie');
        expect(notifier.state.totalItems, 1);

        notifier.addItemLocally('candy');
        expect(notifier.state.totalItems, 2);
      });

      test('powinien obsluzyc nieznany typ przedmiotu', () {
        notifier.addItemLocally('unknown_item');

        expect(notifier.state.countOf('unknown_item'), 1);
      });
    });

    group('consumeItem (tryb lokalny)', () {
      test('powinien zwrocic false gdy przedmiot nie istnieje', () async {
        final result = await notifier.consumeItem('cookie');

        expect(result, false);
      });

      test('powinien skonsumowac przedmiot i zmniejszyc licznik', () async {
        notifier.addItemLocally('cookie');
        notifier.addItemLocally('cookie');
        expect(notifier.state.countOf('cookie'), 2);

        final result = await notifier.consumeItem('cookie');

        expect(result, true);
        expect(notifier.state.countOf('cookie'), 1);
      });

      test('powinien zwrocic false gdy count to 0', () async {
        // Counts ma wpis z 0
        final result = await notifier.consumeItem('cookie');

        expect(result, false);
      });
    });
  });

  group('availableRewards', () {
    test('powinien miec 4 nagrody', () {
      expect(availableRewards.length, 4);
    });

    test('kazda nagroda powinna miec unikalne id', () {
      final ids = availableRewards.map((r) => r.id).toSet();
      expect(ids.length, availableRewards.length);
    });

    test('kazda nagroda powinna miec nazwe i sciezke ikony', () {
      for (final reward in availableRewards) {
        expect(reward.id, isNotEmpty);
        expect(reward.name, isNotEmpty);
        expect(reward.iconPath, isNotEmpty);
      }
    });

    test('powinien zawierac cookie, candy, icecream, chocolate', () {
      final ids = availableRewards.map((r) => r.id).toSet();
      expect(ids, containsAll(['cookie', 'candy', 'icecream', 'chocolate']));
    });
  });
}
