import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Callback do kontroli głośności muzyki w tle (audio ducking)
typedef VolumeCallback = Future<void> Function(double volume);

/// Singleton do odtwarzania efektów dźwiękowych (SFX)
/// Używany głównie dla dźwięków sukcesu, błędów, ewolucji itp.
class SoundEffectsController {
  static final SoundEffectsController _instance = SoundEffectsController._internal();
  factory SoundEffectsController() => _instance;
  SoundEffectsController._internal();

  AudioPlayer? _sfxPlayer;
  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 1.0;

  // Audio ducking - callbacki do kontroli muzyki w tle
  VolumeCallback? _onDuckingStart;
  VolumeCallback? _onDuckingEnd;
  double _originalBgVolume = 0.5;
  static const double _duckedVolume = 0.1; // 10% głośności podczas efektu

  /// Rejestruje callbacki do audio ducking
  /// Wywoływane przy starcie aplikacji z main.dart lub ProviderScope
  void registerDuckingCallbacks({
    required VolumeCallback onDuckingStart,
    required VolumeCallback onDuckingEnd,
    double originalVolume = 0.5,
  }) {
    _onDuckingStart = onDuckingStart;
    _onDuckingEnd = onDuckingEnd;
    _originalBgVolume = originalVolume;
  }

  /// Inicjalizuje audio player (wywoływane lazy przy pierwszym użyciu)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _sfxPlayer = AudioPlayer();

      // Konfiguracja AudioContext tylko dla mobile (iOS/Android)
      // Na Windows/Linux/Web pomijamy - domyślna konfiguracja działa
      if (!kIsWeb) {
        try {
          await _sfxPlayer!.setAudioContext(AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              // playback + mixWithOthers = gra dźwięki bez przerywania muzyki
              category: AVAudioSessionCategory.playback,
              options: {
                AVAudioSessionOptions.mixWithOthers,
              },
            ),
          ));
        } catch (e) {
          // Windows/Linux nie obsługują AudioContext - ignoruj
        }
      }

      // Nie zapętlaj - efekty grają raz
      await _sfxPlayer!.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer!.setVolume(_volume);

      _isInitialized = true;
    } catch (e) {
      // BULLETPROOF: Platforma może nie obsługiwać audio
      // ignore: avoid_print
      print('[SFX ERROR] Init error: $e');
    }
  }

  /// Odtwarza efekt dźwiękowy sukcesu (z audio ducking)
  Future<void> playSuccess() async {
    await _playSfxWithDucking('sounds/success.mp3', durationMs: 1500);
  }

  /// Odtwarza efekt sukcesu BEZ audio ducking (gdy ducking jest już aktywny)
  Future<void> playSuccessRaw() async {
    if (_isMuted) return;
    await _ensureInitialized();
    if (_sfxPlayer == null) return;

    try {
      await _sfxPlayer!.stop();
      if (kIsWeb) {
        await _sfxPlayer!.play(UrlSource('sounds/success.mp3'));
      } else {
        await _sfxPlayer!.play(AssetSource('sounds/success.mp3'));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SFX ERROR] playSuccessRaw error: $e');
    }
  }

  /// Odtwarza efekt dźwiękowy ewolucji (dłuższy, z audio ducking)
  Future<void> playEvolution() async {
    // Używamy success.mp3 jako placeholder dla ewolucji
    // Można dodać dedykowany dźwięk evolution.mp3
    await _playSfxWithDucking('sounds/success.mp3', durationMs: 3000);
  }

  /// Odtwarza krótki dźwięk (np. sylaba) z lekkim ducking
  /// Używane przez zewnętrzne AudioPlayery (np. syllable player)
  Future<void> duckMusicDuring(Future<void> Function() playAction, {int durationMs = 800}) async {
    if (_isMuted) {
      await playAction();
      return;
    }

    try {
      // AUDIO DUCKING: Wycisz muzykę w tle
      if (_onDuckingStart != null) {
        await _onDuckingStart!(_duckedVolume);
      }

      // Wykonaj akcję odtwarzania
      await playAction();

      // Poczekaj na zakończenie dźwięku
      await Future.delayed(Duration(milliseconds: durationMs));

      // AUDIO DUCKING: Przywróć głośność
      if (_onDuckingEnd != null) {
        await _onDuckingEnd!(_originalBgVolume);
      }
    } catch (e) {
      // W przypadku błędu przywróć głośność
      if (_onDuckingEnd != null) {
        await _onDuckingEnd!(_originalBgVolume);
      }
    }
  }

  /// Odtwarza efekt z audio ducking (wycisza muzykę w tle)
  Future<void> _playSfxWithDucking(String assetPath, {int durationMs = 1500}) async {
    if (_isMuted) return;

    await _ensureInitialized();
    if (_sfxPlayer == null) return;

    try {
      // AUDIO DUCKING: Wycisz muzykę w tle
      if (_onDuckingStart != null) {
        await _onDuckingStart!(_duckedVolume);
      }

      // Zatrzymaj poprzedni dźwięk jeśli jeszcze gra
      await _sfxPlayer!.stop();

      if (kIsWeb) {
        await _sfxPlayer!.play(UrlSource(assetPath));
      } else {
        // Na mobile audioplayers dodaje prefix 'assets/'
        await _sfxPlayer!.play(AssetSource(assetPath));
      }

      // Poczekaj na zakończenie efektu
      await Future.delayed(Duration(milliseconds: durationMs));

      // AUDIO DUCKING: Przywróć głośność muzyki w tle
      if (_onDuckingEnd != null) {
        await _onDuckingEnd!(_originalBgVolume);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[SFX ERROR] Play error: $e');

      // W przypadku błędu przywróć głośność
      if (_onDuckingEnd != null) {
        await _onDuckingEnd!(_originalBgVolume);
      }
    }
  }

  /// Wycisza/odcisza efekty dźwiękowe
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// Ustawia głośność (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_sfxPlayer != null) {
      await _sfxPlayer!.setVolume(_volume);
    }
  }

  /// Aktualizuje oryginalną głośność muzyki w tle
  void updateOriginalBgVolume(double volume) {
    _originalBgVolume = volume;
  }

  /// Zwolnij zasoby
  void dispose() {
    _sfxPlayer?.dispose();
    _sfxPlayer = null;
    _isInitialized = false;
  }
}
