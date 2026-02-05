import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/background_music_provider.dart';
import '../providers/pet_provider.dart';
import '../services/sound_effects_controller.dart';
import '../services/sound_effects_service.dart';

/// Ekran ustawień - przyjazny dla dzieci, bezpieczny dla rodziców
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _sfxEnabled = true;
  bool _parentUnlocked = false;
  String _appVersion = '';

  // Animacja parental gate (4 sekundy)
  late AnimationController _gateController;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _gateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _parentUnlocked = true);
        SoundEffectsService.instance.playSuccess();
      }
    });
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = 'v${info.version}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _appVersion = 'v1.0.0');
      }
    }
  }

  @override
  void dispose() {
    _gateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(backgroundMusicProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚙️ ', style: TextStyle(fontSize: 24)),
            const Text('Ustawienia'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            SoundEffectsService.instance.playClick();
            context.pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // === SEKCJA DZIECIĘCA ===
          _buildChildSection(musicState),

          const SizedBox(height: 24),

          // === SEKCJA RODZICIELSKA ===
          _buildParentSection(),

          const SizedBox(height: 32),

          // Wersja aplikacji
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tarnas Kids $_appVersion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChildSection(BackgroundMusicState musicState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.yellowColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎵', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'Dźwięki',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Muzyka
          _buildSettingTile(
            emoji: '🎶',
            title: 'Muzyka',
            subtitle: 'Melodia w tle',
            trailing: SizedBox(
              width: 140,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
                  thumbColor: AppTheme.primaryColor,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.1),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: musicState.userMuted ? 0 : musicState.volume,
                  onChanged: (value) {
                    if (value == 0) {
                      ref.read(backgroundMusicProvider.notifier).pause();
                    } else {
                      if (musicState.userMuted || !musicState.isPlaying) {
                        ref.read(backgroundMusicProvider.notifier).play();
                      }
                      ref.read(backgroundMusicProvider.notifier).setVolume(value);
                    }
                  },
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Efekty dźwiękowe
          _buildSettingTile(
            emoji: '🔔',
            title: 'Dźwięki',
            subtitle: 'Efekty w grach',
            trailing: Transform.scale(
              scale: 1.1,
              child: Switch(
                value: _sfxEnabled,
                activeColor: AppTheme.greenColor,
                activeTrackColor: AppTheme.greenColor.withOpacity(0.3),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (value) {
                  setState(() => _sfxEnabled = value);
                  SoundEffectsController().setMuted(!value);
                  SoundEffectsService.instance.setMuted(!value);
                  if (value) {
                    SoundEffectsService.instance.playSuccess();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLightColor,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildParentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.purpleColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.purpleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _parentUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: AppTheme.purpleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strefa rodzica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      _parentUnlocked ? 'Odblokowano' : 'Chronione hasłem',
                      style: TextStyle(
                        fontSize: 13,
                        color: _parentUnlocked
                            ? AppTheme.greenColor
                            : AppTheme.textLightColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (_parentUnlocked)
                TextButton(
                  onPressed: () => setState(() => _parentUnlocked = false),
                  child: Text(
                    'Zablokuj',
                    style: TextStyle(color: AppTheme.purpleColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_parentUnlocked)
            _buildParentalGate()
          else
            _buildParentOptions(),
        ],
      ),
    );
  }

  Widget _buildParentalGate() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHolding = true);
        _gateController.forward(from: 0);
      },
      onTapUp: (_) {
        setState(() => _isHolding = false);
        _gateController.reset();
      },
      onTapCancel: () {
        setState(() => _isHolding = false);
        _gateController.reset();
      },
      child: AnimatedBuilder(
        animation: _gateController,
        builder: (context, child) {
          final progress = _gateController.value;
          final remaining = (4 - (progress * 4)).ceil();

          return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHolding
                    ? AppTheme.purpleColor
                    : AppTheme.purpleColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Progress bar
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.purpleColor.withOpacity(0.3),
                            AppTheme.purpleColor.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Text
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isHolding
                              ? Icons.hourglass_top_rounded
                              : Icons.touch_app_rounded,
                          color: AppTheme.purpleColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isHolding
                              ? 'Trzymaj... ${remaining}s'
                              : 'Przytrzymaj 4 sekundy',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.purpleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParentOptions() {
    return Column(
      children: [
        _buildParentOption(
          emoji: '🥚',
          title: 'Reset zwierzaka',
          subtitle: 'Zacznij przygodę od nowa',
          onTap: _confirmResetPet,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        _buildParentOption(
          emoji: '📊',
          title: 'Statystyki',
          subtitle: 'Zobacz postępy dziecka',
          onTap: () => context.push('/parent-panel'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        _buildParentOption(
          emoji: '💌',
          title: 'Poleć znajomemu',
          subtitle: 'Udostępnij aplikację',
          onTap: _shareApp,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        _buildParentOption(
          emoji: '📋',
          title: 'Regulamin',
          subtitle: 'Warunki korzystania z aplikacji',
          onTap: () => context.push('/terms'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        _buildParentOption(
          emoji: '🔒',
          title: 'Polityka prywatnosci',
          subtitle: 'Jak chronimy dane dziecka',
          onTap: () => context.push('/privacy-policy'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        _buildParentOption(
          emoji: '🗑️',
          title: 'Usuń wszystkie dane',
          subtitle: 'Wyczyść całą aplikację',
          onTap: _confirmDeleteData,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildParentOption({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        SoundEffectsService.instance.playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.shade50
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red.shade600 : AppTheme.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? Colors.red.shade300 : AppTheme.textLightColor,
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'Moje dziecko uwielbia Tarnas Kids! '
      'Edukacyjna aplikacja z grami, rysowaniem i wirtualnym zwierzakiem. '
      'Sprawdź sam!',
    );
  }

  void _confirmResetPet() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🥚 ', style: TextStyle(fontSize: 28)),
            Text('Nowa przygoda?'),
          ],
        ),
        content: const Text(
          'Czy na pewno chcesz zacząć od nowa?\n\n'
          'Twój zwierzak wróci do jajka, ale zebrane smakołyki pozostaną! 🍪',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Nie, zostaję',
              style: TextStyle(color: AppTheme.textLightColor, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(petProvider.notifier).reset();
              Navigator.pop(ctx);
              SoundEffectsService.instance.playSuccess();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Text('🥚 ', style: TextStyle(fontSize: 20)),
                      Text('Nowe jajko czeka na opiekę!'),
                    ],
                  ),
                  backgroundColor: AppTheme.greenColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tak, resetuj! 🚀', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 10),
            const Text('Na pewno?'),
          ],
        ),
        content: const Text(
          'Czy na pewno chcesz usunąć WSZYSTKIE dane?\n\n'
          '• 🥚 Zwierzak\n'
          '• 🍪 Smakołyki\n'
          '• 🎮 Postępy w grach\n\n'
          'Tej operacji nie można cofnąć!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Anuluj',
              style: TextStyle(color: AppTheme.textLightColor, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(petProvider.notifier).reset();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Text('🗑️ ', style: TextStyle(fontSize: 20)),
                      Text('Wszystko usunięte'),
                    ],
                  ),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Usuń wszystko', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
