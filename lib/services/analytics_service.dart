import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serwis analityki - wysyła zdarzenia do Firebase, PostHog i Supabase
/// BULLETPROOF MODE: Wszystkie błędy są łapane i logowane, nie crashują aplikacji
class AnalyticsService {
  static AnalyticsService? _instance;

  FirebaseAnalytics? _firebaseAnalytics;
  SupabaseClient? _supabaseClient;
  String? _userId;
  bool _isInitialized = false;

  AnalyticsService._internal();

  /// Singleton
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  /// Czy serwis jest zainicjalizowany
  bool get isInitialized => _isInitialized;

  /// Aktualne ID użytkownika
  String? get userId => _userId;

  /// Inicjalizuje serwis analityki
  Future<void> initialize({SupabaseClient? supabaseClient}) async {
    if (_isInitialized) return;

    try {
      // Firebase Analytics
      _firebaseAnalytics = FirebaseAnalytics.instance;

      // Supabase (opcjonalnie)
      _supabaseClient = supabaseClient;

      _isInitialized = true;
      debugPrint('[ANALYTICS] Zainicjalizowano Firebase Analytics i PostHog');
    } catch (e) {
      debugPrint('[ANALYTICS] Błąd inicjalizacji: $e');
    }
  }

  /// Identyfikuje użytkownika we wszystkich systemach
  Future<void> identifyUser(String userId) async {
    _userId = userId;

    // Firebase
    if (_firebaseAnalytics != null) {
      try {
        await _firebaseAnalytics!.setUserId(id: userId);
      } catch (e) {
        debugPrint('[ANALYTICS] Firebase identifyUser error: $e');
      }
    }

    // PostHog
    try {
      debugPrint('➡️ [POSTHOG] Próba identyfikacji użytkownika: $userId');
      await Posthog().identify(userId: userId);
      debugPrint('✅ [POSTHOG] Użytkownik zidentyfikowany: $userId');
    } catch (e) {
      debugPrint('❌ [POSTHOG] Błąd identyfikacji: $e');
    }

    debugPrint('[ANALYTICS] User ID ustawiony: $userId');
  }

  /// Resetuje użytkownika (np. przy wylogowaniu)
  Future<void> resetUser() async {
    _userId = null;

    // Firebase
    if (_firebaseAnalytics != null) {
      try {
        await _firebaseAnalytics!.setUserId(id: null);
      } catch (e) {
        debugPrint('[ANALYTICS] Firebase reset error: $e');
      }
    }

    // PostHog
    try {
      await Posthog().reset();
    } catch (e) {
      debugPrint('[ANALYTICS] PostHog reset error: $e');
    }
  }

  // ============================================
  // SCREEN VIEWS
  // ============================================

  /// Loguje wyświetlenie ekranu
  Future<void> logScreenView(String screenName) async {
    await _logEvent('screen_view', {'screen_name': screenName});

    // Firebase ma dedykowaną metodę logScreenView
    if (_firebaseAnalytics != null) {
      try {
        await _firebaseAnalytics!.logScreenView(screenName: screenName);
      } catch (e) {
        debugPrint('[ANALYTICS] Firebase screen view error: $e');
      }
    }
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

  /// Wewnętrzna metoda logowania zdarzeń do wszystkich systemów
  Future<void> _logEvent(String eventName, Map<String, dynamic> parameters) async {
    // Zawsze loguj do konsoli w debug mode
    if (kDebugMode) {
      debugPrint('[ANALYTICS] $eventName: $parameters');
    }

    // Firebase Analytics
    if (_firebaseAnalytics != null) {
      try {
        // Konwertuj parametry do Map<String, Object>
        final firebaseParams = <String, Object>{};
        for (final entry in parameters.entries) {
          final value = entry.value;
          if (value != null) {
            firebaseParams[entry.key] = value is bool ? (value ? 1 : 0) : value;
          }
        }
        await _firebaseAnalytics!.logEvent(
          name: eventName,
          parameters: firebaseParams,
        );
      } catch (e) {
        debugPrint('[ANALYTICS] Firebase error: $e');
      }
    }

    // PostHog
    try {
      // Konwertuj parametry do Map<String, Object>
      final posthogParams = <String, Object>{};
      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value != null) {
          posthogParams[entry.key] = value;
        }
      }

      // DIAGNOSTYKA: Wyraźny log przed wysłaniem
      debugPrint('➡️ [POSTHOG] Próba wysłania: $eventName | params: $posthogParams');

      await Posthog().capture(
        eventName: eventName,
        properties: posthogParams,
      );

      // DIAGNOSTYKA: Potwierdzenie wysłania
      debugPrint('✅ [POSTHOG] Wysłano: $eventName');
    } catch (e) {
      debugPrint('❌ [POSTHOG] Błąd wysyłania $eventName: $e');
    }

    // Supabase (opcjonalnie - do własnej analizy)
    if (_supabaseClient != null) {
      try {
        await _supabaseClient!.from('analytics_events').insert({
          'user_id': _userId,
          'event_name': eventName,
          'parameters': parameters,
          'created_at': DateTime.now().toIso8601String(),
          'platform': _getPlatform(),
        });
      } catch (e) {
        // Ignoruj błędy Supabase - nie są krytyczne
        if (kDebugMode) {
          debugPrint('[ANALYTICS] Supabase error: $e');
        }
      }
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
