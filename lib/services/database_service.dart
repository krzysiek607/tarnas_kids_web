import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
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

  /// Pobiera ID aktualnego użytkownika (anonimowego lub zalogowanego)
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Losuje nagrodę i zapisuje ją w tabeli 'inventory'
  /// Zwraca wylosowaną nagrodę
  Future<Reward> addReward(String itemType) async {
    // Losuj jeden z 4 smakołyków
    final random = Random();
    final reward = availableRewards[random.nextInt(availableRewards.length)];

    final userId = currentUserId;
    if (userId == null) {
      print('Brak zalogowanego użytkownika - nagroda tylko lokalnie');
      return reward;
    }

    try {
      // Zapisz do tabeli inventory w Supabase z user_id
      await _client.from('inventory').insert({
        'user_id': userId,
        'item_type': itemType,
        'reward_id': reward.id,
        'reward_name': reward.name,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Nagroda zapisana dla użytkownika: $userId');
    } catch (e) {
      // Jeśli błąd zapisu do bazy - loguj ale nie przerywaj
      // Nagroda i tak zostanie pokazana dziecku
      print('Błąd zapisu nagrody do Supabase: $e');
    }

    return reward;
  }

  /// Pobiera wszystkie nagrody z ekwipunku aktualnego użytkownika
  Future<List<Map<String, dynamic>>> getInventory() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('inventory')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania ekwipunku: $e');
      return [];
    }
  }

  /// Liczy nagrody danego typu dla aktualnego użytkownika
  Future<int> countRewards(String rewardId) async {
    final userId = currentUserId;
    if (userId == null) return 0;

    try {
      final response = await _client
          .from('inventory')
          .select()
          .eq('user_id', userId)
          .eq('reward_id', rewardId);
      return (response as List).length;
    } catch (e) {
      print('Błąd liczenia nagród: $e');
      return 0;
    }
  }

  /// Pobiera liczniki wszystkich nagród (zgrupowane) dla aktualnego użytkownika
  Future<Map<String, int>> getInventoryCounts() async {
    final userId = currentUserId;
    if (userId == null) {
      return {for (final r in availableRewards) r.id: 0};
    }

    try {
      final response = await _client
          .from('inventory')
          .select('reward_id')
          .eq('user_id', userId);
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

  /// Stream nasłuchujący zmian w ekwipunku (realtime) dla aktualnego użytkownika
  /// Zwraca mapy z licznikami dla każdego typu nagrody
  Stream<Map<String, int>> getInventoryStream() {
    final controller = StreamController<Map<String, int>>();
    final userId = currentUserId;

    if (userId == null) {
      // Brak użytkownika - zwróć puste liczniki
      controller.add({for (final r in availableRewards) r.id: 0});
      return controller.stream;
    }

    // Początkowe pobranie danych
    getInventoryCounts().then((counts) {
      if (!controller.isClosed) {
        controller.add(counts);
      }
    });

    // Subskrypcja realtime z filtrem po user_id
    final subscription = _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
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

  /// Konsumuje (usuwa) jeden przedmiot danego typu z ekwipunku aktualnego użytkownika
  /// Zwraca true jeśli udało się usunąć, false jeśli brak przedmiotu
  Future<bool> consumeItem(String rewardId) async {
    debugPrint('🍪 KARMIENIE: Próba zjedzenia: $rewardId');

    final userId = currentUserId;
    if (userId == null) {
      debugPrint('🍪 KARMIENIE: Brak zalogowanego użytkownika!');
      return false;
    }
    debugPrint('🍪 KARMIENIE: User ID: $userId');

    try {
      // KROK A: Pobierz ID jednego najstarszego rekordu
      debugPrint('🍪 KARMIENIE: Szukam najstarszego $rewardId...');
      final response = await _client
          .from('inventory')
          .select('id')
          .eq('user_id', userId)
          .eq('reward_id', rewardId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('🍪 KARMIENIE: Brak przedmiotu $rewardId do konsumpcji!');
        return false;
      }

      final itemId = response['id'];
      debugPrint('🍪 KARMIENIE: Znaleziono ID do usunięcia: $itemId');

      // KROK B: Usuń rekord o tym konkretnym ID (z weryfikacją user_id)
      await _client
          .from('inventory')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);

      debugPrint('🍪 KARMIENIE: Usunięto pomyślnie! ($rewardId, id: $itemId)');
      return true;
    } catch (e) {
      debugPrint('🍪 KARMIENIE: BŁĄD: $e');
      return false;
    }
  }

  /// Sprawdza czy jest dostępny przedmiot danego typu
  Future<bool> hasItem(String rewardId) async {
    final count = await countRewards(rewardId);
    return count > 0;
  }
}
