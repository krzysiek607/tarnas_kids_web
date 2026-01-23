import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serwis analityki - loguje zdarzenia do Supabase i konsoli
class AnalyticsService {
  static AnalyticsService? _instance;
  SupabaseClient? _client;
  String? _userId;

  AnalyticsService._internal();

  /// Singleton
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  /// Inicjalizuje serwis z klientem Supabase
  void initialize(SupabaseClient client) {
    _client = client;
    _userId = client.auth.currentUser?.id;
    debugPrint('[ANALYTICS] Zainicjalizowano. User ID: $_userId');
  }

  /// Ustawia ID użytkownika (po zalogowaniu)
  void setUserId(String userId) {
    _userId = userId;
    debugPrint('[ANALYTICS] User ID ustawiony: $userId');
  }

  /// Czy serwis jest zainicjalizowany
  bool get isInitialized => _client != null;

  /// Aktualne ID użytkownika
  String? get userId => _userId;

  // ============================================
  // SCREEN VIEWS
  // ============================================

  /// Loguje wyświetlenie ekranu
  Future<void> logScreenView(String screenName) async {
    await _logEvent('screen_view', {'screen_name': screenName});
  }

  // ============================================
  // GAME EVENTS
  // ============================================

  /// Loguje rozpoczęcie gry
  Future<void> logGameStart(String gameName) async {
    await _logEvent('game_start', {'game_name': gameName});
  }

  /// Loguje ukończenie gry
  Future<void> logGameComplete(String gameName, {int? score, int? level}) async {
    await _logEvent('game_complete', {
      'game_name': gameName,
      if (score != null) 'score': score,
      if (level != null) 'level': level,
    });
  }

  // ============================================
  // REWARD EVENTS
  // ============================================

  /// Loguje zdobycie nagrody
  Future<void> logRewardEarned(String rewardName, {String? source}) async {
    await _logEvent('reward_earned', {
      'reward_name': rewardName,
      if (source != null) 'source': source,
    });
  }

  // ============================================
  // PET EVENTS
  // ============================================

  /// Loguje nakarmienie zwierzaka
  Future<void> logPetFed(String foodType) async {
    await _logEvent('pet_fed', {'food_type': foodType});
  }

  /// Loguje interakcję ze zwierzakiem
  Future<void> logPetInteraction(String action) async {
    await _logEvent('pet_interaction', {'action': action});
  }

  // ============================================
  // TRACING EVENTS
  // ============================================

  /// Loguje ukończenie rysowania ze szczegółami wyniku
  Future<void> logTracingComplete({
    required String patternName,
    required double accuracy,
    required double coverage,
    required bool rewardEarned,
  }) async {
    await _logEvent('tracing_complete', {
      'pattern_name': patternName,
      'accuracy': accuracy.round(),
      'coverage': coverage.round(),
      'reward_earned': rewardEarned,
    });
  }

  // ============================================
  // INTERNAL
  // ============================================

  /// Wewnętrzna metoda logowania zdarzeń
  Future<void> _logEvent(String eventName, Map<String, dynamic> parameters) async {
    // Zawsze loguj do konsoli w debug mode
    if (kDebugMode) {
      debugPrint('[ANALYTICS] $eventName: $parameters');
    }

    // Jeśli Supabase nie jest zainicjalizowany - tylko konsola
    if (_client == null) return;

    try {
      await _client!.from('analytics_events').insert({
        'user_id': _userId,
        'event_name': eventName,
        'parameters': parameters,
        'created_at': DateTime.now().toIso8601String(),
        'platform': _getPlatform(),
      });
    } catch (e) {
      // Nie przerywaj działania aplikacji przy błędzie analityki
      debugPrint('[ANALYTICS] Błąd zapisu: $e');
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }
}

/// Globalny dostęp do analityki
AnalyticsService get analytics => AnalyticsService.instance;
