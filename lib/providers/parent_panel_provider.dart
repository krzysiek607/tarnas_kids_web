import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dane statystyk dla Panelu Rodzica
class ParentPanelStats {
  final Map<String, int> gameStats;
  final int totalGamesPlayed;
  final int totalRewards;
  final String favoriteGame;
  final Map<String, int> dailySessions;
  final int currentStreak;
  final bool isLoading;

  const ParentPanelStats({
    this.gameStats = const {},
    this.totalGamesPlayed = 0,
    this.totalRewards = 0,
    this.favoriteGame = '',
    this.dailySessions = const {},
    this.currentStreak = 0,
    this.isLoading = true,
  });

  ParentPanelStats copyWith({
    Map<String, int>? gameStats,
    int? totalGamesPlayed,
    int? totalRewards,
    String? favoriteGame,
    Map<String, int>? dailySessions,
    int? currentStreak,
    bool? isLoading,
  }) {
    return ParentPanelStats(
      gameStats: gameStats ?? this.gameStats,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalRewards: totalRewards ?? this.totalRewards,
      favoriteGame: favoriteGame ?? this.favoriteGame,
      dailySessions: dailySessions ?? this.dailySessions,
      currentStreak: currentStreak ?? this.currentStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier zarzadzajacy danymi Panelu Rodzica
class ParentPanelNotifier extends StateNotifier<ParentPanelStats> {
  ParentPanelNotifier() : super(const ParentPanelStats()) {
    loadStatistics();
  }

  /// Laduje wszystkie statystyki z Supabase
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Pobierz game_start events (z created_at do wykresu)
      final gameStartEvents = await supabase
          .from('analytics_events')
          .select('parameters, created_at')
          .eq('user_id', userId)
          .eq('event_name', 'game_start');

      // Pobierz reward_earned events
      final rewardEvents = await supabase
          .from('analytics_events')
          .select('id')
          .eq('user_id', userId)
          .eq('event_name', 'reward_earned');

      // Przetwarzanie statystyk gier
      final Map<String, int> gameCount = {};
      final Map<String, int> dailySessionsMap = {};
      final Set<String> daysWithGames = {};

      for (final event in gameStartEvents) {
        // Zliczanie gier
        final params = event['parameters'] as Map<String, dynamic>?;
        if (params != null && params['game_name'] != null) {
          final gameName = params['game_name'] as String;
          gameCount[gameName] = (gameCount[gameName] ?? 0) + 1;
        }

        // Zliczanie sesji dziennych (ostatnie 7 dni)
        final createdAt = event['created_at'] as String?;
        if (createdAt != null) {
          final date = DateTime.tryParse(createdAt);
          if (date != null) {
            final dateKey = _dateKey(date);
            dailySessionsMap[dateKey] = (dailySessionsMap[dateKey] ?? 0) + 1;
            daysWithGames.add(dateKey);
          }
        }
      }

      // Ulubiona gra
      String favorite = '';
      int maxPlays = 0;
      gameCount.forEach((game, count) {
        if (count > maxPlays) {
          maxPlays = count;
          favorite = game;
        }
      });

      // Streak - ile kolejnych dni z gra (wstecz od dzisiaj)
      final streak = _calculateStreak(daysWithGames);

      // Sesje dzienne dla ostatnich 7 dni
      final Map<String, int> last7DaysSessions = {};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final key = _dateKey(date);
        last7DaysSessions[key] = dailySessionsMap[key] ?? 0;
      }

      state = ParentPanelStats(
        gameStats: gameCount,
        totalGamesPlayed: gameCount.values.fold(0, (a, b) => a + b),
        totalRewards: rewardEvents.length,
        favoriteGame: favorite,
        dailySessions: last7DaysSessions,
        currentStreak: streak,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PARENT_PANEL] Blad ladowania statystyk: $e');
      }
      state = state.copyWith(isLoading: false);
    }
  }

  /// Klucz daty w formacie yyyy-MM-dd
  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Oblicza streak (ile kolejnych dni z co najmniej 1 gra)
  static int _calculateStreak(Set<String> daysWithGames) {
    if (daysWithGames.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();

    // Sprawdz od dzisiaj wstecz
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);

      if (daysWithGames.contains(key)) {
        streak++;
      } else {
        // Jesli dzisiaj nie gral, sprawdz od wczoraj
        if (i == 0) continue;
        break;
      }
    }

    return streak;
  }
}

/// Provider dla statystyk panelu rodzica
final parentPanelProvider =
    StateNotifierProvider<ParentPanelNotifier, ParentPanelStats>(
  (ref) => ParentPanelNotifier(),
);
