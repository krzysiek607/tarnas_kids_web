import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../providers/background_music_provider.dart';

/// Ekran preloadera - laduje fonty emoji przed pokazaniem intro wideo
class PreloaderScreen extends ConsumerStatefulWidget {
  const PreloaderScreen({super.key});

  @override
  ConsumerState<PreloaderScreen> createState() => _PreloaderScreenState();
}

class _PreloaderScreenState extends ConsumerState<PreloaderScreen> {
  // Emoji do preloadowania - uzywane w calej aplikacji
  static const List<String> _emojisToPreload = [
    '👋', '🎨', '📘', '🎮', '⭐', '🌟', '✨',
    '🍎', '🍌', '🍊', '🍇', '🍓', '🌸', '🦋',
    '😴', '🚿', '👕', '🥣', '🌰', '💧', '🌱', '🌸',
    '🥚', '🐛', '🧶', '🌅', '☀️', '🌇', '🌙',
    '🫓', '🍅', '🧀', '🍕', '🐣', '🐥', '🐔',
    '👩', '👨', '🐔', '🍦', '🐱', '🐟', '👟',
    '🏠', '☕', '💧', '❄️', '🗺️', '🎬', '🚗',
    '⭕', '👜', '💡', '🥛', '🎉', '🔄', '🏠', '🧮',
    // Pet/Zwierzak emoji
    '🍖', '😊', '⚡', '🧼', '😋', '🎾', '🛏️', '😫',
    '🥺', '🙀', '🛁', '😢', '😺', '☀️',
  ];

  bool _fontsLoaded = false;

  @override
  void initState() {
    super.initState();
    _preloadFonts();
  }

  Future<void> _preloadFonts() async {
    // Daj chwile na renderowanie ukrytych emoji
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _fontsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gdy fonty zaladowane - pokaz intro wideo
    if (_fontsLoaded) {
      return _VideoIntroContent(
        onStartMusic: () {
          // Uruchom muzyke po zakonczeniu intro
          ref.read(backgroundMusicProvider.notifier).play();
        },
      );
    }

    // Ekran ladowania - BEZ emoji, tylko kolor tla i ukryte emoji do preloadu
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Ukryte emoji do preloadowania fontow - renderowane poza ekranem
          Positioned(
            left: -10000,
            top: -10000,
            child: Column(
              children: _emojisToPreload
                  .map((e) => Text(e, style: const TextStyle(fontSize: 20)))
                  .toList(),
            ),
          ),
          // Prosty indicator ladowania bez emoji
          Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ekran intro z wideo - 8 sekund odtwarzania + 2 sekundy pauzy na koncu
class _VideoIntroContent extends StatefulWidget {
  final VoidCallback onStartMusic;

  const _VideoIntroContent({required this.onStartMusic});

  @override
  State<_VideoIntroContent> createState() => _VideoIntroContentState();
}

class _VideoIntroContentState extends State<_VideoIntroContent> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _videoEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/videos/Taro_Lumi_intro.mp4',
    );

    try {
      await _controller.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);

        // Listener na zakonczenie wideo
        _controller.addListener(_onVideoUpdate);

        // Rozpocznij odtwarzanie
        await _controller.play();
      }
    } catch (e) {
      // Jesli wideo nie zaladuje sie - przejdz do ekranu glownego po 2s
      debugPrint('Blad ladowania wideo: $e');
      await Future.delayed(const Duration(seconds: 2));
      _navigateToHome();
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // Sprawdz czy wideo sie zakonczylo
    if (position >= duration && duration.inMilliseconds > 0 && !_videoEnded) {
      _videoEnded = true;
      _onVideoComplete();
    }
  }

  Future<void> _onVideoComplete() async {
    // Zatrzymaj na ostatniej klatce przez 2 sekundy
    await _controller.pause();
    await Future.delayed(const Duration(seconds: 2));

    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      // Uruchom muzyke przed przejsciem
      widget.onStartMusic();
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
      ),
    );
  }
}
