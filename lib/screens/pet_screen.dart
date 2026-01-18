import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/pet_provider.dart';

/// Ekran gry Zwierzak (Tamagotchi)
class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Moj Zwierzak'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _showResetDialog(context, ref),
            tooltip: 'Resetuj',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Paski statystyk
              _StatsPanel(petState: petState),

              const SizedBox(height: 20),

              // Kontener na animacje zwierzaka
              Expanded(
                child: _PetDisplay(
                  mood: petState.currentMood,
                  isSleeping: petState.isSleeping,
                ),
              ),

              const SizedBox(height: 20),

              // Przyciski akcji
              _ActionButtons(
                petState: petState,
                onFeed: () => ref.read(petProvider.notifier).feed(),
                onPlay: () => ref.read(petProvider.notifier).play(),
                onSleep: petState.isSleeping
                    ? () => ref.read(petProvider.notifier).wakeUp()
                    : () => ref.read(petProvider.notifier).sleep(),
                onWash: () => ref.read(petProvider.notifier).wash(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Text('Nowa gra?'),
          ],
        ),
        content: const Text('Czy chcesz zaczac od nowa? Twoj zwierzak wrocido poczatkowego stanu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nie'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(petProvider.notifier).reset();
              Navigator.pop(ctx);
            },
            child: const Text('Tak'),
          ),
        ],
      ),
    );
  }
}

/// Panel ze statystykami
class _StatsPanel extends StatelessWidget {
  final PetState petState;

  const _StatsPanel({required this.petState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _StatBar(
            label: 'Glod',
            value: petState.hunger,
            icon: '🍖',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Szczescie',
            value: petState.happiness,
            icon: '😊',
            color: Colors.pink,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Energia',
            value: petState.energy,
            icon: '⚡',
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _StatBar(
            label: 'Higiena',
            value: petState.hygiene,
            icon: '🧼',
            color: Colors.cyan,
          ),
        ],
      ),
    );
  }
}

/// Pojedynczy pasek statystyki
class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final String icon;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Tlo paska
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Wypelnienie paska
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 16,
                width: (MediaQuery.of(context).size.width - 200) * (value / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${value.toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getValueColor(value),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getValueColor(double value) {
    if (value < 30) return Colors.red;
    if (value < 50) return Colors.orange;
    return AppTheme.greenColor;
  }
}

/// Wyswietlanie zwierzaka
class _PetDisplay extends StatelessWidget {
  final String mood;
  final bool isSleeping;

  const _PetDisplay({
    required this.mood,
    required this.isSleeping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getBackgroundColor().withOpacity(0.3),
            _getBackgroundColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _getBackgroundColor().withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder na animacje - tutaj mozna pozniej dodac video/Lottie
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildPetImage(),
          ),
          const SizedBox(height: 16),
          // Etykieta nastroju
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getMoodText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetImage() {
    // Placeholder - duze emoji reprezentujace nastroj
    // W przyszlosci zamien na Image.asset lub video
    return Text(
      _getMoodEmoji(),
      key: ValueKey(mood),
      style: const TextStyle(fontSize: 120),
    );
  }

  String _getMoodEmoji() {
    switch (mood) {
      case 'happy':
        return '🐱';
      case 'eating':
        return '😋';
      case 'playing':
        return '🎉';
      case 'sleeping':
        return '😴';
      case 'tired':
        return '😫';
      case 'hungry':
        return '🥺';
      case 'dirty':
        return '🙀';
      case 'bathing':
        return '🛁';
      case 'sad':
        return '😢';
      case 'neutral':
        return '😺';
      default:
        return '🐱';
    }
  }

  String _getMoodText() {
    switch (mood) {
      case 'happy':
        return 'Szczesliwy!';
      case 'eating':
        return 'Mniam mniam!';
      case 'playing':
        return 'Zabawa!';
      case 'sleeping':
        return 'Zzz...';
      case 'tired':
        return 'Zmeczony...';
      case 'hungry':
        return 'Glodny!';
      case 'dirty':
        return 'Potrzebuje kapieli!';
      case 'bathing':
        return 'Plusk plusk!';
      case 'sad':
        return 'Smutny...';
      case 'neutral':
        return 'W porzadku';
      default:
        return 'Hej!';
    }
  }

  Color _getBackgroundColor() {
    switch (mood) {
      case 'happy':
      case 'playing':
        return AppTheme.greenColor;
      case 'eating':
        return AppTheme.yellowColor;
      case 'sleeping':
        return AppTheme.purpleColor;
      case 'bathing':
        return AppTheme.accentColor;
      case 'sad':
      case 'hungry':
      case 'tired':
      case 'dirty':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// Przyciski akcji
class _ActionButtons extends StatelessWidget {
  final PetState petState;
  final VoidCallback onFeed;
  final VoidCallback onPlay;
  final VoidCallback onSleep;
  final VoidCallback onWash;

  const _ActionButtons({
    required this.petState,
    required this.onFeed,
    required this.onPlay,
    required this.onSleep,
    required this.onWash,
  });

  @override
  Widget build(BuildContext context) {
    final isSleeping = petState.isSleeping;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: '🍖',
          label: 'Nakarm',
          color: Colors.orange,
          onTap: isSleeping ? null : onFeed,
          disabled: isSleeping,
        ),
        _ActionButton(
          icon: '🎾',
          label: 'Baw sie',
          color: Colors.pink,
          onTap: (isSleeping || petState.energy < 15) ? null : onPlay,
          disabled: isSleeping || petState.energy < 15,
        ),
        _ActionButton(
          icon: isSleeping ? '☀️' : '🛏️',
          label: isSleeping ? 'Obudz' : 'Spij',
          color: AppTheme.purpleColor,
          onTap: onSleep,
          disabled: false,
        ),
        _ActionButton(
          icon: '🧼',
          label: 'Umyj',
          color: AppTheme.accentColor,
          onTap: isSleeping ? null : onWash,
          disabled: isSleeping,
        ),
      ],
    );
  }
}

/// Pojedynczy przycisk akcji
class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          width: 75,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade300 : color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.grey : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
