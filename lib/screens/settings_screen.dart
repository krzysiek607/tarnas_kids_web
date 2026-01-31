import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/background_music_provider.dart';
import '../providers/pet_provider.dart';
import '../services/sound_effects_controller.dart';

/// Ekran ustawień - minimalistyczny, bezpieczny dla dzieci
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sfxEnabled = true;

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(backgroundMusicProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ustawienia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SEKCJA DZIECIĘCA ===
              _buildChildSection(musicState),

              const SizedBox(height: 40),

              // === SEKCJA RODZICIELSKA ===
              _buildParentSection(),

              const Spacer(),

              // Wersja aplikacji
              Center(
                child: Text(
                  'Tarnas Kids v1.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLightColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Muzyka
          _SettingRow(
            icon: Icons.music_note_rounded,
            iconColor: AppTheme.primaryColor,
            label: 'Muzyka',
            child: _buildMusicSlider(musicState),
          ),

          const SizedBox(height: 20),

          // Dźwięki
          _SettingRow(
            icon: Icons.volume_up_rounded,
            iconColor: AppTheme.accentColor,
            label: 'Dźwięki',
            child: _buildSfxToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSlider(BackgroundMusicState musicState) {
    return Row(
      children: [
        Icon(
          Icons.volume_mute_rounded,
          size: 20,
          color: AppTheme.textLightColor,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
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
        Icon(
          Icons.volume_up_rounded,
          size: 20,
          color: AppTheme.textLightColor,
        ),
      ],
    );
  }

  Widget _buildSfxToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _sfxEnabled = !_sfxEnabled;
        });
        SoundEffectsController().setMuted(!_sfxEnabled);
        // Zagraj dźwięk testowy jeśli włączone
        if (_sfxEnabled) {
          SoundEffectsController().playSuccess();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _sfxEnabled ? AppTheme.greenColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(22),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _sfxEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _sfxEnabled ? '🔔' : '🔕',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.purpleColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_rounded,
                color: AppTheme.purpleColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Dla rodziców',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ParentalGateButton(
            onUnlocked: () => _openParentSettings(),
          ),
        ],
      ),
    );
  }

  void _openParentSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ParentSettingsSheet(
        onResetPet: _confirmResetPet,
        onDeleteData: _confirmDeleteData,
      ),
    );
  }

  void _confirmResetPet() {
    Navigator.pop(context); // Zamknij bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🥚 '),
            Text('Reset zwierzaka'),
          ],
        ),
        content: const Text(
          'Czy na pewno chcesz zacząć od nowa?\n\nZwierzak wróci do jajka, ale zebrane smakołyki pozostaną.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anuluj',
              style: TextStyle(color: AppTheme.textLightColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(petProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Text('🥚', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
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
            ),
            child: const Text('Resetuj'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData() {
    Navigator.pop(context); // Zamknij bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Usuń wszystko'),
          ],
        ),
        content: const Text(
          'Czy na pewno chcesz usunąć WSZYSTKIE dane?\n\n'
          '• Zwierzak\n'
          '• Smakołyki\n'
          '• Postęp w grach\n\n'
          'Tej operacji nie można cofnąć!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anuluj',
              style: TextStyle(color: AppTheme.textLightColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Reset pet
              ref.read(petProvider.notifier).reset();
              // TODO: Clear inventory from Supabase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Text('🗑️', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('Dane zostały usunięte'),
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
            ),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }
}

/// Wiersz ustawienia
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const Spacer(),
        child,
      ],
    );
  }
}

/// Przycisk Parental Gate - wymaga przytrzymania 4 sekundy
class _ParentalGateButton extends StatefulWidget {
  final VoidCallback onUnlocked;

  const _ParentalGateButton({required this.onUnlocked});

  @override
  State<_ParentalGateButton> createState() => _ParentalGateButtonState();
}

class _ParentalGateButtonState extends State<_ParentalGateButton>
    with SingleTickerProviderStateMixin {
  static const int _holdDurationSeconds = 4;

  late AnimationController _progressController;
  bool _isHolding = false;
  Timer? _unlockTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _holdDurationSeconds),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onUnlocked();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _unlockTimer?.cancel();
    super.dispose();
  }

  void _onPressStart() {
    setState(() => _isHolding = true);
    _progressController.forward(from: 0);
  }

  void _onPressEnd() {
    setState(() => _isHolding = false);
    _progressController.reset();
  }

  void _onUnlocked() {
    setState(() => _isHolding = false);
    _progressController.reset();
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: _onPressEnd,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.purpleColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Tło z progress
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController.value,
                      child: Container(
                        color: AppTheme.purpleColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Tekst
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isHolding ? Icons.lock_open_rounded : Icons.touch_app_rounded,
                          color: AppTheme.purpleColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isHolding
                              ? 'Trzymaj... ${(_holdDurationSeconds - (_progressController.value * _holdDurationSeconds)).ceil()}s'
                              : 'Przytrzymaj ${_holdDurationSeconds}s aby wejść',
                          style: TextStyle(
                            fontSize: 16,
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
}

/// Bottom sheet z opcjami dla rodziców
class _ParentSettingsSheet extends StatelessWidget {
  final VoidCallback onResetPet;
  final VoidCallback onDeleteData;

  const _ParentSettingsSheet({
    required this.onResetPet,
    required this.onDeleteData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded,
                    color: AppTheme.purpleColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Panel rodzica',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Opcje
          _ParentOptionTile(
            icon: Icons.egg_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Reset zwierzaka',
            subtitle: 'Zacznij od nowego jajka',
            onTap: onResetPet,
          ),

          const Divider(height: 1, indent: 72),

          _ParentOptionTile(
            icon: Icons.bar_chart_rounded,
            iconColor: AppTheme.accentColor,
            title: 'Statystyki',
            subtitle: 'Zobacz postępy dziecka',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Statystyki - wkrótce!'),
                  backgroundColor: AppTheme.accentColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1, indent: 72),

          _ParentOptionTile(
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.red.shade400,
            title: 'Usuń wszystkie dane',
            subtitle: 'Wyczyść całą aplikację',
            onTap: onDeleteData,
            isDestructive: true,
          ),

          const SizedBox(height: 16),

          // Przycisk zamknięcia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Zamknij',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textLightColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Kafelek opcji w panelu rodzica
class _ParentOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ParentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red.shade400 : AppTheme.textColor,
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLightColor,
            ),
          ],
        ),
      ),
    );
  }
}
