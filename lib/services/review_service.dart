import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serwis prośby o ocenę w Store
/// Wyświetla prompt po 5 ukończonych grach (raz na instalację)
class ReviewService {
  static const String _gamesCompletedKey = 'review_games_completed';
  static const String _reviewShownKey = 'review_shown';
  static const int _gamesThreshold = 5;

  static final ReviewService instance = ReviewService._internal();
  ReviewService._internal();

  /// Wywołaj po ukończeniu gry - automatycznie sprawdzi czy pokazać prompt
  Future<void> onGameCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    // Sprawdź czy już pokazano
    final alreadyShown = prefs.getBool(_reviewShownKey) ?? false;
    if (alreadyShown) return;

    // Zwiększ licznik
    final count = (prefs.getInt(_gamesCompletedKey) ?? 0) + 1;
    await prefs.setInt(_gamesCompletedKey, count);

    if (kDebugMode) {
      debugPrint('[REVIEW] Ukończone gry: $count/$_gamesThreshold');
    }

    if (count >= _gamesThreshold) {
      await _requestReview();
      await prefs.setBool(_reviewShownKey, true);
    }
  }

  Future<void> _requestReview() async {
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        if (kDebugMode) {
          debugPrint('[REVIEW] Prompt wyswietlony');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[REVIEW] Blad: $e');
      }
    }
  }
}
