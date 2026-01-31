import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/background_music_provider.dart';
import '../providers/pet_provider.dart';
import '../services/sound_effects_service.dart';

/// Ekran glowny aplikacji Tarnas Kids
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _musicInitialized = false;

  @override
  void initState() {
    super.initState();
    // Sprobuj uruchomic muzyke automatycznie po wejsciu na ekran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoPlayMusic();
    });
  }

  /// Probuje automatycznie uruchomic muzyke
  void _tryAutoPlayMusic() {
    if (_musicInitialized) return;
    _musicInitialized = true;

    final musicState = ref.read(backgroundMusicProvider);
    // Jesli muzyka nie gra i uzytkownik jej nie wyciszyl - uruchom
    if (!musicState.isPlaying && !musicState.userMuted) {
      ref.read(backgroundMusicProvider.notifier).play();
    }
  }

  /// Zwraca ścieżkę do ikony zwierzaka na podstawie fazy ewolucji
  /// Przycisk "Zwierzak" na menu pokazuje aktualny stan jajka/zwierzaka
  String _getPetIconPath(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.egg:
        // Faza 1: Jajko
        return 'assets/images/Creature/Egg.webp';
      case EvolutionStage.firstCrack:
      case EvolutionStage.secondCrack:
      case EvolutionStage.hatched:
        // Faza 2+: Pęknięte jajko (lub wykluty zwierzak)
        return 'assets/images/Creature/first_crack_idle.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(backgroundMusicProvider);
    final petState = ref.watch(petProvider);

    // Dynamiczna ikona dla przycisku "Zwierzak" na podstawie fazy ewolucji
    final petIconPath = _getPetIconPath(petState.evolutionStage);

    return Scaffold(
      body: Stack(
        children: [
          // Warstwa 1: Tlo - pelny ekran
          SizedBox.expand(
            child: Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Warstwa 2: Przyciski górne (ustawienia + muzyka)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Row(
              children: [
                _buildSettingsButton(),
                const SizedBox(width: 8),
                _buildMusicButton(musicState),
              ],
            ),
          ),

          // Warstwa 3: Menu przyciskow w ksztalcie luku
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 190,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Przycisk 1 (skrajny lewy) - nizej
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: _ArchMenuButton(
                    iconPath: 'assets/images/icons/main_przygoda.png',
                    tooltip: 'Przygoda',
                    color: AppTheme.accentColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wkrotce wiecej!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                // Przycisk 2 (srodkowy lewy) - wyzej
                // DYNAMICZNA IKONA: Pokazuje aktualną fazę ewolucji zwierzaka
                _ArchMenuButton(
                  iconPath: petIconPath,
                  tooltip: 'Zwierzak',
                  color: AppTheme.primaryColor,
                  onTap: () => context.push('/pet'),
                ),
                // Przycisk 3 (srodkowy prawy) - wyzej
                _ArchMenuButton(
                  iconPath: 'assets/images/icons/main_nauka.png',
                  tooltip: 'Nauka',
                  color: AppTheme.yellowColor,
                  onTap: () => context.push('/learning'),
                ),
                // Przycisk 4 (skrajny prawy) - nizej
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: _ArchMenuButton(
                    iconPath: 'assets/images/icons/main_zabawa.png',
                    tooltip: 'Zabawa',
                    color: AppTheme.purpleColor,
                    onTap: () => context.push('/fun'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Przycisk ustawień
  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {
        SoundEffectsService.instance.playClick();
        context.push('/settings');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.settings_rounded,
          color: AppTheme.textLightColor,
          size: 24,
        ),
      ),
    );
  }

  /// Przycisk wyciszania muzyki
  Widget _buildMusicButton(BackgroundMusicState musicState) {
    return GestureDetector(
      onTap: () {
        SoundEffectsService.instance.playClick();
        ref.read(backgroundMusicProvider.notifier).toggle();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          musicState.userMuted
              ? Icons.volume_off_rounded
              : Icons.volume_up_rounded,
          color: musicState.userMuted
              ? AppTheme.textLightColor
              : AppTheme.primaryColor,
          size: 24,
        ),
      ),
    );
  }
}

/// Przycisk menu w ksztalcie luku - ikona z obrazka z Tooltip na tap
class _ArchMenuButton extends StatefulWidget {
  final String iconPath;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ArchMenuButton({
    required this.iconPath,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ArchMenuButton> createState() => _ArchMenuButtonState();
}

class _ArchMenuButtonState extends State<_ArchMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final GlobalKey _tooltipKey = GlobalKey();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isNavigating) return;
    _isNavigating = true;

    // Dźwięk kliknięcia
    SoundEffectsService.instance.playClick();

    // Pokaz tooltip
    final dynamic tooltip = _tooltipKey.currentState;
    tooltip?.ensureTooltipVisible();

    // Po 500ms wykonaj nawigację
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _isNavigating = false;
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tooltipKey,
      message: widget.tooltip,
      preferBelow: true,
      triggerMode: TooltipTriggerMode.manual,
      showDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          _handleTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.iconPath,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jesli obrazek nie istnieje
                    return Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
