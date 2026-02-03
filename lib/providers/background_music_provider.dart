import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Funkcja do logowania - tylko bledy i wazne zdarzenia
// Ustaw na true tylko do debugowania
const bool _enableAudioLogs = true;

void _log(String message) {
  if (_enableAudioLogs) {
    // ignore: avoid_print
    print('[AUDIO] $message');
  }
}

// Zawsze loguj bledy
void _logError(String message) {
  // ignore: avoid_print
  print('[AUDIO ERROR] $message');
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

      // Listener na logi (tylko bledy)
      _audioPlayer!.onLog.listen((msg) {
        if (msg.contains('error') || msg.contains('Error')) {
          _logError('AudioPlayer: $msg');
        }
      });

      // Listener na zakonczenie (dla debug)
      _audioPlayer!.onPlayerComplete.listen((_) {
        _log('AudioPlayer completed - looping');
      });

      // Listenery na pozycje i czas trwania - WYLACZONE (zasmiecaly konsole)
      // _audioPlayer!.onDurationChanged.listen((duration) { ... });
      // _audioPlayer!.onPositionChanged.listen((position) { ... });

      _isInitialized = true;
      _log('AudioPlayer initialized successfully');

      // Sprawdz dostepne zrodla
      _log('Platform: ${kIsWeb ? "Web" : "Mobile"}');
    } on UnimplementedError catch (e) {
      // BULLETPROOF: Windows/Linux może nie obsługiwać audio
      _logError('AudioPlayer nie obsługiwany na tej platformie: $e');
      state = state.copyWith(error: 'Audio niedostępne na tej platformie');
    } catch (e) {
      _logError('AudioPlayer init error: $e');
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
      _logError('Audio play error: $e');
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
      _logError('Audio pause error: $e');
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
      _logError('Audio resume error: $e');
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
      _logError('Audio setVolume error: $e');
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
