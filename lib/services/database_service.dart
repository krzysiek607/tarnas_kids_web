import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model smakołyka/nagrody
class Reward {
  final String id;
  final String name;
  final String iconPath;

  const Reward({
    required this.id,
    required this.name,
    required this.iconPath,
  });
}

/// Dostępne smakołyki do wylosowania
const List<Reward> availableRewards = [
  Reward(
    id: 'cookie',
    name: 'Ciastko',
    iconPath: 'assets/images/rewards/cookie.png',
  ),
  Reward(
    id: 'candy',
    name: 'Cukierek',
    iconPath: 'assets/images/rewards/candy.png',
  ),
  Reward(
    id: 'icecream',
    name: 'Lody',
    iconPath: 'assets/images/rewards/icecream.png',
  ),
  Reward(
    id: 'chocolate',
    name: 'Czekolada',
    iconPath: 'assets/images/rewards/chocolate.png',
  ),
];

/// Serwis do komunikacji z bazą danych Supabase
class DatabaseService {
  static DatabaseService? _instance;
  final SupabaseClient _client;

  DatabaseService._internal(this._client);

  /// Singleton - zwraca instancję serwisu
  static DatabaseService get instance {
    if (_instance == null) {
      throw Exception(
        'DatabaseService nie został zainicjalizowany. '
        'Wywołaj DatabaseService.initialize() w main.dart',
      );
    }
    return _instance!;
  }

  /// Inicjalizuje serwis z klientem Supabase
  static void initialize(SupabaseClient client) {
    _instance = DatabaseService._internal(client);
  }

  /// Czy serwis jest zainicjalizowany
  static bool get isInitialized => _instance != null;

  /// Losuje nagrodę i zapisuje ją w tabeli 'inventory'
  /// Zwraca wylosowaną nagrodę
  Future<Reward> addReward(String itemType) async {
    // Losuj jeden z 4 smakołyków
    final random = Random();
    final reward = availableRewards[random.nextInt(availableRewards.length)];

    try {
      // Zapisz do tabeli inventory w Supabase
      await _client.from('inventory').insert({
        'item_type': itemType,
        'reward_id': reward.id,
        'reward_name': reward.name,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Jeśli błąd zapisu do bazy - loguj ale nie przerywaj
      // Nagroda i tak zostanie pokazana dziecku
      print('Błąd zapisu nagrody do Supabase: $e');
    }

    return reward;
  }

  /// Pobiera wszystkie nagrody z ekwipunku
  Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final response = await _client
          .from('inventory')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania ekwipunku: $e');
      return [];
    }
  }

  /// Liczy nagrody danego typu
  Future<int> countRewards(String rewardId) async {
    try {
      final response = await _client
          .from('inventory')
          .select()
          .eq('reward_id', rewardId);
      return (response as List).length;
    } catch (e) {
      print('Błąd liczenia nagród: $e');
      return 0;
    }
  }

  /// Pobiera liczniki wszystkich nagród (zgrupowane)
  Future<Map<String, int>> getInventoryCounts() async {
    try {
      final response = await _client.from('inventory').select('reward_id');
      final items = List<Map<String, dynamic>>.from(response);

      // Zlicz każdy typ
      final counts = <String, int>{};
      for (final reward in availableRewards) {
        counts[reward.id] = 0;
      }

      for (final item in items) {
        final rewardId = item['reward_id'] as String?;
        if (rewardId != null && counts.containsKey(rewardId)) {
          counts[rewardId] = counts[rewardId]! + 1;
        }
      }

      return counts;
    } catch (e) {
      print('Błąd pobierania liczników: $e');
      return {for (final r in availableRewards) r.id: 0};
    }
  }

  /// Stream nasłuchujący zmian w ekwipunku (realtime)
  /// Zwraca mapy z licznikami dla każdego typu nagrody
  Stream<Map<String, int>> getInventoryStream() {
    // Kontroler streamu
    final controller = StreamController<Map<String, int>>();

    // Początkowe pobranie danych
    getInventoryCounts().then((counts) {
      if (!controller.isClosed) {
        controller.add(counts);
      }
    });

    // Subskrypcja realtime
    final subscription = _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) async {
          // Przelicz liczniki po każdej zmianie
          final counts = <String, int>{};
          for (final reward in availableRewards) {
            counts[reward.id] = 0;
          }

          for (final item in data) {
            final rewardId = item['reward_id'] as String?;
            if (rewardId != null && counts.containsKey(rewardId)) {
              counts[rewardId] = counts[rewardId]! + 1;
            }
          }

          if (!controller.isClosed) {
            controller.add(counts);
          }
        });

    // Zamknij subskrypcję gdy stream zostanie zamknięty
    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  /// Konsumuje (usuwa) jeden przedmiot danego typu z ekwipunku
  /// Zwraca true jeśli udało się usunąć, false jeśli brak przedmiotu
  Future<bool> consumeItem(String rewardId) async {
    try {
      // Znajdź najstarszy przedmiot danego typu
      final response = await _client
          .from('inventory')
          .select('id')
          .eq('reward_id', rewardId)
          .order('created_at', ascending: true)
          .limit(1);

      final items = List<Map<String, dynamic>>.from(response);

      if (items.isEmpty) {
        print('Brak przedmiotu $rewardId do konsumpcji');
        return false;
      }

      // Usuń znaleziony przedmiot
      final itemId = items.first['id'];
      await _client.from('inventory').delete().eq('id', itemId);

      print('Skonsumowano przedmiot: $rewardId (id: $itemId)');
      return true;
    } catch (e) {
      print('Błąd konsumpcji przedmiotu: $e');
      return false;
    }
  }

  /// Sprawdza czy jest dostępny przedmiot danego typu
  Future<bool> hasItem(String rewardId) async {
    final count = await countRewards(rewardId);
    return count > 0;
  }
}
