import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Stan ekwipunku - liczniki smakołyków
class InventoryState {
  final Map<String, int> counts;
  final bool isLoading;
  final String? error;

  const InventoryState({
    this.counts = const {},
    this.isLoading = false,
    this.error,
  });

  /// Czy ekwipunek jest pusty
  bool get isEmpty => counts.values.every((count) => count == 0);

  /// Łączna liczba przedmiotów
  int get totalItems => counts.values.fold(0, (sum, count) => sum + count);

  /// Pobierz liczbę dla danego typu
  int countOf(String rewardId) => counts[rewardId] ?? 0;

  /// Czy jest dostępny przedmiot
  bool hasItem(String rewardId) => countOf(rewardId) > 0;

  InventoryState copyWith({
    Map<String, int>? counts,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      counts: counts ?? this.counts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier dla ekwipunku
class InventoryNotifier extends StateNotifier<InventoryState> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  /// BULLETPROOF: Zestaw przedmiotów obecnie przetwarzanych (debouncing)
  final Set<String> _processingItems = {};

  InventoryNotifier() : super(const InventoryState(isLoading: true)) {
    _initialize();
  }

  /// Inicjalizuje i nasłuchuje zmian w ekwipunku
  void _initialize() {
    if (!DatabaseService.isInitialized) {
      // Jeśli baza nie jest dostępna - użyj lokalnego stanu
      state = InventoryState(
        counts: {for (final r in availableRewards) r.id: 0},
        isLoading: false,
      );
      return;
    }

    // Nasłuchuj SUROWEGO streamu z bazy danych
    _subscription = DatabaseService.instance.getInventoryStream().listen(
      (List<Map<String, dynamic>> items) {
        // Przelicz liczniki z surowych danych
        final counts = DatabaseService.calculateCounts(items);
        state = InventoryState(counts: counts, isLoading: false);
      },
      onError: (error) {
        state = InventoryState(
          counts: {for (final r in availableRewards) r.id: 0},
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  /// Odśwież ekwipunek z bazy
  Future<void> refresh() async {
    if (!DatabaseService.isInitialized) return;

    state = state.copyWith(isLoading: true);
    try {
      final counts = await DatabaseService.instance.getInventoryCounts();
      state = InventoryState(counts: counts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Konsumuje przedmiot (nakarm zwierzaka)
  /// Zwraca true jeśli udało się skonsumować
  /// BULLETPROOF: Debouncing - ignoruje wielokrotne kliknięcia na ten sam przedmiot
  Future<bool> consumeItem(String rewardId) async {
    // BULLETPROOF: Sprawdź czy przedmiot jest już przetwarzany
    if (_processingItems.contains(rewardId)) {
      return false; // Ignoruj - już w trakcie przetwarzania
    }

    // Sprawdź czy mamy przedmiot
    if (!state.hasItem(rewardId)) {
      return false;
    }

    // Oznacz jako przetwarzany
    _processingItems.add(rewardId);

    try {
      if (DatabaseService.isInitialized) {
        // Usuń z bazy - stream automatycznie zaktualizuje stan
        final success = await DatabaseService.instance.consumeItem(rewardId);
        return success;
      } else {
        // Lokalny tryb - zmniejsz licznik
        final newCounts = Map<String, int>.from(state.counts);
        newCounts[rewardId] = (newCounts[rewardId] ?? 1) - 1;
        state = state.copyWith(counts: newCounts);
        return true;
      }
    } finally {
      // Zawsze odznacz jako przetworzony
      _processingItems.remove(rewardId);
    }
  }

  /// Dodaje przedmiot lokalnie (gdy brak bazy)
  void addItemLocally(String rewardId) {
    final newCounts = Map<String, int>.from(state.counts);
    newCounts[rewardId] = (newCounts[rewardId] ?? 0) + 1;
    state = state.copyWith(counts: newCounts);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider dla ekwipunku
final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>(
  (ref) => InventoryNotifier(),
);

/// Provider dla pojedynczego licznika (optymalizacja renderowania)
final itemCountProvider = Provider.family<int, String>((ref, rewardId) {
  final inventory = ref.watch(inventoryProvider);
  return inventory.countOf(rewardId);
});
