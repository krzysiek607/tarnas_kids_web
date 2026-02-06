import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
      if (kDebugMode) {
        debugPrint('Brak zalogowanego użytkownika - nagroda tylko lokalnie');
      }
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
      if (kDebugMode) {
        debugPrint('Nagroda zapisana dla użytkownika: $userId');
      }
    } catch (e) {
      // Jeśli błąd zapisu do bazy - loguj ale nie przerywaj
      // Nagroda i tak zostanie pokazana dziecku
      if (kDebugMode) {
        debugPrint('Błąd zapisu nagrody do Supabase: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
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
      if (kDebugMode) {
        debugPrint('Błąd pobierania ekwipunku: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
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
      return (response is List) ? response.length : 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Błąd liczenia nagród: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
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
      if (kDebugMode) {
        debugPrint('Błąd pobierania liczników: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return {for (final r in availableRewards) r.id: 0};
    }
  }

  /// Stream nasłuchujący zmian w ekwipunku (realtime) dla aktualnego użytkownika
  /// Zwraca SUROWE dane z Supabase - StreamBuilder sam przelicza
  Stream<List<Map<String, dynamic>>> getInventoryStream() {
    final userId = currentUserId;
    if (userId == null) {
      // Brak użytkownika - zwróć pusty stream
      return Stream.value([]);
    }

    if (kDebugMode) {
      debugPrint('[INVENTORY STREAM] Uruchamiam stream dla user: $userId');
    }

    // Bezpośredni stream z Supabase - automatycznie emituje przy każdej zmianie
    return _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }

  /// Pomocnicza metoda do przeliczenia surowych danych na liczniki
  static Map<String, int> calculateCounts(List<Map<String, dynamic>> items) {
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
  }

  /// Konsumuje (usuwa) jeden przedmiot danego typu z ekwipunku aktualnego użytkownika
  /// Zwraca true jeśli udało się usunąć, false jeśli brak przedmiotu
  Future<bool> consumeItem(String rewardId) async {
    if (kDebugMode) {
      debugPrint('🍪 KARMIENIE: Próba zjedzenia: $rewardId');
    }

    final userId = currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('🍪 KARMIENIE: Brak zalogowanego użytkownika!');
      }
      return false;
    }
    if (kDebugMode) {
      debugPrint('🍪 KARMIENIE: User ID: $userId');
    }

    try {
      // KROK A: Pobierz ID jednego najstarszego rekordu
      if (kDebugMode) {
        debugPrint('🍪 KARMIENIE: Szukam najstarszego $rewardId...');
      }
      final response = await _client
          .from('inventory')
          .select('id')
          .eq('user_id', userId)
          .eq('reward_id', rewardId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        if (kDebugMode) {
          debugPrint('🍪 KARMIENIE: Brak przedmiotu $rewardId do konsumpcji!');
        }
        return false;
      }

      final itemId = response['id'];
      if (kDebugMode) {
        debugPrint('🍪 KARMIENIE: Znaleziono ID do usunięcia: $itemId');
      }

      // KROK B: Usuń rekord o tym konkretnym ID (z weryfikacją user_id)
      await _client
          .from('inventory')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);

      if (kDebugMode) {
        debugPrint('🍪 KARMIENIE: Usunięto pomyślnie! ($rewardId, id: $itemId)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🍪 KARMIENIE: BŁĄD: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  /// Sprawdza czy jest dostępny przedmiot danego typu
  Future<bool> hasItem(String rewardId) async {
    final count = await countRewards(rewardId);
    return count > 0;
  }

  // ============================================
  // PET STATE - stan zwierzaka w bazie
  // ============================================

  /// Pobiera stan zwierzaka z bazy (tabela pet_states)
  Future<Map<String, dynamic>?> getPetState() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('pet_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PET] Błąd pobierania stanu: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return null;
    }
  }

  /// Zapisuje stan zwierzaka do bazy (upsert)
  Future<bool> savePetState({
    required double hunger,
    required double happiness,
    required double energy,
    required double hygiene,
    int? evolutionPoints,
  }) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final data = {
        'user_id': userId,
        'hunger': hunger,
        'happiness': happiness,
        'energy': energy,
        'hygiene': hygiene,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Dodaj evolution_points tylko jeśli przekazano
      if (evolutionPoints != null) {
        data['evolution_points'] = evolutionPoints;
      }

      await _client.from('pet_states').upsert(data, onConflict: 'user_id');
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PET] Błąd zapisywania stanu: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  /// Dodaje punkty ewolucji atomowo (RPC) i zwraca nową wartość.
  /// Używa server-side RPC zamiast read-modify-write (brak race condition).
  Future<int> addEvolutionPoints(int points) async {
    final userId = currentUserId;
    if (userId == null) return 0;

    try {
      final result = await _client.rpc(
        'add_evolution_points',
        params: {'points_to_add': points},
      );

      final newPoints = (result as int?) ?? 0;
      if (kDebugMode) {
        debugPrint('[PET] Evolution points += $points → $newPoints (RPC)');
      }
      return newPoints;
    } catch (e) {
      // Fallback na client-side jeśli RPC nie istnieje jeszcze na serwerze
      if (kDebugMode) {
        debugPrint('[PET] RPC fallback - $e');
      }
      try {
        final state = await getPetState();
        final currentPoints = (state?['evolution_points'] as int?) ?? 0;
        final newPoints = currentPoints + points;

        await _client.from('pet_states').upsert({
          'user_id': userId,
          'evolution_points': newPoints,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');

        if (kDebugMode) {
          debugPrint('[PET] Evolution points: $currentPoints + $points = $newPoints (fallback)');
        }
        return newPoints;
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint('[PET] Błąd aktualizacji evolution_points: $fallbackError');
        }
        FirebaseCrashlytics.instance.recordError(fallbackError, StackTrace.current);
        return 0;
      }
    }
  }

  /// Pobiera aktualne punkty ewolucji
  Future<int> getEvolutionPoints() async {
    final state = await getPetState();
    return (state?['evolution_points'] as int?) ?? 0;
  }

  /// Resetuje punkty ewolucji do 0
  Future<bool> resetEvolutionPoints() async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _client.from('pet_states').upsert({
        'user_id': userId,
        'evolution_points': 0,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
      if (kDebugMode) {
        debugPrint('[PET] Evolution points zresetowane do 0');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PET] Błąd resetowania evolution_points: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  /// Rozpoczyna sen - zapisuje sleep_start_time
  Future<bool> startSleep() async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _client.from('pet_states').upsert({
        'user_id': userId,
        'sleep_start_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
      if (kDebugMode) {
        debugPrint('[PET] Sen rozpoczęty');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PET] Błąd rozpoczynania snu: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  /// Budzi zwierzaka - oblicza regenerację energii i czyści sleep_start_time
  /// Zwraca ilość zregenerowanej energii (1 minuta = 1 punkt)
  Future<int> wakeUpAndCalculateEnergy() async {
    final userId = currentUserId;
    if (userId == null) return 0;

    try {
      // Pobierz aktualny stan
      final state = await getPetState();
      if (state == null) return 0;

      final sleepStartStr = state['sleep_start_time'] as String?;
      if (sleepStartStr == null) return 0;

      // Oblicz czas snu
      final sleepStart = DateTime.parse(sleepStartStr);
      final now = DateTime.now();
      final minutesSlept = now.difference(sleepStart).inMinutes;

      // Wyczyść sleep_start_time
      await _client.from('pet_states').update({
        'sleep_start_time': null,
        'updated_at': now.toIso8601String(),
      }).eq('user_id', userId);

      if (kDebugMode) {
        debugPrint('[PET] Obudzony po $minutesSlept minutach snu');
      }
      return minutesSlept;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PET] Błąd budzenia: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return 0;
    }
  }

  /// Sprawdza czy zwierzak śpi (czy sleep_start_time jest ustawione)
  Future<DateTime?> getSleepStartTime() async {
    final state = await getPetState();
    if (state == null) return null;

    final sleepStartStr = state['sleep_start_time'] as String?;
    if (sleepStartStr == null) return null;

    return DateTime.tryParse(sleepStartStr);
  }
}
