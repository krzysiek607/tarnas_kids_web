import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Funkcja do logowania - uzywamy print() dla lepszej widocznosci w Android logs
void _log(String message) {
  // ignore: avoid_print
  print('[AUDIO] $message');
}

/// Stan muzyki w tle
class BackgroundMusicState {
  final bool isPlaying;
  final double volume;
  final String? error;
  final bool userMuted; // Czy uzytkownik recznie wylaczyl dzwiek

  const BackgroundMusicState({
    this.isPlaying = false,
    this.volume = 0.5,
    this.error,
    this.userMuted = false,
  });

  BackgroundMusicState copyWith({
    bool? isPlaying,
    double? volume,
    String? error,
    bool? userMuted,
  }) {
    return BackgroundMusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      error: error,
      userMuted: userMuted ?? this.userMuted,
    );
  }
}

/// Notifier do zarzadzania muzyka w tle
class BackgroundMusicNotifier extends StateNotifier<BackgroundMusicState> {
  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;

  BackgroundMusicNotifier() : super(const BackgroundMusicState());

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();

      // Konfiguracja dla Androida
      await _audioPlayer!.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      ));

      // Ustaw tryb zapetlenia
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      // Ustaw glosnosc
      await _audioPlayer!.setVolume(state.volume);

      // Listener na logi
      _audioPlayer!.onLog.listen((msg) {
        _log('AudioPlayer log: $msg');
      });

      // Listener na stan odtwarzacza
      _audioPlayer!.onPlayerStateChanged.listen((playerState) {
        _log('AudioPlayer state changed: $playerState');
      });

      // Listener na zakonczenie
      _audioPlayer!.onPlayerComplete.listen((_) {
        _log('AudioPlayer completed');
      });

      // Listener na czas trwania - potwierdza ze plik zostal zaladowany
      _audioPlayer!.onDurationChanged.listen((duration) {
        _log('AudioPlayer duration: $duration');
      });

      // Listener na pozycje
      _audioPlayer!.onPositionChanged.listen((position) {
        // Loguj co 5 sekund zeby nie zasmiecac
        if (position.inSeconds % 5 == 0 && position.inMilliseconds % 1000 < 500) {
          _log('AudioPlayer position: $position');
        }
      });

      _isInitialized = true;
      _log('AudioPlayer initialized successfully');

      // Sprawdz dostepne zrodla
      _log('Platform: ${kIsWeb ? "Web" : "Mobile"}');
    } catch (e) {
      _log('AudioPlayer init error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Rozpocznij odtwarzanie muzyki
  Future<void> play() async {
    await _ensureInitialized();
    if (_audioPlayer == null) {
      _log('AudioPlayer is null after init!');
      return;
    }

    try {
      _log('Attempting to play audio...');
      _log('Current player state: ${_audioPlayer!.state}');

      if (kIsWeb) {
        // Na web uzyj UrlSource
        await _audioPlayer!.play(UrlSource('audio/Tarnas_kids_theme.mp3'));
        _log('Web: Playing from UrlSource');
      } else {
        // Na Android/iOS
        // Plik jest w assets/audio/, audioplayers dodaje prefix "assets/"
        // wiec sciezka to "audio/nazwa.mp3"
        const assetPath = 'audio/Tarnas_kids_theme.mp3';
        _log('Mobile: Playing from AssetSource: $assetPath');

        await _audioPlayer!.play(AssetSource(assetPath));
        _log('Mobile: play() called successfully');
        _log('Player state after play: ${_audioPlayer!.state}');
      }

      state = state.copyWith(isPlaying: true, error: null);
      _log('State updated to isPlaying: true');
    } catch (e, stack) {
      _log('Audio play error: $e');
      _log('Stack: $stack');
      state = state.copyWith(isPlaying: false, error: e.toString());
    }
  }

  /// Zatrzymaj muzyke
  Future<void> pause() async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      _log('Audio pause error: $e');
    }
  }

  /// Wznow muzyke
  Future<void> resume() async {
    if (_audioPlayer == null) {
      await play();
      return;
    }
    try {
      await _audioPlayer!.resume();
      state = state.copyWith(isPlaying: true);
    } catch (e) {
      _log('Audio resume error: $e');
      // Sprobuj odtworzyc od nowa
      await play();
    }
  }

  /// Przelacz odtwarzanie (przez uzytkownika)
  Future<void> toggle() async {
    _log('Toggle called. Current isPlaying: ${state.isPlaying}, userMuted: ${state.userMuted}');
    if (state.isPlaying) {
      // Uzytkownik wylacza - zapamietaj to
      state = state.copyWith(userMuted: true);
      await pause();
    } else {
      // Uzytkownik wlacza - odblokuj
      state = state.copyWith(userMuted: false);
      await play();
    }
  }

  /// Wstrzymaj gdy aplikacja idzie w tlo
  Future<void> onAppPaused() async {
    _log('App paused - stopping music');
    if (_audioPlayer != null && state.isPlaying) {
      await _audioPlayer!.pause();
      state = state.copyWith(isPlaying: false);
    }
  }

  /// Wznow gdy aplikacja wraca na pierwszy plan (tylko jesli user nie wyciszyl)
  Future<void> onAppResumed() async {
    _log('App resumed - userMuted: ${state.userMuted}');
    if (!state.userMuted && _audioPlayer != null && _isInitialized) {
      await _audioPlayer!.resume();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Ustaw glosnosc (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.setVolume(volume);
      state = state.copyWith(volume: volume);
    } catch (e) {
      _log('Audio setVolume error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}

/// Provider dla muzyki w tle
final backgroundMusicProvider =
    StateNotifierProvider<BackgroundMusicNotifier, BackgroundMusicState>(
  (ref) => BackgroundMusicNotifier(),
);
