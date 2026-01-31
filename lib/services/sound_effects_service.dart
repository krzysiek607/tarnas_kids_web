import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Singleton do zarządzania dźwiękami UI
/// Udostępnia metody: playClick(), playSuccess(), playError()
class SoundEffectsService {
  // Singleton pattern
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  static SoundEffectsService get instance => _instance;
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  // Audio players dla każdego typu dźwięku (dla lepszej responsywności)
  AudioPlayer? _clickPlayer;
  AudioPlayer? _successPlayer;
  AudioPlayer? _errorPlayer;

  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 1.0;

  // Ścieżki do plików dźwiękowych
  static const String _clickPath = 'sounds/click.mp3';
  static const String _successPath = 'sounds/success.mp3';
  static const String _errorPath = 'sounds/error.mp3';

  /// Czy dźwięki są wyciszone
  bool get isMuted => _isMuted;

  /// Aktualna głośność (0.0 - 1.0)
  double get volume => _volume;

  /// Inicjalizuje serwis i preloaduje dźwięki
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Utwórz playery
      _clickPlayer = AudioPlayer();
      _successPlayer = AudioPlayer();
      _errorPlayer = AudioPlayer();

      // Konfiguracja audio context dla każdego playera
      final audioContext = AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );

      await Future.wait([
        _clickPlayer!.setAudioContext(audioContext),
        _successPlayer!.setAudioContext(audioContext),
        _errorPlayer!.setAudioContext(audioContext),
      ]);

      // Ustaw tryb - dźwięki grają raz
      await Future.wait([
        _clickPlayer!.setReleaseMode(ReleaseMode.stop),
        _successPlayer!.setReleaseMode(ReleaseMode.stop),
        _errorPlayer!.setReleaseMode(ReleaseMode.stop),
      ]);

      // Ustaw głośność
      await Future.wait([
        _clickPlayer!.setVolume(_volume),
        _successPlayer!.setVolume(_volume),
        _errorPlayer!.setVolume(_volume),
      ]);

      // Preload dźwięków (na mobile)
      if (!kIsWeb) {
        await _preloadSounds();
      }

      _isInitialized = true;
    } catch (e) {
      // ignore: avoid_print
      print('[SoundEffectsService] Init error: $e');
    }
  }

  /// Preloaduje dźwięki do pamięci
  Future<void> _preloadSounds() async {
    try {
      // Krótkie odtworzenie z zerową głośnością żeby preloadować
      await _clickPlayer!.setVolume(0);
      await _clickPlayer!.play(AssetSource(_clickPath));
      await _clickPlayer!.stop();
      await _clickPlayer!.setVolume(_volume);
    } catch (e) {
      // Plik może nie istnieć - to OK
    }

    try {
      await _successPlayer!.setVolume(0);
      await _successPlayer!.play(AssetSource(_successPath));
      await _successPlayer!.stop();
      await _successPlayer!.setVolume(_volume);
    } catch (e) {
      // Plik może nie istnieć - to OK
    }

    try {
      await _errorPlayer!.setVolume(0);
      await _errorPlayer!.play(AssetSource(_errorPath));
      await _errorPlayer!.stop();
      await _errorPlayer!.setVolume(_volume);
    } catch (e) {
      // Plik może nie istnieć - to OK
    }
  }

  /// Lazy initialization
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Odtwarza dźwięk kliknięcia
  Future<void> playClick() async {
    if (_isMuted) return;
    await _ensureInitialized();
    if (_clickPlayer == null) return;

    try {
      await _clickPlayer!.stop();
      if (kIsWeb) {
        await _clickPlayer!.play(UrlSource(_clickPath));
      } else {
        await _clickPlayer!.play(AssetSource(_clickPath));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SoundEffectsService] playClick error: $e');
    }
  }

  /// Odtwarza dźwięk sukcesu
  Future<void> playSuccess() async {
    if (_isMuted) return;
    await _ensureInitialized();
    if (_successPlayer == null) return;

    try {
      await _successPlayer!.stop();
      if (kIsWeb) {
        await _successPlayer!.play(UrlSource(_successPath));
      } else {
        await _successPlayer!.play(AssetSource(_successPath));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SoundEffectsService] playSuccess error: $e');
    }
  }

  /// Odtwarza dźwięk błędu (delikatny, nie straszący)
  Future<void> playError() async {
    if (_isMuted) return;
    await _ensureInitialized();
    if (_errorPlayer == null) return;

    try {
      await _errorPlayer!.stop();
      if (kIsWeb) {
        await _errorPlayer!.play(UrlSource(_errorPath));
      } else {
        await _errorPlayer!.play(AssetSource(_errorPath));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SoundEffectsService] playError error: $e');
    }
  }

  /// Włącza/wyłącza dźwięki
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// Ustawia głośność (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);

    if (_clickPlayer != null) {
      await _clickPlayer!.setVolume(_volume);
    }
    if (_successPlayer != null) {
      await _successPlayer!.setVolume(_volume);
    }
    if (_errorPlayer != null) {
      await _errorPlayer!.setVolume(_volume);
    }
  }

  /// Zwolnij zasoby
  void dispose() {
    _clickPlayer?.dispose();
    _successPlayer?.dispose();
    _errorPlayer?.dispose();
    _clickPlayer = null;
    _successPlayer = null;
    _errorPlayer = null;
    _isInitialized = false;
  }
}
